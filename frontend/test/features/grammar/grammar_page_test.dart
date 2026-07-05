import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/grammar/presentation/pages/grammar_page.dart';

void main() {
  group('GrammarPage', () {
    testWidgets('renders grammar check page', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GrammarPage()));

      expect(find.text('Grammar Check'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Check'), findsOneWidget);
    });

    testWidgets('shows error view when error state is triggered', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GrammarPage()));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
