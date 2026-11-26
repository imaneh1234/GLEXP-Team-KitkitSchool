import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/voice_script.dart';
import '../services/audio_service.dart';
import '../theme.dart';
import '../utils/persian_numbers.dart';
import '../widgets/common.dart';

/// Activity 3 — "Let's count" (inspired by Kitkit's Counting / FeedingTime).
///
/// The child taps every pomegranate (a symbol of Yalda night). Each tap
/// says the next number and shows it in Persian digits. When all are
/// counted, the child picks the matching digit. Counting one-by-one before
/// answering builds one-to-one correspondence, which 4-year-olds need.
class CountingScreen extends StatefulWidget {
  const CountingScreen({super.key, this.random, this.rounds = 5, this.maxNumber = 10});

  final Random? random;
  final int rounds;
  final int maxNumber;

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  late final Random _random = widget.random ?? Random();
  late List<int> _questions;
  int _round = 0;
  int _stars = 0;

  /// For each pomegranate: 0 = not counted yet, otherwise its count number.
  late List<int> _countedAs;
  int _counted = 0;
  late List<int> _choices;
  final Set<int> _wrongChoices = {};
  bool _celebrating = false;
  bool _finished = false;

  int get _target => _questions[_round];
  bool get _allCounted => _counted == _target;

  @override
  void initState() {
    super.initState();
    _start();
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) AudioService.instance.say(VoiceScript.countingInstruction);
    });
  }

  void _start() {
    // Start small and grow, so early success builds confidence.
    final pool = List<int>.generate(widget.maxNumber, (i) => i + 1)..shuffle(_random);
    _questions = pool.take(widget.rounds).toList()..sort();
    _round = 0;
    _stars = 0;
    _finished = false;
    _setUpRound();
  }

  void _setUpRound() {
    _countedAs = List<int>.filled(_target, 0);
    _counted = 0;
    _wrongChoices.clear();
    final options = <int>{_target};
    while (options.length < 3) {
      final delta = _random.nextInt(3) + 1;
      final candidate = _random.nextBool() ? _target + delta : _target - delta;
      if (candidate >= 1 && candidate <= widget.maxNumber) options.add(candidate);
    }
    _choices = options.toList()..shuffle(_random);
  }

  void _tapFruit(int index) {
    if (_countedAs[index] != 0 || _celebrating) return;
    setState(() {
      _counted++;
      _countedAs[index] = _counted;
    });
    AudioService.instance.say(VoiceScript.number(_counted));
    if (_allCounted) {
      Future<void>.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) AudioService.instance.say(VoiceScript.countingQuestion);
      });
    }
  }

  Future<void> _choose(int value) async {
    if (_celebrating) return;
    if (value != _target) {
      setState(() => _wrongChoices.add(value));
      AudioService.instance.tryAgain();
      return;
    }
    setState(() {
      _celebrating = true;
      if (_wrongChoices.isEmpty) _stars++;
    });
    unawaited(celebrate());
    await Future<void>.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    setState(() {
      _celebrating = false;
      if (_round + 1 >= _questions.length) {
        _finished = true;
        AudioService.instance.say(VoiceScript.allDone);
      } else {
        _round++;
        _setUpRound();
      }
    });
  }

  @override
  void dispose() {
    AudioService.instance.stopVoice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: StarProgress(earned: _stars, total: _questions.length)),
      body: SafeArea(
        child: _finished
            ? FinishedView(stars: _stars, onPlayAgain: () => setState(_start))
            : Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // The running count, in Persian digits.
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Text(
                              _counted == 0 ? ' ' : toPersianDigits(_counted),
                              key: ValueKey(_counted),
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: AppColors.pomegranate,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              alignment: WrapAlignment.center,
                              children: [
                                for (var i = 0; i < _target; i++)
                                  _Pomegranate(
                                    key: ValueKey('fruit_${_round}_$i'),
                                    countedAs: _countedAs[i],
                                    onTap: () => _tapFruit(i),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          AnimatedOpacity(
                            opacity: _allCounted ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: IgnorePointer(
                              ignoring: !_allCounted,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SpeakerButton(
                                        size: 48,
                                        onPressed: () =>
                                            AudioService.instance.say(VoiceScript.countingQuestion),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text('چند تا انار هست؟',
                                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 16,
                                    children: [
                                      for (final c in _choices)
                                        _NumberChoice(
                                          key: ValueKey('choice_$c'),
                                          value: c,
                                          dimmed: _wrongChoices.contains(c),
                                          highlighted: _celebrating && c == _target,
                                          onTap: () => _choose(c),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CelebrationOverlay(visible: _celebrating),
                ],
              ),
      ),
    );
  }
}

class _Pomegranate extends StatelessWidget {
  const _Pomegranate({super.key, required this.countedAs, required this.onTap});

  final int countedAs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final counted = countedAs != 0;
    return Semantics(
      button: true,
      label: counted ? 'انار ${persianNumberWords[countedAs]}' : 'انار',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: counted ? 0.92 : 1,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: 110,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(size: const Size(110, 120), painter: _PomegranatePainter(dim: counted)),
                if (counted)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(
                      toPersianDigits(countedAs),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PomegranatePainter extends CustomPainter {
  _PomegranatePainter({required this.dim});

  final bool dim;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.58);
    final radius = w * 0.42;
    final body = dim ? const Color(0xFF9E3B45) : AppColors.pomegranate;

    // Crown (the little "hat" on top of a pomegranate).
    final crown = Path()
      ..moveTo(w * 0.36, h * 0.2)
      ..lineTo(w * 0.4, h * 0.06)
      ..lineTo(w * 0.46, h * 0.16)
      ..lineTo(w * 0.5, h * 0.03)
      ..lineTo(w * 0.54, h * 0.16)
      ..lineTo(w * 0.6, h * 0.06)
      ..lineTo(w * 0.64, h * 0.2)
      ..close();
    canvas.drawPath(crown, Paint()..color = const Color(0xFF8C1C28));
    canvas.drawCircle(center, radius, Paint()..color = body);
    // Shine.
    canvas.drawCircle(
      center + Offset(-radius * 0.4, -radius * 0.4),
      radius * 0.18,
      Paint()..color = Colors.white.withValues(alpha: dim ? 0.15 : 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _PomegranatePainter old) => old.dim != dim;
}

class _NumberChoice extends StatelessWidget {
  const _NumberChoice({
    super.key,
    required this.value,
    required this.dimmed,
    required this.highlighted,
    required this.onTap,
  });

  final int value;
  final bool dimmed;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.35 : 1,
      duration: const Duration(milliseconds: 250),
      child: Semantics(
        button: true,
        label: persianNumberWords[value],
        child: Material(
          color: highlighted ? AppColors.leaf : AppColors.card,
          elevation: 4,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: dimmed ? null : onTap,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: Text(
                  toPersianDigits(value),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: highlighted ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
