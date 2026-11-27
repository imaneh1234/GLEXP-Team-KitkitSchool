import '../utils/persian_numbers.dart';
import 'letters.dart';
import 'syllables.dart';

/// Every sentence the app speaks, in one place.
///
/// This list is also the recording script for the voice artist. When a
/// recording exists at `assets/audio/<key>.mp3` (or .m4a / .wav), the app plays
/// it. Until then it falls back to the device's Persian text-to-speech voice,
/// if one is installed. See docs/RECORDING_SCRIPT.md.
class VoiceLine {
  const VoiceLine(this.key, this.text, {this.note = ''});

  final String key;
  final String text;

  /// Direction for the voice artist.
  final String note;
}

class VoiceScript {
  static const welcome = VoiceLine('welcome', 'سلام! بیا با هم بازی کنیم و یاد بگیریم.');

  static const homeSounds = VoiceLine('home_sounds', 'صدای حرف‌ها');
  static const homeTracing = VoiceLine('home_tracing', 'بنویسیم');
  static const homeCounting = VoiceLine('home_counting', 'بشماریم');
  static const homeReading = VoiceLine('home_reading', 'بخوانیم');

  static const soundsInstruction = VoiceLine(
    'sounds_instruction',
    'خوب گوش کن! کدام حرف را شنیدی؟',
  );

  static const readingInstruction = VoiceLine(
    'reading_instruction',
    'گوش کن! کدام را شنیدی؟ آن را پیدا کن.',
  );

  static const tracingInstruction = VoiceLine(
    'tracing_instruction',
    'از دایره‌ی سبز شروع کن و انگشتت را روی خط بکش.',
  );
  static const tracingDot = VoiceLine('tracing_dot', 'حالا نقطه را بگذار.');

  static const countingInstruction = VoiceLine(
    'counting_instruction',
    'روی انارها بزن و بشمار.',
  );
  static const countingQuestion = VoiceLine('counting_question', 'چند تا انار هست؟');

  static const praise = [
    VoiceLine('praise_1', 'آفرین!', note: 'Warm and happy.'),
    VoiceLine('praise_2', 'عالی بود!', note: 'Warm and happy.'),
    VoiceLine('praise_3', 'خیلی خوب!', note: 'Warm and happy.'),
  ];
  static const tryAgain = VoiceLine(
    'try_again',
    'دوباره امتحان کن.',
    note: 'Gentle and encouraging, never disappointed.',
  );
  static const allDone = VoiceLine('all_done', 'آفرین! همه را درست انجام دادی.');

  static VoiceLine letter(PersianLetter l) => VoiceLine(
        l.audioKey,
        l.spokenPrompt,
        note: l.isVowel
            ? 'Say the vowel sound, a short pause, then the example word.'
            : 'Say the letter name, a short pause, then the example word. '
                'An education adviser may prefer the letter SOUND instead of the name.',
      );

  static VoiceLine syllable(Syllable s) => VoiceLine(
        s.audioKey,
        s.text,
        note: 'Only the syllable, clearly and slowly (${s.consonant.name} + ${s.vowel.name}).',
      );

  static VoiceLine number(int n) => VoiceLine('number_$n', persianNumberWords[n]!);

  /// Every line, for generating the recording checklist.
  static List<VoiceLine> get all => [
        welcome,
        homeSounds,
        homeTracing,
        homeCounting,
        homeReading,
        soundsInstruction,
        readingInstruction,
        tracingInstruction,
        tracingDot,
        countingInstruction,
        countingQuestion,
        ...praise,
        tryAgain,
        allDone,
        for (final l in alphabetSequence) letter(l),
        for (final s in allSyllables) syllable(s),
        for (var n = 1; n <= 10; n++) number(n),
      ];

  static String digitsFor(int n) => toPersianDigits(n);
}
