import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../config/theme.dart';
import '../models/daily_phrase.dart';
import '../services/tts_service.dart';
import '../services/phrase_audio_service.dart';
import '../services/sense_voice_service.dart';
import '../services/storage_service.dart';
import '../config/game_config.dart';
import '../utils/app_icons.dart';
import '../utils/chinese_convert.dart';
import '../utils/responsive.dart';
import '../widgets/clay_button.dart';
import '../widgets/clay_card.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class PhraseLearningScreen extends StatefulWidget {
  final PhraseCategory category;

  const PhraseLearningScreen({super.key, required this.category});

  @override
  State<PhraseLearningScreen> createState() => _PhraseLearningScreenState();
}

class _PhraseLearningScreenState extends State<PhraseLearningScreen>
    with TickerProviderStateMixin {
  final TtsService _tts = TtsService();
  final PhraseAudioService _phraseAudio = PhraseAudioService();
  final SenseVoiceService _stt = SenseVoiceService.instance;
  StreamSubscription<String>? _partialResultSubscription;
  int _currentIndex = 0;
  bool _showEnglish = false;
  late AnimationController _cardController;
  late AnimationController _progressController;

  // ── STT state
  bool _isListening = false;
  String _recognizedText = '';
  double? _score;
  bool _hasAttempted = false;
  bool _isTranscribing = false;

  // ── Model state
  bool _isModelReady = false;

  // ── Score tracking
  final Map<int, double> _bestScores = {};
  final Map<int, int> _attemptCounts = {};
  int _sessionXp = 0;
  int _lastXpEarned = 0;
  bool _imagesPrecached = false;

  List<DailyPhrase> get _phrases => widget.category.phrases;
  DailyPhrase get _current => _phrases[_currentIndex];

  @override
  void initState() {
    super.initState();
    _isModelReady = _stt.isModelReady;
    _loadSavedScores();
    _partialResultSubscription = _stt.partialResults.listen((text) {
      if (!mounted) {
        return;
      }

      setState(() {
        _recognizedText = text;
      });
    });
    if (!_isModelReady) _initModel();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _updateProgress();
    // Auto-play audio for first card
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _playCurrentPhrase();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      for (final phrase in _phrases) {
        precacheImage(AssetImage(phrase.imagePath), context);
      }
    }
  }

  /// Play current phrase audio (edge-tts asset), fallback to device TTS.
  Future<void> _playCurrentPhrase() async {
    final ok = await _phraseAudio.play(widget.category.id, _currentIndex);
    if (!ok) {
      await _tts.init();
      await _tts.speak(_current.chinese);
    }
  }

  @override
  void dispose() {
    _phraseAudio.dispose();
    _tts.dispose();
    _partialResultSubscription?.cancel();
    // Don't dispose the singleton STT service
    _cardController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    _progressController.animateTo(
      (_currentIndex + 1) / _phrases.length,
      curve: Curves.easeOut,
    );
  }

  void _loadSavedScores() {
    final catId = widget.category.id;
    for (var i = 0; i < _phrases.length; i++) {
      final best = StorageService.getPhraseBestScore(catId, i);
      if (best != null) _bestScores[i] = best;
      final att = StorageService.getPhraseAttempts(catId, i);
      if (att > 0) _attemptCounts[i] = att;
    }
  }

  /// Initialize STT model (copy from assets on first launch).
  Future<void> _initModel() async {
    final ok = await _stt.init();
    if (!mounted) return;
    setState(() {
      _isModelReady = ok;
    });
  }

  void _showSummaryDialog() {
    final practiced = _bestScores.length;
    final total = _phrases.length;

    // Stars summary
    int totalStars = 0;
    for (final score in _bestScores.values) {
      totalStars += GameConfig.starsForScore(score);
    }
    final maxStars = total * 3;

    // Level info
    final totalXp = StorageService.getTotalXp();
    final level = GameConfig.levelForXp(totalXp);
    final nextLvl = GameConfig.nextLevel(totalXp);
    final progress = GameConfig.levelProgress(totalXp);

    final feedbackPath = totalStars >= practiced * 2
        ? AppIcons.party
        : totalStars >= practiced
            ? AppIcons.thumbsup
            : AppIcons.flex;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcons.svg(feedbackPath, size: 28),
            const SizedBox(width: 8),
            const Text('練習完成！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Session XP
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '+$_sessionXp XP',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Level progress
            Row(
              children: [
                AppIcons.svg(AppIcons.levelIcon(level.level), size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lv.${level.level} ${level.titleZh}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.cardBg,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                      ),
                      if (nextLvl != null)
                        Text(
                          '$totalXp / ${nextLvl.xpRequired} XP',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textLight),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stars summary
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcons.svg(AppIcons.star,
                    size: 22, color: const Color(0xFFFFD93D)),
                const SizedBox(width: 4),
                Text(
                  '$totalStars / $maxStars',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            // Per-phrase breakdown with stars
            ...List.generate(_phrases.length, (i) {
              final best = _bestScores[i];
              final stars = best != null ? GameConfig.starsForScore(best) : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _phrases[i].chinese,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    best != null
                        ? AppIcons.starRow(stars, size: 16)
                        : AppIcons.starRow(0, size: 16),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  Future<void> _goTo(int index) async {
    if (index < 0 || index >= _phrases.length) return;
    if (_isListening) await _stt.cancel();
    // Animate out
    await _cardController.reverse();
    setState(() {
      _currentIndex = index;
      _showEnglish = false;
      _recognizedText = '';
      _score = null;
      _hasAttempted = false;
    });
    _updateProgress();
    // Animate in
    _cardController.forward();
    HapticFeedback.lightImpact();
    // Auto-play
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _playCurrentPhrase();
    });
  }

  void _toggleEnglish() {
    setState(() => _showEnglish = !_showEnglish);
    HapticFeedback.selectionClick();
  }

  // ── Speech recognition — tap once to start live recognition, tap again to stop
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
      return;
    }
    await _startListening();
  }

  Future<void> _startListening() async {
    await _phraseAudio.stop();
    await _tts.stop();

    if (_stt.isInitializing) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('語音模型正在準備中，請稍候...'),
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }

    if (!_isModelReady) {
      await _initModel();
      if (!_isModelReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('語音模型初始化失敗，請稍後再試'),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _score = null;
      _hasAttempted = false;
      _isTranscribing = false;
    });
    HapticFeedback.mediumImpact();

    final started = await _stt.startRecording();
    if (!started && mounted) {
      setState(() => _isListening = false);
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.phraseSttUnavailable),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    setState(() {
      _isListening = false;
      _isTranscribing = true;
    });
    HapticFeedback.lightImpact();

    await Future<void>.delayed(const Duration(milliseconds: 16));

    final result = await _stt.stopAndTranscribe();
    if (!mounted) return;

    if (result.success) {
      _onRecognitionComplete(result.text, 0.90);
    } else {
      setState(() => _isTranscribing = false);
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error ?? l.phraseSttError),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _onRecognitionComplete(String recognized, double confidence) {
    final score = _calculateScore(recognized, _current.chinese, confidence);
    final isFirstAttempt = (_attemptCounts[_currentIndex] ?? 0) == 0;
    final xp = GameConfig.xpForAttempt(score, isFirstAttempt: isFirstAttempt);

    setState(() {
      _isListening = false;
      _isTranscribing = false;
      _recognizedText = recognized;
      _score = score;
      _hasAttempted = true;
      _lastXpEarned = xp;
      _sessionXp += xp;

      // Update local best score
      final prev = _bestScores[_currentIndex];
      if (prev == null || score > prev) {
        _bestScores[_currentIndex] = score;
      }
      _attemptCounts[_currentIndex] = (_attemptCounts[_currentIndex] ?? 0) + 1;
    });
    HapticFeedback.lightImpact();

    // Persist to Hive
    StorageService.savePhraseScore(
      categoryId: widget.category.id,
      phraseIndex: _currentIndex,
      score: score,
    );
    StorageService.addXp(xp);
    StorageService.updateStreak();
  }

  /// Scoring algorithm inspired by voice3's ScoringEngine:
  /// score = textMatchScore * 0.6 + confidence * 0.4 * 100
  ///
  /// Both recognized (simplified from STT) and expected (traditional from
  /// phrase data) are normalised to simplified Chinese before comparison.
  double _calculateScore(
      String recognized, String expected, double confidence) {
    if (recognized.isEmpty) return 0;

    final recNorm = _normalize(ChineseConvert.toSimplified(recognized));
    final expNorm = _normalize(ChineseConvert.toSimplified(expected));

    // Exact match
    if (recNorm == expNorm) {
      return (100.0 * 0.6 + confidence * 100 * 0.4).clamp(0, 100);
    }

    // Character-level similarity (LCS-based)
    final lcsLen = _lcsLength(recNorm, expNorm);
    final maxLen =
        recNorm.length > expNorm.length ? recNorm.length : expNorm.length;
    final matchRatio = maxLen > 0 ? lcsLen / maxLen : 0.0;
    final textScore = matchRatio * 100;

    return (textScore * 0.6 + confidence * 100 * 0.4).clamp(0, 100);
  }

  /// Normalize Chinese text: remove whitespace and punctuation
  String _normalize(String s) {
    return s
        .replaceAll(RegExp(r'[\s\u3000]+'), '') // CJK & latin whitespace
        .replaceAll(RegExp("[，。！？、；：\"'（）《》—…,.!?;:()\\[\\]{}-]"), '')
        .toLowerCase();
  }

  /// Longest common subsequence length
  int _lcsLength(String a, String b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }
    return dp[m][n];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    final catName = isZh ? widget.category.nameZh : widget.category.nameEn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(catName),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // ── Progress bar
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${_currentIndex + 1} / ${_phrases.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (ctx, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          minHeight: 8,
                          backgroundColor: AppColors.cardBg,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // ── Main phrase card
              FadeTransition(
                opacity: _cardController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.15, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _cardController,
                    curve: Curves.easeOut,
                  )),
                  child: _buildPhraseCard(),
                ),
              ),

              const Spacer(flex: 1),

              // ── Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Listen button
                  _CircleAction(
                    icon: Icons.volume_up_rounded,
                    color: AppColors.primary,
                    label: l.phraseListenAgain,
                    onTap: () => _playCurrentPhrase(),
                  ),
                  const SizedBox(width: 20),
                  // Mic button
                  _MicButton(
                    isListening: _isListening,
                    available: true, // always show; error handled in toggle
                    onTap: _toggleListening,
                  ),
                  const SizedBox(width: 20),
                  // Show/hide English
                  _CircleAction(
                    icon: _showEnglish
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.tone2,
                    label: _showEnglish
                        ? l.phraseHideTranslation
                        : l.phraseShowTranslation,
                    onTap: _toggleEnglish,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Navigation
              Row(
                children: [
                  Expanded(
                    child: ClayButton(
                      color: _currentIndex > 0
                          ? AppColors.cardBg
                          : AppColors.cardBgAlt,
                      onTap: _currentIndex > 0
                          ? () => _goTo(_currentIndex - 1)
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_rounded,
                              color: _currentIndex > 0
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                              size: 20),
                          const SizedBox(width: 6),
                          Text(
                            l.phrasePrevious,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _currentIndex > 0
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClayButton(
                      color: _currentIndex < _phrases.length - 1
                          ? AppColors.primary
                          : AppColors.success,
                      onTap: _currentIndex < _phrases.length - 1
                          ? () => _goTo(_currentIndex + 1)
                          : _showSummaryDialog,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex < _phrases.length - 1
                                ? l.phraseNext
                                : l.phraseFinish,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _currentIndex < _phrases.length - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhraseCard() {
    final l = AppLocalizations.of(context)!;
    final bestScore = _bestScores[_currentIndex];
    final attempts = _attemptCounts[_currentIndex] ?? 0;
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Best score badge
          if (bestScore != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  GameConfig.starDisplay(GameConfig.starsForScore(bestScore)),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  '練習 $attempts 次',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // 詞彙圖片
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              _current.imagePath,
              width: context.s(100),
              height: context.s(100),
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          const SizedBox(height: 12),
          // Pinyin
          Text(
            _current.pinyin,
            style: TextStyle(
              fontSize: context.sp(20),
              color: AppColors.textMedium,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Chinese characters
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _current.chinese,
              style: TextStyle(
                fontSize: context.sp(48),
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // English translation (toggle)
          AnimatedOpacity(
            opacity: _showEnglish ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: AnimatedSlide(
              offset: _showEnglish ? Offset.zero : const Offset(0, 0.2),
              duration: const Duration(milliseconds: 250),
              child: Text(
                _current.english,
                style: TextStyle(
                  fontSize: context.sp(18),
                  color: AppColors.tone2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // ── Listening / transcribing indicator
          if (_isListening) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _PulsingDot(),
                const SizedBox(width: 8),
                Text(
                  l.phraseListening,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (_isTranscribing && !_isListening && !_hasAttempted) ...[
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '識別中...',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (_isListening && _recognizedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBgAlt,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    '即時識別',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _recognizedText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── Score result
          if (_hasAttempted && !_isListening) ...[
            const SizedBox(height: 16),
            _ScoreDisplay(
              score: _score ?? 0,
              recognizedText: _recognizedText,
              expectedText: _current.chinese,
              xpEarned: _lastXpEarned,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Animated progress builder helper
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder(
      {super.key, required this.animation, required this.builder});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder_(animation: animation, builder: builder);
  }
}

class AnimatedBuilder_ extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder_(
      {super.key, required Animation<double> animation, required this.builder})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}

// ── Circle action button
class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: context.s(64),
            height: context.s(64),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: context.s(30)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
      ],
    );
  }
}

// ── Mic button with press-and-hold interaction
class _MicButton extends StatelessWidget {
  final bool isListening;
  final bool available;
  final VoidCallback onTap;

  const _MicButton({
    required this.isListening,
    required this.available,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bgColor = isListening ? AppColors.error : AppColors.primary;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.s(72),
            height: context.s(72),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: isListening ? 0.9 : 0.85),
              shape: BoxShape.circle,
              boxShadow: [
                if (isListening)
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                else
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Icon(
              isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: Colors.white,
              size: context.s(36),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isListening ? l.phraseStopRecording : l.phraseTapToSpeak,
          style: TextStyle(
            fontSize: 12,
            color: isListening ? AppColors.error : AppColors.textMedium,
            fontWeight: isListening ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ── Pulsing red dot for recording indicator
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(Tween(begin: 0.3, end: 1.0)),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Score display widget with animated stars
class _ScoreDisplay extends StatefulWidget {
  final double score;
  final String recognizedText;
  final String expectedText;
  final int xpEarned;

  const _ScoreDisplay({
    required this.score,
    required this.recognizedText,
    required this.expectedText,
    required this.xpEarned,
  });

  @override
  State<_ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<_ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final stars = GameConfig.starsForScore(widget.score);
    final int scoreInt = widget.score.round();
    final Color scoreColor;
    final String iconPath;
    final String feedback;

    if (scoreInt >= 80) {
      scoreColor = AppColors.success;
      iconPath = AppIcons.party;
      feedback = l.phraseScoreExcellent;
    } else if (scoreInt >= 60) {
      scoreColor = AppColors.primary;
      iconPath = AppIcons.thumbsup;
      feedback = l.phraseScoreGood;
    } else if (scoreInt >= 30) {
      scoreColor = AppColors.star;
      iconPath = AppIcons.flex;
      feedback = l.phraseScoreTryAgain;
    } else {
      scoreColor = AppColors.error;
      iconPath = AppIcons.refresh;
      feedback = l.phraseScoreRetry;
    }

    return Column(
      children: [
        // Animated stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final filled = i < stars;
            final delay = i * 0.18;
            final end = (delay + 0.35).clamp(0.0, 1.0);
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Interval(delay, end, curve: Curves.elasticOut),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AppIcons.svg(
                  filled ? AppIcons.star : AppIcons.starOutline,
                  size: filled ? 44 : 38,
                  color: filled ? const Color(0xFFFFD93D) : AppColors.textLight,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Score + feedback
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.7),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcons.svg(iconPath, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    feedback,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$scoreInt 分',
                style: TextStyle(
                  fontSize: 14,
                  color: scoreColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // XP badge
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.6, 0.9),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${widget.xpEarned} XP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        if (widget.recognizedText.isNotEmpty) ...[
          const SizedBox(height: 6),
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.7, 1.0),
            ),
            child: Text(
              l.phraseYouSaid(widget.recognizedText),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
