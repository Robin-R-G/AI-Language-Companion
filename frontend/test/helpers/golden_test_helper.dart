import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

WidgetController createGoldenWrapper(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1E3A8A),
    ),
    home: Scaffold(body: child),
  );
}

Future<void> verifyGolden(
  WidgetTester tester,
  Finder finder,
  String goldenFile, {
  bool autoUpdateGoldenFiles = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E3A8A),
      ),
      home: Scaffold(body: finder.evaluate().first.widget),
    ),
  );

  await expectLater(
    finder,
    matchesGoldenFile('goldens/$goldenFile'),
  );
}
