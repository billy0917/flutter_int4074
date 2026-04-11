import 'package:audioplayers/audioplayers.dart';

/// Plays pre-generated edge-tts audio files for phrase categories.
class PhraseAudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Play the audio file for [categoryId] phrase at [index].
  /// Returns false if the asset doesn't exist or playback fails.
  Future<bool> play(String categoryId, int index) async {
    try {
      await _player.stop();
      final asset = 'assets/audio/phrases/${categoryId}_$index.mp3';
      await _player.play(AssetSource(asset.replaceFirst('assets/', '')));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
