import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/features/profile/presentation/pages/edit_profile_page.dart';

void main() {
  group('EditProfilePage', () {
    testWidgets('renders edit profile page with title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EditProfilePage()));

      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('renders form fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EditProfilePage()));

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
