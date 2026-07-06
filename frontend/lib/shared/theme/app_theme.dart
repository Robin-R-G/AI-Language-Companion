// lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../../core/constants/design_tokens.dart';

/// Re-exports canonical design tokens so existing imports keep working.
/// Prefer importing design_tokens.dart directly for new code.
export '../../core/constants/design_tokens.dart';

/// Skill-specific color accents for lesson category chips and progress bars.
class SkillColors {
  SkillColors._();

  static const grammar = Color(0xFF6C63FF);
  static const grammarDark = Color(0xFF524BCC);
  static const vocabulary = Color(0xFF22C55E);
  static const vocabularyDark = Color(0xFF16A34A);
  static const speaking = Color(0xFFEF4444);
  static const speakingDark = Color(0xFFDC2626);
  static const writing = Color(0xFFF59E0B);
  static const writingDark = Color(0xFFD97706);
  static const reading = Color(0xFF14B8A6);
  static const readingDark = Color(0xFF0D9488);
  static const listening = Color(0xFF7C3AED);
  static const listeningDark = Color(0xFF6D28D9);
}
