// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$grammarRepositoryHash() => r'beb52c024f55f296919c210970d9f8ff42950368';

/// See also [grammarRepository].
@ProviderFor(grammarRepository)
final grammarRepositoryProvider =
    AutoDisposeProvider<GrammarRepository>.internal(
      grammarRepository,
      name: r'grammarRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$grammarRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GrammarRepositoryRef = AutoDisposeProviderRef<GrammarRepository>;
String _$grammarControllerHash() => r'23d131dde9d65da1abf2afe56c288830e6137f64';

/// See also [GrammarController].
@ProviderFor(GrammarController)
final grammarControllerProvider =
    AutoDisposeNotifierProvider<
      GrammarController,
      AsyncValue<GrammarResult?>
    >.internal(
      GrammarController.new,
      name: r'grammarControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$grammarControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GrammarController = AutoDisposeNotifier<AsyncValue<GrammarResult?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
