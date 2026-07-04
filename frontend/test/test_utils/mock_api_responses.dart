/// Mock API response fixtures for testing.
class MockApiResponses {
  MockApiResponses._();

  static const Map<String, dynamic> userProfile = {
    'id': 'user_123',
    'auth_user_id': 'auth_abc',
    'full_name': 'Rahul Nair',
    'email': 'rahul@example.com',
    'native_language': 'Malayalam',
    'target_language': 'English',
    'proficiency_level': 'B1',
    'target_exam': 'ielts',
    'xp': 1200,
    'streak': 5,
    'level': 8,
    'lessons_completed': 15,
    'voice_sessions_completed': 10,
    'mock_exams_completed': 3,
    'is_premium': false,
    'subscription_plan': 'free',
    'created_at': '2026-01-15T10:30:00Z',
    'updated_at': '2026-07-01T08:00:00Z',
  };

  static const Map<String, dynamic> subscription = {
    'id': 'sub_abc123',
    'user_id': 'user_123',
    'plan': 'premium',
    'status': 'active',
    'store': 'revenuecat',
    'product_id': 'premium_monthly',
    'current_period_start': '2026-06-01T00:00:00Z',
    'current_period_end': '2026-07-01T00:00:00Z',
    'is_trial': false,
    'trial_days_remaining': 0,
    'will_renew': true,
    'features': ['unlimited_voice', 'all_lessons', 'mock_exams'],
  };

  static const Map<String, dynamic> subscriptionPlan = {
    'id': 'premium_monthly',
    'name': 'Premium Monthly',
    'description': 'Full access to all features',
    'price': 9.99,
    'currency': 'USD',
    'period': 'monthly',
    'features': ['unlimited_voice', 'all_lessons', 'mock_exams', 'analytics'],
    'is_popular': true,
    'store_product_id': 'com.ailanguagecoach.premium.monthly',
  };

  static const Map<String, dynamic> voiceSession = {
    'id': 'vs_abc123',
    'user_id': 'user_123',
    'provider': 'livekit',
    'duration_seconds': 300,
    'room_id': 'room_xyz',
    'started_at': '2026-07-01T10:00:00Z',
    'ended_at': '2026-07-01T10:05:00Z',
    'average_latency_ms': 150,
    'overall_score': 78,
    'transcript_text': 'Hello, how are you today?',
  };

  static const Map<String, dynamic> pronunciationScore = {
    'fluency_score': 82,
    'grammar_score': 75,
    'vocabulary_score': 80,
    'pronunciation_score': 70,
    'overall_score': 78,
    'feedback': 'Good fluency. Work on pronunciation of "th" sounds.',
    'strengths': ['Natural rhythm', 'Good vocabulary range'],
    'issues': ['"th" sounds need practice', 'Rising intonation on statements'],
    'practice_words': ['think', 'three', 'weather', 'mother'],
    'shadowing_exercise': 'The weather in Manchester is rather interesting this time of year.',
    'estimated_proficiency': 'B1',
  };

  static const Map<String, dynamic> lesson = {
    'id': 'lesson_001',
    'title': 'Present Perfect Simple',
    'description': 'Learn how to use the present perfect tense correctly.',
    'category': 'grammar',
    'difficulty': 'B1',
    'xp_reward': 50,
    'estimated_minutes': 15,
    'content': 'The present perfect is formed with have/has + past participle...',
    'is_completed': false,
    'progress_percentage': 0,
  };

  static const Map<String, dynamic> vocabularyWord = {
    'id': 'vw_001',
    'word': 'Empathetic',
    'meaning': 'Showing an ability to understand and share the feelings of another.',
    'meaning_malayalam': 'സഹാനുഭൂതിയുള്ള',
    'ipa': '/ˌɛmpəˈθɛtɪk/',
    'example_sentence': 'She showed an empathetic response to her friend.',
    'synonyms': ['compassionate', 'understanding'],
    'antonyms': ['apathetic', 'indifferent'],
    'cefr_level': 'B2',
  };

  static const Map<String, dynamic> chatMessage = {
    'id': 'msg_001',
    'conversation_id': 'conv_001',
    'role': 'assistant',
    'content': 'Hello! How can I help you with your English today?',
    'created_at': '2026-07-01T10:00:00Z',
    'grammar_feedback': null,
    'translation': null,
  };

  static const Map<String, dynamic> grammarFeedback = {
    'is_correct': false,
    'original': 'I have went to the store',
    'corrected': 'I have gone to the store',
    'explanation': '"Went" is the simple past form. After "have/has", use the past participle "gone".',
    'explanation_malayalam': '"Went" എന്നത് സിംപിൾ പാസ്റ്റ് ഫോം ആണ്. "have/has" ന് ശേഷം പാസ്റ്റ് പാർട്ടിസിപ്പിൾ "gone" ഉപയോഗിക്കണം.',
    'category': 'Tense',
    'examples': ['I have eaten lunch.', 'She has visited Paris.'],
  };

  static const Map<String, dynamic> mockExam = {
    'id': 'exam_001',
    'type': 'ielts',
    'section': 'writing',
    'score': 6.5,
    'max_score': 9.0,
    'started_at': '2026-07-01T10:00:00Z',
    'completed_at': '2026-07-01T10:45:00Z',
    'feedback': 'Good task achievement. Work on coherence.',
  };

  static const Map<String, dynamic> achievement = {
    'id': 'ach_001',
    'name': 'First Steps',
    'description': 'Complete your first lesson',
    'icon': 'star',
    'xp_reward': 100,
    'unlocked_at': '2026-01-20T10:00:00Z',
  };

  static const Map<String, dynamic> dioErrorResponse = {
    'error': {
      'code': 'INVALID_REQUEST',
      'message': 'Missing required field: transcript',
    },
  };

  static const Map<String, dynamic> dioSuccessResponse = {
    'success': true,
    'data': {'id': 'new_id'},
    'message': 'Operation completed successfully',
  };

  static const List<Map<String, dynamic>> lessonsList = [
    {
      'id': 'lesson_001',
      'title': 'Present Perfect Simple',
      'difficulty': 'B1',
      'xp_reward': 50,
    },
    {
      'id': 'lesson_002',
      'title': 'Conditional Clauses Type 2',
      'difficulty': 'B2',
      'xp_reward': 75,
    },
    {
      'id': 'lesson_003',
      'title': 'Phrasal Verbs in Context',
      'difficulty': 'A2',
      'xp_reward': 30,
    },
  ];

  static const List<Map<String, dynamic>> voiceSessionsList = [
    {
      'id': 'vs_001',
      'duration_seconds': 300,
      'overall_score': 75,
      'created_at': '2026-07-01T10:00:00Z',
    },
    {
      'id': 'vs_002',
      'duration_seconds': 600,
      'overall_score': 82,
      'created_at': '2026-07-02T14:00:00Z',
    },
  ];
}
