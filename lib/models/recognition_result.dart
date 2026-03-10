import 'dart:convert';

class CharacterTone {
  final String char;
  final String pinyin;
  final int toneNumber;
  final String toneNameZh;
  final String toneNameEn;

  CharacterTone({
    required this.char,
    required this.pinyin,
    required this.toneNumber,
    required this.toneNameZh,
    required this.toneNameEn,
  });

  factory CharacterTone.fromJson(Map<String, dynamic> json) {
    return CharacterTone(
      char: json['char'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      toneNumber: json['tone_number'] as int? ?? 1,
      toneNameZh: json['tone_name_zh'] as String? ?? '',
      toneNameEn: json['tone_name_en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'char': char,
        'pinyin': pinyin,
        'tone_number': toneNumber,
        'tone_name_zh': toneNameZh,
        'tone_name_en': toneNameEn,
      };
}

class RecognitionResult {
  final String objectNameZh;
  final String objectNameEn;
  final String pinyin;
  final String pinyinNoTone;
  final List<CharacterTone> characters;
  final String cantoneseReference;
  final String exampleSentenceZh;
  final String exampleSentencePinyin;
  final String exampleSentenceEn;
  final String? imagePath;

  RecognitionResult({
    required this.objectNameZh,
    required this.objectNameEn,
    required this.pinyin,
    required this.pinyinNoTone,
    required this.characters,
    required this.cantoneseReference,
    required this.exampleSentenceZh,
    required this.exampleSentencePinyin,
    required this.exampleSentenceEn,
    this.imagePath,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    final charsList = (json['characters'] as List<dynamic>?) ?? [];
    return RecognitionResult(
      objectNameZh: json['object_name_zh'] as String? ?? '',
      objectNameEn: json['object_name_en'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      pinyinNoTone: json['pinyin_no_tone'] as String? ?? '',
      characters: charsList
          .map((c) => CharacterTone.fromJson(c as Map<String, dynamic>))
          .toList(),
      cantoneseReference: json['cantonese_reference'] as String? ?? '',
      exampleSentenceZh: json['example_sentence_zh'] as String? ?? '',
      exampleSentencePinyin: json['example_sentence_pinyin'] as String? ?? '',
      exampleSentenceEn: json['example_sentence_en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'object_name_zh': objectNameZh,
        'object_name_en': objectNameEn,
        'pinyin': pinyin,
        'pinyin_no_tone': pinyinNoTone,
        'characters': characters.map((c) => c.toJson()).toList(),
        'cantonese_reference': cantoneseReference,
        'example_sentence_zh': exampleSentenceZh,
        'example_sentence_pinyin': exampleSentencePinyin,
        'example_sentence_en': exampleSentenceEn,
      };

  RecognitionResult copyWith({String? imagePath}) {
    return RecognitionResult(
      objectNameZh: objectNameZh,
      objectNameEn: objectNameEn,
      pinyin: pinyin,
      pinyinNoTone: pinyinNoTone,
      characters: characters,
      cantoneseReference: cantoneseReference,
      exampleSentenceZh: exampleSentenceZh,
      exampleSentencePinyin: exampleSentencePinyin,
      exampleSentenceEn: exampleSentenceEn,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  static RecognitionResult? tryParseFromRawJson(String raw) {
    try {
      // Extract JSON from possible markdown code fences
      String cleaned = raw.trim();
      final jsonRegex = RegExp(r'\{[\s\S]*\}');
      final match = jsonRegex.firstMatch(cleaned);
      if (match != null) {
        cleaned = match.group(0)!;
      }
      final map = jsonDecode(cleaned) as Map<String, dynamic>;
      return RecognitionResult.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
