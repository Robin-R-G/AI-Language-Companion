class ProgressStats {
  final String id;
  final double ieltsScore;
  final double studyHours;
  final int dayStreak;
  final int xpEarned;
  final Map<String, double> weeklyActivity;
  final Map<String, double> skillScores;

  const ProgressStats({
    required this.id,
    required this.ieltsScore,
    required this.studyHours,
    required this.dayStreak,
    required this.xpEarned,
    required this.weeklyActivity,
    required this.skillScores,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      id: json['id'] as String,
      ieltsScore: (json['ielts_score'] as num).toDouble(),
      studyHours: (json['study_hours'] as num).toDouble(),
      dayStreak: json['day_streak'] as int,
      xpEarned: json['xp_earned'] as int,
      weeklyActivity: (json['weekly_activity'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      skillScores: (json['skill_scores'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ielts_score': ieltsScore,
    'study_hours': studyHours,
    'day_streak': dayStreak,
    'xp_earned': xpEarned,
    'weekly_activity': weeklyActivity,
    'skill_scores': skillScores,
  };
}
