import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    await bootstrap();
  } catch (e) {
    debugPrint('Bootstrap error: $e');
  }

  runApp(const ProviderScope(child: AILanguageCoachApp()));
}
