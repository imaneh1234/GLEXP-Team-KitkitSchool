import 'dart:ui' show Offset;

/// One unit of the alphabet sequence: a letter (like ب) or a vowel sign
/// (like اَ or او), as used in the prototype's activities.
///
/// The units and their order follow the opening lessons of Iran's Grade 1
/// Persian textbook (فارسی اول دبستان):
///   آ، ب، اَ، د، م، ن، او، ت، ای، س، اُ، ر، اِ
/// An education adviser should check this against the current edition.
class PersianLetter {
  const PersianLetter({
    required this.id,
    required this.char,
    required this.name,
    required this.exampleWord,
    required this.joinsToNext,
    required this.strokes,
    this.isVowel = false,
    this.customForms,
    this.customFormLabels,
  });

  /// True for vowel units (اَ اِ اُ او ای). Children learn these as the
  /// "glue" that turns letters into syllables they can read.
  final bool isVowel;

  /// For vowel units: example shapes to show instead of letter positions,
  /// e.g. اَ at the start of a word and بَ after a letter.
  final List<String>? customForms;
  final List<String>? customFormLabels;

  /// Latin identifier, used for audio file names (e.g. `letter_be.mp3`).
  final String id;

  /// The letter itself, in its isolated (stand-alone) form.
  final String char;

  /// The letter's spoken name, written with vowel marks (e.g. بِ).
  final String name;

  /// A familiar, picturable word that starts with this letter.
  final String exampleWord;

  /// Seven Persian letters (ا د ذ ر ز ژ و) never join the letter after them.
  /// Those letters only have two shapes instead of four.
  final bool joinsToNext;

  /// Tracing guide: the letter's strokes, in the order a child writes them.
  ///
  /// Each stroke is a list of points in a 0–1 box (0,0 = top-left,
  /// 1,1 = bottom-right). Persian is written right to left, so the main body
  /// usually starts on the right. A stroke with a single point is a dot,
  /// which is added after the body, as children are taught in school.
  ///
  /// NOTE FOR DESIGNERS: these shapes are first approximations made for the
  /// prototype. A calligraphy/handwriting teacher should review them and an
  /// animator can replace them with precise paths (same format).
  final List<List<Offset>> strokes;

  /// The shapes this letter takes in a word, using the joining line (ـ).
  /// Order: isolated, start of word, middle of word, end of word.
  List<String> get positionalForms =>
      customForms ??
      (joinsToNext ? [char, '$charـ', 'ـ$charـ', 'ـ$char'] : [char, 'ـ$char']);

  /// Labels to show under each positional form.
  List<String> get positionalFormLabels =>
      customFormLabels ??
      (joinsToNext ? const ['تنها', 'اول', 'وسط', 'آخر'] : const ['تنها', 'آخر']);

  /// Audio key used to find this letter's recording.
  String get audioKey => 'letter_$id';

  /// What the voice says for this letter. Used as the text-to-speech fallback
  /// until a voice artist's recording is added.
  String get spokenPrompt => '$name، مثلِ $exampleWord';
}

/// The whole sequence, in textbook order.
const List<PersianLetter> alphabetSequence = [
  PersianLetter(
    id: 'alef_madda',
    char: 'آ',
    name: 'آ',
    exampleWord: 'آب',
    joinsToNext: false,
    strokes: [
      // Upright line, top to bottom.
      [Offset(0.5, 0.24), Offset(0.5, 0.68)],
      // The madda (wavy hat), right to left.
      [Offset(0.62, 0.13), Offset(0.56, 0.09), Offset(0.5, 0.13), Offset(0.44, 0.16), Offset(0.38, 0.12)],
    ],
  ),
  PersianLetter(
    id: 'be',
    char: 'ب',
    name: 'بِ',
    exampleWord: 'بابا',
    joinsToNext: true,
    strokes: [
      // The "boat": down on the right, along the line, up on the left.
      [
        Offset(0.82, 0.42),
        Offset(0.8, 0.58),
        Offset(0.7, 0.66),
        Offset(0.5, 0.68),
        Offset(0.3, 0.66),
        Offset(0.2, 0.58),
        Offset(0.18, 0.46),
      ],
      // One dot below.
      [Offset(0.5, 0.84)],
    ],
  ),
  PersianLetter(
    id: 'vowel_a',
    char: 'اَ',
    name: 'اَ',
    exampleWord: 'اَسب',
    joinsToNext: false,
    isVowel: true,
    customForms: ['اَ', 'بَ'],
    customFormLabels: ['اول کلمه', 'با «ب»'],
    strokes: [
      // Alef, top to bottom, then the small slanted line above (زبر).
      [Offset(0.5, 0.3), Offset(0.5, 0.68)],
      [Offset(0.6, 0.12), Offset(0.42, 0.21)],
    ],
  ),
  PersianLetter(
    id: 'dal',
    char: 'د',
    name: 'دال',
    exampleWord: 'دندان',
    joinsToNext: false,
    strokes: [
      [
        Offset(0.4, 0.28),
        Offset(0.52, 0.42),
        Offset(0.6, 0.56),
        Offset(0.58, 0.66),
        Offset(0.48, 0.68),
        Offset(0.34, 0.68),
      ],
    ],
  ),
  PersianLetter(
    id: 'mim',
    char: 'م',
    name: 'میم',
    exampleWord: 'ماه',
    joinsToNext: true,
    strokes: [
      // Small round head, then the tail going down on the left.
      [
        Offset(0.56, 0.58),
        Offset(0.64, 0.5),
        Offset(0.72, 0.58),
        Offset(0.66, 0.68),
        Offset(0.54, 0.68),
        Offset(0.44, 0.68),
        Offset(0.38, 0.78),
        Offset(0.38, 0.9),
      ],
    ],
  ),
  PersianLetter(
    id: 'nun',
    char: 'ن',
    name: 'نون',
    exampleWord: 'نان',
    joinsToNext: true,
    strokes: [
      // A deep bowl, right to left.
      [
        Offset(0.76, 0.42),
        Offset(0.75, 0.6),
        Offset(0.64, 0.74),
        Offset(0.5, 0.77),
        Offset(0.36, 0.74),
        Offset(0.26, 0.6),
        Offset(0.25, 0.44),
      ],
      // One dot above, inside the bowl.
      [Offset(0.5, 0.5)],
    ],
  ),
  PersianLetter(
    id: 'vowel_u',
    char: 'او',
    name: 'او',
    exampleWord: 'توت',
    joinsToNext: false,
    isVowel: true,
    customForms: ['او', 'بو', 'تو'],
    customFormLabels: ['اول کلمه', 'با «ب»', 'با «ت»'],
    strokes: [
      // Alef on the right, then و: round head on the line, tail going down-left.
      [Offset(0.74, 0.24), Offset(0.74, 0.68)],
      [
        Offset(0.44, 0.62),
        Offset(0.48, 0.53),
        Offset(0.56, 0.55),
        Offset(0.57, 0.63),
        Offset(0.52, 0.7),
        Offset(0.46, 0.79),
        Offset(0.36, 0.87),
        Offset(0.24, 0.9),
      ],
    ],
  ),
  PersianLetter(
    id: 'te',
    char: 'ت',
    name: 'تِ',
    exampleWord: 'توپ',
    joinsToNext: true,
    strokes: [
      [
        Offset(0.82, 0.44),
        Offset(0.8, 0.58),
        Offset(0.7, 0.66),
        Offset(0.5, 0.68),
        Offset(0.3, 0.66),
        Offset(0.2, 0.58),
        Offset(0.18, 0.46),
      ],
      // Two dots above, right one first.
      [Offset(0.57, 0.46)],
      [Offset(0.43, 0.46)],
    ],
  ),
  PersianLetter(
    id: 'vowel_i',
    char: 'ای',
    name: 'ای',
    exampleWord: 'سیب',
    joinsToNext: false,
    isVowel: true,
    customForms: ['ای', 'بیـ', 'بی'],
    customFormLabels: ['اول کلمه', 'وسط', 'آخر'],
    strokes: [
      // Alef on the right, then ی: a small curve and a wide bowl to the left.
      [Offset(0.78, 0.24), Offset(0.78, 0.68)],
      [
        Offset(0.6, 0.46),
        Offset(0.5, 0.52),
        Offset(0.52, 0.6),
        Offset(0.62, 0.66),
        Offset(0.62, 0.76),
        Offset(0.5, 0.83),
        Offset(0.32, 0.84),
        Offset(0.18, 0.78),
        Offset(0.13, 0.67),
      ],
    ],
  ),
  PersianLetter(
    id: 'sin',
    char: 'س',
    name: 'سین',
    exampleWord: 'سیب',
    joinsToNext: true,
    strokes: [
      // Three little "teeth", then a bowl.
      [
        Offset(0.88, 0.54),
        Offset(0.86, 0.64),
        Offset(0.8, 0.66),
        Offset(0.76, 0.56),
        Offset(0.72, 0.66),
        Offset(0.66, 0.66),
        Offset(0.62, 0.56),
        Offset(0.6, 0.68),
        Offset(0.54, 0.8),
        Offset(0.42, 0.86),
        Offset(0.28, 0.84),
        Offset(0.18, 0.74),
        Offset(0.16, 0.62),
      ],
    ],
  ),
  PersianLetter(
    id: 'vowel_o',
    char: 'اُ',
    name: 'اُ',
    exampleWord: 'اُردک',
    joinsToNext: false,
    isVowel: true,
    customForms: ['اُ', 'بُ'],
    customFormLabels: ['اول کلمه', 'با «ب»'],
    strokes: [
      // Alef, then the small و-shaped sign above (پیش).
      [Offset(0.5, 0.36), Offset(0.5, 0.68)],
      [
        Offset(0.56, 0.17),
        Offset(0.58, 0.08),
        Offset(0.65, 0.05),
        Offset(0.71, 0.11),
        Offset(0.66, 0.19),
        Offset(0.55, 0.24),
        Offset(0.42, 0.28),
      ],
    ],
  ),
  PersianLetter(
    id: 're',
    char: 'ر',
    name: 'رِ',
    exampleWord: 'روباه',
    joinsToNext: false,
    strokes: [
      [
        Offset(0.6, 0.54),
        Offset(0.6, 0.68),
        Offset(0.54, 0.8),
        Offset(0.44, 0.9),
        Offset(0.3, 0.94),
      ],
    ],
  ),
  PersianLetter(
    id: 'vowel_e',
    char: 'اِ',
    name: 'اِ',
    exampleWord: 'اِستخر',
    joinsToNext: false,
    isVowel: true,
    customForms: ['اِ', 'بِ'],
    customFormLabels: ['اول کلمه', 'با «ب»'],
    strokes: [
      // Alef, then the small slanted line below (زیر).
      [Offset(0.5, 0.24), Offset(0.5, 0.68)],
      [Offset(0.6, 0.78), Offset(0.42, 0.87)],
    ],
  ),
];

/// Letters (not vowels) that can start a syllable in the reading game.
List<PersianLetter> get syllableConsonants =>
    alphabetSequence.where((u) => !u.isVowel && u.id != 'alef_madda').toList();
