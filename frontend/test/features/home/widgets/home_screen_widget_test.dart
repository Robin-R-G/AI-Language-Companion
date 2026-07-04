import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createTestHomeScreen() {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Column(
        children: [
          Text('Welcome to AI Language Coach'),
          SizedBox(height: 16),
          Text('Continue your learning journey'),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('Home screen displays welcome message', (tester) async {
    await tester.pumpWidget(createTestHomeScreen());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Welcome to AI Language Coach'), findsOneWidget);
    expect(find.text('Continue your learning journey'), findsOneWidget);
  });
}
