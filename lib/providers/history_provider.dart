import 'package:flutter/material.dart';
import '../models/learning_record.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<LearningRecord> _records = [];

  List<LearningRecord> get records => List.unmodifiable(_records);

  List<LearningRecord> get recentRecords => _records.take(10).toList();

  int get totalWords => _records.length;

  int get currentStreak {
    if (_records.isEmpty) return 0;
    final now = DateTime.now();
    int streak = 0;
    DateTime checkDay = DateTime(now.year, now.month, now.day);
    final dates = _records
        .map((r) =>
            DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final date in dates) {
      if (date == checkDay ||
          date == checkDay.subtract(const Duration(days: 1))) {
        streak++;
        checkDay = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  void loadRecords() {
    _records = StorageService.getAllRecords();
    notifyListeners();
  }

  Future<void> addRecord(LearningRecord record) async {
    await StorageService.saveRecord(record);
    loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await StorageService.deleteRecord(id);
    loadRecords();
  }

  Future<void> clearAll() async {
    await StorageService.clearAllRecords();
    loadRecords();
  }

  Future<void> updateRecord(LearningRecord record) async {
    await StorageService.updateRecord(record);
    loadRecords();
  }

  List<LearningRecord> search(String query) {
    if (query.trim().isEmpty) return _records;
    final q = query.toLowerCase();
    return _records
        .where((r) =>
            r.objectNameZh.contains(q) ||
            r.objectNameEn.toLowerCase().contains(q) ||
            r.pinyin.toLowerCase().contains(q))
        .toList();
  }
}
