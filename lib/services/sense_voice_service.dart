import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class SttResult {
  final String text;
  final bool success;
  final String? error;
  final String detectedLanguage;

  const SttResult({
    required this.text,
    this.success = true,
    this.error,
    this.detectedLanguage = 'zh',
  });

  const SttResult.failure(String message)
      : text = '',
        success = false,
        error = message,
        detectedLanguage = '';
}

/// Real-time Mandarin STT using a Chinese-only streaming Zipformer model.
///
/// Model files are bundled in the APK under assets/streaming_zh_model/
/// and copied to the app's documents directory on first use.
class SenseVoiceService {
  // ── Singleton ──
  static final SenseVoiceService instance = SenseVoiceService._();
  SenseVoiceService._();

  static const _modelDir = 'streaming_zh_asr_2025';
  static const _assetPrefix = 'assets/streaming_zh_model';

  static const _encoderFile = 'encoder.int8.onnx';
  static const _decoderFile = 'decoder.onnx';
  static const _joinerFile = 'joiner.int8.onnx';
  static const _tokensFile = 'tokens.txt';
  static const _sampleRate = 16000;

  static const _requiredFiles = [
    _encoderFile,
    _decoderFile,
    _joinerFile,
    _tokensFile,
  ];

  final AudioRecorder _recorder = AudioRecorder();
  final StreamController<String> _partialResultsController =
      StreamController<String>.broadcast();

  sherpa.OnlineRecognizer? _recognizer;
  sherpa.OnlineStream? _onlineStream;
  StreamSubscription<Uint8List>? _audioSubscription;
  Completer<void>? _audioDoneCompleter;

  bool _isRecording = false;
  bool _isModelReady = false;
  bool _isInitializing = false;
  String _latestPartialText = '';

  bool get isRecording => _isRecording;
  bool get isModelReady => _isModelReady;
  bool get isInitializing => _isInitializing;
  Stream<String> get partialResults => _partialResultsController.stream;

  Future<Directory> _getModelDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_modelDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Check whether model files have already been copied to the documents dir.
  Future<bool> isModelCopied() async {
    final dir = await _getModelDir();
    for (final name in _requiredFiles) {
      final file = File('${dir.path}/$name');
      if (!await file.exists()) return false;
    }
    return true;
  }

  /// Copy bundled model assets to the documents directory (once).
  Future<void> _copyAssetsIfNeeded() async {
    final dir = await _getModelDir();
    for (final name in _requiredFiles) {
      final outFile = File('${dir.path}/$name');
      if (await outFile.exists()) continue;
      debugPrint('[StreamingSTT] Copying asset $name ...');
      final data = await rootBundle.load('$_assetPrefix/$name');
      await outFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
  }

  Future<bool> init() async {
    if (_isModelReady && _recognizer != null) {
      return true;
    }
    if (_isInitializing) {
      return false;
    }

    _isInitializing = true;
    try {
      await _copyAssetsIfNeeded();

      final dir = await _getModelDir();
      sherpa.initBindings();

      _recognizer?.free();
      _recognizer = sherpa.OnlineRecognizer(
        sherpa.OnlineRecognizerConfig(
          model: sherpa.OnlineModelConfig(
            transducer: sherpa.OnlineTransducerModelConfig(
              encoder: '${dir.path}/$_encoderFile',
              decoder: '${dir.path}/$_decoderFile',
              joiner: '${dir.path}/$_joinerFile',
            ),
            tokens: '${dir.path}/$_tokensFile',
            numThreads: 2,
            debug: false,
            modelType: 'zipformer2',
          ),
          decodingMethod: 'greedy_search',
          enableEndpoint: false,
        ),
      );

      _isModelReady = true;
      _isInitializing = false;
      debugPrint('[StreamingSTT] Recognizer ready');
      return true;
    } catch (e) {
      debugPrint('[StreamingSTT] Init error: $e');
      _isModelReady = false;
      _isInitializing = false;
      return false;
    }
  }

  Future<bool> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        debugPrint('[StreamingSTT] Microphone permission denied');
        return false;
      }

      if (_recognizer == null && !await init()) {
        return false;
      }

      await _audioSubscription?.cancel();
      _resetLiveStream();

      _latestPartialText = '';
      _partialResultsController.add('');
      _onlineStream = _recognizer!.createStream();
      _audioDoneCompleter = Completer<void>();

      final audioStream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );

      _audioSubscription = audioStream.listen(
        _handleAudioChunk,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[StreamingSTT] Audio stream error: $error');
          if (!(_audioDoneCompleter?.isCompleted ?? true)) {
            _audioDoneCompleter!.completeError(error, stackTrace);
          }
        },
        onDone: () {
          if (!(_audioDoneCompleter?.isCompleted ?? true)) {
            _audioDoneCompleter!.complete();
          }
        },
        cancelOnError: false,
      );

      _isRecording = true;
      return true;
    } catch (e) {
      debugPrint('[StreamingSTT] Start error: $e');
      _isRecording = false;
      return false;
    }
  }

  void _handleAudioChunk(Uint8List chunk) {
    final recognizer = _recognizer;
    final stream = _onlineStream;
    if (recognizer == null || stream == null || chunk.isEmpty) {
      return;
    }

    final samples = _pcm16ToFloat32(chunk);
    if (samples.isEmpty) {
      return;
    }

    stream.acceptWaveform(samples: samples, sampleRate: _sampleRate);

    while (recognizer.isReady(stream)) {
      recognizer.decode(stream);
    }

    final partial = recognizer.getResult(stream).text.trim();
    if (partial != _latestPartialText) {
      _latestPartialText = partial;
      _partialResultsController.add(partial);
    }
  }

  Float32List _pcm16ToFloat32(Uint8List bytes) {
    final sampleCount = bytes.length ~/ 2;
    final samples = Float32List(sampleCount);
    final byteData = ByteData.sublistView(bytes);

    for (var i = 0; i < sampleCount; i++) {
      samples[i] = byteData.getInt16(i * 2, Endian.little) / 32768.0;
    }

    return samples;
  }

  Future<SttResult> stopAndTranscribe() async {
    final recognizer = _recognizer;
    final stream = _onlineStream;
    if (!_isRecording || recognizer == null || stream == null) {
      return const SttResult.failure('Not recording');
    }

    try {
      await _recorder.stop().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Stopping audio recording timed out'),
      );

      final audioDone = _audioDoneCompleter;
      if (audioDone != null) {
        await audioDone.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
      }

      stream.inputFinished();
      while (recognizer.isReady(stream)) {
        recognizer.decode(stream);
      }

      final finalText = recognizer.getResult(stream).text.trim();
      final text = finalText.isNotEmpty ? finalText : _latestPartialText;

      _isRecording = false;
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      _audioDoneCompleter = null;
      _resetLiveStream();

      if (text.isEmpty) {
        return const SttResult.failure('No speech detected');
      }

      return SttResult(text: text, detectedLanguage: 'zh');
    } catch (e) {
      debugPrint('[StreamingSTT] Stop error: $e');
      _isRecording = false;
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      _audioDoneCompleter = null;
      _resetLiveStream();
      return SttResult.failure(e.toString());
    }
  }

  Future<void> cancel() async {
    try {
      if (_isRecording) {
        await _recorder.cancel();
      }
    } catch (_) {}

    _isRecording = false;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    _audioDoneCompleter = null;
    _resetLiveStream();
  }

  void _resetLiveStream() {
    _onlineStream?.free();
    _onlineStream = null;
    _latestPartialText = '';
  }

  Future<void> dispose() async {
    await cancel();
    await _partialResultsController.close();
    _recorder.dispose();
    _recognizer?.free();
    _recognizer = null;
    _isModelReady = false;
  }
}
