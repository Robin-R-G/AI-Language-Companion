import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_utils/test_helpers.dart';

class SmokeTestPage extends StatelessWidget {
  final String title;
  final Widget child;

  const SmokeTestPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}

void main() {
  group('Smoke Tests - Page Rendering', () {
    testWidgets('generic page renders Scaffold', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const SmokeTestPage(
            title: 'Test Page',
            child: Center(child: Text('Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Test Page'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('page with AppBar renders correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const SmokeTestPage(
            title: 'Settings',
            child: Center(child: Text('Settings Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('page with ListView renders scrollable content', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          SmokeTestPage(
            title: 'List Page',
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  ListTile(title: Text('Item $index')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('page with form fields renders correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          SmokeTestPage(
            title: 'Form Page',
            child: Column(
              children: [
                const TextField(decoration: InputDecoration(labelText: 'Name')),
                const TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Submit')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('page with loading indicator renders', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const SmokeTestPage(
            title: 'Loading',
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('page with error state renders', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const SmokeTestPage(
            title: 'Error',
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48),
                  SizedBox(height: 16),
                  Text('Something went wrong'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('page with grid view renders correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          SmokeTestPage(
            title: 'Grid',
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: 6,
              itemBuilder: (context, index) =>
                  Card(child: Center(child: Text('Grid $index'))),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Grid 0'), findsOneWidget);
    });

    testWidgets('page navigation works', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(
                          body: Center(child: Text('Second Page')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Second'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to Second'));
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('page with bottom sheet renders', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => const SizedBox(
                        height: 200,
                        child: Center(child: Text('Bottom Sheet')),
                      ),
                    );
                  },
                  child: const Text('Show Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Bottom Sheet'), findsOneWidget);
    });
  });
}
