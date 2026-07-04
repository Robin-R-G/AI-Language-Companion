import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '..\..\helpers/golden_test_helper.dart';

void main() {
  testWidgets('AppBar renders correctly in light mode', (tester) async {
    await tester.pumpWidget(
      createGoldenWrapper(
        Scaffold(
          appBar: AppBar(
            title: const Text('AI Language Coach'),
            actions: [
              IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            ],
          ),
          body: const Center(child: Text('Content placeholder')),
        ),
        isDark: false,
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_bar_light.png'),
    );
  });

  testWidgets('AppBar renders correctly in dark mode', (tester) async {
    await tester.pumpWidget(
      createGoldenWrapper(
        Scaffold(
          appBar: AppBar(
            title: const Text('AI Language Coach'),
            actions: [
              IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            ],
          ),
          body: const Center(child: Text('Content placeholder')),
        ),
        isDark: true,
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_bar_dark.png'),
    );
  });
}
