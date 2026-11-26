import 'dart:ui' show Offset;

/// One Persian letter as used in the prototype's activities.
///
/// The letters and their order follow the opening lessons of Iran's Grade 1
/// Persian textbook (فارسی اول دبستان): آ، ب، د، م، ن، ت، س، ر.
/// (The textbook also teaches the short vowels  ـَ ـِ ـُ  and the long vowels
/// او / ای in between; those are planned for the next milestone.)
class PersianLetter {
  const PersianLetter({
    required this.id,
    required this.char,
    required this.name,
    required this.exampleWord,
    required this.joinsToNext,
    required this.strokes,
  });

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
  List<String> get positionalForms => joinsToNext
      ? [char, '$charـ', 'ـ$charـ', 'ـ$char']
      : [char, 'ـ$char'];

  /// Labels to show under each positional form.
  List<String> get positionalFormLabels =>
      joinsToNext ? const ['تنها', 'اول', 'وسط', 'آخر'] : const ['تنها', 'آخر'];

  /// Audio key used to find this letter's recording.
  String get audioKey => 'letter_$id';

  /// What the voice says for this letter. Used as the text-to-speech fallback
  /// until a voice artist's recording is added.
  String get spokenPrompt => '$name، مثلِ $exampleWord';
}

const List<PersianLetter> prototypeLetters = [
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
];
