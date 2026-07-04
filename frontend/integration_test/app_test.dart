// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ai_language_coach/main.dart' as app;
import 'package:ai_language_coach/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Integration Tests', () {
    testWidgets('App launches and displays main view', (tester) async {
      // Launch the application
      app.main();
      await tester.pumpAndSettle();

      // Verify core app configuration is loaded
      expect(find.byType(AILanguageCoachApp), findsOneWidget);
    });
  });
}
