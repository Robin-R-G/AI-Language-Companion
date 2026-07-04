class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? nativeLanguage;
  final String? targetLanguage;
  final String? targetExam;
  final DateTime? createdAt;

  const UserProfile({
    required this.id, required this.name, required this.email,
    this.avatarUrl, this.nativeLanguage, this.targetLanguage,
    this.targetExam, this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      nativeLanguage: json['native_language'] as String?,
      targetLanguage: json['target_language'] as String?,
      targetExam: json['target_exam'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email,
    'avatar_url': avatarUrl, 'native_language': nativeLanguage,
    'target_language': targetLanguage, 'target_exam': targetExam,
    'created_at': createdAt?.toIso8601String(),
  };

  UserProfile copyWith({
    String? name, String? email, String? avatarUrl,
    String? nativeLanguage, String? targetLanguage, String? targetExam,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      targetExam: targetExam ?? this.targetExam,
      createdAt: createdAt,
    );
  }
}
