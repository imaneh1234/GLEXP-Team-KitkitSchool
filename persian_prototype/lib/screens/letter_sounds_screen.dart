import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/letters.dart';
import '../data/voice_script.dart';
import '../services/audio_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Activity 1 — "Sounds of the letters" (inspired by Kitkit's SoundTrain /
/// BirdPhonics). The child hears a letter and taps the matching card.
/// Designed for pre-readers: the instruction is spoken, and the only text
/// on screen is the letters themselves.
class LetterSoundsScreen extends StatefulWidget {
  const LetterSoundsScreen({super.key, this.random, this.rounds = 6});

  final Random? random;
  final int rounds;

  @override
  State<LetterSoundsScreen> createState() => _LetterSoundsScreenState();
}

class _LetterSoundsScreenState extends State<LetterSoundsScreen> {
  late final Random _random = widget.random ?? Random();
  late List<PersianLetter> _targets;
  late List<PersianLetter> _options;
  final Set<String> _wrongPicks = {};
  int _round = 0;
  int _stars = 0;
  bool _celebrating = false;
  bool _finished = false;

  PersianLetter get _target => _targets[_round];

  /// For automated tests only: the letter the child should find.
  PersianLetter get debugTarget => _target;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    final shuffled = [...prototypeLetters]..shuffle(_random);
    _targets = shuffled.take(widget.rounds).toList();
    _round = 0;
    _stars = 0;
    _finished = false;
    _setUpRound();
    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      await AudioService.instance.say(VoiceScript.soundsInstruction);
      await Future<void>.delayed(const Duration(milliseconds: 2400));
      if (mounted) _playTarget();
    });
  }

  void _setUpRound() {
    final others = prototypeLetters.where((l) => l.id != _target.id).toList()..shuffle(_random);
    _options = [_target, ...others.take(2)]..shuffle(_random);
    _wrongPicks.clear();
  }

  void _playTarget() => AudioService.instance.say(VoiceScript.letter(_target));

  Future<void> _pick(PersianLetter letter) async {
    if (_celebrating) return;
    if (letter.id != _target.id) {
      setState(() => _wrongPicks.add(letter.id));
      AudioService.instance.tryAgain();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _playTarget();
      return;
    }
    setState(() {
      _celebrating = true;
      if (_wrongPicks.isEmpty) _stars++; // a star for getting it first time
    });
    unawaited(celebrate());
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      _celebrating = false;
      if (_round + 1 >= _targets.length) {
        _finished = true;
        AudioService.instance.say(VoiceScript.allDone);
      } else {
        _round++;
        _setUpRound();
      }
    });
    if (!_finished) _playTarget();
  }

  @override
  void dispose() {
    AudioService.instance.stopVoice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StarProgress(earned: _stars, total: _targets.length),
      ),
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
                          SpeakerButton(onPressed: _playTarget, size: 110),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final option in _options)
                                _LetterCard(
                                  key: ValueKey('option_${option.id}'),
                                  letter: option,
                                  dimmed: _wrongPicks.contains(option.id),
                                  highlighted: _celebrating && option.id == _target.id,
                                  onTap: () => _pick(option),
                                ),
                            ],
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

class _LetterCard extends StatelessWidget {
  const _LetterCard({
    super.key,
    required this.letter,
    required this.dimmed,
    required this.highlighted,
    required this.onTap,
  });

  final PersianLetter letter;
  final bool dimmed;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.sizeOf(context).width / 3.6).clamp(96.0, 170.0);
    return AnimatedOpacity(
      opacity: dimmed ? 0.35 : 1,
      duration: const Duration(milliseconds: 250),
      child: AnimatedScale(
        scale: highlighted ? 1.12 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Semantics(
          button: true,
          label: 'حرف ${letter.name}',
          child: Material(
            color: highlighted ? AppColors.leaf : AppColors.card,
            elevation: 4,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: dimmed ? null : onTap,
              child: SizedBox(
                width: size,
                height: size * 1.15,
                child: Center(
                  child: Text(
                    letter.char,
                    style: TextStyle(
                      fontSize: size * 0.62,
                      fontWeight: FontWeight.w700,
                      color: highlighted ? Colors.white : AppColors.ink,
                      height: 1.2,
                    ),
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
