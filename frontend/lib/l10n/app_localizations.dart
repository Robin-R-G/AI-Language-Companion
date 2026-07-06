import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('ta'),
    Locale('te'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Language Coach'**
  String get appTitle;

  /// No description provided for @appTitleDescription.
  ///
  /// In en, this message translates to:
  /// **'The application title'**
  String get appTitleDescription;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get navLessons;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeContinueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get homeContinueLearning;

  /// No description provided for @homeDailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get homeDailyStreak;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homeRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get homeRecentActivity;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @grammarTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar Check'**
  String get grammarTitle;

  /// No description provided for @grammarHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste your text here...'**
  String get grammarHint;

  /// No description provided for @grammarCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get grammarCheck;

  /// No description provided for @grammarChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get grammarChecking;

  /// No description provided for @grammarError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while checking grammar'**
  String get grammarError;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressProjectedScore.
  ///
  /// In en, this message translates to:
  /// **'Projected Exam Score'**
  String get progressProjectedScore;

  /// No description provided for @progressWeeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get progressWeeklyActivity;

  /// No description provided for @progressScoreBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Score Breakdown'**
  String get progressScoreBreakdown;

  /// No description provided for @progressStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Study Time'**
  String get progressStudyTime;

  /// No description provided for @progressDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get progressDayStreak;

  /// No description provided for @progressXpEarned.
  ///
  /// In en, this message translates to:
  /// **'XP Earned'**
  String get progressXpEarned;

  /// No description provided for @readingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Practice'**
  String get readingTitle;

  /// No description provided for @readingStart.
  ///
  /// In en, this message translates to:
  /// **'Start Reading'**
  String get readingStart;

  /// No description provided for @readingComprehension.
  ///
  /// In en, this message translates to:
  /// **'Reading Comprehension'**
  String get readingComprehension;

  /// No description provided for @readingSelectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get readingSelectDifficulty;

  /// No description provided for @writingTitle.
  ///
  /// In en, this message translates to:
  /// **'Writing Practice'**
  String get writingTitle;

  /// No description provided for @writingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Writing Prompt'**
  String get writingPrompt;

  /// No description provided for @writingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get writingSubmit;

  /// No description provided for @writingFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get writingFeedback;

  /// No description provided for @listeningTitle.
  ///
  /// In en, this message translates to:
  /// **'Listening Practice'**
  String get listeningTitle;

  /// No description provided for @listeningStart.
  ///
  /// In en, this message translates to:
  /// **'Start Listening'**
  String get listeningStart;

  /// No description provided for @listeningTranscript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get listeningTranscript;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settingsPrivacy;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsLightMode;

  /// No description provided for @settingsSystemMode.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsSystemMode;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get notificationsMarkRead;

  /// No description provided for @notificationsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get notificationsClearAll;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionFree;

  /// No description provided for @subscriptionPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get subscriptionPremium;

  /// No description provided for @subscriptionSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscriptionSubscribe;

  /// No description provided for @subscriptionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get subscriptionRestore;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileName;

  /// No description provided for @editProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get editProfileEmail;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProfileSave;

  /// No description provided for @editProfileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get editProfileCancel;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorRetry;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoInternet;

  /// No description provided for @emptyState.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyState;

  /// No description provided for @lessonDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Details'**
  String get lessonDetailTitle;

  /// No description provided for @lessonStart.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get lessonStart;

  /// No description provided for @lessonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get lessonContinue;

  /// No description provided for @lessonCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get lessonCompleted;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your experience...'**
  String get splashLoading;

  /// No description provided for @mockExamTitle.
  ///
  /// In en, this message translates to:
  /// **'Mock Exam'**
  String get mockExamTitle;

  /// No description provided for @mockExamStart.
  ///
  /// In en, this message translates to:
  /// **'Start Exam'**
  String get mockExamStart;

  /// No description provided for @mockExamSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Answers'**
  String get mockExamSubmit;

  /// No description provided for @mockExamTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get mockExamTimeRemaining;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Practice'**
  String get voiceTitle;

  /// No description provided for @voiceStartCall.
  ///
  /// In en, this message translates to:
  /// **'Start Call'**
  String get voiceStartCall;

  /// No description provided for @voiceEndCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get voiceEndCall;

  /// No description provided for @voiceMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get voiceMute;

  /// No description provided for @voiceUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get voiceUnmute;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'kn',
    'ko',
    'ml',
    'ta',
    'te',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
