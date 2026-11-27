import 'letters.dart';

/// A vowel that can follow a letter to make a syllable.
class VowelSign {
  const VowelSign({required this.id, required this.mark, required this.name, required this.isLong});

  final String id;

  /// What is written after the letter: a short-vowel mark (ـَ ـِ ـُ)
  /// or a long-vowel letter (ا و ی).
  final String mark;

  /// How teachers name it (زبر، زیر، پیش، ...), for parents and voice notes.
  final String name;

  final bool isLong;
}

/// The six vowels of Persian, as taught in Grade 1.
const List<VowelSign> vowelSigns = [
  VowelSign(id: 'a', mark: 'َ', name: 'زبر (اَ)', isLong: false), // ـَ
  VowelSign(id: 'e', mark: 'ِ', name: 'زیر (اِ)', isLong: false), // ـِ
  VowelSign(id: 'o', mark: 'ُ', name: 'پیش (اُ)', isLong: false), // ـُ
  VowelSign(id: 'aa', mark: 'ا', name: 'آ', isLong: true),
  VowelSign(id: 'u', mark: 'و', name: 'او', isLong: true),
  VowelSign(id: 'i', mark: 'ی', name: 'ای', isLong: true),
];

/// A letter + vowel, e.g. ب + ـُ = بُ  or  ب + ا = با.
class Syllable {
  const Syllable(this.consonant, this.vowel);

  final PersianLetter consonant;
  final VowelSign vowel;

  String get id => '${consonant.id}_${vowel.id}';

  /// The written syllable. Flutter joins and shapes the letters correctly
  /// (for example ب + ی is drawn as بی).
  String get text => '${consonant.char}${vowel.mark}';

  String get audioKey => 'syllable_$id';
}

/// Every syllable the reading game can use, built from the taught letters.
List<Syllable> get allSyllables => [
      for (final c in syllableConsonants)
        for (final v in vowelSigns) Syllable(c, v),
    ];
