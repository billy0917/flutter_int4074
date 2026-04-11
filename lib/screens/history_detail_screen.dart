import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/learning_record.dart';
import '../models/recognition_result.dart';
import '../providers/history_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';
import '../widgets/clay_card.dart';
import '../widgets/clay_button.dart';
import '../widgets/tone_display.dart';
import '../utils/app_icons.dart';
import '../widgets/star_rating.dart';
import '../widgets/loading_animation.dart';
import '../widgets/info_row.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../utils/responsive.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import '../config/api_config.dart';

class HistoryDetailScreen extends StatefulWidget {
  final LearningRecord record;

  const HistoryDetailScreen({super.key, required this.record});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final TtsService _tts = TtsService();
  bool _loadingQuiz = false;
  String? _quizError;
  ModelPreset _selectedPreset = ModelPreset.stable;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _tts.setSpeed(StorageService.getTtsSpeed());
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  RecognitionResult _toRecognitionResult() {
    return RecognitionResult(
      objectNameZh: widget.record.objectNameZh,
      objectNameEn: widget.record.objectNameEn,
      pinyin: widget.record.pinyin,
      pinyinNoTone: widget.record.pinyinNoTone,
      characters: widget.record.characters
          .map((c) => CharacterTone(
                char: c.char,
                pinyin: c.pinyin,
                toneNumber: c.toneNumber,
                toneNameZh: c.toneNameZh,
                toneNameEn: c.toneNameEn,
              ))
          .toList(),
      cantoneseReference: widget.record.cantoneseReference,
      exampleSentenceZh: widget.record.exampleSentenceZh,
      exampleSentencePinyin: widget.record.exampleSentencePinyin,
      exampleSentenceEn: widget.record.exampleSentenceEn,
      imagePath: widget.record.imagePath,
    );
  }

  Future<void> _startQuiz() async {
    final l = AppLocalizations.of(context)!;
    setState(() {
      _loadingQuiz = true;
      _quizError = null;
    });

    final result = _toRecognitionResult();
    final questions = await ApiService.generateQuiz(result, preset: _selectedPreset);
    if (!mounted) return;

    if (questions == null || questions.isEmpty) {
      setState(() {
        _loadingQuiz = false;
        _quizError = l.errorApi;
      });
      return;
    }

    setState(() => _loadingQuiz = false);

    Navigator.pushNamed(
      context,
      AppRoutes.quiz,
      arguments: {
        'result': result,
        'questions': questions,
        'recordId': widget.record.id,
        'preset': _selectedPreset,
      },
    );
  }

  Future<void> _deleteRecord() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.historyDelete),
        content: Text(l.historyDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l.confirm,
                  style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<HistoryProvider>().deleteRecord(widget.record.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final rec = widget.record;
    final locale =
        context.watch<LocaleProvider>().locale.languageCode;
    final isZh = locale == 'zh';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(rec.objectNameZh),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: _deleteRecord,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              if (rec.imagePath.isNotEmpty &&
                  File(rec.imagePath).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  child: Image.file(
                    File(rec.imagePath),
                    height: AppConstants.imageHeight(context),
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 20),

              // Main card
              ClayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            rec.objectNameZh,
                            style: TextStyle(
                              fontSize: context.sp(48),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            rec.pinyin,
                            style: TextStyle(
                              fontSize: context.sp(28),
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24),
                    if (rec.characters.isNotEmpty) ...[
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: rec.characters
                            .map((c) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      c.char,
                                      style: TextStyle(
                                        fontSize: context.sp(22),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ToneDisplay(
                                      toneNumber: c.toneNumber,
                                      toneNameZh: isZh
                                          ? c.toneNameZh
                                          : c.toneNameEn,
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    InfoRow(
                        label: l.resultEnglish, value: rec.objectNameEn),
                    const SizedBox(height: 8),
                    if (rec.cantoneseReference.isNotEmpty)
                      InfoRow(
                          label: l.resultCantonese,
                          value: rec.cantoneseReference),
                    const SizedBox(height: 6),
                    if (rec.exampleSentenceZh.isNotEmpty) ...[
                      Text(l.resultExample,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium)),
                      const SizedBox(height: 4),
                      Text(rec.exampleSentenceZh,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textDark)),
                      Text(rec.exampleSentencePinyin,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.primary)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // TTS
              ClayButton(
                color: AppColors.tone2.withValues(alpha: 0.9),
                width: double.infinity,
                onTap: () => _tts.speak(rec.objectNameZh),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.volume_up_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      l.resultListen,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quiz history
              if (rec.quizAttempts.isNotEmpty) ...[
                ClayCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '測驗記錄',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...rec.quizAttempts.reversed.take(5).map((attempt) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                StarRating(
                                  stars: attempt.starRating,
                                  size: 18,
                                  animate: false,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${attempt.correctAnswers}/${attempt.totalQuestions}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormatter.formatDate(
                                      attempt.attemptedAt,
                                      locale: locale),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Start quiz
              // Model selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ModelPreset.values.map((preset) {
                    final selected = _selectedPreset == preset;
                    final isStable = preset == ModelPreset.stable;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPreset = preset),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isStable ? Icons.verified_rounded : Icons.bolt_rounded,
                                size: 16,
                                color: selected ? Colors.white : AppColors.textMedium,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isStable
                                    ? l.cameraModelStable
                                    : l.cameraModelFast,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                  color: selected ? Colors.white : AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              if (_loadingQuiz)
                Center(child: LoadingAnimation(message: l.generateQuizLoading))
              else
                ClayButton(
                  color: AppColors.primary,
                  width: double.infinity,
                  onTap: _startQuiz,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcons.svg(AppIcons.pencil, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        l.startQuiz,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

              if (_quizError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Text(
                        _quizError!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.modelSwitchHint,
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 12),
                        textAlign: TextAlign.center,
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
}

