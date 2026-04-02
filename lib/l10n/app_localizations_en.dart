// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PinPin Go';

  @override
  String get homeGreetingMorning => 'Good Morning! ☀️';

  @override
  String get homeGreetingAfternoon => 'Good Afternoon! 🌤️';

  @override
  String get homeGreetingEvening => 'Good Evening! 🌙';

  @override
  String get homeSubtitle => 'Ready to learn Mandarin?';

  @override
  String get featureSnap => 'Snap';

  @override
  String get featureSnapSub => 'Snap & Learn';

  @override
  String get featureQuiz => 'Quiz';

  @override
  String get featureQuizSub => 'Quiz Time';

  @override
  String get featureHistory => 'History';

  @override
  String get featureHistorySub => 'History';

  @override
  String get featureFavorites => 'Favorites';

  @override
  String get featureFavoritesSub => 'Coming Soon';

  @override
  String get featureGames => 'Games';

  @override
  String get featureGamesSub => 'In Development';

  @override
  String get featureAchievements => 'Achievements';

  @override
  String get featureAchievementsSub => 'In Development';

  @override
  String get featureComingSoon => 'Coming Soon';

  @override
  String get comingSoonMsg => 'This feature is coming soon, stay tuned!';

  @override
  String get recentLearned => 'Recently Learned';

  @override
  String get moreFeatures => 'More Features';

  @override
  String statsWordsLearned(int count) {
    return 'Learned $count words';
  }

  @override
  String statsStreak(int days) {
    return '$days day streak';
  }

  @override
  String get cameraTitle => 'Snap & Learn';

  @override
  String get cameraHint => 'Take a photo of something to learn!';

  @override
  String get cameraRecognize => 'Start Recognition';

  @override
  String get cameraRetake => 'Retake';

  @override
  String get cameraAlbum => 'Album';

  @override
  String get loadingRecognize => 'AI is recognizing…';

  @override
  String get resultTitle => 'Learning Card';

  @override
  String get resultHanzi => 'Chinese';

  @override
  String get resultPinyin => 'Pinyin';

  @override
  String get resultTone => 'Tone';

  @override
  String get resultEnglish => 'English';

  @override
  String get resultCantonese => 'Cantonese';

  @override
  String get resultExample => 'Example';

  @override
  String get resultListen => '🔊 Listen';

  @override
  String get resultStartQuiz => '📝 Start Quiz';

  @override
  String get resultRetake => '📷 Take Another';

  @override
  String get quizTitle => 'Quiz';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Q$current / $total';
  }

  @override
  String get quizDrawHint => 'Draw the tone contour below';

  @override
  String get quizClear => 'Clear';

  @override
  String get quizSubmit => 'Submit';

  @override
  String get quizNext => 'Next →';

  @override
  String get quizCorrect => 'Correct! Great job! 🎉';

  @override
  String get quizIncorrect => 'Not quite~ The correct answer is:';

  @override
  String get quizResultTitle => 'Quiz Complete! 🎉';

  @override
  String quizResultScore(int correct, int total) {
    return 'You got $correct / $total correct!';
  }

  @override
  String quizResultAccuracy(int percent) {
    return 'Accuracy: $percent%';
  }

  @override
  String get quizRetry => '🔄 Try Again';

  @override
  String get quizGoHome => '🏠 Home';

  @override
  String get historyTitle => 'History';

  @override
  String get historyNoQuiz => 'No quiz taken';

  @override
  String get historySearch => 'Search…';

  @override
  String get historyEmpty => 'No learning records yet';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyDeleteConfirm => 'Delete this record?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language / 語言';

  @override
  String get settingsTtsSpeed => 'Speech Speed';

  @override
  String get settingsClearHistory => 'Clear All History';

  @override
  String get settingsClearConfirm =>
      'Clear all records? This cannot be undone.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version 1.0.0';

  @override
  String get errorApi => 'Recognition failed, please retry';

  @override
  String get errorNoCamera => 'Cannot access camera';

  @override
  String get errorNetwork => 'Please check your network connection';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get toneFirst => '1st Tone (Level)';

  @override
  String get toneSecond => '2nd Tone (Rising)';

  @override
  String get toneThird => '3rd Tone (Dipping)';

  @override
  String get toneFourth => '4th Tone (Falling)';

  @override
  String get toneLight => 'Neutral Tone';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get generateQuizLoading => 'Generating quiz…';

  @override
  String get todayStats => 'Today\'s Stats';

  @override
  String get featurePhrases => 'Phrases';

  @override
  String get featurePhrasesSub => 'Daily Phrases';

  @override
  String get phraseLearningTitle => 'Daily Phrase Learning';

  @override
  String phraseCategoryCount(int count) {
    return '$count phrases';
  }

  @override
  String get phraseListenAgain => 'Listen again';

  @override
  String get phraseShowTranslation => 'Show translation';

  @override
  String get phraseHideTranslation => 'Hide translation';

  @override
  String get phrasePrevious => 'Previous';

  @override
  String get phraseNext => 'Next';

  @override
  String get phraseFinish => 'Done';

  @override
  String get phraseListening => 'Listening…';

  @override
  String get phraseTapToSpeak => 'Tap mic to speak';

  @override
  String get phraseStopRecording => 'Tap to stop';

  @override
  String get phraseSttError => 'Speech recognition error';

  @override
  String get phraseSttUnavailable =>
      'Cannot use speech recognition, check mic permission';

  @override
  String get phraseScoreExcellent => 'Excellent! Very accurate!';

  @override
  String get phraseScoreGood => 'Good job! Keep going!';

  @override
  String get phraseScoreTryAgain => 'Try again, you got this!';

  @override
  String get phraseScoreRetry => 'Didn\'t catch that, try again';

  @override
  String phraseYouSaid(String text) {
    return 'You said: $text';
  }
}
