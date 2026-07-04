import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/subscription.dart';

part 'subscription_providers.g.dart';

@riverpod
class CurrentSubscription extends _$CurrentSubscription {
  @override
  AsyncValue<Subscription?> build() => const AsyncValue.data(null);

  Future<void> loadSubscription() async {
    state = const AsyncValue.loading();
    final repo = ref.read(subscriptionRepositoryProvider);
    final result = await repo.getCurrentSubscription();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (sub) => state = AsyncValue.data(sub),
    );
  }
}

@riverpod
class SubscriptionPlans extends _$SubscriptionPlans {
  @override
  AsyncValue<List<SubscriptionPlan>> build() => const AsyncValue.data([]);

  Future<void> loadPlans() async {
    state = const AsyncValue.loading();
    final repo = ref.read(subscriptionRepositoryProvider);
    final result = await repo.getPlans();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (plans) => state = AsyncValue.data(plans),
    );
  }
}
