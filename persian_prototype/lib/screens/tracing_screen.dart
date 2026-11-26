import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/letters.dart';
import '../data/voice_script.dart';
import '../services/audio_service.dart';
import '../theme.dart';
import '../tracing/tracing_engine.dart';
import '../widgets/common.dart';

/// Activity 2 — "Let's write" (inspired by Kitkit's LetterTrace).
/// The child traces the letter with a finger: right to left, body first,
/// then the dots. A glowing bead shows where to go next.
class TracingScreen extends StatefulWidget {
  const TracingScreen({super.key});

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  /// How close (in the 0–1 box) the finger must be to the guide.
  static const double tolerance = 0.085;

  int _letterIndex = 0;
  late TracingEngine _engine;
  bool _celebrating = false;
  final Set<String> _completed = {};

  PersianLetter get _letter => prototypeLetters[_letterIndex];

  @override
  void initState() {
    super.initState();
    _engine = TracingEngine(_letter.strokes);
    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      await AudioService.instance.say(VoiceScript.tracingInstruction);
    });
  }

  void _selectLetter(int index) {
    setState(() {
      _letterIndex = index;
      _engine = TracingEngine(_letter.strokes);
      _celebrating = false;
    });
    AudioService.instance.say(VoiceScript.letter(_letter));
  }

  Offset _toBox(Offset local, double side) => Offset(local.dx / side, local.dy / side);

  void _handle(bool advanced, bool wasDot) {
    if (!advanced) return;
    setState(() {});
    if (_engine.isComplete) {
      _onLetterComplete();
    } else if (_engine.currentIsDot && !wasDot && _engine.pointIndex == 0) {
      // Body finished; next comes a dot.
      AudioService.instance.say(VoiceScript.tracingDot);
    } else if (wasDot) {
      AudioService.instance.tap();
    }
  }

  Future<void> _onLetterComplete() async {
    setState(() {
      _celebrating = true;
      _completed.add(_letter.id);
    });
    unawaited(celebrate());
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _celebrating = false);
  }

  @override
  void dispose() {
    AudioService.instance.stopVoice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _engine.isComplete;
    return Scaffold(
      appBar: AppBar(
        title: const Text('بنویسیم'),
        actions: [
          IconButton(
            tooltip: 'از اول',
            iconSize: 34,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(_engine.reset),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final landscape = constraints.maxWidth > constraints.maxHeight;
            final canvasSide = landscape
                ? min(constraints.maxHeight - 120, constraints.maxWidth * 0.55)
                : min(constraints.maxWidth - 32, constraints.maxHeight - 290);
            final canvas = _TracingCanvas(
              side: max(canvasSide, 220),
              letter: _letter,
              engine: _engine,
              onDown: (p, side) {
                final wasDot = _engine.currentIsDot;
                _handle(_engine.fingerDown(_toBox(p, side), tolerance), wasDot);
              },
              onMove: (p, side) {
                final wasDot = _engine.currentIsDot;
                _handle(_engine.fingerMove(_toBox(p, side), tolerance), wasDot);
              },
              onUp: _engine.fingerUp,
            );
            final info = _LetterInfo(
              letter: _letter,
              done: done,
              onListen: () => AudioService.instance.say(VoiceScript.letter(_letter)),
              onNext: () => _selectLetter((_letterIndex + 1) % prototypeLetters.length),
            );
            return Column(
              children: [
                _LetterPicker(
                  selected: _letterIndex,
                  completed: _completed,
                  onSelect: _selectLetter,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: landscape
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [canvas, const SizedBox(width: 24), Flexible(child: info)],
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [canvas, const SizedBox(height: 12), info],
                                ),
                              ),
                      ),
                      CelebrationOverlay(visible: _celebrating),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The row of letters at the top. In right-to-left layout it starts on the
/// right, just like a line of Persian text.
class _LetterPicker extends StatelessWidget {
  const _LetterPicker({required this.selected, required this.completed, required this.onSelect});

  final int selected;
  final Set<String> completed;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: prototypeLetters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final letter = prototypeLetters[i];
          final isSelected = i == selected;
          return Material(
            color: isSelected ? AppColors.teal : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            elevation: isSelected ? 3 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelect(i),
              child: SizedBox(
                width: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      letter.char,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.ink,
                      ),
                    ),
                    if (completed.contains(letter.id))
                      const PositionedDirectional(
                        top: 2,
                        end: 4,
                        child: Icon(Icons.star_rounded, size: 18, color: AppColors.sun),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Letter name, example word and the letter's shapes inside words.
class _LetterInfo extends StatelessWidget {
  const _LetterInfo({
    required this.letter,
    required this.done,
    required this.onListen,
    required this.onNext,
  });

  final PersianLetter letter;
  final bool done;
  final VoidCallback onListen;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final forms = letter.positionalForms;
    final labels = letter.positionalFormLabels;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpeakerButton(onPressed: onListen, size: 56),
              const SizedBox(width: 12),
              Text(
                '${letter.char} مثلِ ${letter.exampleWord}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // How the letter looks at the start, middle and end of a word.
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < forms.length; i++)
                Container(
                  width: 74,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.guide, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(forms[i], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                      Text(labels[i], style: const TextStyle(fontSize: 13, color: Color(0xFF6B7F86))),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: done
                ? BigButton(
                    key: const ValueKey('next'),
                    icon: Icons.arrow_forward_rounded, // mirrored automatically in RTL
                    label: 'حرف بعدی',
                    color: AppColors.teal,
                    onPressed: onNext,
                  )
                : const SizedBox(key: ValueKey('empty'), height: 0),
          ),
        ],
      ),
    );
  }
}

class _TracingCanvas extends StatelessWidget {
  const _TracingCanvas({
    required this.side,
    required this.letter,
    required this.engine,
    required this.onDown,
    required this.onMove,
    required this.onUp,
  });

  final double side;
  final PersianLetter letter;
  final TracingEngine engine;
  final void Function(Offset local, double side) onDown;
  final void Function(Offset local, double side) onMove;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'صفحه‌ی نوشتن حرف ${letter.name}',
      child: Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [BoxShadow(blurRadius: 10, color: Color(0x22000000), offset: Offset(0, 4))],
        ),
        child: Listener(
          onPointerDown: (e) => onDown(e.localPosition, side),
          onPointerMove: (e) => onMove(e.localPosition, side),
          onPointerUp: (_) => onUp(),
          onPointerCancel: (_) => onUp(),
          child: CustomPaint(
            size: Size.square(side),
            painter: _TracingPainter(engine: engine, progress: engine.progress),
          ),
        ),
      ),
    );
  }
}

class _TracingPainter extends CustomPainter {
  _TracingPainter({required this.engine, required this.progress});

  final TracingEngine engine;
  final double progress; // used to decide when to repaint

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset px(Offset p) => Offset(p.dx * s, p.dy * s);
    final width = s * 0.085;

    // Writing line (the baseline children write on).
    final baseline = Paint()
      ..color = const Color(0xFFBFD7EA)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(s * 0.06, s * 0.68), Offset(s * 0.94, s * 0.68), baseline);

    final guide = Paint()
      ..color = AppColors.guide
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final ink = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Path pathOf(List<Offset> pts, int count) {
      final path = Path()..moveTo(px(pts.first).dx, px(pts.first).dy);
      for (var i = 1; i < count; i++) {
        path.lineTo(px(pts[i]).dx, px(pts[i]).dy);
      }
      return path;
    }

    for (var i = 0; i < engine.paths.length; i++) {
      final pts = engine.paths[i];
      final isDone = i < engine.strokeIndex;
      final isCurrent = i == engine.strokeIndex;
      if (pts.length == 1) {
        canvas.drawCircle(px(pts.first), width * 0.75,
            Paint()..color = isDone ? AppColors.teal : AppColors.guide);
        continue;
      }
      canvas.drawPath(pathOf(pts, pts.length), guide);
      if (isDone) {
        canvas.drawPath(pathOf(pts, pts.length), ink);
      } else if (isCurrent && engine.pointIndex > 1) {
        canvas.drawPath(pathOf(pts, engine.pointIndex), ink);
      }
    }

    if (engine.isComplete) return;

    final current = engine.paths[engine.strokeIndex];

    // Dashed centre line and arrow for the current stroke, so the direction
    // of writing (right to left) is visible.
    if (current.length > 1) {
      final dash = Paint()
        ..color = const Color(0xFF9AA9AE)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (var i = max(engine.pointIndex, 1); i < current.length; i += 2) {
        canvas.drawLine(px(current[i - 1]), px(current[i]), dash);
      }
      if (engine.pointIndex == 0) {
        final a = current[0];
        final b = current[min(3, current.length - 1)];
        _drawArrow(canvas, px(a), px(b), width);
      }
    }

    // Start circle (green) for a new stroke, then the moving "bead".
    final target = px(engine.nextTarget!);
    if (engine.pointIndex == 0) {
      canvas.drawCircle(target, width * 0.75, Paint()..color = AppColors.leaf);
      canvas.drawCircle(
          target,
          width * 0.75,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4);
    } else {
      canvas.drawCircle(target, width * 0.45, Paint()..color = AppColors.saffron);
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, double width) {
    final dir = to - from;
    if (dir.distance == 0) return;
    final unit = dir / dir.distance;
    final tip = from + unit * (width * 2.2);
    final normal = Offset(-unit.dy, unit.dx);
    final base = tip - unit * width * 0.8;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((base + normal * width * 0.5).dx, (base + normal * width * 0.5).dy)
      ..lineTo((base - normal * width * 0.5).dx, (base - normal * width * 0.5).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.leaf);
  }

  @override
  bool shouldRepaint(covariant _TracingPainter old) => true;
}
