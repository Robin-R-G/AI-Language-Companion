/// Application constants and environment configuration.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'AI Language Coach';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  // RevenueCat Configuration
  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'your-revenuecat-api-key',
  );

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

  // Exams
  static const List<Map<String, String>> exams = [
    {
      'code': 'ielts',
      'name': 'IELTS',
      'description': 'International English Language Testing System',
    },
    {
      'code': 'pte',
      'name': 'PTE Academic',
      'description': 'Pearson Test of English Academic',
    },
    {
      'code': 'toefl',
      'name': 'TOEFL',
      'description': 'Test of English as a Foreign Language',
    },
    {'code': 'oet', 'name': 'OET', 'description': 'Occupational English Test'},
    {
      'code': 'goethe_a1',
      'name': 'Goethe A1',
      'description': 'Goethe-Zertifikat A1',
    },
    {
      'code': 'goethe_a2',
      'name': 'Goethe A2',
      'description': 'Goethe-Zertifikat A2',
    },
    {
      'code': 'goethe_b1',
      'name': 'Goethe B1',
      'description': 'Goethe-Zertifikat B1',
    },
    {
      'code': 'goethe_b2',
      'name': 'Goethe B2',
      'description': 'Goethe-Zertifikat B2',
    },
    {
      'code': 'goethe_c1',
      'name': 'Goethe C1',
      'description': 'Goethe-Zertifikat C1',
    },
    {
      'code': 'goethe_c2',
      'name': 'Goethe C2',
      'description': 'Goethe-Zertifikat C2',
    },
    {
      'code': 'general',
      'name': 'General',
      'description': 'Everyday language learning',
    },
    {
      'code': 'business',
      'name': 'Business English',
      'description': 'Professional communication skills',
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
