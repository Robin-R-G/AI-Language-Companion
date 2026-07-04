import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/listening/presentation/pages/listening_page.dart';

void main() {
  group('ListeningPage', () {
    testWidgets('renders listening page with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ListeningPage()),
      );

      expect(find.text('Listening Practice'), findsOneWidget);
    });

    testWidgets('renders scaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ListeningPage()),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
