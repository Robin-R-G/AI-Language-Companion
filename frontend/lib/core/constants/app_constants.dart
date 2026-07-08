import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application constants and environment configuration.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'AI Language Coach';
  static const String appVersion = '1.0.0';

  // Platform Identifiers
  static const String androidPackageName = 'com.ailanguagecoach.app';
  static const String iosAppStoreId = '1234567890';

  // API Configuration — loaded from the bundled .env asset at runtime
  // (see bootstrap.dart). Falls back to compile-time --dart-define flags.
  // Secrets are never hard-coded in source.
  static String get supabaseUrl {
    final value = dotenv.env['SUPABASE_URL'];
    if (value != null && value.isNotEmpty && !value.startsWith('your-')) return value;
    final fallback = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    if (fallback.isNotEmpty && !fallback.startsWith('your-')) return fallback;
    throw Exception('SUPABASE_URL not configured. Set it in .env or via --dart-define.');
  }

  static String get supabaseAnonKey {
    final value = dotenv.env['SUPABASE_ANON_KEY'];
    if (value != null && value.isNotEmpty && !value.startsWith('your-')) return value;
    final fallback = const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
    if (fallback.isNotEmpty && !fallback.startsWith('your-')) return fallback;
    throw Exception('SUPABASE_ANON_KEY not configured. Set it in .env or via --dart-define.');
  }

  // RevenueCat Configuration
  static String get revenueCatApiKey {
    final value = dotenv.env['REVENUECAT_API_KEY'];
    if (value != null && value.isNotEmpty) return value;
    return const String.fromEnvironment(
      'REVENUECAT_API_KEY',
      defaultValue: 'your-revenuecat-api-key',
    );
  }

  // API Endpoints
  static const String apiBaseUrl = '/functions/v1';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userProfileKey = 'user_profile';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeModeKey = 'theme_mode';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Voice Configuration
  static const Duration minVoiceSession = Duration(minutes: 1);
  static const Duration maxVoiceSession = Duration(minutes: 30);
  static const double defaultVoiceSpeed = 1.0;

  // Gamification
  static const int xpPerLesson = 100;
  static const int xpPerVoiceSession = 50;
  static const int xpPerMockExam = 200;
  static const int streakBonusMultiplier = 2;

  // Free Tier Limits
  static const int freeVoiceMinutesPerDay = 5;
  static const int freeLessonsPerDay = 3;
  static const int freeMockExamsPerMonth = 2;

  // Native Languages
  static const List<Map<String, String>> nativeLanguages = [
    {'code': 'ml', 'name': 'Malayalam', 'nativeName': 'മലയാളം'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
    {'code': 'kn', 'name': 'Kannada', 'nativeName': 'ಕನ್ನಡ'},
    {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી'},
    {'code': 'pa', 'name': 'Punjabi', 'nativeName': 'ਪੰਜਾਬੀ'},
    {'code': 'ur', 'name': 'Urdu', 'nativeName': 'اردو'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
    {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
    {'code': 'pt', 'name': 'Portuguese', 'nativeName': 'Português'},
    {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский'},
  ];

  // Target Languages
  static const List<Map<String, String>> targetLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
  ];

  // Proficiency Levels (CEFR)
  static const List<Map<String, String>> proficiencyLevels = [
    {
      'code': 'A1',
      'name': 'Beginner',
      'description': 'Can understand and use familiar everyday expressions',
    },
    {
      'code': 'A2',
      'name': 'Elementary',
      'description': 'Can communicate in simple and routine tasks',
    },
    {
      'code': 'B1',
      'name': 'Intermediate',
      'description': 'Can deal with most situations while travelling',
    },
    {
      'code': 'B2',
      'name': 'Upper Intermediate',
      'description': 'Can interact with a degree of fluency',
    },
    {
      'code': 'C1',
      'name': 'Advanced',
      'description':
          'Can use language flexibly for social and professional purposes',
    },
    {
      'code': 'C2',
      'name': 'Mastery',
      'description':
          'Can understand with ease virtually everything heard or read',
    },
  ];

  // Exams - Aligned with Official Exam Resource Guide
  // Each exam includes a 'language' field for onboarding filtering.
  // 'language' values: 'en', 'de', 'fr', 'es', 'ja', 'ko', 'zh', 'all'
  static const List<Map<String, String>> exams = [
    // ─── English Exams ──────────────────────────────────────────────────────
    {
      'code': 'ielts',
      'name': 'IELTS',
      'description': 'International English Language Testing System',
      'language': 'en',
    },
    {
      'code': 'toefl',
      'name': 'TOEFL iBT',
      'description': 'Test of English as a Foreign Language',
      'language': 'en',
    },
    {
      'code': 'pte',
      'name': 'PTE Academic',
      'description': 'Pearson Test of English Academic',
      'language': 'en',
    },
    {
      'code': 'oet',
      'name': 'OET',
      'description': 'Occupational English Test',
      'language': 'en',
    },
    {
      'code': 'toeic',
      'name': 'TOEIC',
      'description': 'Test of English for International Communication',
      'language': 'en',
    },
    {
      'code': 'cambridge_a2_key',
      'name': 'Cambridge A2 Key',
      'description': 'Cambridge English: A2 Key (KET)',
      'language': 'en',
    },
    {
      'code': 'cambridge_b1_preliminary',
      'name': 'Cambridge B1 Preliminary',
      'description': 'Cambridge English: B1 Preliminary (PET)',
      'language': 'en',
    },
    {
      'code': 'cambridge_b2_first',
      'name': 'Cambridge B2 First',
      'description': 'Cambridge English: B2 First (FCE)',
      'language': 'en',
    },
    {
      'code': 'cambridge_c1_advanced',
      'name': 'Cambridge C1 Advanced',
      'description': 'Cambridge English: C1 Advanced (CAE)',
      'language': 'en',
    },
    {
      'code': 'cambridge_c2_proficiency',
      'name': 'Cambridge C2 Proficiency',
      'description': 'Cambridge English: C2 Proficiency (CPE)',
      'language': 'en',
    },
    {
      'code': 'duolingo',
      'name': 'Duolingo English Test',
      'description': 'Duolingo English Test',
      'language': 'en',
    },
    {
      'code': 'celpip',
      'name': 'CELPIP',
      'description': 'Canadian English Language Proficiency Index Program',
      'language': 'en',
    },
    {
      'code': 'linguaskill',
      'name': 'Linguaskill',
      'description': 'Cambridge Linguaskill',
      'language': 'en',
    },
    {
      'code': 'sat',
      'name': 'SAT',
      'description': 'College Board SAT',
      'language': 'en',
    },
    {
      'code': 'act',
      'name': 'ACT',
      'description': 'ACT College Readiness Assessment',
      'language': 'en',
    },
    {
      'code': 'gre',
      'name': 'GRE',
      'description': 'Graduate Record Examinations',
      'language': 'en',
    },
    {
      'code': 'gmat',
      'name': 'GMAT',
      'description': 'Graduate Management Admission Test',
      'language': 'en',
    },
    // ─── German Exams ───────────────────────────────────────────────────────
    {
      'code': 'goethe_a1',
      'name': 'Goethe A1',
      'description': 'Goethe-Zertifikat A1',
      'language': 'de',
    },
    {
      'code': 'goethe_a2',
      'name': 'Goethe A2',
      'description': 'Goethe-Zertifikat A2',
      'language': 'de',
    },
    {
      'code': 'goethe_b1',
      'name': 'Goethe B1',
      'description': 'Goethe-Zertifikat B1',
      'language': 'de',
    },
    {
      'code': 'goethe_b2',
      'name': 'Goethe B2',
      'description': 'Goethe-Zertifikat B2',
      'language': 'de',
    },
    {
      'code': 'goethe_c1',
      'name': 'Goethe C1',
      'description': 'Goethe-Zertifikat C1',
      'language': 'de',
    },
    {
      'code': 'goethe_c2',
      'name': 'Goethe C2',
      'description': 'Goethe-Zertifikat C2',
      'language': 'de',
    },
    {
      'code': 'telc',
      'name': 'TELC',
      'description': 'The European Language Certificates',
      'language': 'de',
    },
    {
      'code': 'testdaf',
      'name': 'TestDaF',
      'description': 'Test Deutsch als Fremdsprache',
      'language': 'de',
    },
    {
      'code': 'dsh',
      'name': 'DSH',
      'description': 'Deutsche Sprachpruefung fuer den Hochschulzugang',
      'language': 'de',
    },
    // ─── French Exams ───────────────────────────────────────────────────────
    {
      'code': 'delf_dalf',
      'name': 'DELF/DALF',
      'description': 'Diplome d\'Etudes en Langue Francaise / Diplome Approfondi de Langue Francaise',
      'language': 'fr',
    },
    {
      'code': 'tcf',
      'name': 'TCF',
      'description': 'Test de Connaissance du Francais',
      'language': 'fr',
    },
    {
      'code': 'tef',
      'name': 'TEF',
      'description': 'Test d\'Evaluation de Francais',
      'language': 'fr',
    },
    // ─── Spanish Exams ──────────────────────────────────────────────────────
    {
      'code': 'dele',
      'name': 'DELE',
      'description': 'Diplomas de Espanol como Lengua Extranjera',
      'language': 'es',
    },
    {
      'code': 'siele',
      'name': 'SIELE',
      'description': 'Servicio Internacional de Evaluacion de la Lengua Espanola',
      'language': 'es',
    },
    // ─── Japanese Exams ─────────────────────────────────────────────────────
    {
      'code': 'jlpt',
      'name': 'JLPT',
      'description': 'Japanese-Language Proficiency Test',
      'language': 'ja',
    },
    // ─── Korean Exams ───────────────────────────────────────────────────────
    {
      'code': 'topik',
      'name': 'TOPIK',
      'description': 'Test of Proficiency in Korean',
      'language': 'ko',
    },
    // ─── Chinese Exams ──────────────────────────────────────────────────────
    {
      'code': 'hsk',
      'name': 'HSK',
      'description': 'Hanyu Shuiping Kaoshi (Chinese Proficiency Test)',
      'language': 'zh',
    },
    // ─── General / Universal ────────────────────────────────────────────────
    {
      'code': 'general',
      'name': 'General',
      'description': 'Everyday language learning',
      'language': 'all',
    },
    {
      'code': 'business',
      'name': 'Business English',
      'description': 'Professional communication skills',
      'language': 'en',
    },
  ];

  // Daily Goals (in minutes)
  static const List<int> dailyGoals = [10, 20, 30, 45, 60];

  // Motivational Quotes
  static const List<String> motivationalQuotes = [
    'Your language skills are opening new doors!',
    'Every word you learn brings you closer to fluency.',
    'Practice makes progress, not perfection.',
    'You\'re building bridges to new cultures.',
    'Small daily improvements lead to stunning results.',
    'The best time to start was yesterday. The next best time is now.',
    'Fluency is not about being perfect, it\'s about being understood.',
    'Your dedication today is your success tomorrow.',
  ];
}
