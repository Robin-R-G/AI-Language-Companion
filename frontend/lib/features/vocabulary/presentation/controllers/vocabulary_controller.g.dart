// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vocabularyRepositoryHash() =>
    r'07326ff6221eb443abcb58de0ac18a241ece0280';

/// See also [vocabularyRepository].
@ProviderFor(vocabularyRepository)
final vocabularyRepositoryProvider =
    AutoDisposeProvider<VocabularyRepository>.internal(
      vocabularyRepository,
      name: r'vocabularyRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vocabularyRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VocabularyRepositoryRef = AutoDisposeProviderRef<VocabularyRepository>;
String _$vocabularyControllerHash() =>
    r'09be3edd594760483fb4c208dea8565732bbe275';

/// See also [VocabularyController].
@ProviderFor(VocabularyController)
final vocabularyControllerProvider =
    AutoDisposeNotifierProvider<
      VocabularyController,
      AsyncValue<List<VocabularyHistory>>
    >.internal(
      VocabularyController.new,
      name: r'vocabularyControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vocabularyControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VocabularyController =
    AutoDisposeNotifier<AsyncValue<List<VocabularyHistory>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
