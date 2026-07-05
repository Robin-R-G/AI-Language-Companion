// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listening_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listeningDataSourceHash() =>
    r'96814705eaf737221cfc6dac942a8d37f4650a47';

/// See also [listeningDataSource].
@ProviderFor(listeningDataSource)
final listeningDataSourceProvider =
    AutoDisposeProvider<ListeningRemoteDataSource>.internal(
      listeningDataSource,
      name: r'listeningDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$listeningDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ListeningDataSourceRef =
    AutoDisposeProviderRef<ListeningRemoteDataSource>;
String _$listeningControllerHash() =>
    r'576940818eea6d4631d2d1146b57d0ec3b5b22df';

/// See also [ListeningController].
@ProviderFor(ListeningController)
final listeningControllerProvider =
    AutoDisposeNotifierProvider<
      ListeningController,
      AsyncValue<ListeningExercise?>
    >.internal(
      ListeningController.new,
      name: r'listeningControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$listeningControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ListeningController =
    AutoDisposeNotifier<AsyncValue<ListeningExercise?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
