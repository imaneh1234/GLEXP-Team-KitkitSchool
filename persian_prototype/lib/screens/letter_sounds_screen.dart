import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/letters.dart';
import '../data/voice_script.dart';
import '../widgets/listen_choose_game.dart';

/// Activity 1 — "Sounds of the letters" (inspired by Kitkit's SoundTrain /
/// BirdPhonics). The child hears a letter or vowel and taps the matching card.
/// Designed for pre-readers: the instruction is spoken, and the only text
/// on screen is the letters themselves.
class LetterSoundsScreen extends StatelessWidget {
  const LetterSoundsScreen({super.key, this.rounds = 6});

  final int rounds;

  static List<ChoiceRound> buildRounds(Random random, int rounds) {
    final targets = ([...alphabetSequence]..shuffle(random)).take(rounds);
    return [
      for (final target in targets)
        ChoiceRound(
          prompt: VoiceScript.letter(target),
          correctId: target.id,
          options: [
            target,
            ...(alphabetSequence.where((l) => l.id != target.id).toList()..shuffle(random)).take(2),
          ].map(_option).toList()
            ..shuffle(random),
        ),
    ];
  }

  static ChoiceOption _option(PersianLetter l) =>
      ChoiceOption(id: l.id, text: l.char, semanticsLabel: l.isVowel ? 'نشانه‌ی ${l.name}' : 'حرف ${l.name}');

  @override
  Widget build(BuildContext context) {
    return ListenChooseGame(
      instruction: VoiceScript.soundsInstruction,
      buildRounds: (random) => buildRounds(random, rounds),
    );
  }
}
