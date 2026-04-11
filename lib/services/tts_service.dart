import 'package:flutter_tts/flutter_tts.dart';
import 'edge_tts_service.dart';

/// TTS service that uses Edge TTS (online) with flutter_tts as offline fallback.
class TtsService {
  final EdgeTtsService _edgeTts = EdgeTtsService();
  final FlutterTts _flutterTts = FlutterTts();
  double _speechRate = 0.5;
  bool _flutterTtsInitialized = false;

  Future<void> init() async {
    if (_flutterTtsInitialized) return;
    try {
      await _flutterTts.setLanguage('zh-CN');
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(1.1);
      await _flutterTts.setVolume(1.0);
      _flutterTtsInitialized = true;
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    // Try Edge TTS first (better voice quality)
    try {
      final ok = await _edgeTts.speak(text);
      if (ok) {
        // ignore: avoid_print
        print('[TTS] Edge TTS success for: $text');
        return;
      }
      // ignore: avoid_print
      print('[TTS] Edge TTS returned false, falling back to device TTS');
    } catch (e) {
      // ignore: avoid_print
      print('[TTS] Edge TTS error: $e, falling back to device TTS');
    }

    // Fallback to device TTS (offline)
    try {
      await init();
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try { await _edgeTts.stop(); } catch (_) {}
    try { await _flutterTts.stop(); } catch (_) {}
  }

  Future<void> setSpeed(double speed) async {
    _speechRate = speed;
    // Map 0.0–1.0 to edge-tts rate percentage
    final pct = ((speed - 0.5) * 100).round();
    _edgeTts.rate = '${pct >= 0 ? '+' : ''}$pct%';
    try {
      await _flutterTts.setSpeechRate(speed);
    } catch (_) {}
  }

  double get speechRate => _speechRate;

  Future<void> dispose() async {
    try { await _edgeTts.dispose(); } catch (_) {}
    try { await _flutterTts.stop(); } catch (_) {}
  }
}
