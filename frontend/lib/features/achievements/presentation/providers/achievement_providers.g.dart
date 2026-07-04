// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$achievementsListHash() => r'f7e54fb1052099deec7d427e5db5c98ef55f863b';

/// See also [AchievementsList].
@ProviderFor(AchievementsList)
final achievementsListProvider =
    AutoDisposeNotifierProvider<
      AchievementsList,
      AsyncValue<List<Achievement>>
    >.internal(
      AchievementsList.new,
      name: r'achievementsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$achievementsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AchievementsList = AutoDisposeNotifier<AsyncValue<List<Achievement>>>;
String _$achievementsProgressHash() =>
    r'e14d8ec010330425d0799422afec9911bacde4da';

/// See also [AchievementsProgress].
@ProviderFor(AchievementsProgress)
final achievementsProgressProvider =
    AutoDisposeNotifierProvider<
      AchievementsProgress,
      AsyncValue<List<AchievementProgress>>
    >.internal(
      AchievementsProgress.new,
      name: r'achievementsProgressProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$achievementsProgressHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AchievementsProgress =
    AutoDisposeNotifier<AsyncValue<List<AchievementProgress>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
