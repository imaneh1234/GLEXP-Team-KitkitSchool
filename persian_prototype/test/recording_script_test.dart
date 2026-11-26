import 'dart:io';

import 'package:farsi_play_learn/data/voice_script.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keeps docs/RECORDING_SCRIPT.md (the voice artist's checklist)
/// in step with the app. To regenerate it after changing the voice script:
///   UPDATE_RECORDING_SCRIPT=1 flutter test test/recording_script_test.dart
void main() {
  const path = 'docs/RECORDING_SCRIPT.md';

  String render() {
    final b = StringBuffer()
      ..writeln('# Recording script — فهرست ضبط صدا')
      ..writeln()
      ..writeln('_Generated from `lib/data/voice_script.dart`. Do not edit by hand._')
      ..writeln()
      ..writeln('How to deliver recordings:')
      ..writeln()
      ..writeln('- One file per line below, named exactly as the **File** column, '
          'saved in `assets/audio/` (`.mp3`, `.m4a` or `.wav`).')
      ..writeln('- Native Persian speaker, standard (Tehran) pronunciation, warm and '
          'unhurried, as if speaking to a 5-year-old.')
      ..writeln('- Quiet room, no music, about 0.3 s of silence before and after.')
      ..writeln('- The app plays a recording automatically as soon as the file exists; '
          'until then it uses the device\'s Persian text-to-speech voice, if any.')
      ..writeln()
      ..writeln('| File | Persian text | Direction |')
      ..writeln('|---|---|---|');
    for (final line in VoiceScript.all) {
      b.writeln('| `${line.key}.mp3` | ${line.text} | ${line.note} |');
    }
    return b.toString();
  }

  test('recording script is up to date', () {
    final expected = render();
    if (Platform.environment['UPDATE_RECORDING_SCRIPT'] == '1') {
      File(path).writeAsStringSync(expected);
    }
    expect(File(path).readAsStringSync(), expected,
        reason: 'Run: UPDATE_RECORDING_SCRIPT=1 flutter test test/recording_script_test.dart');
  });
}
