import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/phrase_data.dart';
import '../config/game_config.dart';
import '../config/routes.dart';
import '../models/daily_phrase.dart';
import '../services/storage_service.dart';
import '../widgets/clay_card.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../utils/responsive.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class PhraseCategoriesScreen extends StatefulWidget {
  const PhraseCategoriesScreen({super.key});

  @override
  State<PhraseCategoriesScreen> createState() => _PhraseCategoriesScreenState();
}

class _PhraseCategoriesScreenState extends State<PhraseCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppConstants.animNormal,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.phraseLearningTitle),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: '練習記錄',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.phraseHistory),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animController,
        child: Column(
          children: [
            _PlayerProfileCard(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kPhraseCategories.length,
                itemBuilder: (ctx, i) {
                  final cat = kPhraseCategories[i];
                  final delay = (i * 0.08).clamp(0.0, 0.7);
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animController,
                      curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
                          curve: Curves.easeOut),
                    )),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CategoryTile(
                        category: cat,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.phraseLearning,
                            arguments: cat,
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final PhraseCategory category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    final name = isZh ? category.nameZh : category.nameEn;

    return ClayCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: context.s(56),
            height: context.s(56),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: AppIcons.svg(category.iconPath, size: context.s(28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: context.sp(17),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      l.phraseCategoryCount(category.phrases.length),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcons.svg(AppIcons.star, size: 14, color: AppColors.star),
                        const SizedBox(width: 2),
                        Text(
                          '${StorageService.getCategoryStars(category.id)}/${category.phrases.length * 3}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.star,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textLight, size: 28),
        ],
      ),
    );
  }
}

class _PlayerProfileCard extends StatelessWidget {
  const _PlayerProfileCard();

  @override
  Widget build(BuildContext context) {
    final xp = StorageService.getTotalXp();
    final level = GameConfig.levelForXp(xp);
    final progress = GameConfig.levelProgress(xp);
    final nextLvl = GameConfig.nextLevel(xp);
    final streak = StorageService.getStreak();
    final totalStars = StorageService.getTotalStars();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClayCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: context.s(52),
              height: context.s(52),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: AppIcons.svg(AppIcons.levelIcon(level.level), size: context.s(30)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lv.${level.level} ${level.titleZh}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.cardBgAlt,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nextLvl != null
                        ? '$xp / ${nextLvl.xpRequired} XP'
                        : '$xp XP · MAX',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcons.svg(AppIcons.fire, size: 20),
                    const SizedBox(width: 2),
                    Text(
                      '$streak',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcons.svg(AppIcons.star, size: 20, color: const Color(0xFFFFD93D)),
                    const SizedBox(width: 2),
                    Text(
                      '$totalStars',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
