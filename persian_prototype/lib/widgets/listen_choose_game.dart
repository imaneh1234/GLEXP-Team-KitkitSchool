import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/voice_script.dart';
import '../services/audio_service.dart';
import '../theme.dart';
import 'common.dart';

/// One card the child can choose.
class ChoiceOption {
  const ChoiceOption({required this.id, required this.text, required this.semanticsLabel});

  final String id;
  final String text;
  final String semanticsLabel;
}

/// One question: what the child hears, and the cards to choose from.
class ChoiceRound {
  const ChoiceRound({required this.prompt, required this.options, required this.correctId});

  final VoiceLine prompt;
  final List<ChoiceOption> options;
  final String correctId;
}

/// Shared "listen, then tap the right card" game, used by the letter-sounds
/// and reading activities. Spoken instructions, no text to read, gentle
/// feedback, and a star for every first-time correct answer.
class ListenChooseGame extends StatefulWidget {
  const ListenChooseGame({
    super.key,
    required this.instruction,
    required this.buildRounds,
    this.cardColor = AppColors.card,
  });

  final VoiceLine instruction;

  /// Makes a fresh set of rounds (called again for "play again").
  final List<ChoiceRound> Function(Random random) buildRounds;
  final Color cardColor;

  @override
  State<ListenChooseGame> createState() => ListenChooseGameState();
}

class ListenChooseGameState extends State<ListenChooseGame> {
  final Random _random = Random();
  late List<ChoiceRound> _rounds;
  final Set<String> _wrongPicks = {};
  int _round = 0;
  int _stars = 0;
  bool _celebrating = false;
  bool _finished = false;

  ChoiceRound get _current => _rounds[_round];

  /// For automated tests only: the id of the right answer.
  String get debugCorrectId => _current.correctId;

  @override
  void initState() {
    super.initState();
    _start();
    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      await AudioService.instance.say(widget.instruction);
      await Future<void>.delayed(const Duration(milliseconds: 2400));
      if (mounted) _playPrompt();
    });
  }

  void _start() {
    _rounds = widget.buildRounds(_random);
    _round = 0;
    _stars = 0;
    _finished = false;
    _wrongPicks.clear();
  }

  void _playPrompt() => AudioService.instance.say(_current.prompt);

  Future<void> _pick(ChoiceOption option) async {
    if (_celebrating) return;
    if (option.id != _current.correctId) {
      setState(() => _wrongPicks.add(option.id));
      AudioService.instance.tryAgain();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _playPrompt();
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
      _wrongPicks.clear();
      if (_round + 1 >= _rounds.length) {
        _finished = true;
        AudioService.instance.say(VoiceScript.allDone);
      } else {
        _round++;
      }
    });
    if (!_finished) _playPrompt();
  }

  @override
  void dispose() {
    AudioService.instance.stopVoice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: StarProgress(earned: _stars, total: _rounds.length)),
      body: SafeArea(
        child: _finished
            ? FinishedView(
                stars: _stars,
                onPlayAgain: () {
                  setState(_start);
                  _playPrompt();
                },
              )
            : Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SpeakerButton(onPressed: _playPrompt, size: 110),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final option in _current.options)
                                _ChoiceCard(
                                  key: ValueKey('option_${option.id}'),
                                  option: option,
                                  color: widget.cardColor,
                                  dimmed: _wrongPicks.contains(option.id),
                                  highlighted: _celebrating && option.id == _current.correctId,
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

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    super.key,
    required this.option,
    required this.color,
    required this.dimmed,
    required this.highlighted,
    required this.onTap,
  });

  final ChoiceOption option;
  final Color color;
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
          label: option.semanticsLabel,
          child: Material(
            color: highlighted ? AppColors.leaf : color,
            elevation: 4,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: dimmed ? null : onTap,
              child: SizedBox(
                width: size,
                height: size * 1.15,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        option.text,
                        style: TextStyle(
                          fontSize: size * 0.55,
                          fontWeight: FontWeight.w700,
                          color: highlighted ? Colors.white : AppColors.ink,
                          // Extra line height keeps vowel marks (ـَ ـِ ـُ) clear.
                          height: 1.5,
                        ),
                      ),
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
