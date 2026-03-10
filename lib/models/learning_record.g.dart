// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharacterToneHiveAdapter extends TypeAdapter<CharacterToneHive> {
  @override
  final int typeId = 1;

  @override
  CharacterToneHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CharacterToneHive()
      ..char = fields[0] as String
      ..pinyin = fields[1] as String
      ..toneNumber = fields[2] as int
      ..toneNameZh = fields[3] as String
      ..toneNameEn = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, CharacterToneHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.char)
      ..writeByte(1)
      ..write(obj.pinyin)
      ..writeByte(2)
      ..write(obj.toneNumber)
      ..writeByte(3)
      ..write(obj.toneNameZh)
      ..writeByte(4)
      ..write(obj.toneNameEn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterToneHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizQuestionResultAdapter extends TypeAdapter<QuizQuestionResult> {
  @override
  final int typeId = 2;

  @override
  QuizQuestionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizQuestionResult()
      ..type = fields[0] as String
      ..questionText = fields[1] as String
      ..isCorrect = fields[2] as bool
      ..userAnswer = fields[3] as String
      ..correctAnswer = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, QuizQuestionResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.questionText)
      ..writeByte(2)
      ..write(obj.isCorrect)
      ..writeByte(3)
      ..write(obj.userAnswer)
      ..writeByte(4)
      ..write(obj.correctAnswer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizAttemptAdapter extends TypeAdapter<QuizAttempt> {
  @override
  final int typeId = 3;

  @override
  QuizAttempt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizAttempt()
      ..attemptedAt = fields[0] as DateTime
      ..totalQuestions = fields[1] as int
      ..correctAnswers = fields[2] as int
      ..starRating = fields[3] as int
      ..details = (fields[4] as List).cast<QuizQuestionResult>();
  }

  @override
  void write(BinaryWriter writer, QuizAttempt obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.attemptedAt)
      ..writeByte(1)
      ..write(obj.totalQuestions)
      ..writeByte(2)
      ..write(obj.correctAnswers)
      ..writeByte(3)
      ..write(obj.starRating)
      ..writeByte(4)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAttemptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LearningRecordAdapter extends TypeAdapter<LearningRecord> {
  @override
  final int typeId = 0;

  @override
  LearningRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningRecord()
      ..id = fields[0] as String
      ..imagePath = fields[1] as String
      ..objectNameZh = fields[2] as String
      ..objectNameEn = fields[3] as String
      ..pinyin = fields[4] as String
      ..pinyinNoTone = fields[5] as String
      ..characters = (fields[6] as List).cast<CharacterToneHive>()
      ..cantoneseReference = fields[7] as String
      ..exampleSentenceZh = fields[8] as String
      ..exampleSentencePinyin = fields[9] as String
      ..exampleSentenceEn = fields[10] as String
      ..createdAt = fields[11] as DateTime
      ..quizAttempts = (fields[12] as List).cast<QuizAttempt>();
  }

  @override
  void write(BinaryWriter writer, LearningRecord obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.objectNameZh)
      ..writeByte(3)
      ..write(obj.objectNameEn)
      ..writeByte(4)
      ..write(obj.pinyin)
      ..writeByte(5)
      ..write(obj.pinyinNoTone)
      ..writeByte(6)
      ..write(obj.characters)
      ..writeByte(7)
      ..write(obj.cantoneseReference)
      ..writeByte(8)
      ..write(obj.exampleSentenceZh)
      ..writeByte(9)
      ..write(obj.exampleSentencePinyin)
      ..writeByte(10)
      ..write(obj.exampleSentenceEn)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.quizAttempts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
