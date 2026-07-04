import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/service_providers.dart';
import '../core/services/feature_flag_service.dart';

/// Helper to create a testable MaterialApp wrapper.
class TestApp extends StatelessWidget {
  final Widget child;
  final List<Override>? overrides;

  const TestApp({super.key, required this.child, this.overrides});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }
}

/// Helper to create a ProviderContainer for testing.
ProviderContainer createTestContainer({List<Override>? overrides}) {
  return ProviderContainer(overrides: overrides ?? []);
}

/// Helper to override feature flags for testing.
Override overrideFeatureFlags({Map<String, bool>? flags}) {
  return featureFlagServiceProvider.overrideWith((ref) {
    final service = FeatureFlagService();
    if (flags != null) {
      service.setFlags(flags);
    }
    return service;
  });
}

/// Extension for pumping widgets in tests.
extension WidgetTesterExtensions on WidgetTester {
  /// Pump a widget wrapped in test infrastructure.
  Future<void> pumpTestWidget(
    Widget widget, {
    List<Override>? overrides,
  }) async {
    await pumpWidget(TestApp(overrides: overrides, child: widget));
    await pump();
  }
}
