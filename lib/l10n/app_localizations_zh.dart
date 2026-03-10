// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '拼拼樂';

  @override
  String get homeGreetingMorning => '早安！☀️';

  @override
  String get homeGreetingAfternoon => '午安！🌤️';

  @override
  String get homeGreetingEvening => '晚安！🌙';

  @override
  String get homeSubtitle => '準備好學普通話了嗎？';

  @override
  String get featureSnap => '拍一拍';

  @override
  String get featureSnapSub => 'Snap & Learn';

  @override
  String get featureQuiz => '小測驗';

  @override
  String get featureQuizSub => 'Quiz Time';

  @override
  String get featureHistory => '歷史記錄';

  @override
  String get featureHistorySub => 'History';

  @override
  String get featureFavorites => '收藏夾';

  @override
  String get featureFavoritesSub => '即將推出';

  @override
  String get featureGames => '趣味遊戲';

  @override
  String get featureGamesSub => '開發中';

  @override
  String get featureAchievements => '成就系統';

  @override
  String get featureAchievementsSub => '開發中';

  @override
  String get featureComingSoon => '即將推出';

  @override
  String get comingSoonMsg => '此功能即將推出，敬請期待！';

  @override
  String get recentLearned => '最近學過';

  @override
  String get moreFeatures => '更多功能';

  @override
  String statsWordsLearned(int count) {
    return '已學 $count 個詞';
  }

  @override
  String statsStreak(int days) {
    return '連續 $days 天';
  }

  @override
  String get cameraTitle => '拍一拍';

  @override
  String get cameraHint => '拍下你想學的東西吧！';

  @override
  String get cameraRecognize => '開始辨識';

  @override
  String get cameraRetake => '重新拍攝';

  @override
  String get cameraAlbum => '相簿';

  @override
  String get loadingRecognize => 'AI 正在辨識中…';

  @override
  String get resultTitle => '學習卡片';

  @override
  String get resultHanzi => '漢字';

  @override
  String get resultPinyin => '拼音';

  @override
  String get resultTone => '聲調';

  @override
  String get resultEnglish => '英文';

  @override
  String get resultCantonese => '粵語對照';

  @override
  String get resultExample => '例句';

  @override
  String get resultListen => '🔊 聽發音';

  @override
  String get resultStartQuiz => '📝 開始測驗';

  @override
  String get resultRetake => '📷 再拍一張';

  @override
  String get quizTitle => '小測驗';

  @override
  String quizQuestionOf(int current, int total) {
    return '第 $current 題 / 共 $total 題';
  }

  @override
  String get quizDrawHint => '用手指在下方畫出聲調走勢';

  @override
  String get quizClear => '清除重畫';

  @override
  String get quizSubmit => '提交答案';

  @override
  String get quizNext => '下一題 →';

  @override
  String get quizCorrect => '正確！很棒！🎉';

  @override
  String get quizIncorrect => '不對哦～正確答案是：';

  @override
  String get quizResultTitle => '測驗完成！🎉';

  @override
  String quizResultScore(int correct, int total) {
    return '你答對了 $correct / $total 題！';
  }

  @override
  String quizResultAccuracy(int percent) {
    return '正確率：$percent%';
  }

  @override
  String get quizRetry => '🔄 再測一次';

  @override
  String get quizGoHome => '🏠 回主頁';

  @override
  String get historyTitle => '歷史記錄';

  @override
  String get historyNoQuiz => '未測驗';

  @override
  String get historySearch => '搜索…';

  @override
  String get historyEmpty => '暫無學習記錄';

  @override
  String get historyDelete => '刪除';

  @override
  String get historyDeleteConfirm => '確定要刪除此記錄嗎？';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確定';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '語言 / Language';

  @override
  String get settingsTtsSpeed => '語音速度';

  @override
  String get settingsClearHistory => '清除所有歷史記錄';

  @override
  String get settingsClearConfirm => '確定要清除所有記錄嗎？此操作無法撤銷。';

  @override
  String get settingsAbout => '關於';

  @override
  String get settingsVersion => 'Version 1.0.0';

  @override
  String get errorApi => '辨識失敗，請重試';

  @override
  String get errorNoCamera => '無法使用相機';

  @override
  String get errorNetwork => '請檢查網絡連接';

  @override
  String get retry => '重試';

  @override
  String get back => '返回';

  @override
  String get toneFirst => '第一聲（陰平）';

  @override
  String get toneSecond => '第二聲（陽平）';

  @override
  String get toneThird => '第三聲（上聲）';

  @override
  String get toneFourth => '第四聲（去聲）';

  @override
  String get toneLight => '輕聲';

  @override
  String get startQuiz => '開始測驗';

  @override
  String get generateQuizLoading => '正在生成測驗…';

  @override
  String get todayStats => '今日學習統計';
}
