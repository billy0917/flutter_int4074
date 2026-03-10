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
  static Future<RecognitionResult?> recognizeObject(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      debugPrint('[API] Sending image (${(bytes.length / 1024).toStringAsFixed(1)} KB) to ${ApiConfig.baseUrl}');

      final response = await http
          .post(
            Uri.parse(ApiConfig.baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiConfig.apiKey}',
            },
            body: jsonEncode({
              'model': ApiConfig.model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '你是一個兒童普通話教學助手。用戶會發送一張圖片，請你：\n1. 辨識圖片中最主要的物件\n2. 返回以下 JSON 格式（不要返回其他任何文字，只返回純 JSON）：\n\n{\n  "object_name_zh": "蘋果",\n  "object_name_en": "Apple",\n  "pinyin": "píng guǒ",\n  "pinyin_no_tone": "ping guo",\n  "characters": [\n    {\n      "char": "蘋",\n      "pinyin": "píng",\n      "tone_number": 2,\n      "tone_name_zh": "第二聲（陽平）",\n      "tone_name_en": "2nd tone (rising)"\n    },\n    {\n      "char": "果",\n      "pinyin": "guǒ",\n      "tone_number": 3,\n      "tone_name_zh": "第三聲（上聲）",\n      "tone_name_en": "3rd tone (dipping)"\n    }\n  ],\n  "cantonese_reference": "蘋果 (ping4 gwo2)",\n  "example_sentence_zh": "我喜歡吃蘋果。",\n  "example_sentence_pinyin": "Wǒ xǐ huān chī píng guǒ.",\n  "example_sentence_en": "I like to eat apples."\n}'
                },
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'text',
                      'text': '請辨識這張圖片中的物件，並按要求的 JSON 格式返回結果。'
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
              'max_tokens': 1000,
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[API] Response status: ${response.statusCode}');
      debugPrint('[API] Response body: ${response.body.substring(0, response.body.length.clamp(0, 500))}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            body['choices'][0]['message']['content'] as String? ?? '';
        debugPrint('[API] Model reply: $content');
        final result = RecognitionResult.tryParseFromRawJson(content);
        if (result == null) {
          throw Exception('API 回應格式錯誤，無法解析 JSON。\n模型回覆：${content.substring(0, content.length.clamp(0, 200))}');
        }
        return result;
      } else {
        // Extract error message from API response if available
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
      RecognitionResult result) async {
    try {
      final tonesDesc = result.characters
          .map((c) => '${c.char}=${c.toneNumber}聲')
          .join(', ');

      final response = await http
          .post(
            Uri.parse(ApiConfig.baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiConfig.apiKey}',
            },
            body: jsonEncode({
              'model': ApiConfig.model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '你是一個兒童普通話測驗生成器。根據提供的詞語信息，生成 5 道測驗題。\n\n題目類型必須包含以下混合組合：\n- 1 題「畫聲調」題（draw_tone）\n- 1 題「看圖選拼音」（pick_pinyin）\n- 1 題「聽音選字」（listen_pick_char）\n- 1 題「選擇聲調」（pick_tone）\n- 1 題「聲調走勢配對」（match_tone_shape）\n\n返回純 JSON 數組格式（不含任何其他文字）：\n[\n  {\n    "type": "draw_tone",\n    "question_zh": "請畫出「蘋」(píng) 的聲調走勢",\n    "question_en": "Draw the tone contour for \'蘋\' (píng)",\n    "target_char": "蘋",\n    "target_pinyin": "píng",\n    "correct_tone": 2,\n    "correct_description": "從左下到右上的上升線",\n    "options": [],\n    "correct_index": 0\n  },\n  {\n    "type": "pick_pinyin",\n    "question_zh": "「蘋果」的正確拼音是？",\n    "question_en": "What is the correct pinyin for \'蘋果\'?",\n    "options": ["píng guǒ", "pín guǒ", "píng guó", "péng guǒ"],\n    "correct_index": 0\n  },\n  {\n    "type": "listen_pick_char",\n    "question_zh": "聽發音，選出正確的詞語",\n    "question_en": "Listen and pick the correct word",\n    "tts_text": "蘋果",\n    "options": ["蘋果", "平果", "瓶蓋", "評估"],\n    "correct_index": 0\n  },\n  {\n    "type": "pick_tone",\n    "question_zh": "「píng」是第幾聲？",\n    "question_en": "What tone is \'píng\'?",\n    "options": ["第一聲", "第二聲", "第三聲", "第四聲"],\n    "correct_index": 1\n  },\n  {\n    "type": "match_tone_shape",\n    "question_zh": "以下哪個走勢代表第二聲？",\n    "question_en": "Which contour represents the 2nd tone?",\n    "options": ["flat_high", "rising", "dipping", "falling"],\n    "option_labels_zh": ["→ 平線", "↗ 上升", "↘↗ 先降後升", "↘ 下降"],\n    "option_labels_en": ["→ Flat", "↗ Rising", "↘↗ Dipping", "↘ Falling"],\n    "correct_index": 1\n  }\n]'
                },
                {
                  'role': 'user',
                  'content':
                      '詞語：${result.objectNameZh}（${result.pinyin}），各字聲調：$tonesDesc。請生成 5 道測驗題。'
                }
              ],
              'max_tokens': 2000,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            body['choices'][0]['message']['content'] as String? ?? '';
        return QuizQuestion.tryParseListFromRaw(content);
      }
    } catch (e) {
      debugPrint('generateQuiz error: $e');
    }
    return null;
  }

  static Future<ToneJudgmentResult?> judgeToneDrawing({
    required int targetTone,
    required List<Offset> strokePoints,
    required Size canvasSize,
  }) async {
    try {
      final description = _describeStroke(strokePoints, canvasSize);

      final response = await http
          .post(
            Uri.parse(ApiConfig.baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiConfig.apiKey}',
            },
            body: jsonEncode({
              'model': ApiConfig.model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '你是一個聲調走勢判斷器。用戶在畫布上畫了一條線來表示普通話聲調走勢。\n\n聲調走勢規則：\n- 第一聲（陰平）：高而平的水平線，起點和終點高度接近，都在偏上方\n- 第二聲（陽平）：從中低位上升到高位，起點低於終點\n- 第三聲（上聲）：先下降再上升，呈 V 形或 U 形\n- 第四聲（去聲）：從高位急降到低位，起點高於終點\n\n請判斷用戶畫的走勢是否正確，返回純 JSON（不含其他文字）：\n{\n  "is_correct": true,\n  "detected_tone": 2,\n  "feedback_zh": "很棒！你畫的上升走勢正確地表示了第二聲！",\n  "feedback_en": "Great! Your rising contour correctly represents the 2nd tone!"\n}'
                },
                {
                  'role': 'user',
                  'content': '目標聲調：第${targetTone}聲\n用戶畫的軌跡描述：$description'
                }
              ],
              'max_tokens': 300,
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            body['choices'][0]['message']['content'] as String? ?? '';
        try {
          final jsonRegex = RegExp(r'\{[\s\S]*\}');
          final match = jsonRegex.firstMatch(content);
          if (match != null) {
            final map =
                jsonDecode(match.group(0)!) as Map<String, dynamic>;
            return ToneJudgmentResult.fromJson(map);
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('judgeToneDrawing error: $e');
    }
    return null;
  }

  static String _describeStroke(List<Offset> points, Size canvasSize) {
    if (points.isEmpty) return '用戶沒有畫任何東西';

    final normalized = points
        .map((p) => Offset(
              p.dx / canvasSize.width,
              1.0 - (p.dy / canvasSize.height),
            ))
        .toList();

    final start = normalized.first;
    final end = normalized.last;
    final mid = normalized[normalized.length ~/ 2];

    double minY = 1.0, maxY = 0.0;
    int minIdx = 0, maxIdx = 0;
    for (int i = 0; i < normalized.length; i++) {
      if (normalized[i].dy < minY) {
        minY = normalized[i].dy;
        minIdx = i;
      }
      if (normalized[i].dy > maxY) {
        maxY = normalized[i].dy;
        maxIdx = i;
      }
    }

    return '''起點位置：(${start.dx.toStringAsFixed(2)}, ${start.dy.toStringAsFixed(2)})
終點位置：(${end.dx.toStringAsFixed(2)}, ${end.dy.toStringAsFixed(2)})
中間點位置：(${mid.dx.toStringAsFixed(2)}, ${mid.dy.toStringAsFixed(2)})
最高點出現在軌跡的 ${((maxIdx / normalized.length) * 100).toInt()}% 處，高度 ${maxY.toStringAsFixed(2)}
最低點出現在軌跡的 ${((minIdx / normalized.length) * 100).toInt()}% 處，高度 ${minY.toStringAsFixed(2)}
整體高度差：${(end.dy - start.dy).toStringAsFixed(2)}（正數=上升，負數=下降）
軌跡總點數：${normalized.length}''';
  }
}
