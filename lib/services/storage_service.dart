import 'package:hive_flutter/hive_flutter.dart';
import '../models/learning_record.dart';

class StorageService {
  static const String recordsBoxName = 'learning_records';
  static const String settingsBoxName = 'settings';

  static late Box<LearningRecord> _recordsBox;
  static late Box<dynamic> _settingsBox;

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

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

  // ─── Phrase Practice Records ────────────────────────────────────────────────

  static const String _phraseScoresKey = 'phrase_scores';

  /// Get all phrase scores as {categoryId: {phraseIndex: {best, attempts, last}}}.
  static Map<String, dynamic> _getPhraseScoresMap() {
    final raw = _settingsBox.get(_phraseScoresKey);
    if (raw == null) return {};
    // Hive stores as dynamic; deep-cast to Map<String, dynamic>.
    return Map<String, dynamic>.from(
      (raw as Map).map((k, v) => MapEntry(
        k.toString(),
        Map<String, dynamic>.from(
          (v as Map).map((k2, v2) => MapEntry(
            k2.toString(),
            Map<String, dynamic>.from(v2 as Map),
          )),
        ),
      )),
    );
  }

  /// Record a phrase practice attempt. Keeps best score and total attempts.
  static Future<void> savePhraseScore({
    required String categoryId,
    required int phraseIndex,
    required double score,
  }) async {
    final map = _getPhraseScoresMap();
    final catMap = Map<String, dynamic>.from(
      map[categoryId] as Map<String, dynamic>? ?? {},
    );
    final key = phraseIndex.toString();
    final existing = catMap[key] as Map<String, dynamic>?;
    final bestScore = existing != null
        ? (score > (existing['best'] as num)) ? score : (existing['best'] as num).toDouble()
        : score;
    final attempts = existing != null ? (existing['attempts'] as int) + 1 : 1;
    catMap[key] = {
      'best': bestScore,
      'attempts': attempts,
      'last': DateTime.now().toIso8601String(),
    };
    map[categoryId] = catMap;
    await _settingsBox.put(_phraseScoresKey, map);
  }

  /// Get the best score for a specific phrase. Returns null if never attempted.
  static double? getPhraseBestScore(String categoryId, int phraseIndex) {
    final map = _getPhraseScoresMap();
    final catMap = map[categoryId] as Map<String, dynamic>?;
    if (catMap == null) return null;
    final entry = catMap[phraseIndex.toString()] as Map<String, dynamic>?;
    if (entry == null) return null;
    return (entry['best'] as num).toDouble();
  }

  /// Get total attempts for a specific phrase.
  static int getPhraseAttempts(String categoryId, int phraseIndex) {
    final map = _getPhraseScoresMap();
    final catMap = map[categoryId] as Map<String, dynamic>?;
    if (catMap == null) return 0;
    final entry = catMap[phraseIndex.toString()] as Map<String, dynamic>?;
    if (entry == null) return 0;
    return entry['attempts'] as int;
  }

  /// Get category summary: {practiced, total, averageBest}.
  static Map<String, dynamic> getCategorySummary(
      String categoryId, int totalPhrases) {
    final map = _getPhraseScoresMap();
    final catMap = map[categoryId] as Map<String, dynamic>?;
    if (catMap == null || catMap.isEmpty) {
      return {'practiced': 0, 'total': totalPhrases, 'averageBest': 0.0};
    }
    double sum = 0;
    for (final entry in catMap.values) {
      sum += ((entry as Map)['best'] as num).toDouble();
    }
    return {
      'practiced': catMap.length,
      'total': totalPhrases,
      'averageBest': sum / catMap.length,
    };
  }

  // ─── Gamification ──────────────────────────────────────────────────────────

  static int getTotalXp() {
    return _settingsBox.get('total_xp', defaultValue: 0) as int;
  }

  static Future<int> addXp(int amount) async {
    final current = getTotalXp();
    final updated = current + amount;
    await _settingsBox.put('total_xp', updated);
    return updated;
  }

  static int getStreak() {
    return _settingsBox.get('streak', defaultValue: 0) as int;
  }

  static Future<int> updateStreak() async {
    final lastStr = _settingsBox.get('last_practice_date') as String?;
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (lastStr == todayStr) return getStreak();

    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    int streak = getStreak();
    if (lastStr == yesterdayStr) {
      streak += 1;
    } else {
      streak = 1;
    }

    await _settingsBox.put('streak', streak);
    await _settingsBox.put('last_practice_date', todayStr);
    return streak;
  }

  static int getTotalStars() {
    final map = _getPhraseScoresMap();
    int total = 0;
    for (final catEntry in map.values) {
      for (final entry in (catEntry as Map).values) {
        final best = ((entry as Map)['best'] as num).toDouble();
        if (best >= 80) {
          total += 3;
        } else if (best >= 60) {
          total += 2;
        } else if (best >= 30) {
          total += 1;
        }
      }
    }
    return total;
  }

  static int getCategoryStars(String categoryId) {
    final map = _getPhraseScoresMap();
    final catMap = map[categoryId] as Map<String, dynamic>?;
    if (catMap == null) return 0;
    int total = 0;
    for (final entry in catMap.values) {
      final best = ((entry as Map)['best'] as num).toDouble();
      if (best >= 80) {
        total += 3;
      } else if (best >= 60) {
        total += 2;
      } else if (best >= 30) {
        total += 1;
      }
    }
    return total;
  }
}
