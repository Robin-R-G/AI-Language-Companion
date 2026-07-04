// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentSubscriptionHash() =>
    r'4ca672bf022007b61db25f7a20694072b20c68ff';

/// See also [CurrentSubscription].
@ProviderFor(CurrentSubscription)
final currentSubscriptionProvider =
    AutoDisposeNotifierProvider<
      CurrentSubscription,
      AsyncValue<Subscription?>
    >.internal(
      CurrentSubscription.new,
      name: r'currentSubscriptionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentSubscriptionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentSubscription = AutoDisposeNotifier<AsyncValue<Subscription?>>;
String _$subscriptionPlansHash() => r'adb1c5b6ac4c6436cff30971ba80df375e3e17f5';

/// See also [SubscriptionPlans].
@ProviderFor(SubscriptionPlans)
final subscriptionPlansProvider =
    AutoDisposeNotifierProvider<
      SubscriptionPlans,
      AsyncValue<List<SubscriptionPlan>>
    >.internal(
      SubscriptionPlans.new,
      name: r'subscriptionPlansProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subscriptionPlansHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubscriptionPlans =
    AutoDisposeNotifier<AsyncValue<List<SubscriptionPlan>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
