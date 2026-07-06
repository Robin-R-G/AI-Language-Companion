import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Brand design tokens for AI Language Coach.
/// Extended brand colors, gradients, typography, and asset paths.
/// Complements existing [AppColors], [AppSpacing], [AppRadius], and [AppElevation].
class BrandTokens {
  BrandTokens._();

  // ===========================================================================
  // EXTENDED COLOR PALETTE
  // ===========================================================================

  // Primary Blue Scale (50-900)
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = AppColors.primary500;
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A5F);

  // Secondary Purple Scale (50-900)
  static const Color purple50 = Color(0xFFF5F3FF);
  static const Color purple100 = Color(0xFFEDE9FE);
  static const Color purple200 = Color(0xFFDDD6FE);
  static const Color purple300 = Color(0xFFC4B5FD);
  static const Color purple400 = Color(0xFFA78BFA);
  static const Color purple500 = AppColors.secondary;
  static const Color purple600 = Color(0xFF7C3AED);
  static const Color purple700 = Color(0xFF6D28D9);
  static const Color purple800 = Color(0xFF5B21B6);
  static const Color purple900 = Color(0xFF4C1D95);

  // Tertiary Teal Scale (50-900)
  static const Color teal50 = Color(0xFFF0FDFA);
  static const Color teal100 = Color(0xFFCCFBF1);
  static const Color teal200 = Color(0xFF99F6E4);
  static const Color teal300 = Color(0xFF5EEAD4);
  static const Color teal400 = Color(0xFF2DD4BF);
  static const Color teal500 = AppColors.tertiary;
  static const Color teal600 = Color(0xFF0D9488);
  static const Color teal700 = Color(0xFF0F766E);
  static const Color teal800 = Color(0xFF115E59);
  static const Color teal900 = Color(0xFF134E4A);

  // Accent Green Scale (50-900)
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = AppColors.success;
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color green900 = Color(0xFF14532D);

  // Accent Orange Scale (50-900)
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = AppColors.warning;
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color orange800 = Color(0xFF9A3412);
  static const Color orange900 = Color(0xFF7C2D12);

  // Neutral Scale (50-900)
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ===========================================================================
  // GRADIENTS
  // ===========================================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [blue400, blue600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [purple400, purple600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tertiaryGradient = LinearGradient(
    colors: [teal400, teal600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [orange300, orange500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coolGradient = LinearGradient(
    colors: [blue300, teal400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [green400, green600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFFCA5A5), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [blue500, purple500, teal500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===========================================================================
  // TYPOGRAPHY SCALE
  // ===========================================================================

  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle subtitleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle subtitleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.33,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  static const TextStyle captionLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.38,
  );

  static const TextStyle captionMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.27,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.27,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.33,
  );

  // ===========================================================================
  // ASSET PATHS — Updated to match actual brand/ directory structure
  // ===========================================================================

  // Logo paths (assets/brand/logo/)
  static const String logoFull = 'assets/brand/logo/png/logo-full.png';
  static const String logoIcon = 'assets/brand/logo/png/logo-icon.png';
  static const String logoMonochrome = 'assets/brand/logo/png/logo-monochrome.png';
  static const String logoHorizontal = 'assets/brand/logo/png/logo-horizontal.png';
  static const String logoVertical = 'assets/brand/logo/png/logo-vertical.png';
  static const String logoFavicon = 'assets/brand/logo/png/favicon.png';

  // Logo SVG paths
  static const String logoFullSvg = 'assets/brand/logo/svg/logo-full.svg';
  static const String logoIconSvg = 'assets/brand/logo/svg/logo-icon.svg';
  static const String logoMonochromeSvg = 'assets/brand/logo/svg/logo-monochrome.svg';
  static const String logoHorizontalSvg = 'assets/brand/logo/svg/logo-horizontal.svg';
  static const String logoVerticalSvg = 'assets/brand/logo/svg/logo-vertical.svg';
  static const String logoFaviconSvg = 'assets/brand/logo/svg/favicon.svg';

  // Splash illustration (assets/brand/splash/)
  static const String illustrationSplash = 'assets/brand/splash/png/splash_illustration.png';
  static const String illustrationSplashSvg = 'assets/brand/splash/svg/splash_illustration.svg';

  // Onboarding illustrations (assets/brand/onboarding/)
  static const String illustrationOnboarding1 = 'assets/brand/onboarding/png/onboarding_1.png';
  static const String illustrationOnboarding2 = 'assets/brand/onboarding/png/onboarding_2.png';
  static const String illustrationOnboarding3 = 'assets/brand/onboarding/png/onboarding_3.png';
  static const String illustrationOnboarding4 = 'assets/brand/onboarding/png/onboarding_4.png';
  static const String illustrationOnboarding1Svg = 'assets/brand/onboarding/svg/onboarding_1.svg';
  static const String illustrationOnboarding2Svg = 'assets/brand/onboarding/svg/onboarding_2.svg';
  static const String illustrationOnboarding3Svg = 'assets/brand/onboarding/svg/onboarding_3.svg';
  static const String illustrationOnboarding4Svg = 'assets/brand/onboarding/svg/onboarding_4.svg';

  // Empty state illustrations (assets/brand/empty-states/)
  static const String illustrationEmptyLessons = 'assets/brand/empty-states/png/no_lessons.png';
  static const String illustrationEmptyVocabulary = 'assets/brand/empty-states/png/no_vocabulary.png';
  static const String illustrationEmptyInternet = 'assets/brand/empty-states/png/no_internet.png';
  static const String illustrationEmptyNotifications = 'assets/brand/empty-states/png/no_notifications.png';
  static const String illustrationEmptyChat = 'assets/brand/empty-states/png/no_chat_history.png';
  static const String illustrationEmptyProgress = 'assets/brand/empty-states/png/no_progress.png';
  static const String illustrationEmptyExams = 'assets/brand/empty-states/png/no_exam_history.png';
  static const String illustrationEmptyDownloads = 'assets/brand/empty-states/png/no_downloads.png';

  // Achievement badges (assets/brand/badges/) — tiered variants
  static String badgePath(String badgeName, {String tier = 'gold'}) {
    return 'assets/brand/badges/png/${badgeName}_$tier.png';
  }

  // Named badge convenience paths (gold tier default)
  static const String badgeFirstLesson = 'assets/brand/badges/png/first_lesson_gold.png';
  static const String badgeStreak7 = 'assets/brand/badges/png/streak_7_gold.png';
  static const String badgeStreak30 = 'assets/brand/badges/png/streak_30_gold.png';
  static const String badgeWords100 = 'assets/brand/badges/png/words_100_gold.png';
  static const String badgeWords500 = 'assets/brand/badges/png/words_500_gold.png';
  static const String badgeWords1000 = 'assets/brand/badges/png/words_1000_gold.png';
  static const String badgeGrammarMaster = 'assets/brand/badges/png/grammar_master_gold.png';
  static const String badgePronunciationExpert = 'assets/brand/badges/png/pronunciation_expert_gold.png';
  static const String badgeSpeakingChampion = 'assets/brand/badges/png/speaking_champion_gold.png';
  static const String badgeWritingExpert = 'assets/brand/badges/png/writing_expert_gold.png';
  static const String badgeReadingHero = 'assets/brand/badges/png/reading_hero_gold.png';
  static const String badgeListeningHero = 'assets/brand/badges/png/listening_hero_gold.png';
  static const String badgeIeltsReady = 'assets/brand/badges/png/ielts_ready_gold.png';
  static const String badgeGoetheReady = 'assets/brand/badges/png/goethe_ready_gold.png';
  static const String badgeToeflReady = 'assets/brand/badges/png/toefl_ready_gold.png';

  // XP level icons (assets/brand/xp-levels/)
  static String xpLevelPath(int levelStart) {
    final start = ((levelStart - 1) ~/ 10) * 10 + 1;
    final end = start + 9;
    return 'assets/brand/xp-levels/png/xp_level_${start}_$end.png';
  }

  static const String xpLevel1 = 'assets/brand/xp-levels/png/xp_level_1_10.png';
  static const String xpLevel2 = 'assets/brand/xp-levels/png/xp_level_11_20.png';
  static const String xpLevel3 = 'assets/brand/xp-levels/png/xp_level_21_30.png';
  static const String xpLevel4 = 'assets/brand/xp-levels/png/xp_level_31_40.png';
  static const String xpLevel5 = 'assets/brand/xp-levels/png/xp_level_41_50.png';
  static const String xpLevel6 = 'assets/brand/xp-levels/png/xp_level_51_60.png';
  static const String xpLevel7 = 'assets/brand/xp-levels/png/xp_level_61_70.png';
  static const String xpLevel8 = 'assets/brand/xp-levels/png/xp_level_71_80.png';
  static const String xpLevel9 = 'assets/brand/xp-levels/png/xp_level_81_90.png';
  static const String xpLevel10 = 'assets/brand/xp-levels/png/xp_level_91_100.png';

  // AI assistant avatar (assets/brand/ai-assistant/)
  static const String aiIdle = 'assets/brand/ai-assistant/png/assistant_front_idle.png';
  static const String aiTalking = 'assets/brand/ai-assistant/png/assistant_front_talking.png';
  static const String aiListening = 'assets/brand/ai-assistant/png/assistant_front_listening.png';
  static const String aiThinking = 'assets/brand/ai-assistant/png/assistant_front_thinking.png';
  static const String aiSideIdle = 'assets/brand/ai-assistant/png/assistant_side_idle.png';
  static const String aiIdleSvg = 'assets/brand/ai-assistant/svg/assistant_front_idle.svg';
  static const String aiTalkingSvg = 'assets/brand/ai-assistant/svg/assistant_front_talking.svg';
  static const String aiListeningSvg = 'assets/brand/ai-assistant/svg/assistant_front_listening.svg';
  static const String aiThinkingSvg = 'assets/brand/ai-assistant/svg/assistant_front_thinking.svg';
  static const String aiSideIdleSvg = 'assets/brand/ai-assistant/svg/assistant_side_idle.svg';

  // Exam icons (assets/brand/exam-icons/)
  static String examIconPath(String examCode) {
    return 'assets/brand/exam-icons/png/exam_$examCode.png';
  }

  static const String examIelts = 'assets/brand/exam-icons/png/exam_ielts.png';
  static const String examToefl = 'assets/brand/exam-icons/png/exam_toefl.png';
  static const String examPte = 'assets/brand/exam-icons/png/exam_pte.png';
  static const String examOet = 'assets/brand/exam-icons/png/exam_oet.png';
  static const String examCelpip = 'assets/brand/exam-icons/png/exam_celpip.png';
  static const String examCambridge = 'assets/brand/exam-icons/png/exam_cambridge.png';
  static const String examGoethe = 'assets/brand/exam-icons/png/exam_goethe.png';
  static const String examTestdaf = 'assets/brand/exam-icons/png/exam_testdaf.png';
  static const String examDelf = 'assets/brand/exam-icons/png/exam_delf.png';
  static const String examDalf = 'assets/brand/exam-icons/png/exam_dalf.png';
  static const String examDele = 'assets/brand/exam-icons/png/exam_dele.png';
  static const String examSiele = 'assets/brand/exam-icons/png/exam_siele.png';
  static const String examJlpt = 'assets/brand/exam-icons/png/exam_jlpt.png';
  static const String examTopik = 'assets/brand/exam-icons/png/exam_topik.png';
  static const String examHsk = 'assets/brand/exam-icons/png/exam_hsk.png';
  static const String examDuolingo = 'assets/brand/exam-icons/png/exam_duolingo.png';

  // Language icons (assets/brand/language-icons/)
  static String languageIconPath(String langCode) {
    return 'assets/brand/language-icons/png/lang_$langCode.png';
  }

  static const String langEnglish = 'assets/brand/language-icons/png/lang_english.png';
  static const String langGerman = 'assets/brand/language-icons/png/lang_german.png';
  static const String langFrench = 'assets/brand/language-icons/png/lang_french.png';
  static const String langSpanish = 'assets/brand/language-icons/png/lang_spanish.png';
  static const String langJapanese = 'assets/brand/language-icons/png/lang_japanese.png';
  static const String langKorean = 'assets/brand/language-icons/png/lang_korean.png';
  static const String langChinese = 'assets/brand/language-icons/png/lang_chinese.png';
  static const String langMalayalam = 'assets/brand/language-icons/png/lang_malayalam.png';
  static const String langHindi = 'assets/brand/language-icons/png/lang_hindi.png';
  static const String langArabic = 'assets/brand/language-icons/png/lang_arabic.png';
  static const String langItalian = 'assets/brand/language-icons/png/lang_italian.png';
  static const String langPortuguese = 'assets/brand/language-icons/png/lang_portuguese.png';

  // Category icons (assets/brand/category-icons/)
  static String categoryIconPath(String categoryCode) {
    return 'assets/brand/category-icons/png/cat_$categoryCode.png';
  }

  static const String catVocabulary = 'assets/brand/category-icons/png/cat_vocabulary.png';
  static const String catGrammar = 'assets/brand/category-icons/png/cat_grammar.png';
  static const String catSpeaking = 'assets/brand/category-icons/png/cat_speaking.png';
  static const String catWriting = 'assets/brand/category-icons/png/cat_writing.png';
  static const String catReading = 'assets/brand/category-icons/png/cat_reading.png';
  static const String catListening = 'assets/brand/category-icons/png/cat_listening.png';
  static const String catTranslation = 'assets/brand/category-icons/png/cat_translation.png';
  static const String catFlashcards = 'assets/brand/category-icons/png/cat_flashcards.png';
  static const String catAiTutor = 'assets/brand/category-icons/png/cat_ai_tutor.png';
  static const String catLiveClass = 'assets/brand/category-icons/png/cat_live_class.png';
  static const String catVoiceCall = 'assets/brand/category-icons/png/cat_voice_call.png';
  static const String catProgress = 'assets/brand/category-icons/png/cat_progress.png';
  static const String catLeaderboard = 'assets/brand/category-icons/png/cat_leaderboard.png';
  static const String catCalendar = 'assets/brand/category-icons/png/cat_calendar.png';
  static const String catSettings = 'assets/brand/category-icons/png/cat_settings.png';
  static const String catProfile = 'assets/brand/category-icons/png/cat_profile.png';
  static const String catSubscription = 'assets/brand/category-icons/png/cat_subscription.png';
  static const String catDownloads = 'assets/brand/category-icons/png/cat_downloads.png';
  static const String catBookmarks = 'assets/brand/category-icons/png/cat_bookmarks.png';
  static const String catHistory = 'assets/brand/category-icons/png/cat_history.png';

  // Lottie animations (assets/brand/animations/)
  static const String animLoading = 'assets/brand/animations/loading.json';
  static const String animTyping = 'assets/brand/animations/typing.json';
  static const String animAiThinking = 'assets/brand/animations/ai-thinking.json';
  static const String animListening = 'assets/brand/animations/listening.json';
  static const String animSpeaking = 'assets/brand/animations/speaking.json';
  static const String animVoiceWave = 'assets/brand/animations/voice-wave.json';
  static const String animLessonComplete = 'assets/brand/animations/lesson-complete.json';
  static const String animBadgeUnlock = 'assets/brand/animations/badge-unlock.json';
  static const String animXpIncrease = 'assets/brand/animations/xp-increase.json';
  static const String animCorrectAnswer = 'assets/brand/animations/correct-answer.json';
  static const String animWrongAnswer = 'assets/brand/animations/wrong-answer.json';
  static const String animStreakFire = 'assets/brand/animations/streak-fire.json';

  // Lottie confetti (assets/brand/animations/lottie/)
  static const String animConfetti = 'assets/brand/animations/lottie/confetti.json';

  // Voice wave animations (assets/brand/animations/voice-wave/)
  static const String voiceWaveIdle = 'assets/brand/animations/voice-wave/voice_wave_idle.json';
  static const String voiceWaveListening = 'assets/brand/animations/voice-wave/voice_wave_listening.json';
  static const String voiceWaveSpeaking = 'assets/brand/animations/voice-wave/voice_wave_speaking.json';
  static const String voiceWaveAiResponse = 'assets/brand/animations/voice-wave/voice_wave_ai_response.json';
  static const String voiceWaveRecording = 'assets/brand/animations/voice-wave/voice_wave_recording.json';
  static const String voiceWaveProcessing = 'assets/brand/animations/voice-wave/voice_wave_processing.json';
  static const String voiceWaveDarkMode = 'assets/brand/animations/voice-wave/voice_wave_dark_mode.json';
  static const String voiceWaveLightMode = 'assets/brand/animations/voice-wave/voice_wave_light_mode.json';

  // Mascot paths (assets/brand/mascot/)
  static const String mascotHappy = 'assets/brand/mascot/png/mascot_happy.png';
  static const String mascotThinking = 'assets/brand/mascot/png/mascot_thinking.png';
  static const String mascotCelebrating = 'assets/brand/mascot/png/mascot_celebrating.png';
  static const String mascotListening = 'assets/brand/mascot/png/mascot_listening.png';
  static const String mascotTeaching = 'assets/brand/mascot/png/mascot_teaching.png';
  static const String mascotIdle = 'assets/brand/mascot/png/mascot_idle.png';
  static const String mascotHappySvg = 'assets/brand/mascot/svg/mascot_happy.svg';
  static const String mascotThinkingSvg = 'assets/brand/mascot/svg/mascot_thinking.svg';
  static const String mascotCelebratingSvg = 'assets/brand/mascot/svg/mascot_celebrating.svg';
  static const String mascotListeningSvg = 'assets/brand/mascot/svg/mascot_listening.svg';
  static const String mascotTeachingSvg = 'assets/brand/mascot/svg/mascot_teaching.svg';

  // Avatar paths (assets/brand/avatars/)
  static String avatarPath(int avatarId) => 'assets/brand/avatars/png/avatar_$avatarId.png';
  static String avatarSvgPath(int avatarId) => 'assets/brand/avatars/svg/avatar_$avatarId.svg';
  static String maleAvatarPath(int avatarId) => 'assets/brand/avatars/png/avatar_m$avatarId.png';
  static String femaleAvatarPath(int avatarId) => 'assets/brand/avatars/png/avatar_f$avatarId.png';

  // Notification icons (assets/brand/notification-icons/)
  static const String notifLessonReminder = 'assets/brand/notification-icons/png/notif_lesson_reminder.png';
  static const String notifPracticeReminder = 'assets/brand/notification-icons/png/notif_practice_reminder.png';
  static const String notifStreakReminder = 'assets/brand/notification-icons/png/notif_streak_reminder.png';
  static const String notifSubscription = 'assets/brand/notification-icons/png/notif_subscription.png';
  static const String notifAchievement = 'assets/brand/notification-icons/png/notif_achievement.png';
  static const String notifExamReminder = 'assets/brand/notification-icons/png/notif_exam_reminder.png';

  // Certificate paths (assets/brand/certificates/)
  static const String certificateLight = 'assets/brand/certificates/png/certificate_light.png';
  static const String certificateDark = 'assets/brand/certificates/png/certificate_dark.png';
  static const String certificateLightSvg = 'assets/brand/certificates/svg/certificate_light.svg';
  static const String certificateDarkSvg = 'assets/brand/certificates/svg/certificate_dark.svg';
  static const String certificateTemplateSvg = 'assets/brand/certificates/certificate-template.svg';

  // Marketing assets (assets/brand/marketing/)
  static const String marketingBanner = 'assets/brand/marketing/png/marketing_banner.png';
  static const String marketingBannerSvg = 'assets/brand/marketing/svg/marketing_banner.svg';
  static const String heroBannerSvg = 'assets/brand/marketing/hero-banner.svg';
  static const String featureGraphicSvg = 'assets/brand/marketing/feature-graphic.svg';
  static const String googlePlayBadge = 'assets/brand/marketing/google-play-badge.svg';
  static const String appStoreBadge = 'assets/brand/marketing/app-store-badge.svg';
  static const String socialInstagram = 'assets/brand/marketing/social-instagram.svg';
  static const String socialLinkedin = 'assets/brand/marketing/social-linkedin.svg';

  // ===========================================================================
  // ANIMATION DURATIONS (extends AppDuration)
  // ===========================================================================

  static const Duration spring = Duration(milliseconds: 500);
  static const Duration extraFast = Duration(milliseconds: 100);
  static const Duration extraSlow = Duration(milliseconds: 800);
  static const Duration pageFlip = Duration(milliseconds: 450);
  static const Duration shimmer = Duration(milliseconds: 1200);

  // ===========================================================================
  // BORDER RADIUS EXTENDED (extends AppRadius)
  // ===========================================================================

  static const double xs = 4;
  static const double none = 0;
  static const double xxl = 32;
  static const double xxxl = 40;

  // ===========================================================================
  // SHADOW PRESETS
  // ===========================================================================

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: neutral900.withAlpha(8),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: neutral900.withAlpha(12),
      blurRadius: 24,
      spreadRadius: 2,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get modalShadow => [
    BoxShadow(
      color: neutral900.withAlpha(24),
      blurRadius: 32,
      spreadRadius: 4,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get fabShadow => [
    BoxShadow(
      color: blue500.withAlpha(32),
      blurRadius: 16,
      spreadRadius: 2,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: neutral900.withAlpha(4),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get glowBlue => [
    BoxShadow(
      color: blue500.withAlpha(40),
      blurRadius: 20,
      spreadRadius: 4,
    ),
  ];

  static List<BoxShadow> get glowPurple => [
    BoxShadow(
      color: purple500.withAlpha(40),
      blurRadius: 20,
      spreadRadius: 4,
    ),
  ];

  static List<BoxShadow> get glowTeal => [
    BoxShadow(
      color: teal500.withAlpha(40),
      blurRadius: 20,
      spreadRadius: 4,
    ),
  ];

  // ===========================================================================
  // OPACITY VALUES
  // ===========================================================================

  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityOverlay = 0.50;

  // ===========================================================================
  // SPACING EXTENSIONS (extends AppSpacing)
  // ===========================================================================

  static const double spacing3xs = 2;
  static const double spacing2xs = 6;
  static const double spacing2xl = 48;
  static const double spacing3xl = 56;
  static const double spacing4xl = 64;
  static const double spacing5xl = 80;

  // ===========================================================================
  // BREAKPOINTS
  // ===========================================================================

  static const double mobileSmall = 320;
  static const double mobileMedium = 375;
  static const double mobileLarge = 414;
  static const double tabletSmall = 600;
  static const double tabletMedium = 768;
  static const double tabletLarge = 1024;
  static const double desktopSmall = 1280;
  static const double desktopMedium = 1440;
  static const double desktopLarge = 1920;
}
