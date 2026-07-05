// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$readingDataSourceHash() => r'4dd8da6c7130f0bade17c0b662a6f89a35763d0c';

/// See also [readingDataSource].
@ProviderFor(readingDataSource)
final readingDataSourceProvider =
    AutoDisposeProvider<ReadingRemoteDataSource>.internal(
      readingDataSource,
      name: r'readingDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$readingDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReadingDataSourceRef = AutoDisposeProviderRef<ReadingRemoteDataSource>;
String _$readingControllerHash() => r'ea2af3c1dd492713fd06db2d7b805ff175fea990';

/// See also [ReadingController].
@ProviderFor(ReadingController)
final readingControllerProvider =
    AutoDisposeNotifierProvider<
      ReadingController,
      AsyncValue<ReadingLesson?>
    >.internal(
      ReadingController.new,
      name: r'readingControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$readingControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReadingController = AutoDisposeNotifier<AsyncValue<ReadingLesson?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
