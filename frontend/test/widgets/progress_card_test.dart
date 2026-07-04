import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/progress_card.dart';

void main() {
  group('ProgressCard', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              label: 'Study Time',
              value: '12.5h',
            ),
          ),
        ),
      );

      expect(find.text('Study Time'), findsOneWidget);
      expect(find.text('12.5h'), findsOneWidget);
    });

    testWidgets('renders with icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              label: 'Words',
              value: '500',
              icon: Icons.menu_book,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('renders with subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              label: 'Vocabulary',
              value: '1,240',
              subtitle: 'words learned',
            ),
          ),
        ),
      );

      expect(find.text('words learned'), findsOneWidget);
    });

    testWidgets('renders with progress bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              label: 'Score',
              value: '7.0',
              progress: 0.7,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with trend indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              label: 'Grammar',
              value: '6.5',
              trend: '+0.5',
            ),
          ),
        ),
      );

      expect(find.text('+0.5'), findsOneWidget);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              label: 'Speaking',
              value: '7.5',
            ),
          ),
        ),
      );

      final SemanticsNode semantics = tester.getSemantics(
        find.byType(ProgressCard),
      );
      expect(semantics.label, contains('Speaking'));
      expect(semantics.label, contains('7.5'));
    });
  });
}
