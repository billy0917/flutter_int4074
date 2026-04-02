import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/phrase_data.dart';
import '../config/routes.dart';
import '../models/daily_phrase.dart';
import '../widgets/clay_card.dart';
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
      duration: const Duration(milliseconds: 600),
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
      ),
      body: FadeTransition(
        opacity: _animController,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
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
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.phraseLearning,
                    arguments: cat,
                  ),
                ),
              ),
            );
          },
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(category.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.phraseCategoryCount(category.phrases.length),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
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
