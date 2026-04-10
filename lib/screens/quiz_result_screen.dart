import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../widgets/clay_button.dart';
import '../widgets/clay_card.dart';
import '../widgets/star_rating.dart';
import '../utils/constants.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class QuizResultScreen extends StatelessWidget {
  final int correct;
  final int total;
  final List<Map<String, dynamic>> details;
  final String recordId;

  const QuizResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.details,
    required this.recordId,
  });

  int get _stars {
    if (total == 0) return 0;
    final pct = correct / total;
    if (pct >= 0.8) return 3;
    if (pct >= 0.6) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final percent = total > 0 ? ((correct / total) * 100).round() : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                l.quizResultTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Stars
              Center(child: StarRating(stars: _stars, size: AppConstants.starSize(context).clamp(40, 56))),

              const SizedBox(height: 24),

              // Score card
              ClayCard(
                color: AppColors.cardBg,
                child: Column(
                  children: [
                    Text(
                      l.quizResultScore(correct, total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.quizResultAccuracy(percent),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: total > 0 ? correct / total : 0,
                        backgroundColor:
                            AppColors.textLight.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _stars == 3
                              ? AppColors.success
                              : _stars == 2
                                  ? AppColors.star
                                  : AppColors.error,
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Details
              ClayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '答題詳情：',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...details.asMap().entries.map((entry) {
                      final i = entry.key;
                      final d = entry.value;
                      final isCorrect = d['isCorrect'] as bool;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCorrect ? '✅' : '❌',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${i + 1}. ${d['questionText'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  if (!isCorrect) ...[
                                    Text(
                                      '你選：${d['userAnswer'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    Text(
                                      '正確：${d['correctAnswer'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ClayButton(
                      color: AppColors.cardBgAlt,
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.camera,
                        (r) => r.settings.name == AppRoutes.home,
                      ),
                      child: Center(
                        child: Text(
                          l.quizRetry,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClayButton(
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (r) => false,
                      ),
                      child: Center(
                        child: Text(
                          l.quizGoHome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
