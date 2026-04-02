import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../config/theme.dart';
import '../models/daily_phrase.dart';
import '../services/tts_service.dart';
import '../services/sense_voice_service.dart';
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

  List<DailyPhrase> get _phrases => widget.category.phrases;
  DailyPhrase get _current => _phrases[_currentIndex];

  @override
  void initState() {
    super.initState();
    _tts.init();
    _isModelReady = _stt.isModelReady;
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
    // Auto-play TTS for first card
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _tts.speak(_current.chinese);
    });
  }

  @override
  void dispose() {
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

  /// Initialize STT model (copy from assets on first launch).
  Future<void> _initModel() async {
    final ok = await _stt.init();
    if (!mounted) return;
    setState(() {
      _isModelReady = ok;
    });
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
      if (mounted) _tts.speak(_phrases[index].chinese);
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
    setState(() {
      _isListening = false;
      _isTranscribing = false;
      _recognizedText = recognized;
      _score = score;
      _hasAttempted = true;
    });
    HapticFeedback.lightImpact();
  }

  /// Scoring algorithm inspired by voice3's ScoringEngine:
  /// score = textMatchScore * 0.6 + confidence * 0.4 * 100
  double _calculateScore(
      String recognized, String expected, double confidence) {
    if (recognized.isEmpty) return 0;

    final recNorm = _normalize(recognized);
    final expNorm = _normalize(expected);

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
      .replaceAll(
        RegExp("[，。！？、；：\"'（）《》—…,.!?;:()\\[\\]{}-]"), '')
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
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1]
              ? dp[i - 1][j]
              : dp[i][j - 1];
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
        title: Text('${widget.category.emoji} $catName'),
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
                    onTap: () => _tts.speak(_current.chinese),
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
                          : () => Navigator.pop(context),
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
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pinyin
          Text(
            _current.pinyin,
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.textMedium,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Chinese characters
          Text(
            _current.chinese,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
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
                style: const TextStyle(
                  fontSize: 18,
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
              child: CircularProgressIndicator(strokeWidth: 2.5),
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 30),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bgColor.withOpacity(isListening ? 0.9 : 0.85),
              shape: BoxShape.circle,
              boxShadow: [
                if (isListening)
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                else
                  BoxShadow(
                    color: bgColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Icon(
              isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: Colors.white,
              size: 36,
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

// ── Score display widget
class _ScoreDisplay extends StatelessWidget {
  final double score;
  final String recognizedText;
  final String expectedText;

  const _ScoreDisplay({
    required this.score,
    required this.recognizedText,
    required this.expectedText,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final int scoreInt = score.round();
    final Color scoreColor;
    final String emoji;
    final String feedback;

    if (scoreInt >= 80) {
      scoreColor = AppColors.success;
      emoji = '🎉';
      feedback = l.phraseScoreExcellent;
    } else if (scoreInt >= 60) {
      scoreColor = AppColors.primary;
      emoji = '👍';
      feedback = l.phraseScoreGood;
    } else if (scoreInt >= 30) {
      scoreColor = AppColors.star;
      emoji = '💪';
      feedback = l.phraseScoreTryAgain;
    } else {
      scoreColor = AppColors.error;
      emoji = '🔄';
      feedback = l.phraseScoreRetry;
    }

    return Column(
      children: [
        // Score circle
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scoreColor.withOpacity(0.12),
            border: Border.all(color: scoreColor, width: 3),
          ),
          alignment: Alignment.center,
          child: Text(
            '$scoreInt',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$emoji $feedback',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scoreColor,
          ),
        ),
        if (recognizedText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            l.phraseYouSaid(recognizedText),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ],
    );
  }
}
