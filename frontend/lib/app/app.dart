import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_storage.dart';
import 'router.dart';
import 'theme.dart';

/// Root application widget.
class AILanguageCoachApp extends ConsumerWidget {
  const AILanguageCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'AI Language Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

/// Theme mode provider for light/dark mode toggle.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final savedTheme = LocalStorage.getThemeMode();
  return savedTheme;
});
