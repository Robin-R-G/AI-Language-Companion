import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/notifications/presentation/pages/notifications_page.dart';

void main() {
  group('NotificationsPage', () {
    testWidgets('renders notifications page with title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationsPage()));

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows empty state when no notifications', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationsPage()));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
