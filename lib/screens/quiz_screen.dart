import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/quiz_question.dart';
import '../models/recognition_result.dart';
import '../models/learning_record.dart';
import '../providers/history_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';
import '../widgets/clay_button.dart';
import '../widgets/clay_card.dart';
import '../widgets/tone_drawing_canvas.dart';
import '../utils/app_icons.dart';
import '../widgets/tone_painter.dart';
import '../widgets/loading_animation.dart';
import '../utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class QuizScreen extends StatefulWidget {
  final RecognitionResult recognitionResult;
  final List<QuizQuestion> questions;
  final String recordId;
  final ModelPreset preset;

  const QuizScreen({
    super.key,
    required this.recognitionResult,
    required this.questions,
    required this.recordId,
    this.preset = ModelPreset.fast,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  bool? _isCorrect;
  String _feedback = '';
  final List<Map<String, dynamic>> _results = [];
  final TtsService _tts = TtsService();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  late AnimationController _correctController;
  late AnimationController _starController;

  final GlobalKey<ToneDrawingCanvasState> _canvasKey =
      GlobalKey<ToneDrawingCanvasState>();
  List<Offset> _strokePoints = [];
  Size _canvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _tts.setSpeed(StorageService.getTtsSpeed());

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _correctController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _tts.dispose();
    _shakeController.dispose();
    _correctController.dispose();
    _starController.dispose();
    super.dispose();
  }

  QuizQuestion get _current => widget.questions[_currentIndex];

  Future<void> _submitDrawTone() async {
    if (_strokePoints.isEmpty) return;
    final l = AppLocalizations.of(context)!;

    final judgment = ApiService.judgeToneDrawing(
      targetTone: _current.correctTone ?? 1,
      strokePoints: _strokePoints,
      canvasSize: _canvasSize,
      preset: widget.preset,
    );

    if (!mounted) return;

    final isCorrect = judgment?.isCorrect ?? false;
    final feedback = judgment?.feedbackZh ??
        (isCorrect ? l.quizCorrect : l.quizIncorrect);

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
      _feedback = feedback;
    });

    _onAnswered(
      isCorrect: isCorrect,
      userAnswer: '手繪聲調',
      correctAnswer: '第${_current.correctTone}聲',
    );
  }

  void _selectOption(int index) {
    if (_answered) return;
    final l = AppLocalizations.of(context)!;
    final isCorrect = index == _current.correctIndex;

    setState(() {
      _selectedOption = index;
      _answered = true;
      _isCorrect = isCorrect;
      _feedback = isCorrect ? l.quizCorrect : l.quizIncorrect;
    });

    // Play TTS for listen_pick_char
    if (_current.type == 'listen_pick_char' && _current.ttsText != null) {
      _tts.speak(_current.ttsText!);
    }

    _onAnswered(
      isCorrect: isCorrect,
      userAnswer: index < _current.options.length
          ? _current.options[index]
          : index.toString(),
      correctAnswer: _current.correctIndex < _current.options.length
          ? _current.options[_current.correctIndex]
          : _current.correctIndex.toString(),
    );
  }

  void _onAnswered({
    required bool isCorrect,
    required String userAnswer,
    required String correctAnswer,
  }) {
    final locale =
        context.read<LocaleProvider>().locale.languageCode;
    _results.add({
      'isCorrect': isCorrect,
      'type': _current.type,
      'questionText': locale == 'zh'
          ? _current.questionZh
          : _current.questionEn,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
    });

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _correctController.forward(from: 0);
    } else {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
    }
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
        _isCorrect = null;
        _feedback = '';
        _strokePoints = [];
      });
      _canvasKey.currentState?.clear();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final correct =
        _results.where((r) => r['isCorrect'] == true).length;
    final total = widget.questions.length;
    final pct = total > 0 ? (correct / total) : 0.0;
    final stars = pct >= 0.8
        ? 3
        : pct >= 0.6
            ? 2
            : 1;

    // Save quiz attempt to record
    if (widget.recordId.isNotEmpty) {
      final record = StorageService.getRecord(widget.recordId);
      if (record != null) {
        final attempt = QuizAttempt()
          ..attemptedAt = DateTime.now()
          ..totalQuestions = total
          ..correctAnswers = correct
          ..starRating = stars
          ..details = _results
              .map((r) => QuizQuestionResult()
                ..type = r['type'] as String
                ..questionText = r['questionText'] as String
                ..isCorrect = r['isCorrect'] as bool
                ..userAnswer = r['userAnswer'] as String
                ..correctAnswer = r['correctAnswer'] as String)
              .toList();
        record.quizAttempts.add(attempt);
        await record.save();
        if (mounted) {
          context.read<HistoryProvider>().loadRecords();
        }
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.quizResult,
        arguments: {
          'correct': correct,
          'total': total,
          'details': _results,
          'recordId': widget.recordId,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final total = widget.questions.length;
    final progress = (_currentIndex + 1) / total;
    final locale =
        context.watch<LocaleProvider>().locale.languageCode;
    final isZh = locale == 'zh';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.quizTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            AppColors.textLight.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.quizQuestionOf(_currentIndex + 1, total),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMedium),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Question card
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                ),
                child: ClayCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isZh ? _current.questionZh : _current.questionEn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuestionBody(isZh, l),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Feedback
              if (_answered) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_isCorrect == true)
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (_isCorrect == true)
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _isCorrect == true ? '✅' : '❌',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _feedback,
                          style: TextStyle(
                            fontSize: 14,
                            color: (_isCorrect == true)
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ClayButton(
                  color: AppColors.primary,
                  width: double.infinity,
                  onTap: _nextQuestion,
                  child: Center(
                    child: _currentIndex < total - 1
                        ? Text(
                            l.quizNext,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '完成',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AppIcons.svg(AppIcons.party, size: 20),
                            ],
                          ),
                  ),
                ),
              ],

              // Submit button for draw tone
              if (_current.type == 'draw_tone' && !_answered) ...[
                const SizedBox(height: 12),
                ClayButton(
                    color: AppColors.primary,
                    width: double.infinity,
                    onTap:
                        _strokePoints.isNotEmpty ? _submitDrawTone : null,
                    child: Center(
                      child: Text(
                        l.quizSubmit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildQuestionBody(bool isZh, AppLocalizations l) {
    switch (_current.type) {
      case 'draw_tone':
        return _buildDrawTone(l);
      case 'listen_pick_char':
        return _buildListenPick(isZh, l);
      case 'match_tone_shape':
        return _buildToneShapePick(isZh);
      default:
        return _buildMultipleChoice(isZh);
    }
  }

  Widget _buildDrawTone(AppLocalizations l) {
    return Column(
      children: [
        Text(
          l.quizDrawHint,
          style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (ctx, constraints) {
            _canvasSize = Size(constraints.maxWidth, 180);
            return ToneDrawingCanvas(
              key: _canvasKey,
              height: 180,
              onStrokeChanged: (pts) =>
                  setState(() => _strokePoints = pts),
            );
          },
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          label: Text(l.quizClear,
              style: const TextStyle(color: AppColors.error)),
          onPressed: () {
            _canvasKey.currentState?.clear();
            setState(() => _strokePoints = []);
          },
        ),
        // Show correct tone after answered
        if (_answered)
          Column(
            children: [
              const SizedBox(height: 8),
              Text(
                '正確聲調走勢：',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMedium),
              ),
              const SizedBox(height: 8),
              ToneContourWidget(
                toneNumber: _current.correctTone ?? 1,
                width: 120,
                height: 60,
                animate: true,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildListenPick(bool isZh, AppLocalizations l) {
    return Column(
      children: [
        if (_current.ttsText != null)
          ClayButton(
            color: AppColors.tone2.withValues(alpha: 0.9),
            onTap: () => _tts.speak(_current.ttsText!),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.volume_up_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcons.svg(AppIcons.speaker, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    const Text('播放發音',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        ..._buildOptions(isZh),
      ],
    );
  }

  Widget _buildToneShapePick(bool isZh) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: List.generate(_current.options.length, (i) {
        final label = isZh
            ? (_current.optionLabelsZh?[i] ?? _current.options[i])
            : (_current.optionLabelsEn?[i] ?? _current.options[i]);
        final toneMap = {
          'flat_high': 1,
          'rising': 2,
          'dipping': 3,
          'falling': 4
        };
        final toneNum = toneMap[_current.options[i]] ?? 1;
        return _OptionButton(
          label: label,
          index: i,
          isSelected: _selectedOption == i,
          isCorrect: _answered ? i == _current.correctIndex : null,
          answered: _answered,
          onTap: () => _selectOption(i),
          prefix: ToneContourWidget(
              toneNumber: toneNum, width: 40, height: 20),
        );
      }),
    );
  }

  Widget _buildMultipleChoice(bool isZh) {
    return Column(children: _buildOptions(isZh));
  }

  List<Widget> _buildOptions(bool isZh) {
    final options = _current.options;
    return List.generate(options.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _OptionButton(
          label: options[i],
          index: i,
          isSelected: _selectedOption == i,
          isCorrect: _answered ? i == _current.correctIndex : null,
          answered: _answered,
          onTap: () => _selectOption(i),
        ),
      );
    });
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final bool? isCorrect;
  final bool answered;
  final VoidCallback onTap;
  final Widget? prefix;

  const _OptionButton({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.answered,
    required this.onTap,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.cardBgAlt;
    Color borderColor = Colors.transparent;

    if (answered && isCorrect == true) {
      bgColor = AppColors.success.withValues(alpha: 0.2);
      borderColor = AppColors.success;
    } else if (answered && isSelected && isCorrect == false) {
      bgColor = AppColors.error.withValues(alpha: 0.2);
      borderColor = AppColors.error;
    } else if (!answered && isSelected) {
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      borderColor = AppColors.primary;
    }

    final labels = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  index < labels.length ? labels[index] : '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
