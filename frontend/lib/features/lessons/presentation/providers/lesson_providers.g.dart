// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lessonsListHash() => r'14447e2041d01ded2cf63cfae90d20725a029bfb';

/// See also [LessonsList].
@ProviderFor(LessonsList)
final lessonsListProvider =
    AutoDisposeNotifierProvider<LessonsList, AsyncValue<List<Lesson>>>.internal(
      LessonsList.new,
      name: r'lessonsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lessonsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LessonsList = AutoDisposeNotifier<AsyncValue<List<Lesson>>>;
String _$lessonDetailHash() => r'830c2319afdfbc8627a55c6e2b12939832ce5e3b';

/// See also [LessonDetail].
@ProviderFor(LessonDetail)
final lessonDetailProvider =
    AutoDisposeNotifierProvider<LessonDetail, AsyncValue<Lesson?>>.internal(
      LessonDetail.new,
      name: r'lessonDetailProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lessonDetailHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LessonDetail = AutoDisposeNotifier<AsyncValue<Lesson?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
