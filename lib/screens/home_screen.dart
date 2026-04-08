import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../config/game_config.dart';
import '../providers/history_provider.dart';
import '../models/learning_record.dart';
import '../services/sense_voice_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistoryProvider>().loadRecords();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        Future<void>.delayed(
          const Duration(milliseconds: 900),
          () => SenseVoiceService.instance.init(),
        ),
      );
    });

    _staggerController = AnimationController(
      vsync: this,
      duration: AppConstants.animSlow,
    );

    _slideAnimations = List.generate(
      4,
      (i) => Tween<Offset>(
        begin: const Offset(0, 0.35),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.10, (i * 0.10) + 0.5, curve: Curves.easeOut),
        ),
      ),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.homeGreetingMorning;
    if (h < 18) return l.homeGreetingAfternoon;
    return l.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final history = context.watch<HistoryProvider>();
    final xp = StorageService.getTotalXp();
    final level = GameConfig.levelForXp(xp);
    final streak = StorageService.getStreak();
    final totalStars = StorageService.getTotalStars();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pagePadding, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header
              _slideIn(
                0,
                Row(
                  children: [
                    // 等級頭像 (SVG)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            offset: const Offset(2, 3),
                            blurRadius: 6,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.7),
                            offset: const Offset(-2, -2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: AppIcons.svg(
                        AppIcons.levelIcon(level.level),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(l),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lv.${level.level} ${level.titleZh}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ClayIconButton(
                      icon: Icons.settings_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.settings),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Stats row
              _slideIn(
                1,
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: AppIcons.svg(AppIcons.fire, size: 22),
                        value: '$streak',
                        label: l.statsStreak(streak).replaceAll(
                            RegExp(r'[0-9]+\s*'), ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        icon: AppIcons.svg(AppIcons.star, size: 22,
                            color: const Color(0xFFFFD93D)),
                        value: '$totalStars',
                        label: '星星',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        icon: AppIcons.svg(AppIcons.book, size: 22),
                        value: '${history.totalWords}',
                        label: '已學詞語',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── 日常短語（全寬卡片）
              _slideIn(
                2,
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.phraseCategories),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius:
                          BorderRadius.circular(AppConstants.cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.75),
                          offset: const Offset(-3, -3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.tone2.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: AppIcons.svg(AppIcons.chat, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.featurePhrases,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.featurePhrasesSub,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.textLight,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Recent learned
              if (history.recentRecords.isNotEmpty) ...[
                const SizedBox(height: 24),
                _slideIn(
                  3,
                  Text(
                    l.recentLearned,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _slideIn(
                  3,
                  SizedBox(
                    height: 96,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: history.recentRecords.length,
                      itemBuilder: (ctx, i) {
                        final rec = history.recentRecords[i];
                        return _RecentItem(
                          record: rec,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.historyDetail,
                            arguments: rec,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slideIn(int index, Widget child) {
    if (index >= _slideAnimations.length) return child;
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _staggerController,
        child: child,
      ),
    );
  }
}

// ── Clay icon button (settings etc.)
class _ClayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ClayIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.7),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.textMedium, size: 22),
      ),
    );
  }
}

// ── Stat chip (streak, stars, words) — 使用 Widget icon 取代 emoji
class _StatChip extends StatelessWidget {
  final Widget icon;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Recent learned item
class _RecentItem extends StatelessWidget {
  final LearningRecord record;
  final VoidCallback onTap;

  const _RecentItem({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              record.objectNameZh.isNotEmpty
                  ? record.objectNameZh.substring(0, 1)
                  : '?',
              style: const TextStyle(
                fontSize: 30,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                record.objectNameZh.length > 3
                    ? record.objectNameZh.substring(0, 3)
                    : record.objectNameZh,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMedium),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
