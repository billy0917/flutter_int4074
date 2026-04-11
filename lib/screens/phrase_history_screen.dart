import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/game_config.dart';
import '../config/phrase_data.dart';
import '../config/routes.dart';
import '../models/daily_phrase.dart';
import '../services/storage_service.dart';
import '../widgets/clay_card.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../utils/responsive.dart';

/// Shows the user's phrase practice history grouped by category, with
/// per-phrase best score, attempt count, and last practice time.
class PhraseHistoryScreen extends StatefulWidget {
  const PhraseHistoryScreen({super.key});

  @override
  State<PhraseHistoryScreen> createState() => _PhraseHistoryScreenState();
}

class _PhraseHistoryScreenState extends State<PhraseHistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<_CategoryRecord> _records;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppConstants.animNormal,
    )..forward();
    _loadRecords();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadRecords() {
    final list = <_CategoryRecord>[];
    for (final cat in kPhraseCategories) {
      final phraseRecords = <_PhraseRecord>[];
      for (var i = 0; i < cat.phrases.length; i++) {
        final best = StorageService.getPhraseBestScore(cat.id, i);
        if (best == null) continue;
        final attempts = StorageService.getPhraseAttempts(cat.id, i);
        phraseRecords.add(_PhraseRecord(
          phrase: cat.phrases[i],
          bestScore: best,
          attempts: attempts,
        ));
      }
      if (phraseRecords.isNotEmpty) {
        final summary =
            StorageService.getCategorySummary(cat.id, cat.phrases.length);
        list.add(_CategoryRecord(
          category: cat,
          phrases: phraseRecords,
          practiced: summary['practiced'] as int,
          averageBest: (summary['averageBest'] as num).toDouble(),
        ));
      }
    }
    _records = list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('練習記錄'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcons.svg(AppIcons.pencil, size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    '尚未練習任何詞語',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '完成口語練習後，記錄會顯示在這裡',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _animController,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _records.length,
                itemBuilder: (ctx, i) {
                  final rec = _records[i];
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
                    child: _CategorySection(
                      record: rec,
                      onPracticeAgain: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.phraseLearning,
                          arguments: rec.category,
                        ).then((_) {
                          if (mounted) setState(_loadRecords);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ── Data classes ──

class _CategoryRecord {
  final PhraseCategory category;
  final List<_PhraseRecord> phrases;
  final int practiced;
  final double averageBest;

  const _CategoryRecord({
    required this.category,
    required this.phrases,
    required this.practiced,
    required this.averageBest,
  });
}

class _PhraseRecord {
  final DailyPhrase phrase;
  final double bestScore;
  final int attempts;

  const _PhraseRecord({
    required this.phrase,
    required this.bestScore,
    required this.attempts,
  });
}

// ── Widgets ──

class _CategorySection extends StatelessWidget {
  final _CategoryRecord record;
  final VoidCallback onPracticeAgain;

  const _CategorySection({
    required this.record,
    required this.onPracticeAgain,
  });

  @override
  Widget build(BuildContext context) {
    final cat = record.category;
    final catStars = StorageService.getCategoryStars(cat.id);
    final maxStars = cat.phrases.length * 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClayCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                AppIcons.svg(cat.iconPath, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.nameZh,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        cat.nameEn,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                // Star badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.star.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcons.svg(AppIcons.star, size: 14, color: AppColors.star),
                      const SizedBox(width: 4),
                      Text(
                        '$catStars/$maxStars',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.star,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '已練習 ${record.practiced}/${cat.phrases.length} 個詞語',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
            const Divider(height: 20),
            // Phrase list
            ...record.phrases.map((p) => _PhraseRow(record: p)),
            const SizedBox(height: 8),
            // Practice again button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onPracticeAgain,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('再次練習'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhraseRow extends StatelessWidget {
  final _PhraseRecord record;

  const _PhraseRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final stars = GameConfig.starsForScore(record.bestScore);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 詞彙圖片
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                record.phrase.imagePath,
                width: context.s(36),
                height: context.s(36),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Chinese + pinyin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.phrase.chinese,
                  style: TextStyle(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  record.phrase.pinyin,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          // Attempts
          Text(
            '${record.attempts} 次',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(width: 12),
          // Stars
          AppIcons.starRow(stars, size: 18),
        ],
      ),
    );
  }
}
