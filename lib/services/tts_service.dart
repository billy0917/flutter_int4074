import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  double _speechRate = 0.5;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(1.1);
      await _tts.setVolume(1.0);
      _initialized = true;
    } catch (_) {
      // TTS not available
    }
  }

  Future<void> speak(String text) async {
    try {
      await init();
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> setSpeed(double speed) async {
    _speechRate = speed;
    try {
      await _tts.setSpeechRate(speed);
    } catch (_) {}
  }

  double get speechRate => _speechRate;

  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
