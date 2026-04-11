import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../config/game_config.dart';
import '../config/daily_vocab_data.dart';
import '../providers/history_provider.dart';
import '../services/sense_voice_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../utils/responsive.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  static const double _coverFlowViewportFraction = 0.55;
  static const double _coverFlowCardWidthFactor = 0.68;
  static const double _coverFlowOverlapFactor = 0.24;
  static const double _coverFlowScaleDrop = 0.18;
  static const double _coverFlowOpacityDrop = 0.18;
  static const int _coverFlowVisibleSideCards = 2;

  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late PageController _vocabPageController;
  late final List<Widget> _coverFlowCards;
  int _currentVocabIndex = 0;

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

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    _currentVocabIndex = dayOfYear % kDailyVocabList.length;
    _coverFlowCards = List<Widget>.generate(
      kDailyVocabList.length,
      (index) => RepaintBoundary(
        child: _VocabCard(vocab: kDailyVocabList[index]),
      ),
      growable: false,
    );

    _vocabPageController = PageController(
      initialPage: _currentVocabIndex,
      viewportFraction: _coverFlowViewportFraction,
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: AppConstants.animSlow,
    );

    _fadeAnimations = List.generate(
      3,
      (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.2, (i * 0.2) + 0.6, curve: Curves.easeOut),
        ),
      ),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _vocabPageController.dispose();
    super.dispose();
  }

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.homeGreetingMorning;
    if (h < 18) return l.homeGreetingAfternoon;
    return l.homeGreetingEvening;
  }

  void _onPageChanged(int index) {
    setState(() => _currentVocabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final history = context.watch<HistoryProvider>();
    final xp = StorageService.getTotalXp();
    final level = GameConfig.levelForXp(xp);
    final streak = StorageService.getStreak();
    final totalStars = StorageService.getTotalStars();
    final nextLvl = GameConfig.nextLevel(xp);
    final nextXp = nextLvl?.xpRequired ?? xp;
    final vocab = kDailyVocabList[_currentVocabIndex % kDailyVocabList.length];

    return Scaffold(
      body: Column(
        children: [
          // ── Orange header (extends under status bar)
          Container(
            color: AppColors.primaryLight,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Top bar: mascot, stats, settings
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: context.s(48),
                        height: context.s(48),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: AppIcons.svg(
                          AppIcons.levelIcon(level.level),
                          size: context.s(34),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: _TopStat(icon: AppIcons.fire, value: '$streak', label: '連續天')),
                            const SizedBox(width: 4),
                            Expanded(child: _TopStat(icon: AppIcons.star, value: '$totalStars', label: '星星')),
                            const SizedBox(width: 4),
                            Expanded(child: _TopStat(icon: AppIcons.book, value: '${history.totalWords}', label: '已學詞語')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                        child: Container(
                          width: context.s(48),
                          height: context.s(48),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.settings_rounded,
                              color: Colors.white, size: context.s(26)),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Example sentence banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '例子',
                              style: TextStyle(
                                fontSize: context.sp(20),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _vocabPageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: Container(
                              width: context.s(40),
                              height: context.s(40),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: context.s(24)),
                            ),
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Column(
                                key: ValueKey(_currentVocabIndex),
                                children: [
                                  Text(
                                    vocab.exampleZh,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: context.sp(18),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    vocab.examplePinyin,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.95),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    vocab.exampleEn,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _vocabPageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: Container(
                              width: context.s(40),
                              height: context.s(40),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: context.s(24)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Beige content area
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  // 每日生字 label
                  FadeTransition(
                    opacity: _fadeAnimations[0],
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(28, 12, 28, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '每日生字',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Vocab carousel – Cover Flow style
                  //
                  // TUNABLE VALUES:
                  // _coverFlowCardWidthFactor   -> card width ratio
                  // _coverFlowOverlapFactor     -> spacing / overlap between cards
                  // _coverFlowScaleDrop         -> side-card size reduction
                  // _coverFlowOpacityDrop       -> side-card fade amount
                  // _coverFlowVisibleSideCards  -> visible cards on each side
                  // _coverFlowViewportFraction  -> swipe sensitivity / page snap width
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimations[1],
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          final cardW = totalWidth * _coverFlowCardWidthFactor;
                          return Stack(
                            children: [
                              // Visual layer: repaint-only transforms for smooth scrolling.
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Flow(
                                    delegate: _CoverFlowDelegate(
                                      controller: _vocabPageController,
                                      fallbackPage:
                                          _currentVocabIndex.toDouble(),
                                      cardWidth: cardW,
                                      overlapFactor: _coverFlowOverlapFactor,
                                      scaleDrop: _coverFlowScaleDrop,
                                      opacityDrop: _coverFlowOpacityDrop,
                                      visibleSideCards:
                                          _coverFlowVisibleSideCards,
                                    ),
                                    children: _coverFlowCards,
                                  ),
                                ),
                              ),
                              // Gesture layer: keep native PageView drag physics.
                              PageView.builder(
                                controller: _vocabPageController,
                                onPageChanged: _onPageChanged,
                                itemCount: kDailyVocabList.length,
                                itemBuilder: (_, __) => const SizedBox.expand(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // Feature buttons
                  FadeTransition(
                    opacity: _fadeAnimations[2],
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _FeatureButton(
                              iconWidget:
                                  AppIcons.svg(AppIcons.chat, size: context.s(28)),
                              titleZh: '日常用語',
                              titleEn: 'General word',
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.phraseCategories),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _FeatureButton(
                              iconWidget:
                                  AppIcons.svg(AppIcons.scroll, size: context.s(28)),
                              titleZh: '歷史記錄',
                              titleEn: 'History',
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.history),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom info row: greeting + level
                  FadeTransition(
                    opacity: _fadeAnimations[2],
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              _greeting(l),
                              style: TextStyle(
                                fontSize: context.sp(20),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${level.titleZh} LV.${level.level}  $xp/${nextXp}XP',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top stat badge (in orange header)
class _TopStat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _TopStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30), // Rounded corners for pill shape
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcons.svg(icon, size: 20),
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Daily vocab card for the carousel
class _VocabCard extends StatelessWidget {
  final DailyVocab vocab;

  const _VocabCard({required this.vocab});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 8, 4, 24),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            vocab.pinyin,
            style: TextStyle(
              fontSize: context.sp(28),
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              vocab.chinese,
              style: TextStyle(
                fontSize: context.sp(56),
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildVisual(),
          const SizedBox(height: 20),
          FittedBox(
            child: Text(
              vocab.english,
              style: TextStyle(
                fontSize: context.sp(24),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisual() {
    if (vocab.imagePath.isNotEmpty) {
      return LayoutBuilder(
        builder: (context, _) {
          final sz = context.s(90);
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              vocab.imagePath,
              width: sz,
              height: sz,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              errorBuilder: (_, __, ___) => _fallbackVisual(),
            ),
          );
        },
      );
    }
    return _fallbackVisual();
  }

  Widget _fallbackVisual() {
    return LayoutBuilder(
      builder: (context, _) {
        final sz = context.s(90);
        return Container(
          width: sz,
          height: sz,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            vocab.chinese.isNotEmpty ? vocab.chinese.substring(0, 1) : '?',
            style: TextStyle(fontSize: context.sp(48), color: AppColors.primary),
          ),
        );
      },
    );
  }
}

// ── Feature quick-access button
class _FeatureButton extends StatelessWidget {
  final Widget iconWidget;
  final String titleZh;
  final String titleEn;
  final VoidCallback onTap;

  const _FeatureButton({
    required this.iconWidget,
    required this.titleZh,
    required this.titleEn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: clayDecoration(color: AppColors.cardBg, radius: 22),
        child: Row(
          children: [
            Container(
              width: context.s(50),
              height: context.s(50),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: iconWidget,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    titleZh,
                    style: TextStyle(
                      fontSize: context.sp(17),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    titleEn,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverFlowDelegate extends FlowDelegate {
  final PageController controller;
  final double fallbackPage;
  final double cardWidth;
  final double overlapFactor;
  final double scaleDrop;
  final double opacityDrop;
  final int visibleSideCards;

  _CoverFlowDelegate({
    required this.controller,
    required this.fallbackPage,
    required this.cardWidth,
    required this.overlapFactor,
    required this.scaleDrop,
    required this.opacityDrop,
    required this.visibleSideCards,
  }) : super(repaint: controller);

  @override
  BoxConstraints getConstraintsForChild(
      int i, BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: cardWidth,
      maxWidth: cardWidth,
      minHeight: 0,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double page = fallbackPage;
    if (controller.hasClients && controller.position.haveDimensions) {
      page = controller.page ?? fallbackPage;
    }

    final int center = page.round();
    final int start = math.max(0, center - visibleSideCards);
    final int end = math.min(context.childCount - 1, center + visibleSideCards);
    final List<int> visible = <int>[
      for (int index = start; index <= end; index++) index,
    ];

    visible.sort(
      (a, b) => (page - b).abs().compareTo((page - a).abs()),
    );

    for (final index in visible) {
      final Size? childSize = context.getChildSize(index);
      if (childSize == null) {
        continue;
      }

      final double diff = page - index;
      final double distance = diff.abs();
      final double scale = (1.0 - (distance * scaleDrop)).clamp(0.55, 1.0);
      final double opacity =
          (1.0 - (distance * opacityDrop)).clamp(0.0, 1.0);
      final double scaledWidth = childSize.width * scale;
      final double scaledHeight = childSize.height * scale;
      final double dx =
          ((context.size.width - scaledWidth) / 2) -
          (diff * context.size.width * overlapFactor);
      final double dy = (context.size.height - scaledHeight) / 2;

      final Matrix4 transform = Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        // ignore: deprecated_member_use
        ..translate(dx, dy)
        // ignore: deprecated_member_use
        ..scale(scale, scale);

      context.paintChild(index, transform: transform, opacity: opacity);
    }
  }

  @override
  bool shouldRepaint(covariant _CoverFlowDelegate oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.fallbackPage != fallbackPage ||
        oldDelegate.cardWidth != cardWidth ||
        oldDelegate.overlapFactor != overlapFactor ||
        oldDelegate.scaleDrop != scaleDrop ||
        oldDelegate.opacityDrop != opacityDrop ||
        oldDelegate.visibleSideCards != visibleSideCards;
  }
}
