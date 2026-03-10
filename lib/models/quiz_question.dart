import 'dart:convert';

class QuizQuestion {
  final String type;
  final String questionZh;
  final String questionEn;
  final List<String> options;
  final int correctIndex;
  final String? targetChar;
  final String? targetPinyin;
  final int? correctTone;
  final String? correctDescription;
  final String? ttsText;
  final List<String>? optionLabelsZh;
  final List<String>? optionLabelsEn;

  QuizQuestion({
    required this.type,
    required this.questionZh,
    required this.questionEn,
    required this.options,
    required this.correctIndex,
    this.targetChar,
    this.targetPinyin,
    this.correctTone,
    this.correctDescription,
    this.ttsText,
    this.optionLabelsZh,
    this.optionLabelsEn,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      type: json['type'] as String? ?? '',
      questionZh: json['question_zh'] as String? ?? '',
      questionEn: json['question_en'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? []),
      correctIndex: json['correct_index'] as int? ?? 0,
      targetChar: json['target_char'] as String?,
      targetPinyin: json['target_pinyin'] as String?,
      correctTone: json['correct_tone'] as int?,
      correctDescription: json['correct_description'] as String?,
      ttsText: json['tts_text'] as String?,
      optionLabelsZh: json['option_labels_zh'] != null
          ? List<String>.from(json['option_labels_zh'] as List)
          : null,
      optionLabelsEn: json['option_labels_en'] != null
          ? List<String>.from(json['option_labels_en'] as List)
          : null,
    );
  }

  static List<QuizQuestion>? tryParseListFromRaw(String raw) {
    try {
      String cleaned = raw.trim();
      final jsonRegex = RegExp(r'\[[\s\S]*\]');
      final match = jsonRegex.firstMatch(cleaned);
      if (match != null) {
        cleaned = match.group(0)!;
      }
      final list = jsonDecode(cleaned) as List<dynamic>;
      return list
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
