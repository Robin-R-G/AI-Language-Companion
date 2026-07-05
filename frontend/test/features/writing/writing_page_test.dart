import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/writing/presentation/pages/writing_page.dart';

void main() {
  group('WritingPage', () {
    testWidgets('renders writing page with title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WritingPage()));

      expect(find.text('Writing Practice'), findsOneWidget);
    });

    testWidgets('renders scaffold', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WritingPage()));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
