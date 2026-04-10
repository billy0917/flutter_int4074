import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('zh');

  LocaleProvider() {
    if (StorageService.isInitialized) {
      try {
        final saved = StorageService.getLocale();
        _locale = Locale(saved);
      } catch (_) {
        // Fallback to default locale
      }
    }
  }

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await StorageService.setLocale(locale.languageCode);
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'zh') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('zh'));
    }
  }
}
