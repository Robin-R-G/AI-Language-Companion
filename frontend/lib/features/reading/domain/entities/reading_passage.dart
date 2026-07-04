class ReadingPassage {
  final String id;
  final String title;
  final String content;
  final String difficulty;
  final List<String> questions;
  final List<String> correctAnswers;
  final int wordCount;

  const ReadingPassage({
    required this.id,
    required this.title,
    required this.content,
    required this.difficulty,
    required this.questions,
    required this.correctAnswers,
    required this.wordCount,
  });

  factory ReadingPassage.fromJson(Map<String, dynamic> json) {
    return ReadingPassage(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      difficulty: json['difficulty'] as String,
      questions: List<String>.from(json['questions'] as List),
      correctAnswers: List<String>.from(json['correct_answers'] as List),
      wordCount: json['word_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'difficulty': difficulty,
    'questions': questions,
    'correct_answers': correctAnswers,
    'word_count': wordCount,
  };
}
