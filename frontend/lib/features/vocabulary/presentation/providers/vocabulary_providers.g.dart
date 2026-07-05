// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vocabularyRepositoryHash() =>
    r'88390c8ae3e9e4d2216e00fc75e2a0d606f7bf0b';

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
String _$dailyVocabularyHash() => r'58ddbae261a88ee0a071afb7465caf6f2cd9a1e4';

/// See also [DailyVocabulary].
@ProviderFor(DailyVocabulary)
final dailyVocabularyProvider =
    AutoDisposeNotifierProvider<DailyVocabulary, List<VocabularyWord>>.internal(
      DailyVocabulary.new,
      name: r'dailyVocabularyProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dailyVocabularyHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DailyVocabulary = AutoDisposeNotifier<List<VocabularyWord>>;
String _$vocabularyHistoryHash() => r'410977895d09beae8fef201a70c645cbf12248fc';

/// See also [VocabularyHistory].
@ProviderFor(VocabularyHistory)
final vocabularyHistoryProvider =
    AutoDisposeNotifierProvider<
      VocabularyHistory,
      List<VocabularyWord>
    >.internal(
      VocabularyHistory.new,
      name: r'vocabularyHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vocabularyHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VocabularyHistory = AutoDisposeNotifier<List<VocabularyWord>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
