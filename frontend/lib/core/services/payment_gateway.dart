import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// ── Models ────────────────────────────────────────────────────────────────────

enum PaymentGatewayType { revenueCat, stripe, razorpay, upi, wallet }

enum PaymentStatus { pending, processing, completed, failed, refunded }

class PaymentIntent {
  const PaymentIntent({
    required this.id,
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.status,
    this.metadata,
  });

  final String id;
  final double amount;
  final String currency;
  final PaymentGatewayType gateway;
  final PaymentStatus status;
  final Map<String, dynamic>? metadata;
}

class PaymentResult {
  const PaymentResult({
    required this.success,
    this.transactionId,
    this.error,
    this.data,
  });

  final bool success;
  final String? transactionId;
  final String? error;
  final Map<String, dynamic>? data;

  factory PaymentResult.success(String transactionId,
      [Map<String, dynamic>? data]) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      data: data,
    );
  }

  factory PaymentResult.failure(String error) {
    return PaymentResult(success: false, error: error);
  }
}

// ── Credit package model ──────────────────────────────────────────────────────

class CreditPackage {
  const CreditPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceUsd,
    required this.priceInr,
    this.bonusCredits = 0,
    this.isPopular = false,
    this.revenueCatPackageId,
  });

  final String id;
  final String name;
  final int credits;
  final double priceUsd;
  final double priceInr;
  final int bonusCredits;
  final bool isPopular;
  final String? revenueCatPackageId;

  int get totalCredits => credits + bonusCredits;
}

// ── Gateway ───────────────────────────────────────────────────────────────────

/// Unified payment gateway that routes to the correct provider based on
/// platform and user preference. Architecture:
///
///   RevenueCat / Google Play / Apple IAP / Stripe / Razorpay / UPI
///     ↓
///   PaymentGateway (this class)
///     ↓
///   Supabase (wallet, subscriptions, credits)
///     ↓
///   AI Gateway (credit consumption)
class PaymentGateway {
  PaymentGateway._();
  static final PaymentGateway instance = PaymentGateway._();

  final SupabaseClient _client = Supabase.instance.client;

  // ── RevenueCat / In‑App Purchase ──────────────────────────────────────────

  /// Purchase a subscription via RevenueCat (iOS/Android).
  Future<PaymentResult> purchaseSubscription(String packageIdentifier) async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        return PaymentResult.failure('No offerings available.');
      }

      final pkg = current.availablePackages.firstWhere(
        (p) => p.identifier == packageIdentifier,
        orElse: () => current.availablePackages.first,
      );

      final customerInfo = await Purchases.purchasePackage(pkg);
      final activeEntitlements = customerInfo.entitlements.active;

      if (activeEntitlements.isNotEmpty) {
        // Sync to Supabase — webhook will also handle this, but sync for UX
        await _syncRevenueCatToSupabase(customerInfo);
        return PaymentResult.success(
          customerInfo.originalAppUserId,
          {'entitlements': activeEntitlements.keys.toList()},
        );
      }

      return PaymentResult.failure('Purchase not completed.');
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return PaymentResult.failure('Purchase cancelled.');
      }
      return PaymentResult.failure('Purchase failed: $e');
    } catch (e) {
      return PaymentResult.failure(e.toString());
    }
  }

  /// Restore previous purchases.
  Future<PaymentResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      await _syncRevenueCatToSupabase(customerInfo);
      final hasActive = customerInfo.entitlements.active.isNotEmpty;
      return hasActive
          ? PaymentResult.success(customerInfo.originalAppUserId)
          : PaymentResult.failure('No active subscriptions found.');
    } catch (e) {
      return PaymentResult.failure('Restore failed: $e');
    }
  }

  // ── Stripe (Web / International) ─────────────────────────────────────────

  /// Initiate a Stripe payment via Supabase edge function.
  Future<PaymentResult> stripePayment({
    required double amount,
    required String currency,
    required String description,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'payment-api',
        body: {
          'gateway': 'stripe',
          'action': 'create_payment_intent',
          'amount': (amount * 100).round(), // cents
          'currency': currency,
          'description': description,
          'metadata': metadata,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data.toString());
      }

      final data = response.data as Map<String, dynamic>;
      return PaymentResult.success(
        data['payment_intent_id'] as String,
        {'client_secret': data['client_secret']},
      );
    } catch (e) {
      return PaymentResult.failure('Stripe error: $e');
    }
  }

  // ── Razorpay (India) ─────────────────────────────────────────────────────

  /// Create a Razorpay order via Supabase edge function.
  Future<PaymentResult> razorpayCreateOrder({
    required double amountInr,
    required String description,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'payment-api',
        body: {
          'gateway': 'razorpay',
          'action': 'create_order',
          'amount': (amountInr * 100).round(), // paise
          'currency': 'INR',
          'description': description,
          'metadata': metadata,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data.toString());
      }

      final data = response.data as Map<String, dynamic>;
      return PaymentResult.success(
        data['order_id'] as String,
        data.cast<String, dynamic>(),
      );
    } catch (e) {
      return PaymentResult.failure('Razorpay error: $e');
    }
  }

  /// Verify a Razorpay payment signature server-side.
  Future<PaymentResult> razorpayVerify({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'payment-api',
        body: {
          'gateway': 'razorpay',
          'action': 'verify_payment',
          'order_id': orderId,
          'payment_id': paymentId,
          'signature': signature,
        },
      );

      if (response.status != 200) {
        return PaymentResult.failure('Signature verification failed.');
      }

      // Award credits / activate subscription
      final data = response.data as Map<String, dynamic>;
      return PaymentResult.success(paymentId, data.cast<String, dynamic>());
    } catch (e) {
      return PaymentResult.failure('Verification error: $e');
    }
  }

  // ── Credit packages ──────────────────────────────────────────────────────

  /// Load available credit packages from Supabase.
  Future<List<CreditPackage>> getCreditPackages() async {
    try {
      final response = await _client
          .from('credit_packages')
          .select()
          .eq('is_active', true)
          .order('credits');

      return (response as List).map((row) {
        return CreditPackage(
          id: row['id'] as String,
          name: row['name'] as String,
          credits: row['credits'] as int,
          priceUsd: (row['price_usd'] as num).toDouble(),
          priceInr: (row['price_inr'] as num).toDouble(),
          bonusCredits: (row['bonus_credits'] as int?) ?? 0,
          isPopular: (row['is_popular'] as bool?) ?? false,
          revenueCatPackageId: row['revenuecat_package_id'] as String?,
        );
      }).toList();
    } catch (e) {
      return _defaultPackages;
    }
  }

  /// Purchase a credit package via the best available gateway.
  Future<PaymentResult> purchaseCreditPackage(
    CreditPackage package, {
    PaymentGatewayType gateway = PaymentGatewayType.razorpay,
  }) async {
    switch (gateway) {
      case PaymentGatewayType.revenueCat:
        if (package.revenueCatPackageId != null) {
          return purchaseSubscription(package.revenueCatPackageId!);
        }
        return PaymentResult.failure('No RevenueCat package ID configured.');

      case PaymentGatewayType.razorpay:
        return razorpayCreateOrder(
          amountInr: package.priceInr,
          description: '${package.totalCredits} AI Credits',
          metadata: {
            'package_id': package.id,
            'credits': package.totalCredits,
          },
        );

      case PaymentGatewayType.stripe:
        return stripePayment(
          amount: package.priceUsd,
          currency: 'usd',
          description: '${package.totalCredits} AI Credits',
          metadata: {
            'package_id': package.id,
            'credits': package.totalCredits,
          },
        );

      case PaymentGatewayType.wallet:
        return _deductFromWallet(package.totalCredits);

      case PaymentGatewayType.upi:
        // UPI is handled via Razorpay's UPI flow
        return razorpayCreateOrder(
          amountInr: package.priceInr,
          description: '${package.totalCredits} AI Credits (UPI)',
          metadata: {
            'package_id': package.id,
            'credits': package.totalCredits,
            'method': 'upi',
          },
        );
    }
  }

  // ── Subscription status ──────────────────────────────────────────────────

  Future<bool> isSubscribed() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (_) {
      // Fallback: check Supabase
      final user = _client.auth.currentUser;
      if (user == null) return false;
      final response = await _client
          .from('subscriptions')
          .select('status')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();
      return response != null;
    }
  }

  // ── Internals ────────────────────────────────────────────────────────────

  Future<void> _syncRevenueCatToSupabase(CustomerInfo customerInfo) async {
    try {
      await _client.functions.invoke(
        'revenuecat-sync',
        body: {
          'customer_id': customerInfo.originalAppUserId,
          'entitlements': customerInfo.entitlements.active.keys.toList(),
          'expires': customerInfo.entitlements.active.values
              .map((e) => e.expirationDate?.toString())
              .toList(),
        },
      );
    } catch (_) {
      // Non-critical: webhook will handle the definitive sync
    }
  }

  Future<PaymentResult> _deductFromWallet(int credits) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return PaymentResult.failure('Not authenticated.');

      final response = await _client.functions.invoke(
        'payment-api',
        body: {
          'gateway': 'wallet',
          'action': 'deduct_credits',
          'credits': credits,
        },
      );

      if (response.status == 200) {
        return PaymentResult.success('wallet-${DateTime.now().millisecondsSinceEpoch}');
      }
      return PaymentResult.failure('Insufficient wallet balance.');
    } catch (e) {
      return PaymentResult.failure(e.toString());
    }
  }

  // ── Default packages fallback ─────────────────────────────────────────────

  static const List<CreditPackage> _defaultPackages = [
    CreditPackage(
      id: 'starter',
      name: 'Starter',
      credits: 100,
      priceUsd: 0.99,
      priceInr: 79,
    ),
    CreditPackage(
      id: 'basic',
      name: 'Basic',
      credits: 500,
      priceUsd: 3.99,
      priceInr: 329,
      bonusCredits: 50,
    ),
    CreditPackage(
      id: 'pro',
      name: 'Pro',
      credits: 1500,
      priceUsd: 9.99,
      priceInr: 829,
      bonusCredits: 250,
      isPopular: true,
    ),
    CreditPackage(
      id: 'unlimited',
      name: 'Unlimited',
      credits: 5000,
      priceUsd: 24.99,
      priceInr: 2099,
      bonusCredits: 1000,
    ),
  ];
}

// ── Providers ─────────────────────────────────────────────────────────────────

final paymentGatewayProvider = Provider<PaymentGateway>((ref) {
  return PaymentGateway.instance;
});

final creditPackagesProvider = FutureProvider<List<CreditPackage>>((ref) async {
  return PaymentGateway.instance.getCreditPackages();
});

final subscriptionStatusProvider = FutureProvider<bool>((ref) async {
  return PaymentGateway.instance.isSubscribed();
});
