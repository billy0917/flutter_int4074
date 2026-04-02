/// A single phrase with Chinese text, pinyin, and English translation.
class DailyPhrase {
  final String chinese;
  final String pinyin;
  final String english;

  const DailyPhrase({
    required this.chinese,
    required this.pinyin,
    required this.english,
  });
}

/// A category (theme pack) of daily phrases.
class PhraseCategory {
  final String id;
  final String emoji;
  final String nameZh;
  final String nameEn;
  final List<DailyPhrase> phrases;

  const PhraseCategory({
    required this.id,
    required this.emoji,
    required this.nameZh,
    required this.nameEn,
    required this.phrases,
  });
}
