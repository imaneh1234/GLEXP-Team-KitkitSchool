import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'package:flutter_tts/flutter_tts.dart';

import '../data/voice_script.dart';

/// Plays the app's voice and sound effects. Everything works offline.
///
/// Order of preference for a voice line:
///   1. A real recording in assets/audio/ (best: a native-speaking voice artist).
///   2. The device's built-in Persian text-to-speech voice (fa-IR), if present.
///   3. Silence. Every activity can still be done from the pictures alone.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  static const _extensions = ['mp3', 'm4a', 'wav'];

  /// Set to false in tests, where no audio hardware exists.
  static bool enabled = true;

  AudioPlayer? _voice;
  AudioPlayer? _effects;
  FlutterTts? _tts;
  Set<String>? _bundledAssets;
  bool _initialised = false;

  Future<void> _init() async {
    if (_initialised) return;
    _initialised = true;
    _voice = AudioPlayer();
    _effects = AudioPlayer();
    try {
      final tts = FlutterTts();
      await tts.setLanguage('fa-IR');
      await tts.setSpeechRate(0.42); // slower, for young listeners
      await tts.setPitch(1.05);
      _tts = tts;
    } catch (_) {
      _tts = null; // No Persian voice on this device; stay silent.
    }
  }

  /// Looks up the recording for [key] in the list of files bundled with
  /// the app, so missing recordings are skipped without any error.
  Future<String?> _findRecording(String key) async {
    _bundledAssets ??= await AssetManifest.loadFromAssetBundle(rootBundle)
        .then((m) => m.listAssets().toSet())
        .catchError((Object _) => <String>{});
    for (final ext in _extensions) {
      if (_bundledAssets!.contains('assets/audio/$key.$ext')) return 'audio/$key.$ext';
    }
    return null;
  }

  /// Speaks a line from the voice script.
  Future<void> say(VoiceLine line) async {
    if (!enabled) return;
    try {
      await _init();
      await stopVoice();
      final recording = await _findRecording(line.key);
      if (recording != null) {
        await _voice!.play(AssetSource(recording));
      } else {
        await _tts?.speak(line.text);
      }
    } catch (_) {
      // Audio must never crash a child's game.
    }
  }

  Future<void> stopVoice() async {
    try {
      await _voice?.stop();
      await _tts?.stop();
    } catch (_) {}
  }

  Future<void> _effect(String name) async {
    if (!enabled) return;
    try {
      await _init();
      await _effects!.play(AssetSource('audio/$name.wav'));
    } catch (_) {}
  }

  Future<void> correct() => _effect('sfx_correct');
  Future<void> tryAgain() => _effect('sfx_try_again');
  Future<void> tap() => _effect('sfx_tap');
}
