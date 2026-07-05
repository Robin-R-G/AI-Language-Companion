// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_exam_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mockExamRepositoryHash() =>
    r'2cffed47d37427bec3c61495d3f4cd0996fd0ee9';

/// See also [mockExamRepository].
@ProviderFor(mockExamRepository)
final mockExamRepositoryProvider =
    AutoDisposeProvider<MockExamRepository>.internal(
      mockExamRepository,
      name: r'mockExamRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mockExamRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MockExamRepositoryRef = AutoDisposeProviderRef<MockExamRepository>;
String _$mockExamControllerHash() =>
    r'f7260dc82e287e6e10d694fdbbf8a3bc2b9912d2';

/// See also [MockExamController].
@ProviderFor(MockExamController)
final mockExamControllerProvider =
    AutoDisposeNotifierProvider<
      MockExamController,
      AsyncValue<List<MockExam>>
    >.internal(
      MockExamController.new,
      name: r'mockExamControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mockExamControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MockExamController = AutoDisposeNotifier<AsyncValue<List<MockExam>>>;
String _$examSessionControllerHash() =>
    r'894f839db18f54d29a25a0941ed634038ca66989';

/// See also [ExamSessionController].
@ProviderFor(ExamSessionController)
final examSessionControllerProvider =
    AutoDisposeNotifierProvider<
      ExamSessionController,
      AsyncValue<MockExam?>
    >.internal(
      ExamSessionController.new,
      name: r'examSessionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$examSessionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExamSessionController = AutoDisposeNotifier<AsyncValue<MockExam?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
