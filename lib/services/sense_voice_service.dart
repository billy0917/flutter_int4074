import 'dart:async';
import 'dart:isolate';
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

class _WorkerInitMessage {
  final SendPort replyPort;
  final String encoderPath;
  final String decoderPath;
  final String joinerPath;
  final String tokensPath;

  const _WorkerInitMessage({
    required this.replyPort,
    required this.encoderPath,
    required this.decoderPath,
    required this.joinerPath,
    required this.tokensPath,
  });
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

  StreamSubscription<Uint8List>? _audioSubscription;
  Completer<void>? _audioDoneCompleter;
  Completer<bool>? _initCompleter;
  Completer<String>? _finalResultCompleter;
  Completer<SendPort>? _workerReadyCompleter;
  ReceivePort? _workerReceivePort;
  SendPort? _workerSendPort;
  Isolate? _workerIsolate;

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

  Future<void> _ensureWorker(String modelPath) async {
    if (_workerSendPort != null) {
      return;
    }
    if (_workerReadyCompleter != null) {
      await _workerReadyCompleter!.future;
      return;
    }

    _workerReceivePort?.close();
    final receivePort = ReceivePort();
    _workerReceivePort = receivePort;
    _workerReceivePort!.listen(_handleWorkerMessage);
    _workerReadyCompleter = Completer<SendPort>();

    final encoderPath = '$modelPath/$_encoderFile';
    final decoderPath = '$modelPath/$_decoderFile';
    final joinerPath = '$modelPath/$_joinerFile';
    final tokensPath = '$modelPath/$_tokensFile';

    _workerIsolate = await Isolate.spawn<_WorkerInitMessage>(
      _sttWorkerMain,
      _WorkerInitMessage(
        replyPort: receivePort.sendPort,
        encoderPath: encoderPath,
        decoderPath: decoderPath,
        joinerPath: joinerPath,
        tokensPath: tokensPath,
      ),
      debugName: 'pinpin_stt_worker',
    );

    await _workerReadyCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('STT worker startup timed out'),
    );
  }

  void _handleWorkerMessage(dynamic message) {
    if (message is SendPort) {
      _workerSendPort = message;
      _workerReadyCompleter?.complete(message);
      return;
    }

    if (message is! Map) {
      return;
    }

    final type = message['type'];
    switch (type) {
      case 'init_ok':
        _isInitializing = false;
        _isModelReady = true;
        _initCompleter?.complete(true);
        _initCompleter = null;
        debugPrint('[StreamingSTT] Recognizer ready in worker isolate');
        break;
      case 'init_error':
        _isInitializing = false;
        _isModelReady = false;
        _initCompleter?.complete(false);
        _initCompleter = null;
        debugPrint('[StreamingSTT] Init error: ${message['error']}');
        break;
      case 'partial':
        final partial = (message['text'] as String?) ?? '';
        if (partial != _latestPartialText) {
          _latestPartialText = partial;
          _partialResultsController.add(partial);
        }
        break;
      case 'final':
        _finalResultCompleter?.complete((message['text'] as String?) ?? '');
        _finalResultCompleter = null;
        break;
      case 'stream_error':
        _finalResultCompleter?.completeError(
          StateError((message['error'] as String?) ?? 'Unknown STT error'),
        );
        _finalResultCompleter = null;
        break;
    }
  }

  Future<bool> init() async {
    if (_isModelReady && _workerSendPort != null) {
      return true;
    }
    if (_isInitializing) {
      return await _initCompleter?.future ?? false;
    }

    _initCompleter = Completer<bool>();
    _isInitializing = true;
    try {
      await _copyAssetsIfNeeded();

      final dir = await _getModelDir();
      await _ensureWorker(dir.path);
      _workerSendPort?.send(const {'type': 'init'});
      return await _initCompleter!.future;
    } catch (e) {
      debugPrint('[StreamingSTT] Init error: $e');
      _isModelReady = false;
      _isInitializing = false;
      _initCompleter?.complete(false);
      _initCompleter = null;
      _workerReadyCompleter = null;
      return false;
    }
  }

  Future<bool> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        debugPrint('[StreamingSTT] Microphone permission denied');
        return false;
      }

      if (!await init()) {
        return false;
      }

      await _audioSubscription?.cancel();

      _latestPartialText = '';
      _partialResultsController.add('');
      _workerSendPort?.send(const {'type': 'start_stream'});
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
    if (chunk.isEmpty || _workerSendPort == null) {
      return;
    }

    _workerSendPort!.send({
      'type': 'audio_chunk',
      'audio': TransferableTypedData.fromList([chunk]),
    });
  }

  Future<SttResult> stopAndTranscribe() async {
    if (!_isRecording || _workerSendPort == null) {
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

      _finalResultCompleter = Completer<String>();
      _workerSendPort!.send(const {'type': 'finish_stream'});
      final finalText = await _finalResultCompleter!.future;
      final text = finalText.isNotEmpty ? finalText : _latestPartialText;

      _isRecording = false;
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      _audioDoneCompleter = null;
      _latestPartialText = '';

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
      _latestPartialText = '';
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
    _latestPartialText = '';
    _workerSendPort?.send(const {'type': 'cancel_stream'});
  }

  Future<void> dispose() async {
    await cancel();
    await _partialResultsController.close();
    _recorder.dispose();
    _workerSendPort?.send(const {'type': 'dispose'});
    _workerSendPort = null;
    _workerReadyCompleter = null;
    _workerReceivePort?.close();
    _workerReceivePort = null;
    _workerIsolate?.kill(priority: Isolate.immediate);
    _workerIsolate = null;
    _isModelReady = false;
  }
}

void _sttWorkerMain(_WorkerInitMessage message) {
  sherpa.initBindings();

  sherpa.OnlineRecognizer? recognizer;
  sherpa.OnlineStream? stream;
  String latestPartialText = '';

  final commandPort = ReceivePort();
  message.replyPort.send(commandPort.sendPort);

  commandPort.listen((dynamic rawMessage) {
    if (rawMessage is! Map) {
      return;
    }

    final type = rawMessage['type'];

    try {
      switch (type) {
        case 'init':
          recognizer?.free();
          recognizer = sherpa.OnlineRecognizer(
            sherpa.OnlineRecognizerConfig(
              model: sherpa.OnlineModelConfig(
                transducer: sherpa.OnlineTransducerModelConfig(
                  encoder: message.encoderPath,
                  decoder: message.decoderPath,
                  joiner: message.joinerPath,
                ),
                tokens: message.tokensPath,
                numThreads: 2,
                debug: false,
                modelType: 'zipformer2',
              ),
              decodingMethod: 'greedy_search',
              enableEndpoint: false,
            ),
          );
          message.replyPort.send(const {'type': 'init_ok'});
          break;
        case 'start_stream':
          stream?.free();
          stream = recognizer?.createStream();
          latestPartialText = '';
          break;
        case 'audio_chunk':
          final recognizerRef = recognizer;
          final streamRef = stream;
          if (recognizerRef == null || streamRef == null) {
            break;
          }

          final audio = rawMessage['audio'] as TransferableTypedData;
          final bytes = audio.materialize().asUint8List();
          if (bytes.isEmpty) {
            break;
          }

          final sampleCount = bytes.length ~/ 2;
          final samples = Float32List(sampleCount);
          final byteData = ByteData.sublistView(bytes);
          for (var i = 0; i < sampleCount; i++) {
            samples[i] = byteData.getInt16(i * 2, Endian.little) / 32768.0;
          }

          streamRef.acceptWaveform(samples: samples, sampleRate: 16000);
          while (recognizerRef.isReady(streamRef)) {
            recognizerRef.decode(streamRef);
          }

          final partial = recognizerRef.getResult(streamRef).text.trim();
          if (partial != latestPartialText) {
            latestPartialText = partial;
            message.replyPort.send({'type': 'partial', 'text': partial});
          }
          break;
        case 'finish_stream':
          final recognizerRef = recognizer;
          final streamRef = stream;
          if (recognizerRef == null || streamRef == null) {
            message.replyPort.send(const {'type': 'final', 'text': ''});
            break;
          }

          streamRef.inputFinished();
          while (recognizerRef.isReady(streamRef)) {
            recognizerRef.decode(streamRef);
          }

          final finalText = recognizerRef.getResult(streamRef).text.trim();
          streamRef.free();
          stream = null;
          latestPartialText = '';
          message.replyPort.send({'type': 'final', 'text': finalText});
          break;
        case 'cancel_stream':
          stream?.free();
          stream = null;
          latestPartialText = '';
          break;
        case 'dispose':
          stream?.free();
          recognizer?.free();
          commandPort.close();
          break;
      }
    } catch (error) {
      final errorText = error.toString();
      if (type == 'init') {
        message.replyPort.send({'type': 'init_error', 'error': errorText});
      } else {
        message.replyPort.send({'type': 'stream_error', 'error': errorText});
      }
    }
  });
}
