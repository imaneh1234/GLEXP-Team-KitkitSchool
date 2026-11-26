import 'dart:math';

import 'package:farsi_play_learn/data/letters.dart';
import 'package:farsi_play_learn/data/voice_script.dart';
import 'package:farsi_play_learn/main.dart';
import 'package:farsi_play_learn/screens/counting_screen.dart';
import 'package:farsi_play_learn/screens/letter_sounds_screen.dart';
import 'package:farsi_play_learn/services/audio_service.dart';
import 'package:farsi_play_learn/tracing/tracing_engine.dart';
import 'package:farsi_play_learn/utils/persian_numbers.dart';
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
      for (final l in prototypeLetters) {
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
      final dal = prototypeLetters.firstWhere((l) => l.char == 'د');
      final be = prototypeLetters.firstWhere((l) => l.char == 'ب');
      expect(dal.positionalForms, ['د', 'ـد']);
      expect(be.positionalForms, ['ب', 'بـ', 'ـبـ', 'ـب']);
    });

    test('voice script keys are unique', () {
      final keys = VoiceScript.all.map((l) => l.key).toList();
      expect(keys.toSet().length, keys.length);
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
      for (final l in prototypeLetters) {
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
      await tester.pumpWidget(MaterialApp(
        home: LetterSoundsScreen(random: Random(1), rounds: 2),
      ));
      await tester.pump(const Duration(seconds: 4));
      final state = tester.state(find.byType(LetterSoundsScreen)) as dynamic;
      final target = state.debugTarget as PersianLetter;
      await tester.tap(find.byKey(ValueKey('option_${target.id}')));
      await tester.pump(const Duration(seconds: 3));
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
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
