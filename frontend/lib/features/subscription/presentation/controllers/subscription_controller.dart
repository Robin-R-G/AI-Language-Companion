// lib/features/subscription/presentation/controllers/subscription_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/gamification.dart';

part 'subscription_controller.g.dart';

@riverpod
class SubscriptionController extends _$SubscriptionController {
  @override
  AsyncValue<Subscription?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> loadSubscription() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        state = AsyncValue.data(Subscription.fromJson(response));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error('Failed to load subscription: $e', StackTrace.current);
    }
  }

  bool get isPremium {
    final sub = state.value;
    return sub?.plan == 'Premium' && sub?.status == 'active';
  }
}
