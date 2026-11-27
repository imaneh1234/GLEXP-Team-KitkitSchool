import 'dart:math';

import 'package:farsi_play_learn/data/letters.dart';
import 'package:farsi_play_learn/data/voice_script.dart';
import 'package:farsi_play_learn/main.dart';
import 'package:farsi_play_learn/screens/counting_screen.dart';
import 'package:farsi_play_learn/data/syllables.dart';
import 'package:farsi_play_learn/screens/letter_sounds_screen.dart';
import 'package:farsi_play_learn/screens/reading_screen.dart';
import 'package:farsi_play_learn/services/audio_service.dart';
import 'package:farsi_play_learn/tracing/tracing_engine.dart';
import 'package:farsi_play_learn/utils/persian_numbers.dart';
import 'package:farsi_play_learn/widgets/listen_choose_game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUpAll(() => AudioService.enabled = false);

  group('Persian numbers', () {
    test('converts Western digits to Persian digits', () {
      expect(toPersianDigits(0), '۰');
      expect(toPersianDigits(456), '۴۵۶'); // Persian ۴۵۶, not Arabic ٤٥٦
      expect(toPersianDigits(10), '۱۰');
    });

    test('has a word for every number used', () {
      for (var n = 1; n <= 10; n++) {
        expect(persianNumberWords[n], isNotNull);
      }
    });
  });

  group('Letter data', () {
    test('every stroke point is inside the 0–1 box', () {
      for (final l in alphabetSequence) {
        for (final stroke in l.strokes) {
          expect(stroke, isNotEmpty, reason: l.char);
          for (final p in stroke) {
            expect(p.dx, inInclusiveRange(0, 1), reason: l.char);
            expect(p.dy, inInclusiveRange(0, 1), reason: l.char);
          }
        }
      }
    });

    test('non-joining letters have two shapes, joining letters four', () {
      final dal = alphabetSequence.firstWhere((l) => l.char == 'د');
      final be = alphabetSequence.firstWhere((l) => l.char == 'ب');
      expect(dal.positionalForms, ['د', 'ـد']);
      expect(be.positionalForms, ['ب', 'بـ', 'ـبـ', 'ـب']);
    });

    test('follows the Grade 1 textbook order, vowels included', () {
      expect(alphabetSequence.map((u) => u.char).toList(),
          ['آ', 'ب', 'اَ', 'د', 'م', 'ن', 'او', 'ت', 'ای', 'س', 'اُ', 'ر', 'اِ']);
      expect(alphabetSequence.where((u) => u.isVowel).length, 5);
    });

    test('vowel units show example shapes with a label for each', () {
      for (final u in alphabetSequence.where((u) => u.isVowel)) {
        expect(u.positionalForms.length, u.positionalFormLabels.length, reason: u.char);
      }
    });

    test('voice script keys are unique', () {
      final keys = VoiceScript.all.map((l) => l.key).toList();
      expect(keys.toSet().length, keys.length);
    });
  });

  group('Syllables', () {
    test('7 letters × 6 vowels = 42 syllables, each with a unique id', () {
      expect(allSyllables.length, 42);
      expect(allSyllables.map((s) => s.id).toSet().length, 42);
    });

    test('are written as letter + vowel sign', () {
      final be = syllableConsonants.firstWhere((c) => c.char == 'ب');
      String text(String vowelId) =>
          Syllable(be, vowelSigns.firstWhere((v) => v.id == vowelId)).text;
      expect(text('a'), 'بَ');
      expect(text('e'), 'بِ');
      expect(text('o'), 'بُ');
      expect(text('aa'), 'با');
      expect(text('u'), 'بو');
      expect(text('i'), 'بی');
    });

    test('reading rounds alternate: same letter, then same vowel', () {
      final rounds = ReadingScreen.buildRounds(Random(3), 6);
      final byId = {for (final s in allSyllables) s.id: s};
      for (var r = 0; r < rounds.length; r++) {
        final options = rounds[r].options.map((o) => byId[o.id]!).toList();
        expect(options.length, 3);
        expect(options.map((o) => o.id).toSet().length, 3);
        expect(options.map((o) => o.id), contains(rounds[r].correctId));
        if (r.isEven) {
          expect(options.map((o) => o.consonant.id).toSet().length, 1);
        } else {
          expect(options.map((o) => o.vowel.id).toSet().length, 1);
        }
      }
    });
  });

  group('Tracing engine', () {
    // Body from right to left, then one dot (like ب).
    final strokes = [
      [const Offset(0.8, 0.5), const Offset(0.2, 0.5)],
      [const Offset(0.5, 0.8)],
    ];

    test('follows the stroke in writing direction and then the dot', () {
      final e = TracingEngine(strokes);
      expect(e.fingerDown(const Offset(0.8, 0.5), 0.05), isTrue);
      for (var x = 0.8; x >= 0.2; x -= 0.02) {
        e.fingerMove(Offset(x, 0.5), 0.05);
      }
      e.fingerMove(const Offset(0.2, 0.5), 0.05);
      expect(e.strokeIndex, 1);
      expect(e.currentIsDot, isTrue);
      e.fingerUp();
      expect(e.fingerDown(const Offset(0.5, 0.8), 0.05), isTrue);
      expect(e.isComplete, isTrue);
      expect(e.progress, 1);
    });

    test('does not accept tracing from the wrong end', () {
      final e = TracingEngine(strokes);
      expect(e.fingerDown(const Offset(0.2, 0.5), 0.05), isFalse);
      expect(e.pointIndex, 0);
    });

    test('needs the finger lifted before the next stroke', () {
      final e = TracingEngine([
        [const Offset(0.5, 0.2), const Offset(0.5, 0.3)],
        [const Offset(0.5, 0.32)],
      ]);
      e.fingerDown(const Offset(0.5, 0.2), 0.05);
      e.fingerMove(const Offset(0.5, 0.25), 0.05);
      e.fingerMove(const Offset(0.5, 0.3), 0.05);
      expect(e.strokeIndex, 1);
      // Still holding the finger down, right over the dot: no progress.
      expect(e.fingerMove(const Offset(0.5, 0.32), 0.05), isFalse);
      e.fingerUp();
      expect(e.fingerDown(const Offset(0.5, 0.32), 0.05), isTrue);
      expect(e.isComplete, isTrue);
    });

    test('every prototype letter can be completed by following its guide', () {
      for (final l in alphabetSequence) {
        final e = TracingEngine(l.strokes);
        for (final path in e.paths) {
          e.fingerDown(path.first, 0.04);
          for (final p in path) {
            e.fingerMove(p, 0.04);
          }
          e.fingerUp();
        }
        expect(e.isComplete, isTrue, reason: l.char);
      }
    });
  });

  group('App', () {
    testWidgets('opens right-to-left with three activities', (tester) async {
      await tester.pumpWidget(const FarsiPlayLearnApp());
      await tester.pumpAndSettle();
      expect(find.text('صدای حرف‌ها'), findsOneWidget);
      expect(find.text('بنویسیم'), findsOneWidget);
      expect(find.text('بشماریم'), findsOneWidget);
      final context = tester.element(find.text('بنویسیم'));
      expect(Directionality.of(context), TextDirection.rtl);
    });

    testWidgets('letter sounds: tapping the right letter earns a star', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LetterSoundsScreen(rounds: 2)));
      await tester.pump(const Duration(seconds: 4));
      final state = tester.state<ListenChooseGameState>(find.byType(ListenChooseGame));
      await tester.tap(find.byKey(ValueKey('option_${state.debugCorrectId}')));
      await tester.pump(const Duration(seconds: 3));
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('reading: a wrong syllable fades, the right one moves on', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReadingScreen(rounds: 2)));
      await tester.pump(const Duration(seconds: 4));
      final state = tester.state<ListenChooseGameState>(find.byType(ListenChooseGame));
      final correct = state.debugCorrectId;
      final wrong = find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('option_') &&
          (w.key! as ValueKey<String>).value != 'option_$correct');
      await tester.tap(wrong.first);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byKey(ValueKey('option_$correct')));
      await tester.pump(const Duration(seconds: 3));
      // No star for round one (first try was wrong), and round two has started.
      expect(state.debugCorrectId, isNot(correct));
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('counting: count every pomegranate, then choose the number', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CountingScreen(random: Random(2), rounds: 1, maxNumber: 4),
      ));
      await tester.pump(const Duration(seconds: 1));
      final fruits = find.byWidgetPredicate(
          (w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('fruit_'));
      final count = fruits.evaluate().length;
      for (var i = 0; i < count; i++) {
        await tester.tap(fruits.at(i));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(ValueKey('choice_$count')));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('آفرین!'), findsOneWidget); // finished screen
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
