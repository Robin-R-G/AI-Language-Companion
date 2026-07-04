import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/widgets/info_tile.dart';

void main() {
  group('InfoTile', () {
    testWidgets('renders icon, title, and chevron', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoTile(icon: Icons.person, title: 'Edit Profile'),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders with subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
            ),
          ),
        ),
      );

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('renders custom trailing widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoTile(
              icon: Icons.notifications,
              title: 'Notifications',
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoTile(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InfoTile));
      expect(tapped, isTrue);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoTile(icon: Icons.person, title: 'Profile'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(InfoTile));
      expect(semantics.label, 'Profile');
    });
  });
}
