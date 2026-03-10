import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/history_provider.dart';
import '../models/learning_record.dart';
import '../widgets/clay_card.dart';
import '../widgets/feature_card.dart';
import '../utils/constants.dart';
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
    // Defer loadRecords until after the first frame so Provider's
    // notifyListeners() doesn't fire during the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistoryProvider>().loadRecords();
    });

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimations = List.generate(
      6,
      (i) => Tween<Offset>(
        begin: const Offset(0, 0.4),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.1, (i * 0.1) + 0.5, curve: Curves.easeOut),
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

  void _showComingSoon(BuildContext ctx) {
    final l = AppLocalizations.of(ctx)!;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(l.comingSoonMsg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final history = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar
              _slideIn(
                0,
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(l),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          l.homeSubtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded,
                          color: AppColors.textMedium, size: 28),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.settings),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Stats card
              _slideIn(
                1,
                ClayCard(
                  color: AppColors.primary.withOpacity(0.15),
                  child: Row(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.todayStats,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                l.statsWordsLearned(history.totalWords),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 1,
                                height: 16,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                l.statsStreak(history.currentStreak),
                                style: const TextStyle(
                                  fontSize: 15,
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
              ),

              const SizedBox(height: 20),

              // ── Main feature grid
              _slideIn(2, _sectionLabel('── 主要功能 ──')),
              const SizedBox(height: 10),
              _slideIn(
                2,
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    FeatureCard(
                      emoji: '📷',
                      titleZh: l.featureSnap,
                      titleEn: l.featureSnapSub,
                      color: AppColors.primary.withOpacity(0.85),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.camera),
                    ),
                    FeatureCard(
                      emoji: '📝',
                      titleZh: l.featureQuiz,
                      titleEn: l.featureQuizSub,
                      color: AppColors.secondary.withOpacity(0.85),
                      onTap: () {
                        if (history.records.isEmpty) {
                          _showComingSoon(context);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.camera);
                        }
                      },
                    ),
                    FeatureCard(
                      emoji: '📜',
                      titleZh: l.featureHistory,
                      titleEn: l.featureHistorySub,
                      color: AppColors.primaryLight.withOpacity(0.85),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.history),
                    ),
                    FeatureCard(
                      emoji: '⭐',
                      titleZh: l.featureFavorites,
                      titleEn: l.featureFavoritesSub,
                      color: AppColors.star.withOpacity(0.85),
                      comingSoon: true,
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ),

              // ── Recent learned
              if (history.recentRecords.isNotEmpty) ...[
                const SizedBox(height: 20),
                _slideIn(3, _sectionLabel('── ${l.recentLearned} ──')),
                const SizedBox(height: 10),
                _slideIn(
                  3,
                  SizedBox(
                    height: 90,
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

              // ── Coming soon section
              const SizedBox(height: 20),
              _slideIn(4, _sectionLabel('── ${l.moreFeatures} ──')),
              const SizedBox(height: 10),
              _slideIn(
                4,
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    FeatureCard(
                      emoji: '🎮',
                      titleZh: l.featureGames,
                      titleEn: l.featureGamesSub,
                      color: AppColors.success,
                      comingSoon: true,
                      onTap: () => _showComingSoon(context),
                    ),
                    FeatureCard(
                      emoji: '🏆',
                      titleZh: l.featureAchievements,
                      titleEn: l.featureAchievementsSub,
                      color: AppColors.tone4,
                      comingSoon: true,
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textLight,
        letterSpacing: 1,
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

class _RecentItem extends StatelessWidget {
  final LearningRecord record;
  final VoidCallback onTap;

  const _RecentItem({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(2, 4),
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
                fontSize: 28,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              record.objectNameZh.length > 3
                  ? record.objectNameZh.substring(0, 3)
                  : record.objectNameZh,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textMedium),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
