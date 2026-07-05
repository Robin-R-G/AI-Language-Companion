// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'e5c9c75dd4a85ab1e4de9216425ecb05cc781d39';

/// See also [dashboardRepository].
@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider =
    AutoDisposeProvider<DashboardRepository>.internal(
      dashboardRepository,
      name: r'dashboardRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRepositoryRef = AutoDisposeProviderRef<DashboardRepository>;
String _$homeControllerHash() => r'29821a6632aef93a2c4e967e352fa22509f78b92';

/// See also [HomeController].
@ProviderFor(HomeController)
final homeControllerProvider =
    AutoDisposeNotifierProvider<
      HomeController,
      AsyncValue<DashboardData?>
    >.internal(
      HomeController.new,
      name: r'homeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeController = AutoDisposeNotifier<AsyncValue<DashboardData?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
