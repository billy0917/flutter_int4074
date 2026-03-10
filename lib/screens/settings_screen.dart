import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/history_provider.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../widgets/clay_card.dart';
import '../widgets/clay_button.dart';
import '../utils/constants.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _ttsSpeed;
  final TtsService _tts = TtsService();

  @override
  void initState() {
    super.initState();
    _ttsSpeed = StorageService.getTtsSpeed();
    _tts.init();
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  Future<void> _clearHistory(BuildContext ctx, AppLocalizations l) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(l.settingsClearHistory),
        content: Text(l.settingsClearConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l.confirm,
                  style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<HistoryProvider>().clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('歷史記錄已清除')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isZh = localeProvider.locale.languageCode == 'zh';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.settingsTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          children: [
            // Language section
            ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌐', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        l.settingsLanguage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClayButton(
                          color: isZh
                              ? AppColors.primary
                              : AppColors.cardBgAlt,
                          onTap: () => localeProvider
                              .setLocale(const Locale('zh')),
                          child: Center(
                            child: Text(
                              '繁體中文',
                              style: TextStyle(
                                color: isZh
                                    ? Colors.white
                                    : AppColors.textMedium,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClayButton(
                          color: !isZh
                              ? AppColors.primary
                              : AppColors.cardBgAlt,
                          onTap: () => localeProvider
                              .setLocale(const Locale('en')),
                          child: Center(
                            child: Text(
                              'English',
                              style: TextStyle(
                                color: !isZh
                                    ? Colors.white
                                    : AppColors.textMedium,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TTS Speed
            ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🔊', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        l.settingsTtsSpeed,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_ttsSpeed.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _ttsSpeed,
                    min: 0.3,
                    max: 1.0,
                    divisions: 7,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.textLight.withOpacity(0.4),
                    onChanged: (v) async {
                      setState(() => _ttsSpeed = v);
                      await StorageService.setTtsSpeed(v);
                      await _tts.setSpeed(v);
                    },
                  ),
                  TextButton(
                    onPressed: () => _tts.speak('普通話學習'),
                    child: const Text(
                      '🔊 試聽',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Clear history
            ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🗑️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        l.settingsClearHistory,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClayButton(
                    color: AppColors.error.withOpacity(0.9),
                    width: double.infinity,
                    onTap: () => _clearHistory(context, l),
                    child: Center(
                      child: Text(
                        l.settingsClearHistory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About
            ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('ℹ️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        l.settingsAbout,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'INT4074 Group Project',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textMedium),
                  ),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textLight),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
