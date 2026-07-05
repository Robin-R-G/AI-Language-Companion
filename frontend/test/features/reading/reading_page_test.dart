import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/reading/presentation/pages/reading_page.dart';

void main() {
  group('ReadingPage', () {
    testWidgets('renders reading page with title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReadingPage()));

      expect(find.text('Reading Practice'), findsOneWidget);
    });

    testWidgets('renders scaffold', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReadingPage()));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
