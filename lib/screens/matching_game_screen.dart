import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Set<int> _celebratingIndices = <int>{};
  final _MatchSuccessSfx _matchSfx = _MatchSuccessSfx();
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
      _celebratingIndices.clear();
      _stopwatch.reset();
      _stopwatch.start();
      _initCards();
    });
  }

  void _triggerMatchFeedback(int firstIndex, int secondIndex) {
    HapticFeedback.mediumImpact();
    unawaited(_matchSfx.playSuccess());

    setState(() {
      _celebratingIndices
        ..remove(firstIndex)
        ..remove(secondIndex)
        ..addAll([firstIndex, secondIndex]);
    });

    Future<void>.delayed(const Duration(milliseconds: 720), () {
      if (!mounted) return;
      setState(() {
        _celebratingIndices.remove(firstIndex);
        _celebratingIndices.remove(secondIndex);
      });
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
        final firstIndex = _firstIndex!;
        final secondIndex = _secondIndex!;
        setState(() {
          first.isMatched = true;
          second.isMatched = true;
          _matchedPairs++;
          _firstIndex = null;
          _secondIndex = null;
          _checking = false;
        });
        _triggerMatchFeedback(firstIndex, secondIndex);
        if (_matchedPairs == widget.pairCount) {
          _stopwatch.stop();
          Future<void>.delayed(const Duration(milliseconds: 650), () {
            if (mounted) _showResultDialog();
          });
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
    unawaited(_matchSfx.dispose());
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
                    celebrate: _celebratingIndices.contains(i),
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
  final bool celebrate;
  final VoidCallback onTap;

  const _GameCardWidget({
    required this.card,
    required this.celebrate,
    required this.onTap,
  });

  @override
  State<_GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<_GameCardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnim;
  late final AnimationController _celebrateController;
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
    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
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
    if (widget.celebrate && !old.celebrate) {
      _celebrateController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipController, _celebrateController]),
        builder: (_, child) {
          final angle = _flipAnim.value * 3.1415926;
          final celebrationT = _celebrateController.value;
          final pulseScale = 1.0 + (sin(celebrationT * pi) * 0.08);
          final glowOpacity = (1.0 - celebrationT).clamp(0.0, 1.0);

          return Transform.scale(
            scale: pulseScale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: glowOpacity > 0 && celebrationT > 0
                        ? [
                            BoxShadow(
                              color: AppColors.star.withValues(
                                alpha: 0.32 * glowOpacity,
                              ),
                              blurRadius: 18 + (celebrationT * 14),
                              spreadRadius: 2 + (celebrationT * 3),
                            ),
                            BoxShadow(
                              color: AppColors.success.withValues(
                                alpha: 0.22 * glowOpacity,
                              ),
                              blurRadius: 20 + (celebrationT * 12),
                            ),
                          ]
                        : null,
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: _showFront ? _buildBack() : _buildFront(),
                  ),
                ),
                if (celebrationT > 0 && celebrationT < 1)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _MatchSparkleBurst(progress: celebrationT),
                    ),
                  ),
              ],
            ),
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

class _MatchSparkleBurst extends StatelessWidget {
  final double progress;

  const _MatchSparkleBurst({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _sparkle(
          alignment: const Alignment(-0.75, -0.8),
          distance: 18,
          icon: Icons.auto_awesome_rounded,
          color: AppColors.star,
          size: 16,
        ),
        _sparkle(
          alignment: const Alignment(0.82, -0.72),
          distance: 20,
          icon: Icons.star_rounded,
          color: AppColors.primary,
          size: 14,
        ),
        _sparkle(
          alignment: const Alignment(-0.88, 0.55),
          distance: 16,
          icon: Icons.circle,
          color: AppColors.success,
          size: 8,
        ),
        _sparkle(
          alignment: const Alignment(0.74, 0.68),
          distance: 18,
          icon: Icons.auto_awesome,
          color: AppColors.star,
          size: 12,
        ),
      ],
    );
  }

  Widget _sparkle({
    required Alignment alignment,
    required double distance,
    required IconData icon,
    required Color color,
    required double size,
  }) {
    final offset = Offset(alignment.x * distance, alignment.y * distance);
    final dx = offset.dx * progress;
    final dy = offset.dy * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = 0.6 + (0.7 * sin(progress * pi));

    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Icon(icon, color: color, size: size),
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

class _MatchSuccessSfx {
  final AudioPlayer _player = AudioPlayer();
  static final Uint8List _wavBytes = _buildSuccessWav();

  Future<void> playSuccess() async {
    try {
      await _player.stop();
      await _player.play(BytesSource(_wavBytes));
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  static Uint8List _buildSuccessWav() {
    const sampleRate = 22050;
    const gapMs = 18;
    final notes = <(double freq, int lengthMs, double volume)>[
      (659.25, 70, 0.30),
      (783.99, 85, 0.28),
      (987.77, 150, 0.25),
    ];

    final totalSamples = notes.fold<int>(
      0,
      (sum, note) => sum +
          ((sampleRate * note.$2) ~/ 1000) +
          ((sampleRate * gapMs) ~/ 1000),
    );
    final dataLength = totalSamples * 2;
    final byteData = ByteData(44 + dataLength);

    void writeString(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        byteData.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    byteData.setUint32(4, 36 + dataLength, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little);
    byteData.setUint16(22, 1, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little);
    byteData.setUint16(32, 2, Endian.little);
    byteData.setUint16(34, 16, Endian.little);
    writeString(36, 'data');
    byteData.setUint32(40, dataLength, Endian.little);

    var writeOffset = 44;
    for (final note in notes) {
      final noteSamples = (sampleRate * note.$2) ~/ 1000;
      for (var i = 0; i < noteSamples; i++) {
        final progress = i / noteSamples;
        final attack = (progress / 0.12).clamp(0.0, 1.0);
        final decay = ((1.0 - progress) / 0.40).clamp(0.0, 1.0);
        final envelope = attack < decay ? attack : decay;
        final t = i / sampleRate;
        final wave =
            (sin(2 * pi * note.$1 * t) + (0.35 * sin(4 * pi * note.$1 * t))) /
                1.35;
        final sample = (wave * note.$3 * envelope * 32767).round();
        byteData.setInt16(writeOffset, sample, Endian.little);
        writeOffset += 2;
      }

      final silenceSamples = (sampleRate * gapMs) ~/ 1000;
      for (var i = 0; i < silenceSamples; i++) {
        byteData.setInt16(writeOffset, 0, Endian.little);
        writeOffset += 2;
      }
    }

    return byteData.buffer.asUint8List();
  }
}
