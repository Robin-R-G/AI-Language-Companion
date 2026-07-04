import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/subscription/presentation/pages/subscription_page.dart';

void main() {
  group('SubscriptionPage', () {
    testWidgets('renders subscription page with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SubscriptionPage()),
      );

      expect(find.text('Subscription'), findsOneWidget);
    });

    testWidgets('renders pricing cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SubscriptionPage()),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
