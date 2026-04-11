import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/recognition_result.dart';
import '../models/quiz_question.dart';

class ToneJudgmentResult {
  final bool isCorrect;
  final int detectedTone;
  final String feedbackZh;
  final String feedbackEn;

  ToneJudgmentResult({
    required this.isCorrect,
    required this.detectedTone,
    required this.feedbackZh,
    required this.feedbackEn,
  });

  factory ToneJudgmentResult.fromJson(Map<String, dynamic> json) {
    return ToneJudgmentResult(
      isCorrect: json['is_correct'] as bool? ?? false,
      detectedTone: json['detected_tone'] as int? ?? 0,
      feedbackZh: json['feedback_zh'] as String? ?? '',
      feedbackEn: json['feedback_en'] as String? ?? '',
    );
  }
}

class ApiService {
  static Future<RecognitionResult?> recognizeObject(
    File imageFile, {
    ModelPreset preset = ModelPreset.fast,
  }) async {
    final config = ApiConfig.getConfig(preset);
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      debugPrint('[API] Sending image (${(bytes.length / 1024).toStringAsFixed(1)} KB) to ${ApiConfig.baseUrl} model=${config.model}');

      final response = await http
          .post(
            Uri.parse(ApiConfig.baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode({
              'model': config.model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'Output only raw JSON. No markdown, no ```json, no explanation, no extra text. 辨識圖中主要物件，只返回純JSON，無其他文字。格式：{"object_name_zh":"蘋果","object_name_en":"Apple","pinyin":"píng guǒ","pinyin_no_tone":"ping guo","characters":[{"char":"蘋","pinyin":"píng","tone_number":2,"tone_name_zh":"第二聲（陽平）","tone_name_en":"2nd tone (rising)"}],"cantonese_reference":"蘋果 (ping4 gwo2)","example_sentence_zh":"我喜歡吃蘋果。","example_sentence_pinyin":"Wǒ xǐ huān chī píng guǒ.","example_sentence_en":"I like to eat apples."}'
                },
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'text',
                      'text': '辨識物件，返回JSON。'
                    },
                    {
                      'type': 'image_url',
                      'image_url': {
                        'url': 'data:image/jpeg;base64,$base64Image'
                      }
                    }
                  ]
                }
              ],
              'max_tokens': 500,
              'temperature': 0.3,
              'enable_thinking': false,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] Response status: ${response.statusCode}');
      debugPrint('[API] Response body: ${response.body.substring(0, response.body.length.clamp(0, 500))}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        var content =
            body['choices'][0]['message']['content'] as String? ?? '';
        content = _stripThinkTags(content);
        debugPrint('[API] Model reply: $content');
        final result = RecognitionResult.tryParseFromRawJson(content);
        if (result == null) {
          throw Exception('API 回應格式錯誤，無法解析 JSON。\n模型回覆：${content.substring(0, content.length.clamp(0, 200))}');
        }
        return result;
      } else {
        String detail = response.body;
        try {
          final errBody = jsonDecode(response.body) as Map<String, dynamic>;
          detail = errBody['error']?['message'] as String? ??
              errBody['message'] as String? ??
              response.body;
        } catch (_) {}
        throw Exception('HTTP ${response.statusCode}: $detail');
      }
    } on TimeoutException {
      debugPrint('[API] Request timed out after 30s');
      throw Exception('請求逾時（>30秒），請檢查網絡或稍後再試。');
    } on SocketException catch (e) {
      debugPrint('[API] Network error: $e');
      throw Exception('網絡連接失敗，請檢查網絡。\n($e)');
    } on http.ClientException catch (e) {
      debugPrint('[API] HTTP client error: $e');
      throw Exception('請求失敗：$e');
    } catch (e) {
      debugPrint('[API] recognizeObject error: $e');
      rethrow;
    }
  }

  static Future<List<QuizQuestion>?> generateQuiz(
    RecognitionResult result, {
    ModelPreset preset = ModelPreset.fast,
  }) async {
    final config = ApiConfig.getConfig(preset);
    try {
      final tonesDesc = result.characters
          .map((c) => '${c.char}=${c.toneNumber}聲')
          .join(', ');

      final response = await http
          .post(
            Uri.parse(ApiConfig.baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode({
              'model': config.model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'Output only raw JSON array. No markdown, no ```json, no explanation, no extra text. /no_think 只返回純JSON數組，無其他文字。生成5題：draw_tone×1, pick_pinyin×1, listen_pick_char×1, pick_tone×1, match_tone_shape×1。'
                      '格式：[{"type":"draw_tone","question_zh":"...","question_en":"...","target_char":"蘋","target_pinyin":"píng","correct_tone":2,"correct_description":"上升線","options":[],"correct_index":0},'
                      '{"type":"pick_pinyin","question_zh":"...","question_en":"...","options":[4個拼音],"correct_index":N},'
                      '{"type":"listen_pick_char","question_zh":"聽發音選詞","question_en":"Listen and pick","tts_text":"詞語","options":[4個詞],"correct_index":N},'
                      '{"type":"pick_tone","question_zh":"...","question_en":"...","options":["第一聲","第二聲","第三聲","第四聲"],"correct_index":N},'
                      '{"type":"match_tone_shape","question_zh":"...","question_en":"...","options":["flat_high","rising","dipping","falling"],"option_labels_zh":["→ 平線","↗ 上升","↘↗ 先降後升","↘ 下降"],"option_labels_en":["→ Flat","↗ Rising","↘↗ Dipping","↘ Falling"],"correct_index":N}]'
                },
                {
                  'role': 'user',
                  'content':
                      '${result.objectNameZh}（${result.pinyin}），聲調：$tonesDesc'
                }
              ],
              'max_tokens': 800,
              'temperature': 0.3,
              'enable_thinking': false,
            }),
          )
          .timeout(Duration(seconds: preset == ModelPreset.stable ? 120 : 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        var content =
            body['choices'][0]['message']['content'] as String? ?? '';
        content = _stripThinkTags(content);
        return QuizQuestion.tryParseListFromRaw(content);
      }
    } catch (e) {
      debugPrint('generateQuiz error: $e');
    }
    return null;
  }

  /// Local tone judgment — no API call needed.
  static ToneJudgmentResult? judgeToneDrawing({
    required int targetTone,
    required List<Offset> strokePoints,
    required Size canvasSize,
    ModelPreset preset = ModelPreset.fast,
  }) {
    if (strokePoints.length < 3) return null;

    final normalized = strokePoints
        .map((p) => Offset(
              p.dx / canvasSize.width,
              1.0 - (p.dy / canvasSize.height), // y: 0=bottom, 1=top
            ))
        .toList();

    final start = normalized.first;
    final end = normalized.last;
    final dy = end.dy - start.dy;

    double minY = 1.0;
    int minIdx = 0;
    for (int i = 0; i < normalized.length; i++) {
      if (normalized[i].dy < minY) {
        minY = normalized[i].dy;
        minIdx = i;
      }
    }
    final minPos = minIdx / (normalized.length - 1); // 0‑1

    // Detect tone from stroke shape
    int detected;
    // V-shape check first (tone 3): dip in the middle
    if (minPos > 0.15 &&
        minPos < 0.85 &&
        (start.dy - minY) > 0.08 &&
        (end.dy - minY) > 0.08) {
      detected = 3;
    } else if (dy > 0.10) {
      detected = 2; // rising
    } else if (dy < -0.10) {
      detected = 4; // falling
    } else {
      detected = 1; // flat
    }

    final isCorrect = detected == targetTone;
    const zhNames = {1: '高平線', 2: '上升線', 3: '先降後升', 4: '下降線'};
    const enNames = {1: 'flat', 2: 'rising', 3: 'dipping', 4: 'falling'};

    return ToneJudgmentResult(
      isCorrect: isCorrect,
      detectedTone: detected,
      feedbackZh: isCorrect ? '正確！' : '看起來像${zhNames[detected]}',
      feedbackEn: isCorrect ? 'Correct!' : 'Looks ${enNames[detected]}',
    );
  }

  /// Strip Qwen3 <think>...</think> reasoning tokens from response.
  static String _stripThinkTags(String text) {
    return text.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '').trim();
  }
}