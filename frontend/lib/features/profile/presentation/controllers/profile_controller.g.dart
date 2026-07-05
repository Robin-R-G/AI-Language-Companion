// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryHash() => r'6876d72928f10c5a81e22a3c8aac07ace4b46b21';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
      profileRepository,
      name: r'profileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = AutoDisposeProviderRef<ProfileRepository>;
String _$profileControllerHash() => r'4467fedec7ff20dcd4a6ba43ae08b68cd298824b';

/// See also [ProfileController].
@ProviderFor(ProfileController)
final profileControllerProvider =
    AutoDisposeNotifierProvider<
      ProfileController,
      AsyncValue<UserProfile?>
    >.internal(
      ProfileController.new,
      name: r'profileControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileController = AutoDisposeNotifier<AsyncValue<UserProfile?>>;
String _$progressControllerHash() =>
    r'7923be306eb0ec7a73f8c8ac9bf03727d0ceb01d';

/// See also [ProgressController].
@ProviderFor(ProgressController)
final progressControllerProvider =
    AutoDisposeNotifierProvider<
      ProgressController,
      AsyncValue<UserProgress?>
    >.internal(
      ProgressController.new,
      name: r'progressControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$progressControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProgressController = AutoDisposeNotifier<AsyncValue<UserProgress?>>;
String _$streakControllerHash() => r'2aabfe4d72c28740adb0a3cd30ed42b649bfd0b0';

/// See also [StreakController].
@ProviderFor(StreakController)
final streakControllerProvider =
    AutoDisposeNotifierProvider<
      StreakController,
      AsyncValue<UserStreak?>
    >.internal(
      StreakController.new,
      name: r'streakControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$streakControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StreakController = AutoDisposeNotifier<AsyncValue<UserStreak?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
