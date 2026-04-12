import 'dart:async';

import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../services/storage_service.dart';

class AppStatsProvider extends ChangeNotifier {
  late final StreamSubscription<dynamic> _settingsSub;
  late final StreamSubscription<dynamic> _recordsSub;

  int _totalXp = 0;
  int _totalStars = 0;
  int _totalWords = 0;
  int _streak = 0;
  GameLevel _level = GameConfig.levelForXp(0);

  AppStatsProvider() {
    _refresh(notify: false);
    _settingsSub = StorageService.watchSettings().listen((_) => _refresh());
    _recordsSub = StorageService.watchRecords().listen((_) => _refresh());
  }

  int get totalXp => _totalXp;
  int get totalStars => _totalStars;
  int get totalWords => _totalWords;
  int get streak => _streak;
  GameLevel get level => _level;

  void refresh() => _refresh();

  void _refresh({bool notify = true}) {
    final totalXp = StorageService.getTotalXp();
    final totalStars = StorageService.getTotalStars();
    final totalWords = StorageService.getTotalRecordsCount();
    final streak = StorageService.getStreak();
    final level = GameConfig.levelForXp(totalXp);

    final hasChanged = totalXp != _totalXp ||
        totalStars != _totalStars ||
        totalWords != _totalWords ||
        streak != _streak ||
        level.level != _level.level;

    _totalXp = totalXp;
    _totalStars = totalStars;
    _totalWords = totalWords;
    _streak = streak;
    _level = level;

    if (notify && hasChanged) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _settingsSub.cancel();
    _recordsSub.cancel();
    super.dispose();
  }
}
