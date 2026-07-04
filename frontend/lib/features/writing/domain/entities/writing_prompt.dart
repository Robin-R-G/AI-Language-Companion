class WritingPrompt {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String category;
  final int wordLimit;

  const WritingPrompt({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.wordLimit,
  });

  factory WritingPrompt.fromJson(Map<String, dynamic> json) {
    return WritingPrompt(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
      wordLimit: json['word_limit'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'difficulty': difficulty, 'category': category, 'word_limit': wordLimit,
  };
}

class WritingSubmission {
  final String id;
  final String promptId;
  final String content;
  final String feedback;
  final double score;
  final DateTime submittedAt;

  const WritingSubmission({
    required this.id, required this.promptId, required this.content,
    required this.feedback, required this.score, required this.submittedAt,
  });

  factory WritingSubmission.fromJson(Map<String, dynamic> json) {
    return WritingSubmission(
      id: json['id'] as String,
      promptId: json['prompt_id'] as String,
      content: json['content'] as String,
      feedback: json['feedback'] as String,
      score: (json['score'] as num).toDouble(),
      submittedAt: DateTime.parse(json['submitted_at'] as String),
    );
  }
}
