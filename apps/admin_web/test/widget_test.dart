import 'package:flutter_test/flutter_test.dart';
import 'package:admin_web/main.dart';

void main() {
  testWidgets('Admin app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminApp());
    expect(find.byType(AdminApp), findsOneWidget);
  });
}
