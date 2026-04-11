import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import '../config/theme.dart';
import '../models/vocabulary_item.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../utils/responsive.dart';

// ─────────────────────────────────────────────────────────
//  Card data for the matching game
// ─────────────────────────────────────────────────────────

enum _CardType { pinyin, image }

class _MatchCard {
  final int pairId;
  final _CardType type;
  final VocabularyItem vocab;
  bool isFlipped;
  bool isMatched;

  _MatchCard({
    required this.pairId,
    required this.type,
    required this.vocab,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

// ─────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────

class MatchingGameScreen extends StatefulWidget {
  /// Number of pairs (e.g. 6 → 12 cards in a 3×4 grid).
  final int pairCount;

  const MatchingGameScreen({super.key, this.pairCount = 6});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen>
    with TickerProviderStateMixin {
  late List<_MatchCard> _cards;
  int? _firstIndex;
  int? _secondIndex;
  bool _checking = false;
  int _matchedPairs = 0;
  int _attempts = 0;
  int _earnedXp = 0;
  late final Stopwatch _stopwatch;
  late final AnimationController _headerController;
  late final Animation<double> _headerFade;
  final TtsService _tts = TtsService();

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerController.forward();
    _initCards();
  }

  void _initCards() {
    final all = VocabularyItem.allWithImages();
    all.shuffle(Random());
    final selected = all.take(widget.pairCount).toList();

    _cards = <_MatchCard>[];
    for (int i = 0; i < selected.length; i++) {
      _cards.add(_MatchCard(
        pairId: i,
        type: _CardType.pinyin,
        vocab: selected[i],
      ));
      _cards.add(_MatchCard(
        pairId: i,
        type: _CardType.image,
        vocab: selected[i],
      ));
    }
    _cards.shuffle(Random());
  }

  void _restartGame() {
    setState(() {
      _firstIndex = null;
      _secondIndex = null;
      _checking = false;
      _matchedPairs = 0;
      _attempts = 0;
      _stopwatch.reset();
      _stopwatch.start();
      _initCards();
    });
  }

  void _onCardTap(int index) {
    if (_checking) return;
    final card = _cards[index];
    if (card.isFlipped || card.isMatched) return;

    setState(() => card.isFlipped = true);

    // Pronounce pinyin via TTS when a pinyin card is tapped
    if (card.type == _CardType.pinyin) {
      _tts.speak(card.vocab.chinese);
    }

    if (_firstIndex == null) {
      _firstIndex = index;
      return;
    }

    _secondIndex = index;
    _attempts++;
    _checking = true;

    final first = _cards[_firstIndex!];
    final second = _cards[_secondIndex!];

    if (first.pairId == second.pairId) {
      // Match found
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() {
          first.isMatched = true;
          second.isMatched = true;
          _matchedPairs++;
          _firstIndex = null;
          _secondIndex = null;
          _checking = false;
        });
        if (_matchedPairs == widget.pairCount) {
          _stopwatch.stop();
          _showResultDialog();
        }
      });
    } else {
      // No match — flip back
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          first.isFlipped = false;
          second.isFlipped = false;
          _firstIndex = null;
          _secondIndex = null;
          _checking = false;
        });
      });
    }
  }

  void _showResultDialog() async {
    final l = AppLocalizations.of(context)!;
    final seconds = _stopwatch.elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    int stars;
    if (_attempts <= widget.pairCount + 2) {
      stars = 3;
    } else if (_attempts <= widget.pairCount * 2) {
      stars = 2;
    } else {
      stars = 1;
    }

    // Award EXP based on star rating
    _earnedXp = stars * 10; // 30 / 20 / 10 XP
    await StorageService.addXp(_earnedXp);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.matchingGameComplete,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.star,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l.matchingGameTime(timeStr),
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.matchingGameAttemptsSummary(_attempts),
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.matchingGameEarnedXp(_earnedXp),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: l.matchingGamePlayAgain,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(ctx);
                        _restartGame();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: l.matchingGameBackHome,
                      color: AppColors.success,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────

  @override
  void dispose() {
    _headerController.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header bar
            FadeTransition(
              opacity: _headerFade,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textDark),
                    ),
                    Expanded(
                      child: Text(
                        l.matchingGameTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    // Placeholder to balance the back button
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // ── Status bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusChip(
                    icon: Icons.touch_app_rounded,
                    text: l.matchingGameAttemptsChip(_attempts),
                  ),
                  _StatusChip(
                    icon: Icons.check_circle_outline_rounded,
                    text: l.matchingGameMatchedChip(
                      _matchedPairs,
                      widget.pairCount,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ── Card grid (3 columns × 4 rows, square cards)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (_, i) => _GameCardWidget(
                    card: _cards[i],
                    onTap: () => _onCardTap(i),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Game card with flip animation
// ─────────────────────────────────────────────────────────

class _GameCardWidget extends StatefulWidget {
  final _MatchCard card;
  final VoidCallback onTap;

  const _GameCardWidget({required this.card, required this.onTap});

  @override
  State<_GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<_GameCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnim;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _flipController.addListener(() {
      final half = _flipAnim.value >= 0.5;
      if (half != !_showFront) {
        setState(() => _showFront = !half);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _GameCardWidget old) {
    super.didUpdateWidget(old);
    if (widget.card.isFlipped || widget.card.isMatched) {
      if (_flipController.status != AnimationStatus.forward &&
          _flipController.status != AnimationStatus.completed) {
        _flipController.forward();
      }
    } else {
      if (_flipController.status != AnimationStatus.reverse &&
          _flipController.status != AnimationStatus.dismissed) {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnim,
        builder: (_, child) {
          final angle = _flipAnim.value * 3.1415926;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: _showFront ? _buildBack() : _buildFront(),
          );
        },
      ),
    );
  }

  /// The face-down (hidden) side.
  Widget _buildBack() {
    return Container(
      decoration: clayDecoration(
        color: AppColors.primaryLight,
        radius: 18,
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// The face-up (revealed) side — must be mirrored back because the
  /// parent `Transform` already rotated it 180°.
  Widget _buildFront() {
    final card = widget.card;
    final matched = card.isMatched;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.1415926),
      child: Container(
        decoration: clayDecoration(
          color: matched ? AppColors.success.withValues(alpha: 0.25) : Colors.white,
          radius: 18,
        ),
        child: card.type == _CardType.pinyin
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      card.vocab.pinyin,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: matched
                            ? AppColors.success
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  card.vocab.imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      card.vocab.chinese,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Tiny helper widgets
// ─────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatusChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
