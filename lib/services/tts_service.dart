import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Offline Chinese TTS using sherpa-onnx VITS (aishell3 model).
///
/// Model files are bundled as Flutter assets and copied to the app's
/// documents directory on first use – identical to the STT service pattern.
class TtsService {
  // ── Singleton ──
  static final TtsService instance = TtsService._internal();
  factory TtsService() => instance;
  TtsService._internal();

  static const _modelDir = 'tts_zh_vits_aishell3';
  static const _assetPrefix = 'assets/tts_zh_model';

  static const _modelFile = 'model.onnx';
  static const _lexiconFile = 'lexicon.txt';
  static const _tokensFile = 'tokens.txt';

  static const _requiredFiles = [_modelFile, _lexiconFile, _tokensFile];

  AudioPlayer? _player;
  static bool _bindingsInitialized = false;

  String? _modelDirPath; // cached after first copy
  bool _isModelReady = false;
  bool _isInitializing = false;
  Completer<bool>? _initCompleter;
  double _speechRate = 1.0; // sherpa speed (1.0 = normal)
  final int _speakerId = 0;

  bool get isModelReady => _isModelReady;
  bool get isInitializing => _isInitializing;
  double get speechRate => _speechRate;

  AudioPlayer _ensurePlayer() => _player ??= AudioPlayer();

  // ── Asset helpers ──

  Future<Directory> _getModelDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_modelDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _copyAssetsIfNeeded() async {
    final dir = await _getModelDir();
    _modelDirPath = dir.path;
    for (final name in _requiredFiles) {
      final outFile = File('${dir.path}/$name');
      if (await outFile.exists()) continue;
      debugPrint('[OfflineTTS] Copying asset $name ...');
      final data = await rootBundle.load('$_assetPrefix/$name');
      await outFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
  }

  // ── Lifecycle ──

  /// Initialise the TTS engine. Returns `true` when the model is ready.
  ///
  /// Uses the same Completer-based pattern as [SenseVoiceService.init()] so
  /// that concurrent callers all await the same initialisation future instead
  /// of silently returning.
  Future<bool> init() async {
    if (_isModelReady) return true;
    if (_isInitializing) {
      // Another caller is already initialising – wait for it.
      return await _initCompleter?.future ?? false;
    }

    _initCompleter = Completer<bool>();
    _isInitializing = true;

    try {
      // 1. Initialize native bindings (once per process).
      if (!_bindingsInitialized) {
        sherpa.initBindings();
        _bindingsInitialized = true;
        debugPrint('[OfflineTTS] Native bindings initialized');
      }

      // 2. Copy model assets to documents directory.
      await _copyAssetsIfNeeded();

      // 3. Verify model files exist via background isolate.
      final dirPath = _modelDirPath!;
      _isModelReady = await compute(_initTtsEngine, dirPath);

      if (_isModelReady) {
        debugPrint('[OfflineTTS] Engine ready');
      }

      _initCompleter?.complete(_isModelReady);
      return _isModelReady;
    } catch (e) {
      debugPrint('[OfflineTTS] Init error: $e');
      _isModelReady = false;
      _initCompleter?.complete(false);
      return false;
    } finally {
      _isInitializing = false;
      _initCompleter = null;
    }
  }

  /// Top-level function that can run in compute(). We just verify model
  /// files exist; the actual engine is created lazily on first `speak()`.
  static bool _initTtsEngine(String dirPath) {
    final modelFile = File('$dirPath/$_modelFile');
    final lexiconFile = File('$dirPath/$_lexiconFile');
    final tokensFile = File('$dirPath/$_tokensFile');
    return modelFile.existsSync() &&
        lexiconFile.existsSync() &&
        tokensFile.existsSync();
  }

  /// Lazily create the sherpa OfflineTts engine (main isolate).
  sherpa.OfflineTts? _tts;
  sherpa.OfflineTts _ensureTtsEngine() {
    if (_tts != null) return _tts!;

    final dirPath = _modelDirPath!;
    final vitsConfig = sherpa.OfflineTtsVitsModelConfig(
      model: '$dirPath/$_modelFile',
      lexicon: '$dirPath/$_lexiconFile',
      tokens: '$dirPath/$_tokensFile',
    );

    final modelConfig = sherpa.OfflineTtsModelConfig(
      vits: vitsConfig,
      numThreads: 2,
      debug: false,
    );

    final config = sherpa.OfflineTtsConfig(model: modelConfig);
    _tts = sherpa.OfflineTts(config);
    debugPrint(
      '[OfflineTTS] Engine created – sampleRate=${_tts!.sampleRate}, '
      'speakers=${_tts!.numSpeakers}',
    );
    return _tts!;
  }

  Future<void> speak(String text) async {
    try {
      if (!await init()) {
        debugPrint('[OfflineTTS] speak() aborted – model not ready');
        return;
      }

      final player = _ensurePlayer();
      await player.stop();

      final tts = _ensureTtsEngine();
      final audio = tts.generate(
        text: text,
        sid: _speakerId,
        speed: _speechRate,
      );

      if (audio.samples.isEmpty) {
        debugPrint('[OfflineTTS] generate() returned empty samples');
        return;
      }

      debugPrint(
        '[OfflineTTS] Generated ${audio.samples.length} samples '
        '@ ${audio.sampleRate} Hz',
      );

      final wavBytes = _float32ToWav(audio.samples, audio.sampleRate);

      // Write to a temp file – more reliable on Android than BytesSource.
      final tempDir = await getTemporaryDirectory();
      final wavFile = File('${tempDir.path}/tts_output.wav');
      await wavFile.writeAsBytes(wavBytes, flush: true);
      await player.play(DeviceFileSource(wavFile.path));
    } catch (e) {
      debugPrint('[OfflineTTS] Speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
  }

  Future<void> setSpeed(double speed) async {
    // Map the 0.0–1.0 flutter_tts range to sherpa speed (higher = faster).
    // flutter_tts default was 0.5; sherpa default is 1.0.
    // Simple linear mapping: sherpa_speed = 0.5 + speed
    _speechRate = 0.5 + speed;
  }

  /// Singleton – only stop playback, never destroy the engine.
  /// The engine stays alive for the app's lifetime.
  Future<void> dispose() async {
    try {
      await _player?.stop();
    } catch (_) {}
  }

  // ── WAV encoding ──

  /// Convert Float32List samples to a 16-bit PCM WAV byte buffer.
  static Uint8List _float32ToWav(Float32List samples, int sampleRate) {
    final numSamples = samples.length;
    final dataSize = numSamples * 2; // 16-bit = 2 bytes per sample
    final fileSize = 44 + dataSize;

    final buffer = ByteData(fileSize);

    // RIFF header
    buffer.setUint8(0, 0x52); // R
    buffer.setUint8(1, 0x49); // I
    buffer.setUint8(2, 0x46); // F
    buffer.setUint8(3, 0x46); // F
    buffer.setUint32(4, fileSize - 8, Endian.little);
    buffer.setUint8(8, 0x57); // W
    buffer.setUint8(9, 0x41); // A
    buffer.setUint8(10, 0x56); // V
    buffer.setUint8(11, 0x45); // E

    // fmt sub-chunk
    buffer.setUint8(12, 0x66); // f
    buffer.setUint8(13, 0x6D); // m
    buffer.setUint8(14, 0x74); // t
    buffer.setUint8(15, 0x20); // (space)
    buffer.setUint32(16, 16, Endian.little); // sub-chunk size
    buffer.setUint16(20, 1, Endian.little); // PCM format
    buffer.setUint16(22, 1, Endian.little); // mono
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    buffer.setUint16(32, 2, Endian.little); // block align
    buffer.setUint16(34, 16, Endian.little); // bits per sample

    // data sub-chunk
    buffer.setUint8(36, 0x64); // d
    buffer.setUint8(37, 0x61); // a
    buffer.setUint8(38, 0x74); // t
    buffer.setUint8(39, 0x61); // a
    buffer.setUint32(40, dataSize, Endian.little);

    // Convert float samples [-1.0, 1.0] → 16-bit signed integers.
    for (int i = 0; i < numSamples; i++) {
      final clamped = samples[i].clamp(-1.0, 1.0);
      final int16 = (clamped * 32767).round();
      buffer.setInt16(44 + i * 2, int16, Endian.little);
    }

    return buffer.buffer.asUint8List();
  }
}
