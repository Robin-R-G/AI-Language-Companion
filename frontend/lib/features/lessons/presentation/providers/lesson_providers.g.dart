// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lessonsListHash() => r'360e819358947b29488e868cc544ef76ece2817c';

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
String _$lessonDetailHash() => r'91b0beef19544644772e80e9f9e9a58a5fb93516';

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
