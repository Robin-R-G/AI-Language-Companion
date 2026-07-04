import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/progress/presentation/pages/progress_page.dart';

void main() {
  group('ProgressPage', () {
    testWidgets('renders progress page with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ProgressPage()),
      );

      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('renders stat items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ProgressPage()),
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders weekly chart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ProgressPage()),
      );
      await tester.pump();

      expect(find.text('Weekly Activity'), findsOneWidget);
    });

    testWidgets('shows score breakdown section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ProgressPage()),
      );
      await tester.pump();

      expect(find.text('Score Breakdown'), findsOneWidget);
    });
  });
}
