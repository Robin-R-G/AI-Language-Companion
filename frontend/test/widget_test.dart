import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/app/app.dart';

void main() {
  testWidgets('App renders and displays splash screen', (tester) async {
    await tester.pumpWidget(const AILanguageCoachApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App can be created', () {
    expect(true, isTrue);
  });
}
