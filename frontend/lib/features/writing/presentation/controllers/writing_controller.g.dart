// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$writingRepositoryHash() => r'482dba96bc59de230ea4832424f5c4e5634eab82';

/// See also [writingRepository].
@ProviderFor(writingRepository)
final writingRepositoryProvider =
    AutoDisposeProvider<WritingRepository>.internal(
      writingRepository,
      name: r'writingRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$writingRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WritingRepositoryRef = AutoDisposeProviderRef<WritingRepository>;
String _$writingControllerHash() => r'970a85b6d5a8cda2dc34ab9ffe30d2810af4498f';

/// See also [WritingController].
@ProviderFor(WritingController)
final writingControllerProvider =
    AutoDisposeNotifierProvider<
      WritingController,
      AsyncValue<WritingEvaluation?>
    >.internal(
      WritingController.new,
      name: r'writingControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$writingControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WritingController =
    AutoDisposeNotifier<AsyncValue<WritingEvaluation?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
