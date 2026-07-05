// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_providers.dart';

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
String _$dailyVocabularyHash() => r'd993dd696fca841418cb3c55abd981d3a3f2bf75';

/// See also [DailyVocabulary].
@ProviderFor(DailyVocabulary)
final dailyVocabularyProvider =
    AutoDisposeNotifierProvider<
      DailyVocabulary,
      List<domain.VocabularyWord>
    >.internal(
      DailyVocabulary.new,
      name: r'dailyVocabularyProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dailyVocabularyHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DailyVocabulary = AutoDisposeNotifier<List<domain.VocabularyWord>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
