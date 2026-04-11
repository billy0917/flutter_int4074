import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/main_shell.dart';
import '../screens/camera_screen.dart';
import '../screens/result_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/quiz_result_screen.dart';
import '../screens/history_screen.dart';
import '../screens/history_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/phrase_categories_screen.dart';
import '../screens/phrase_learning_screen.dart';
import '../screens/phrase_history_screen.dart';
import '../screens/matching_game_screen.dart';
import '../config/api_config.dart';
import '../models/recognition_result.dart';
import '../models/learning_record.dart';
import '../models/quiz_question.dart';
import '../models/daily_phrase.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const camera = '/camera';
  static const result = '/result';
  static const quiz = '/quiz';
  static const quizResult = '/quiz-result';
  static const history = '/history';
  static const historyDetail = '/history-detail';
  static const settings = '/settings';
  static const phraseCategories = '/phrase-categories';
  static const phraseLearning = '/phrase-learning';
  static const phraseHistory = '/phrase-history';
  static const matchingGame = '/matching-game';

  static Route<dynamic> generateRoute(RouteSettings settings_) {
    switch (settings_.name) {
      case splash:
        return _fadeRoute(const SplashScreen());
      case home:
        return _slideRoute(const MainShell());
      case camera:
        return _slideRoute(const CameraScreen());
      case result:
        final resultArgs = settings_.arguments as Map<String, dynamic>;
        return _slideRoute(ResultScreen(
          result: resultArgs['result'] as RecognitionResult,
          preset: resultArgs['preset'] as ModelPreset? ?? ModelPreset.fast,
        ));
      case quiz:
        final args = settings_.arguments as Map<String, dynamic>;
        return _slideRoute(QuizScreen(
          recognitionResult: args['result'] as RecognitionResult,
          questions: args['questions'] as List<QuizQuestion>,
          recordId: args['recordId'] as String,
          preset: args['preset'] as ModelPreset? ?? ModelPreset.fast,
        ));
      case quizResult:
        final args = settings_.arguments as Map<String, dynamic>;
        return _slideRoute(QuizResultScreen(
          correct: args['correct'] as int,
          total: args['total'] as int,
          details: args['details'] as List<Map<String, dynamic>>,
          recordId: args['recordId'] as String,
        ));
      case history:
        return _slideRoute(const HistoryScreen());
      case historyDetail:
        final record = settings_.arguments as LearningRecord;
        return _slideRoute(HistoryDetailScreen(record: record));
      case AppRoutes.settings:
        return _slideRoute(const SettingsScreen());
      case phraseCategories:
        return _slideRoute(const PhraseCategoriesScreen());
      case phraseLearning:
        final category = settings_.arguments as PhraseCategory;
        return _slideRoute(PhraseLearningScreen(category: category));
      case phraseHistory:
        return _slideRoute(const PhraseHistoryScreen());
      case matchingGame:
        return _slideRoute(const MatchingGameScreen());
      default:
        return _fadeRoute(const SplashScreen());
    }
  }

  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
