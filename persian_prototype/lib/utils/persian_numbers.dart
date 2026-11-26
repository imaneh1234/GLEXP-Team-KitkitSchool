/// Helpers for showing numbers the way Iranian children see them in school.
///
/// Persian digits (۰–۹) are different characters from the Western digits
/// (0–9) that computers use internally. Note that ۴ ۵ ۶ also look different
/// from the Arabic-Indic forms (٤ ٥ ٦), so we must use the Persian code points.
library;

const List<String> persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// Converts any Western digits in [value] into Persian digits.
/// Example: toPersianDigits(25) == '۲۵'
String toPersianDigits(Object value) {
  final buffer = StringBuffer();
  for (final rune in value.toString().runes) {
    final char = String.fromCharCode(rune);
    final digit = int.tryParse(char);
    buffer.write(digit == null ? char : persianDigits[digit]);
  }
  return buffer.toString();
}

/// Spoken / written Persian number words for the numbers used in the prototype.
const Map<int, String> persianNumberWords = {
  1: 'یک',
  2: 'دو',
  3: 'سه',
  4: 'چهار',
  5: 'پنج',
  6: 'شش',
  7: 'هفت',
  8: 'هشت',
  9: 'نه',
  10: 'ده',
};
