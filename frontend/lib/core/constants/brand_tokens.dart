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
  // blue500 = AppColors.primary500
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
  // purple500 = AppColors.secondary
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
  // teal500 = AppColors.tertiary
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
  // green500 = AppColors.success
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
  // orange500 = AppColors.warning
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
  // ASSET PATHS
  // ===========================================================================

  // Logo paths
  static const String logoFull = 'assets/images/logo/logo_full.png';
  static const String logoIcon = 'assets/images/logo/logo_icon.png';
  static const String logoMonochrome = 'assets/images/logo/logo_monochrome.png';
  static const String logoHorizontal = 'assets/images/logo/logo_horizontal.png';
  static const String logoVertical = 'assets/images/logo/logo_vertical.png';
  static const String logoFavicon = 'assets/images/logo/logo_favicon.png';

  // Illustration paths
  static const String illustrationSplash = 'assets/images/illustrations/splash.png';
  static const String illustrationOnboarding1 = 'assets/images/illustrations/onboarding_1.png';
  static const String illustrationOnboarding2 = 'assets/images/illustrations/onboarding_2.png';
  static const String illustrationOnboarding3 = 'assets/images/illustrations/onboarding_3.png';
  static const String illustrationOnboarding4 = 'assets/images/illustrations/onboarding_4.png';
  static const String illustrationEmptyChat = 'assets/images/illustrations/empty_chat.png';
  static const String illustrationEmptyLessons = 'assets/images/illustrations/empty_lessons.png';
  static const String illustrationEmptyVocabulary = 'assets/images/illustrations/empty_vocabulary.png';
  static const String illustrationEmptyFriends = 'assets/images/illustrations/empty_friends.png';
  static const String illustrationEmptyGoals = 'assets/images/illustrations/empty_goals.png';
  static const String illustrationEmptyBadges = 'assets/images/illustrations/empty_badges.png';
  static const String illustrationEmptyExams = 'assets/images/illustrations/empty_exams.png';
  static const String illustrationEmptyRewards = 'assets/images/illustrations/empty_rewards.png';
  static const String illustrationError = 'assets/images/illustrations/error.png';
  static const String illustrationSuccess = 'assets/images/illustrations/success.png';

  // Badge paths (17 badges)
  static const String badgeFirstLesson = 'assets/images/badges/badge_first_lesson.png';
  static const String badgeStreak7 = 'assets/images/badges/badge_streak_7.png';
  static const String badgeStreak30 = 'assets/images/badges/badge_streak_30.png';
  static const String badgeStreak90 = 'assets/images/badges/badge_streak_90.png';
  static const String badgeStreak365 = 'assets/images/badges/badge_streak_365.png';
  static const String badgeVocabulary100 = 'assets/images/badges/badge_vocabulary_100.png';
  static const String badgeVocabulary500 = 'assets/images/badges/badge_vocabulary_500.png';
  static const String badgeVocabulary1000 = 'assets/images/badges/badge_vocabulary_1000.png';
  static const String badgePerfectScore = 'assets/images/badges/badge_perfect_score.png';
  static const String badgeExamPassed = 'assets/images/badges/badge_exam_passed.png';
  static const String badgeExamMaster = 'assets/images/badges/badge_exam_master.png';
  static const String badgeSocialButterfly = 'assets/images/badges/badge_social_butterfly.png';
  static const String badgeHelpful = 'assets/images/badges/badge_helpful.png';
  static const String badgeNightOwl = 'assets/images/badges/badge_night_owl.png';
  static const String badgeEarlyBird = 'assets/images/badges/badge_early_bird.png';
  static const String badgeSpeedDemon = 'assets/images/badges/badge_speed_demon.png';
  static const String badgePolyglot = 'assets/images/badges/badge_polyglot.png';

  // XP level paths (10 tiers)
  static const String xpLevel1 = 'assets/images/xp/xp_level_1.png';
  static const String xpLevel2 = 'assets/images/xp/xp_level_2.png';
  static const String xpLevel3 = 'assets/images/xp/xp_level_3.png';
  static const String xpLevel4 = 'assets/images/xp/xp_level_4.png';
  static const String xpLevel5 = 'assets/images/xp/xp_level_5.png';
  static const String xpLevel6 = 'assets/images/xp/xp_level_6.png';
  static const String xpLevel7 = 'assets/images/xp/xp_level_7.png';
  static const String xpLevel8 = 'assets/images/xp/xp_level_8.png';
  static const String xpLevel9 = 'assets/images/xp/xp_level_9.png';
  static const String xpLevel10 = 'assets/images/xp/xp_level_10.png';

  // AI assistant paths (6 states)
  static const String aiIdle = 'assets/images/ai/ai_idle.png';
  static const String aiThinking = 'assets/images/ai/ai_thinking.png';
  static const String aiSpeaking = 'assets/images/ai/ai_speaking.png';
  static const String aiHappy = 'assets/images/ai/ai_happy.png';
  static const String aiEncouraging = 'assets/images/ai/ai_encouraging.png';
  static const String aiCorrecting = 'assets/images/ai/ai_correcting.png';

  // Exam icon paths (16)
  static const String examA1 = 'assets/images/exams/exam_a1.png';
  static const String examA2 = 'assets/images/exams/exam_a2.png';
  static const String examB1 = 'assets/images/exams/exam_b1.png';
  static const String examB2 = 'assets/images/exams/exam_b2.png';
  static const String examC1 = 'assets/images/exams/exam_c1.png';
  static const String examC2 = 'assets/images/exams/exam_c2.png';
  static const String examGrammar = 'assets/images/exams/exam_grammar.png';
  static const String examVocabulary = 'assets/images/exams/exam_vocabulary.png';
  static const String examListening = 'assets/images/exams/exam_listening.png';
  static const String examReading = 'assets/images/exams/exam_reading.png';
  static const String examWriting = 'assets/images/exams/exam_writing.png';
  static const String examSpeaking = 'assets/images/exams/exam_speaking.png';
  static const String examPronunciation = 'assets/images/exams/exam_pronunciation.png';
  static const String examIdioms = 'assets/images/exams/exam_idioms.png';
  static const String examCollocations = 'assets/images/exams/exam_collocations.png';
  static const String examPhrasalVerbs = 'assets/images/exams/exam_phrasal_verbs.png';

  // Language icon paths (12)
  static const String langEnglish = 'assets/images/languages/lang_english.png';
  static const String langSpanish = 'assets/images/languages/lang_spanish.png';
  static const String langFrench = 'assets/images/languages/lang_french.png';
  static const String langGerman = 'assets/images/languages/lang_german.png';
  static const String langItalian = 'assets/images/languages/lang_italian.png';
  static const String langPortuguese = 'assets/images/languages/lang_portuguese.png';
  static const String langJapanese = 'assets/images/languages/lang_japanese.png';
  static const String langKorean = 'assets/images/languages/lang_korean.png';
  static const String langChinese = 'assets/images/languages/lang_chinese.png';
  static const String langArabic = 'assets/images/languages/lang_arabic.png';
  static const String langRussian = 'assets/images/languages/lang_russian.png';
  static const String langHindi = 'assets/images/languages/lang_hindi.png';

  // Category icon paths (20)
  static const String categoryGreetings = 'assets/images/categories/category_greetings.png';
  static const String categoryTravel = 'assets/images/categories/category_travel.png';
  static const String categoryFood = 'assets/images/categories/category_food.png';
  static const String categoryShopping = 'assets/images/categories/category_shopping.png';
  static const String categoryBusiness = 'assets/images/categories/category_business.png';
  static const String categoryTechnology = 'assets/images/categories/category_technology.png';
  static const String categoryHealth = 'assets/images/categories/category_health.png';
  static const String categorySports = 'assets/images/categories/category_sports.png';
  static const String categoryMusic = 'assets/images/categories/category_music.png';
  static const String categoryMovies = 'assets/images/categories/category_movies.png';
  static const String categoryLiterature = 'assets/images/categories/category_literature.png';
  static const String categoryScience = 'assets/images/categories/category_science.png';
  static const String categoryHistory = 'assets/images/categories/category_history.png';
  static const String categoryArt = 'assets/images/categories/category_art.png';
  static const String categoryFashion = 'assets/images/categories/category_fashion.png';
  static const String categoryNature = 'assets/images/categories/category_nature.png';
  static const String categoryEnvironment = 'assets/images/categories/category_environment.png';
  static const String categoryEducation = 'assets/images/categories/category_education.png';
  static const String categoryCulture = 'assets/images/categories/category_culture.png';
  static const String categoryEmotions = 'assets/images/categories/category_emotions.png';

  // Animation paths (12 Lottie + 6 voice wave)
  static const String animLoading = 'assets/animations/loading.json';
  static const String animSuccess = 'assets/animations/success.json';
  static const String animError = 'assets/animations/error.json';
  static const String animConfetti = 'assets/animations/confetti.json';
  static const String animLevelUp = 'assets/animations/level_up.json';
  static const String animAchievement = 'assets/animations/achievement.json';
  static const String animSpeaking = 'assets/animations/speaking.json';
  static const String animListening = 'assets/animations/listening.json';
  static const String animTyping = 'assets/animations/typing.json';
  static const String animCelebration = 'assets/animations/celebration.json';
  static const String animTransition = 'assets/animations/transition.json';
  static const String animOnboarding = 'assets/animations/onboarding.json';
  static const String voiceWave1 = 'assets/animations/voice_wave_1.json';
  static const String voiceWave2 = 'assets/animations/voice_wave_2.json';
  static const String voiceWave3 = 'assets/animations/voice_wave_3.json';
  static const String voiceWave4 = 'assets/animations/voice_wave_4.json';
  static const String voiceWave5 = 'assets/animations/voice_wave_5.json';
  static const String voiceWave6 = 'assets/animations/voice_wave_6.json';

  // Mascot paths (6 states)
  static const String mascotDefault = 'assets/images/mascot/mascot_default.png';
  static const String mascotHappy = 'assets/images/mascot/mascot_happy.png';
  static const String mascotSad = 'assets/images/mascot/mascot_sad.png';
  static const String mascotThinking = 'assets/images/mascot/mascot_thinking.png';
  static const String mascotCelebrating = 'assets/images/mascot/mascot_celebrating.png';
  static const String mascotSleeping = 'assets/images/mascot/mascot_sleeping.png';

  // Avatar path generator
  static String avatarPath(String userId) => 'assets/images/avatars/avatar_$userId.png';

  // Notification icon paths (7)
  static const String notifBadge = 'assets/images/notifications/notif_badge.png';
  static const String notifAchievement = 'assets/images/notifications/notif_achievement.png';
  static const String notifReminder = 'assets/images/notifications/notif_reminder.png';
  static const String notifFriend = 'assets/images/notifications/notif_friend.png';
  static const String notifMessage = 'assets/images/notifications/notif_message.png';
  static const String notifExam = 'assets/images/notifications/notif_exam.png';
  static const String notifStreak = 'assets/images/notifications/notif_streak.png';

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
