import '../../../../core/errors/result.dart';
import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<Result<Subscription>> getCurrentSubscription();
  Future<Result<List<SubscriptionPlan>>> getPlans();
  Future<Result<Subscription>> purchase(String planId, String storeProductId);
  Future<Result<Subscription>> restorePurchases();
  Future<Result<void>> cancelSubscription();
  Future<Result<bool>> checkFeatureAccess(String feature);
}
