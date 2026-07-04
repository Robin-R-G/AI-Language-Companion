class ListeningExercise {
  final String id;
  final String title;
  final String audioUrl;
  final String transcript;
  final String difficulty;
  final List<String> questions;
  final List<String> correctAnswers;
  final int durationSeconds;

  const ListeningExercise({
    required this.id, required this.title, required this.audioUrl,
    required this.transcript, required this.difficulty,
    required this.questions, required this.correctAnswers,
    required this.durationSeconds,
  });

  factory ListeningExercise.fromJson(Map<String, dynamic> json) {
    return ListeningExercise(
      id: json['id'] as String,
      title: json['title'] as String,
      audioUrl: json['audio_url'] as String,
      transcript: json['transcript'] as String,
      difficulty: json['difficulty'] as String,
      questions: List<String>.from(json['questions'] as List),
      correctAnswers: List<String>.from(json['correct_answers'] as List),
      durationSeconds: json['duration_seconds'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'audio_url': audioUrl,
    'transcript': transcript, 'difficulty': difficulty,
    'questions': questions, 'correct_answers': correctAnswers,
    'duration_seconds': durationSeconds,
  };
}
