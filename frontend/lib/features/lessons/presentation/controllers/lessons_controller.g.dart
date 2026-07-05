// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lessons_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lessonsRepositoryHash() => r'36c41685ae5131d32207f6713175126388bba556';

/// See also [lessonsRepository].
@ProviderFor(lessonsRepository)
final lessonsRepositoryProvider =
    AutoDisposeProvider<LessonsRepository>.internal(
      lessonsRepository,
      name: r'lessonsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lessonsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LessonsRepositoryRef = AutoDisposeProviderRef<LessonsRepository>;
String _$lessonsControllerHash() => r'a1b7675f9991ce481032a2b158b713acb8a6e058';

/// See also [LessonsController].
@ProviderFor(LessonsController)
final lessonsControllerProvider =
    AutoDisposeNotifierProvider<
      LessonsController,
      AsyncValue<List<Lesson>>
    >.internal(
      LessonsController.new,
      name: r'lessonsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lessonsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LessonsController = AutoDisposeNotifier<AsyncValue<List<Lesson>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
