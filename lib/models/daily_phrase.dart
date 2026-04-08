/// A single phrase with Chinese text, pinyin, English translation, and image.
class DailyPhrase {
  final String chinese;
  final String pinyin;
  final String english;
  final String imagePath;

  const DailyPhrase({
    required this.chinese,
    required this.pinyin,
    required this.english,
    required this.imagePath,
  });
}

/// A category (theme pack) of daily phrases.
class PhraseCategory {
  final String id;
  final String iconPath;
  final String nameZh;
  final String nameEn;
  final List<DailyPhrase> phrases;

  const PhraseCategory({
    required this.id,
    required this.iconPath,
    required this.nameZh,
    required this.nameEn,
    required this.phrases,
  });
}
