import 'package:hive_flutter/hive_flutter.dart';
import '../models/learning_record.dart';

class StorageService {
  static const String recordsBoxName = 'learning_records';
  static const String settingsBoxName = 'settings';

  static late Box<LearningRecord> _recordsBox;
  static late Box<dynamic> _settingsBox;

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LearningRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CharacterToneHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(QuizQuestionResultAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(QuizAttemptAdapter());
    }

    _recordsBox = await Hive.openBox<LearningRecord>(recordsBoxName);
    _settingsBox = await Hive.openBox<dynamic>(settingsBoxName);
    _initialized = true;
  }

  // ─── Learning Records ───────────────────────────────────────────────────────

  static Future<void> saveRecord(LearningRecord record) async {
    await _recordsBox.put(record.id, record);
  }

  static List<LearningRecord> getAllRecords() {
    final list = _recordsBox.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static LearningRecord? getRecord(String id) {
    return _recordsBox.get(id);
  }

  static Future<void> deleteRecord(String id) async {
    await _recordsBox.delete(id);
  }

  static Future<void> clearAllRecords() async {
    await _recordsBox.clear();
  }

  static Future<void> updateRecord(LearningRecord record) async {
    await record.save();
  }

  // ─── Settings ───────────────────────────────────────────────────────────────

  static String getLocale() {
    return _settingsBox.get('locale', defaultValue: 'zh') as String;
  }

  static Future<void> setLocale(String locale) async {
    await _settingsBox.put('locale', locale);
  }

  static double getTtsSpeed() {
    return _settingsBox.get('ttsSpeed', defaultValue: 0.5) as double;
  }

  static Future<void> setTtsSpeed(double speed) async {
    await _settingsBox.put('ttsSpeed', speed);
  }
}
