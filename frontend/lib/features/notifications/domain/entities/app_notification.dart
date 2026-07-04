class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id, required this.title, required this.body,
    required this.type, required this.isRead, required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'body': body,
    'type': type, 'is_read': isRead, 'created_at': createdAt.toIso8601String(),
  };

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id, title: title, body: body, type: type,
      isRead: isRead ?? this.isRead, createdAt: createdAt,
    );
  }
}
