// test/fakes/fake_repositories.dart

// Static DTO structures for testing
class FakeData {
  FakeData._();

  static const Map<String, dynamic> sampleUserProfile = {
    'id': 'user_123',
    'full_name': 'Rahul Nair',
    'native_language': 'Malayalam',
    'target_language': 'English',
    'proficiency_level': 'B1',
    'xp': 1200,
    'streak': 5,
  };

  static const List<Map<String, dynamic>> sampleLessons = [
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
    }
  ];

  static const List<Map<String, dynamic>> sampleVocabCards = [
    {
      'word': 'Empathetic',
      'meaning': 'Showing an ability to understand and share the feelings of another.',
      'meaning_malayalam': 'സഹാനുഭൂതിയുള്ള',
      'ipa': '/ˌɛmpəˈθɛtɪk/',
    }
  ];
}
