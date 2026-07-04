import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a widget in MaterialApp + ProviderScope for widget testing.
Widget buildTestableWidget(
  Widget child, {
  List<Override> overrides = const [],
  ThemeData? theme,
  Locale? locale,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: theme ?? ThemeData(useMaterial3: true),
      locale: locale,
      home: Scaffold(body: child),
    ),
  );
}

/// Wraps a widget in MaterialApp + ProviderScope for page-level testing.
Widget buildTestablePage(
  Widget child, {
  List<Override> overrides = const [],
  ThemeData? theme,
  String? initialRoute,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: theme ?? ThemeData(useMaterial3: true),
      initialRoute: initialRoute ?? '/',
      home: child,
    ),
  );
}

/// Creates a mock ProviderContainer with overrides.
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(overrides: overrides);
}

/// Pump and settle helper for widget tests.
Future<void> pumpAndSettle(
  WidgetTester tester,
  Widget widget, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle(timeout);
}

/// Finder helper for Semantics-based accessibility testing.
Finder findSemanticsLabel(String label) {
  return find.bySemanticsLabel(label);
}

/// Verify that a widget is accessible by checking semantic labels.
void expectAccessible(WidgetTester tester, String semanticsLabel) {
  expect(
    findSemanticsLabel(semanticsLabel),
    findsOneWidget,
    reason: 'Widget with semantics label "$semanticsLabel" not found',
  );
}

/// Verify minimum touch target size (48x48 dp per WCAG AA).
void expectMinTouchTargetSize(
  WidgetTester tester,
  Finder finder, {
  double minWidth = 48,
  double minHeight = 48,
}) {
  final size = tester.getSize(finder);
  expect(
    size.width,
    greaterThanOrEqualTo(minWidth),
    reason: 'Touch target width ${size.width} < $minWidth dp',
  );
  expect(
    size.height,
    greaterThanOrEqualTo(minHeight),
    reason: 'Touch target height ${size.height} < $minHeight dp',
  );
}
