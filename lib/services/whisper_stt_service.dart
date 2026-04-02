import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../config/api_config.dart';

/// Result from Whisper STT transcription.
class WhisperResult {
  final String text;
  final bool success;
  final String? error;

  const WhisperResult({
    required this.text,
    this.success = true,
    this.error,
  });

  const WhisperResult.failure(String message)
      : text = '',
        success = false,
        error = message;
}

/// Service that records audio and sends it to OpenAI Whisper API
/// via the same API gateway the app already uses.
class WhisperSttService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _filePath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// Start recording audio (m4a format, suitable for Whisper).
  Future<bool> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        debugPrint('[WhisperSTT] Microphone permission denied');
        return false;
      }

      final dir = await getTemporaryDirectory();
      _filePath =
          '${dir.path}/stt_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 64000,
        ),
        path: _filePath!,
      );
      _isRecording = true;
      debugPrint('[WhisperSTT] Recording started → $_filePath');
      return true;
    } catch (e) {
      debugPrint('[WhisperSTT] Start recording error: $e');
      _isRecording = false;
      return false;
    }
  }

  /// Stop recording and send audio to Whisper API for transcription.
  Future<WhisperResult> stopAndTranscribe() async {
    if (!_isRecording || _filePath == null) {
      return const WhisperResult.failure('Not recording');
    }

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      debugPrint('[WhisperSTT] Recording stopped → $path');

      final filePath = path ?? _filePath!;
      final file = File(filePath);
      if (!await file.exists()) {
        return const WhisperResult.failure('Recording file not found');
      }

      final fileSize = await file.length();
      debugPrint('[WhisperSTT] File size: ${(fileSize / 1024).toStringAsFixed(1)} KB');

      if (fileSize < 1000) {
        // Too small — likely silence
        return const WhisperResult.failure('Recording too short');
      }

      return await _transcribeWithWhisper(file);
    } catch (e) {
      _isRecording = false;
      debugPrint('[WhisperSTT] Stop error: $e');
      return WhisperResult.failure(e.toString());
    }
  }

  /// Cancel recording without transcription.
  Future<void> cancel() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
      }
    } catch (_) {}
    _isRecording = false;
    _cleanupFile();
  }

  /// Send audio file to OpenAI-compatible Whisper endpoint.
  Future<WhisperResult> _transcribeWithWhisper(File audioFile) async {
    try {
      // The API gateway base is `.../v1/chat/completions`,
      // Whisper endpoint is at `.../v1/audio/transcriptions`
      final baseUri = Uri.parse(ApiConfig.baseUrl);
      final whisperUrl = baseUri.replace(
        pathSegments: [
          ...baseUri.pathSegments
              .take(baseUri.pathSegments.length - 2), // keep /v1
          'audio',
          'transcriptions',
        ],
      );

      debugPrint('[WhisperSTT] Sending to $whisperUrl');

      final request = http.MultipartRequest('POST', whisperUrl);
      request.headers['Authorization'] = 'Bearer ${ApiConfig.apiKey}';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'zh';
      request.fields['response_format'] = 'json';
      request.files.add(
        await http.MultipartFile.fromPath('file', audioFile.path),
      );

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('[WhisperSTT] Response ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final text = (json['text'] as String? ?? '').trim();
        _cleanupFile();
        if (text.isEmpty) {
          return const WhisperResult.failure('No speech detected');
        }
        return WhisperResult(text: text);
      } else {
        _cleanupFile();
        return WhisperResult.failure(
            'API error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[WhisperSTT] Transcription error: $e');
      _cleanupFile();
      return WhisperResult.failure(e.toString());
    }
  }

  void _cleanupFile() {
    if (_filePath != null) {
      try {
        File(_filePath!).deleteSync();
      } catch (_) {}
      _filePath = null;
    }
  }

  Future<void> dispose() async {
    await cancel();
    _recorder.dispose();
  }
}
