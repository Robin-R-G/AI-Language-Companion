class AppSettings {
  final String themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vocabReminders;

  const AppSettings({
    this.themeMode = 'system',
    this.language = 'en',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vocabReminders = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['theme_mode'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vocabReminders: json['vocab_reminders'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'theme_mode': themeMode, 'language': language,
    'notifications_enabled': notificationsEnabled,
    'sound_enabled': soundEnabled, 'vocab_reminders': vocabReminders,
  };

  AppSettings copyWith({String? themeMode, String? language, bool? notificationsEnabled, bool? soundEnabled, bool? vocabReminders}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vocabReminders: vocabReminders ?? this.vocabReminders,
    );
  }
}
