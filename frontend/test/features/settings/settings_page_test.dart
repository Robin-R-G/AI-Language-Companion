import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/settings/presentation/pages/settings_page.dart';

void main() {
  group('SettingsPage', () {
    testWidgets('renders settings page with title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders settings tiles', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
