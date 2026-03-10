import 'package:hive/hive.dart';

part 'learning_record.g.dart';

@HiveType(typeId: 1)
class CharacterToneHive extends HiveObject {
  @HiveField(0)
  late String char;
  @HiveField(1)
  late String pinyin;
  @HiveField(2)
  late int toneNumber;
  @HiveField(3)
  late String toneNameZh;
  @HiveField(4)
  late String toneNameEn;
}

@HiveType(typeId: 2)
class QuizQuestionResult extends HiveObject {
  @HiveField(0)
  late String type;
  @HiveField(1)
  late String questionText;
  @HiveField(2)
  late bool isCorrect;
  @HiveField(3)
  late String userAnswer;
  @HiveField(4)
  late String correctAnswer;
}

@HiveType(typeId: 3)
class QuizAttempt extends HiveObject {
  @HiveField(0)
  late DateTime attemptedAt;
  @HiveField(1)
  late int totalQuestions;
  @HiveField(2)
  late int correctAnswers;
  @HiveField(3)
  late int starRating;
  @HiveField(4)
  late List<QuizQuestionResult> details;
}

@HiveType(typeId: 0)
class LearningRecord extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String imagePath;
  @HiveField(2)
  late String objectNameZh;
  @HiveField(3)
  late String objectNameEn;
  @HiveField(4)
  late String pinyin;
  @HiveField(5)
  late String pinyinNoTone;
  @HiveField(6)
  late List<CharacterToneHive> characters;
  @HiveField(7)
  late String cantoneseReference;
  @HiveField(8)
  late String exampleSentenceZh;
  @HiveField(9)
  late String exampleSentencePinyin;
  @HiveField(10)
  late String exampleSentenceEn;
  @HiveField(11)
  late DateTime createdAt;
  @HiveField(12)
  late List<QuizAttempt> quizAttempts;
}
