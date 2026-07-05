// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_exam_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mockExamsListHash() => r'2fd36a249dc75933d9f02af0596d48aa6ebddaf5';

/// See also [MockExamsList].
@ProviderFor(MockExamsList)
final mockExamsListProvider =
    AutoDisposeNotifierProvider<
      MockExamsList,
      AsyncValue<List<MockExam>>
    >.internal(
      MockExamsList.new,
      name: r'mockExamsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mockExamsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MockExamsList = AutoDisposeNotifier<AsyncValue<List<MockExam>>>;
String _$activeExamHash() => r'58c290d647bac1d79255cdb76bc16eb770779827';

/// See also [ActiveExam].
@ProviderFor(ActiveExam)
final activeExamProvider =
    AutoDisposeNotifierProvider<ActiveExam, AsyncValue<MockExam?>>.internal(
      ActiveExam.new,
      name: r'activeExamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeExamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveExam = AutoDisposeNotifier<AsyncValue<MockExam?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
