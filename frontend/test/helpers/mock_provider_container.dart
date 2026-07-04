// test/helpers/mock_provider_container.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to create a [ProviderContainer] for testing with overridden providers.
/// Automatically handles container disposal in [tearDown].
ProviderContainer createMockContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}
