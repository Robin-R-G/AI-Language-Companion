// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$grammarCheckHash() => r'ef994a922e1ea4452df384365941f579ee6fefe9';

/// See also [GrammarCheck].
@ProviderFor(GrammarCheck)
final grammarCheckProvider =
    AutoDisposeNotifierProvider<
      GrammarCheck,
      AsyncValue<GrammarCorrection?>
    >.internal(
      GrammarCheck.new,
      name: r'grammarCheckProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$grammarCheckHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GrammarCheck = AutoDisposeNotifier<AsyncValue<GrammarCorrection?>>;
String _$grammarHistoryHash() => r'0f9b7dce58321c5a8eb4b037141c2980c38c7a5b';

/// See also [GrammarHistory].
@ProviderFor(GrammarHistory)
final grammarHistoryProvider =
    AutoDisposeNotifierProvider<
      GrammarHistory,
      AsyncValue<List<GrammarCorrection>>
    >.internal(
      GrammarHistory.new,
      name: r'grammarHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$grammarHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GrammarHistory =
    AutoDisposeNotifier<AsyncValue<List<GrammarCorrection>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
