import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/syllables.dart';
import '../data/voice_script.dart';
import '../widgets/listen_choose_game.dart';

/// Activity 4 — "Let's read" (inspired by Kitkit's WordMachine / BirdPhonics).
///
/// The child hears a syllable (e.g. بُ) and finds it among three cards.
/// Rounds alternate between two kinds, which together teach decoding:
///  * same letter, different vowel  (بَ / بِ / بُ)  → look at the vowel sign;
///  * same vowel, different letter  (بو / تو / سو) → look at the letter.
class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key, this.rounds = 8});

  final int rounds;

  static List<ChoiceRound> buildRounds(Random random, int rounds) {
    final syllables = allSyllables;
    final result = <ChoiceRound>[];
    for (var r = 0; r < rounds; r++) {
      final target = syllables[random.nextInt(syllables.length)];
      final sameLetter = r.isEven;
      final pool = syllables
          .where((s) => s.id != target.id)
          .where((s) => sameLetter
              ? s.consonant.id == target.consonant.id
              : s.vowel.id == target.vowel.id)
          .toList()
        ..shuffle(random);
      final options = [target, ...pool.take(2)]..shuffle(random);
      result.add(ChoiceRound(
        prompt: VoiceScript.syllable(target),
        correctId: target.id,
        options: [
          for (final s in options) ChoiceOption(id: s.id, text: s.text, semanticsLabel: s.text),
        ],
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListenChooseGame(
      instruction: VoiceScript.readingInstruction,
      cardColor: const Color(0xFFFFFBF2),
      buildRounds: (random) => buildRounds(random, rounds),
    );
  }
}
