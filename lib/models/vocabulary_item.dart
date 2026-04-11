import '../config/daily_vocab_data.dart';

/// A vocabulary item used in the matching game.
class VocabularyItem {
  final String chinese;
  final String pinyin;
  final String english;
  final String imagePath;

  const VocabularyItem({
    required this.chinese,
    required this.pinyin,
    required this.english,
    required this.imagePath,
  });

  /// Create from the existing [DailyVocab] data.
  factory VocabularyItem.fromDailyVocab(DailyVocab v) => VocabularyItem(
        chinese: v.chinese,
        pinyin: v.pinyin,
        english: v.english,
        imagePath: v.imagePath,
      );

  /// Get all vocabulary items that have a valid image path.
  static List<VocabularyItem> allWithImages() => kDailyVocabList
      .where((v) => v.imagePath.isNotEmpty)
      .map(VocabularyItem.fromDailyVocab)
      .toList();
}
