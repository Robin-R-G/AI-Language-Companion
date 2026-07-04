import 'package:flutter/material.dart';

Widget createGoldenWrapper(Widget child, {bool isDark = false}) {
  return MaterialApp(
    theme: isDark
        ? ThemeData.dark()
        : ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF1E3A8A),
          ),
    home: Scaffold(body: child),
  );
}
