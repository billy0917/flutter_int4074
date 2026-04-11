import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'拼拼樂'**
  String get appName;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In zh, this message translates to:
  /// **'早安！☀️'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In zh, this message translates to:
  /// **'午安！🌤️'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In zh, this message translates to:
  /// **'晚安！🌙'**
  String get homeGreetingEvening;

  /// No description provided for @homeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'準備好學普通話了嗎？'**
  String get homeSubtitle;

  /// No description provided for @featureSnap.
  ///
  /// In zh, this message translates to:
  /// **'拍一拍'**
  String get featureSnap;

  /// No description provided for @featureSnapSub.
  ///
  /// In zh, this message translates to:
  /// **'Snap & Learn'**
  String get featureSnapSub;

  /// No description provided for @featureQuiz.
  ///
  /// In zh, this message translates to:
  /// **'小測驗'**
  String get featureQuiz;

  /// No description provided for @featureQuizSub.
  ///
  /// In zh, this message translates to:
  /// **'Quiz Time'**
  String get featureQuizSub;

  /// No description provided for @featureHistory.
  ///
  /// In zh, this message translates to:
  /// **'歷史記錄'**
  String get featureHistory;

  /// No description provided for @featureHistorySub.
  ///
  /// In zh, this message translates to:
  /// **'History'**
  String get featureHistorySub;

  /// No description provided for @featureFavorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏夾'**
  String get featureFavorites;

  /// No description provided for @featureFavoritesSub.
  ///
  /// In zh, this message translates to:
  /// **'即將推出'**
  String get featureFavoritesSub;

  /// No description provided for @featureGames.
  ///
  /// In zh, this message translates to:
  /// **'趣味遊戲'**
  String get featureGames;

  /// No description provided for @featureGamesSub.
  ///
  /// In zh, this message translates to:
  /// **'開發中'**
  String get featureGamesSub;

  /// No description provided for @featureAchievements.
  ///
  /// In zh, this message translates to:
  /// **'成就系統'**
  String get featureAchievements;

  /// No description provided for @featureAchievementsSub.
  ///
  /// In zh, this message translates to:
  /// **'開發中'**
  String get featureAchievementsSub;

  /// No description provided for @featureComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即將推出'**
  String get featureComingSoon;

  /// No description provided for @comingSoonMsg.
  ///
  /// In zh, this message translates to:
  /// **'此功能即將推出，敬請期待！'**
  String get comingSoonMsg;

  /// No description provided for @recentLearned.
  ///
  /// In zh, this message translates to:
  /// **'最近學過'**
  String get recentLearned;

  /// No description provided for @moreFeatures.
  ///
  /// In zh, this message translates to:
  /// **'更多功能'**
  String get moreFeatures;

  /// No description provided for @statsWordsLearned.
  ///
  /// In zh, this message translates to:
  /// **'已學 {count} 個詞'**
  String statsWordsLearned(int count);

  /// No description provided for @statsStreak.
  ///
  /// In zh, this message translates to:
  /// **'連續 {days} 天'**
  String statsStreak(int days);

  /// No description provided for @cameraTitle.
  ///
  /// In zh, this message translates to:
  /// **'拍一拍'**
  String get cameraTitle;

  /// No description provided for @cameraHint.
  ///
  /// In zh, this message translates to:
  /// **'拍下你想學的東西吧！'**
  String get cameraHint;

  /// No description provided for @cameraRecognize.
  ///
  /// In zh, this message translates to:
  /// **'開始辨識'**
  String get cameraRecognize;

  /// No description provided for @cameraRetake.
  ///
  /// In zh, this message translates to:
  /// **'重新拍攝'**
  String get cameraRetake;

  /// No description provided for @cameraAlbum.
  ///
  /// In zh, this message translates to:
  /// **'相簿'**
  String get cameraAlbum;

  /// No description provided for @cameraModelFast.
  ///
  /// In zh, this message translates to:
  /// **'快速'**
  String get cameraModelFast;

  /// No description provided for @cameraModelStable.
  ///
  /// In zh, this message translates to:
  /// **'穩定（較慢）'**
  String get cameraModelStable;

  /// No description provided for @modelSwitchHint.
  ///
  /// In zh, this message translates to:
  /// **'如模型無法使用，請嘗試切換到另一個模型。'**
  String get modelSwitchHint;

  /// No description provided for @loadingRecognize.
  ///
  /// In zh, this message translates to:
  /// **'AI 正在辨識中…'**
  String get loadingRecognize;

  /// No description provided for @resultTitle.
  ///
  /// In zh, this message translates to:
  /// **'學習卡片'**
  String get resultTitle;

  /// No description provided for @resultHanzi.
  ///
  /// In zh, this message translates to:
  /// **'漢字'**
  String get resultHanzi;

  /// No description provided for @resultPinyin.
  ///
  /// In zh, this message translates to:
  /// **'拼音'**
  String get resultPinyin;

  /// No description provided for @resultTone.
  ///
  /// In zh, this message translates to:
  /// **'聲調'**
  String get resultTone;

  /// No description provided for @resultEnglish.
  ///
  /// In zh, this message translates to:
  /// **'英文'**
  String get resultEnglish;

  /// No description provided for @resultCantonese.
  ///
  /// In zh, this message translates to:
  /// **'粵語對照'**
  String get resultCantonese;

  /// No description provided for @resultExample.
  ///
  /// In zh, this message translates to:
  /// **'例句'**
  String get resultExample;

  /// No description provided for @resultListen.
  ///
  /// In zh, this message translates to:
  /// **'聽發音'**
  String get resultListen;

  /// No description provided for @resultStartQuiz.
  ///
  /// In zh, this message translates to:
  /// **'開始測驗'**
  String get resultStartQuiz;

  /// No description provided for @resultRetake.
  ///
  /// In zh, this message translates to:
  /// **'再拍一張'**
  String get resultRetake;

  /// No description provided for @quizTitle.
  ///
  /// In zh, this message translates to:
  /// **'小測驗'**
  String get quizTitle;

  /// No description provided for @quizQuestionOf.
  ///
  /// In zh, this message translates to:
  /// **'第 {current} 題 / 共 {total} 題'**
  String quizQuestionOf(int current, int total);

  /// No description provided for @quizDrawHint.
  ///
  /// In zh, this message translates to:
  /// **'用手指在下方畫出聲調走勢'**
  String get quizDrawHint;

  /// No description provided for @quizClear.
  ///
  /// In zh, this message translates to:
  /// **'清除重畫'**
  String get quizClear;

  /// No description provided for @quizSubmit.
  ///
  /// In zh, this message translates to:
  /// **'提交答案'**
  String get quizSubmit;

  /// No description provided for @quizNext.
  ///
  /// In zh, this message translates to:
  /// **'下一題 →'**
  String get quizNext;

  /// No description provided for @quizCorrect.
  ///
  /// In zh, this message translates to:
  /// **'正確！很棒！🎉'**
  String get quizCorrect;

  /// No description provided for @quizIncorrect.
  ///
  /// In zh, this message translates to:
  /// **'不對哦～正確答案是：'**
  String get quizIncorrect;

  /// No description provided for @quizResultTitle.
  ///
  /// In zh, this message translates to:
  /// **'測驗完成！🎉'**
  String get quizResultTitle;

  /// No description provided for @quizResultScore.
  ///
  /// In zh, this message translates to:
  /// **'你答對了 {correct} / {total} 題！'**
  String quizResultScore(int correct, int total);

  /// No description provided for @quizResultAccuracy.
  ///
  /// In zh, this message translates to:
  /// **'正確率：{percent}%'**
  String quizResultAccuracy(int percent);

  /// No description provided for @quizRetry.
  ///
  /// In zh, this message translates to:
  /// **'🔄 再測一次'**
  String get quizRetry;

  /// No description provided for @quizGoHome.
  ///
  /// In zh, this message translates to:
  /// **'🏠 回主頁'**
  String get quizGoHome;

  /// No description provided for @historyTitle.
  ///
  /// In zh, this message translates to:
  /// **'歷史記錄'**
  String get historyTitle;

  /// No description provided for @historyNoQuiz.
  ///
  /// In zh, this message translates to:
  /// **'未測驗'**
  String get historyNoQuiz;

  /// No description provided for @historySearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索…'**
  String get historySearch;

  /// No description provided for @historyEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暫無學習記錄'**
  String get historyEmpty;

  /// No description provided for @historyDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get historyDelete;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除此記錄嗎？'**
  String get historyDeleteConfirm;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'確定'**
  String get confirm;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'設定'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'語言 / Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTtsSpeed.
  ///
  /// In zh, this message translates to:
  /// **'語音速度'**
  String get settingsTtsSpeed;

  /// No description provided for @settingsClearHistory.
  ///
  /// In zh, this message translates to:
  /// **'清除所有歷史記錄'**
  String get settingsClearHistory;

  /// No description provided for @settingsClearConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要清除所有記錄嗎？此操作無法撤銷。'**
  String get settingsClearConfirm;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'關於'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In zh, this message translates to:
  /// **'Version 1.0.0'**
  String get settingsVersion;

  /// No description provided for @errorApi.
  ///
  /// In zh, this message translates to:
  /// **'辨識失敗，請重試'**
  String get errorApi;

  /// No description provided for @errorNoCamera.
  ///
  /// In zh, this message translates to:
  /// **'無法使用相機'**
  String get errorNoCamera;

  /// No description provided for @errorNetwork.
  ///
  /// In zh, this message translates to:
  /// **'請檢查網絡連接'**
  String get errorNetwork;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重試'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get back;

  /// No description provided for @toneFirst.
  ///
  /// In zh, this message translates to:
  /// **'第一聲（陰平）'**
  String get toneFirst;

  /// No description provided for @toneSecond.
  ///
  /// In zh, this message translates to:
  /// **'第二聲（陽平）'**
  String get toneSecond;

  /// No description provided for @toneThird.
  ///
  /// In zh, this message translates to:
  /// **'第三聲（上聲）'**
  String get toneThird;

  /// No description provided for @toneFourth.
  ///
  /// In zh, this message translates to:
  /// **'第四聲（去聲）'**
  String get toneFourth;

  /// No description provided for @toneLight.
  ///
  /// In zh, this message translates to:
  /// **'輕聲'**
  String get toneLight;

  /// No description provided for @startQuiz.
  ///
  /// In zh, this message translates to:
  /// **'開始測驗'**
  String get startQuiz;

  /// No description provided for @generateQuizLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在生成測驗…'**
  String get generateQuizLoading;

  /// No description provided for @todayStats.
  ///
  /// In zh, this message translates to:
  /// **'今日學習統計'**
  String get todayStats;

  /// No description provided for @featurePhrases.
  ///
  /// In zh, this message translates to:
  /// **'日常用語'**
  String get featurePhrases;

  /// No description provided for @featurePhrasesSub.
  ///
  /// In zh, this message translates to:
  /// **'讀法學習'**
  String get featurePhrasesSub;

  /// No description provided for @phraseLearningTitle.
  ///
  /// In zh, this message translates to:
  /// **'日常用語讀法學習'**
  String get phraseLearningTitle;

  /// No description provided for @phraseCategoryCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 個詞語'**
  String phraseCategoryCount(int count);

  /// No description provided for @phraseListenAgain.
  ///
  /// In zh, this message translates to:
  /// **'再聽一次'**
  String get phraseListenAgain;

  /// No description provided for @phraseShowTranslation.
  ///
  /// In zh, this message translates to:
  /// **'顯示翻譯'**
  String get phraseShowTranslation;

  /// No description provided for @phraseHideTranslation.
  ///
  /// In zh, this message translates to:
  /// **'隱藏翻譯'**
  String get phraseHideTranslation;

  /// No description provided for @phrasePrevious.
  ///
  /// In zh, this message translates to:
  /// **'上一個'**
  String get phrasePrevious;

  /// No description provided for @phraseNext.
  ///
  /// In zh, this message translates to:
  /// **'下一個'**
  String get phraseNext;

  /// No description provided for @phraseFinish.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get phraseFinish;

  /// No description provided for @phraseListening.
  ///
  /// In zh, this message translates to:
  /// **'聆聽中…'**
  String get phraseListening;

  /// No description provided for @phraseTapToSpeak.
  ///
  /// In zh, this message translates to:
  /// **'點擊麦克風'**
  String get phraseTapToSpeak;

  /// No description provided for @phraseStopRecording.
  ///
  /// In zh, this message translates to:
  /// **'點擊停止'**
  String get phraseStopRecording;

  /// No description provided for @phraseSttError.
  ///
  /// In zh, this message translates to:
  /// **'語音識別出錯'**
  String get phraseSttError;

  /// No description provided for @phraseSttUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'無法使用語音識別，請檢查麦克風權限'**
  String get phraseSttUnavailable;

  /// No description provided for @phraseScoreExcellent.
  ///
  /// In zh, this message translates to:
  /// **'太棒了！非常標準！'**
  String get phraseScoreExcellent;

  /// No description provided for @phraseScoreGood.
  ///
  /// In zh, this message translates to:
  /// **'不錯！繼續加油！'**
  String get phraseScoreGood;

  /// No description provided for @phraseScoreTryAgain.
  ///
  /// In zh, this message translates to:
  /// **'再試一次，你可以的！'**
  String get phraseScoreTryAgain;

  /// No description provided for @phraseScoreRetry.
  ///
  /// In zh, this message translates to:
  /// **'沒有聽清，再來一次吧'**
  String get phraseScoreRetry;

  /// No description provided for @phraseYouSaid.
  ///
  /// In zh, this message translates to:
  /// **'你說的是：{text}'**
  String phraseYouSaid(String text);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
