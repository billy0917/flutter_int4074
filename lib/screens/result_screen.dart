import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/recognition_result.dart';
import '../providers/history_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';
import '../widgets/clay_card.dart';
import '../widgets/clay_button.dart';
import '../widgets/tone_display.dart';
import '../widgets/loading_animation.dart';
import '../utils/app_icons.dart';
import '../widgets/info_row.dart';
import '../utils/constants.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class ResultScreen extends StatefulWidget {
  final RecognitionResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TtsService _tts = TtsService();
  bool _loadingQuiz = false;
  String? _quizError;

  @override
  void initState() {
    super.initState();
    _tts.init();
    final speed = StorageService.getTtsSpeed();
    _tts.setSpeed(speed);
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  Future<void> _startQuiz() async {
    final l = AppLocalizations.of(context)!;
    setState(() {
      _loadingQuiz = true;
      _quizError = null;
    });

    final questions = await ApiService.generateQuiz(widget.result);
    if (!mounted) return;

    if (questions == null || questions.isEmpty) {
      setState(() {
        _loadingQuiz = false;
        _quizError = l.errorApi;
      });
      return;
    }

    // find matching record id
    final history = context.read<HistoryProvider>();
    String recordId = '';
    for (final r in history.records) {
      if (r.objectNameZh == widget.result.objectNameZh) {
        recordId = r.id;
        break;
      }
    }

    setState(() => _loadingQuiz = false);

    Navigator.pushNamed(
      context,
      AppRoutes.quiz,
      arguments: {
        'result': widget.result,
        'questions': questions,
        'recordId': recordId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final r = widget.result;
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final isZh = locale == 'zh';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.resultTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              if (r.imagePath != null && r.imagePath!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  child: Image.file(
                    File(r.imagePath!),
                    height: AppConstants.imageHeight(context),
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 20),

              // Main learning card
              ClayCard(
                color: AppColors.cardBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hanzi + pinyin
                    Center(
                      child: Column(
                        children: [
                          Text(
                            r.objectNameZh,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.pinyin,
                            style: const TextStyle(
                              fontSize: 28,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 24, color: AppColors.textLight),

                    // Tone display per character
                    if (r.characters.isNotEmpty) ...[
                      Text(
                        l.resultTone,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: r.characters
                            .map((c) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      c.char,
                                      style: const TextStyle(
                                        fontSize: 22,
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

                    // English
                    InfoRow(label: l.resultEnglish, value: r.objectNameEn),
                    const SizedBox(height: 8),

                    // Cantonese
                    if (r.cantoneseReference.isNotEmpty)
                      InfoRow(
                          label: l.resultCantonese,
                          value: r.cantoneseReference),
                    const SizedBox(height: 8),

                    // Example sentence
                    if (r.exampleSentenceZh.isNotEmpty) ...[
                      Text(
                        l.resultExample,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.exampleSentenceZh,
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.textDark),
                      ),
                      Text(
                        r.exampleSentencePinyin,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.primary),
                      ),
                      Text(
                        r.exampleSentenceEn,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMedium),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // TTS button
              ClayButton(
                color: AppColors.tone2.withValues(alpha: 0.9),
                width: double.infinity,
                onTap: () => _tts.speak(r.objectNameZh),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Quiz button
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
                        l.resultStartQuiz,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              if (_quizError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _quizError!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 12),

              // Retake button
              ClayButton(
                color: AppColors.cardBgAlt,
                width: double.infinity,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.camera,
                  (r) => r.settings.name == AppRoutes.home,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcons.svg(AppIcons.camera, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l.resultRetake,
                      style: const TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 16,
                      ),
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

