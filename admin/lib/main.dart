import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/admin_config.dart';
import 'core/routes/router.dart';
import 'core/theme/admin_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase client using our configuration values
  await Supabase.initialize(
    url: AdminConfig.supabaseUrl,
    anonKey: AdminConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: AdminApp(),
    ),
  );
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AI Coach Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.lightTheme,
      darkTheme: AdminTheme.darkTheme,
      themeMode: ThemeMode.dark, // Defaulting to sleek premium Dark Mode
      routerConfig: router,
    );
  }
}
