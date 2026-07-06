import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_models.freezed.dart';
part 'marketplace_models.g.dart';

@freezed
abstract class TutorProfile with _$TutorProfile {
  const factory TutorProfile({
    required String id,
    required String userId,
    String? status,
    String? rejectionReason,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? submittedAt,
    String? governmentIdType,
    String? governmentIdUrl,
    bool? governmentIdVerified,
    String? certificateType,
    String? certificateUrl,
    bool? certificateVerified,
    String? introVideoUrl,
    bool? introVideoVerified,
    int? yearsOfExperience,
    @Default([]) List<String> specializations,
    @Default([]) List<String> languagesSpoken,
    @Default([]) List<String> targetExams,
    String? education,
    int? proposedPriceCents,
    int? approvedPriceCents,
    bool? priceChangeRequested,
    bool? idVerified,
    bool? certificateUploaded,
    bool? profilePhotoUploaded,
    bool? introVideoUploaded,
    bool? backgroundCheckPassed,
    int? totalStudents,
    double? totalHoursTaught,
    int? totalEarningsCents,
    bool? isFeatured,
    bool? isHidden,
    bool? isBlocked,
    String? blockReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? userProfiles,
  }) = _TutorProfile;

  factory TutorProfile.fromJson(Map<String, dynamic> json) =>
      _$TutorProfileFromJson(json);
}

@freezed
abstract class TutorDocument with _$TutorDocument {
  const factory TutorDocument({
    required String id,
    required String tutorId,
    required String documentType,
    required String fileUrl,
    String? fileName,
    int? fileSizeBytes,
    String? mimeType,
    @Default('pending') String verificationStatus,
    String? rejectionReason,
    DateTime? verifiedAt,
    DateTime? uploadedAt,
  }) = _TutorDocument;

  factory TutorDocument.fromJson(Map<String, dynamic> json) =>
      _$TutorDocumentFromJson(json);
}

@freezed
abstract class TutorAvailability with _$TutorAvailability {
  const factory TutorAvailability({
    required String id,
    required String tutorId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    @Default(true) bool isActive,
  }) = _TutorAvailability;

  factory TutorAvailability.fromJson(Map<String, dynamic> json) =>
      _$TutorAvailabilityFromJson(json);
}

@freezed
abstract class TutorReview with _$TutorReview {
  const factory TutorReview({
    required String id,
    required String tutorId,
    required String studentId,
    String? bookingId,
    required int rating,
    String? reviewText,
    @Default(false) bool isAnonymous,
    @Default(true) bool isApproved,
    DateTime? createdAt,
    Map<String, dynamic>? userProfiles,
  }) = _TutorReview;

  factory TutorReview.fromJson(Map<String, dynamic> json) =>
      _$TutorReviewFromJson(json);
}

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String studentId,
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    @Default('pending') String status,
    required int pricePaidCents,
    @Default(0) int platformCommissionCents,
    @Default(0) int tutorPayoutCents,
    String? paymentMethod,
    String? transactionId,
    String? meetingLink,
    int? rating,
    String? review,
    @Default('none') String refundStatus,
    @Default(0) int refundAmountCents,
    String? refundReason,
    DateTime? completedAt,
    String? cancellationReason,
    String? notes,
    DateTime? createdAt,
    Map<String, dynamic>? tutorProfiles,
    Map<String, dynamic>? userProfiles,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}

@freezed
abstract class PaymentSettlement with _$PaymentSettlement {
  const factory PaymentSettlement({
    required String id,
    required String bookingId,
    required String studentId,
    required String tutorId,
    required int amountPaidCents,
    required int platformCommissionCents,
    required double commissionPercent,
    @Default(0) int taxAmountCents,
    required int netTutorAmountCents,
    required int platformRevenueCents,
    String? paymentMethod,
    String? transactionId,
    @Default('pending') String settlementStatus,
    DateTime? settledAt,
    DateTime? createdAt,
    Map<String, dynamic>? tutorProfiles,
    Map<String, dynamic>? userProfiles,
  }) = _PaymentSettlement;

  factory PaymentSettlement.fromJson(Map<String, dynamic> json) =>
      _$PaymentSettlementFromJson(json);
}

@freezed
abstract class TutorWallet with _$TutorWallet {
  const factory TutorWallet({
    required String id,
    required String tutorId,
    @Default(0) int pendingBalanceCents,
    @Default(0) int availableBalanceCents,
    @Default(0) int processingBalanceCents,
    @Default(0) int totalEarnedCents,
    @Default(0) int totalWithdrawnCents,
    @Default(0) int totalTaxDeductedCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TutorWallet;

  factory TutorWallet.fromJson(Map<String, dynamic> json) =>
      _$TutorWalletFromJson(json);
}

@freezed
abstract class TutorPayoutMethod with _$TutorPayoutMethod {
  const factory TutorPayoutMethod({
    required String id,
    required String tutorId,
    required String methodType,
    required String accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
    String? upiId,
    String? beneficiaryName,
    @Default(false) bool isVerified,
    @Default(false) bool isDefault,
    DateTime? createdAt,
  }) = _TutorPayoutMethod;

  factory TutorPayoutMethod.fromJson(Map<String, dynamic> json) =>
      _$TutorPayoutMethodFromJson(json);
}

@freezed
abstract class TutorPayout with _$TutorPayout {
  const factory TutorPayout({
    required String id,
    required String tutorId,
    String? payoutMethodId,
    required int amountCents,
    @Default(0) int chargesCents,
    @Default(0) int taxDeductedCents,
    required int netAmountCents,
    @Default('pending') String status,
    String? rejectionReason,
    DateTime? approvedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    String? transactionReference,
    DateTime? createdAt,
    Map<String, dynamic>? tutorPayoutMethods,
  }) = _TutorPayout;

  factory TutorPayout.fromJson(Map<String, dynamic> json) =>
      _$TutorPayoutFromJson(json);
}

@freezed
abstract class PlatformAccount with _$PlatformAccount {
  const factory PlatformAccount({
    required String id,
    required String provider,
    required String accountName,
    String? businessName,
    String? accountNumber,
    String? ifscCode,
    String? upiId,
    String? beneficiaryName,
    String? gstNumber,
    String? panNumber,
    @Default('INR') String currency,
    @Default(true) bool isActive,
    @Default(false) bool isDefault,
    DateTime? createdAt,
  }) = _PlatformAccount;

  factory PlatformAccount.fromJson(Map<String, dynamic> json) =>
      _$PlatformAccountFromJson(json);
}

@freezed
abstract class CommissionRule with _$CommissionRule {
  const factory CommissionRule({
    required String id,
    required String ruleType,
    String? referenceId,
    required double commissionPercent,
    @Default(0) int minCommissionCents,
    int? maxCommissionCents,
    @Default(true) bool isActive,
    DateTime? effectiveFrom,
    DateTime? effectiveUntil,
    DateTime? createdAt,
  }) = _CommissionRule;

  factory CommissionRule.fromJson(Map<String, dynamic> json) =>
      _$CommissionRuleFromJson(json);
}

@freezed
abstract class PricingConfig with _$PricingConfig {
  const factory PricingConfig({
    required String id,
    required String configType,
    String? referenceId,
    @Default(500) int minPriceCents,
    @Default(10000) int maxPriceCents,
    @Default(2000) int defaultPriceCents,
    @Default(1.0) double premiumMultiplier,
    @Default('INR') String currency,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _PricingConfig;

  factory PricingConfig.fromJson(Map<String, dynamic> json) =>
      _$PricingConfigFromJson(json);
}

@freezed
abstract class Dispute with _$Dispute {
  const factory Dispute({
    required String id,
    required String disputeType,
    required String filedBy,
    String? againstUser,
    String? bookingId,
    String? tutorId,
    required String subject,
    required String description,
    @Default([]) List<String> evidenceUrls,
    @Default('open') String status,
    String? resolution,
    String? resolvedBy,
    DateTime? resolvedAt,
    @Default(0) int refundAmountCents,
    @Default(false) bool refundIssued,
    @Default('medium') String priority,
    DateTime? createdAt,
    Map<String, dynamic>? userProfiles,
  }) = _Dispute;

  factory Dispute.fromJson(Map<String, dynamic> json) =>
      _$DisputeFromJson(json);
}

@freezed
abstract class DisputeMessage with _$DisputeMessage {
  const factory DisputeMessage({
    required String id,
    required String disputeId,
    required String senderId,
    required String message,
    @Default([]) List<String> attachmentUrls,
    @Default(false) bool isInternalNote,
    DateTime? createdAt,
    Map<String, dynamic>? userProfiles,
  }) = _DisputeMessage;

  factory DisputeMessage.fromJson(Map<String, dynamic> json) =>
      _$DisputeMessageFromJson(json);
}

@freezed
abstract class BusinessDocument with _$BusinessDocument {
  const factory BusinessDocument({
    required String id,
    required String documentType,
    String? referenceId,
    String? referenceType,
    String? recipientId,
    required String documentNumber,
    required DateTime documentDate,
    int? amountCents,
    int? taxCents,
    int? totalCents,
    @Default('INR') String currency,
    String? fileUrl,
    String? fileFormat,
    @Default({}) Map<String, dynamic> metadata,
    DateTime? createdAt,
  }) = _BusinessDocument;

  factory BusinessDocument.fromJson(Map<String, dynamic> json) =>
      _$BusinessDocumentFromJson(json);
}

@freezed
abstract class Coupon with _$Coupon {
  const factory Coupon({
    required String id,
    required String code,
    String? description,
    required String discountType,
    required double discountValue,
    @Default(0) int minBookingAmountCents,
    int? maxDiscountCents,
    int? usageLimit,
    @Default(0) int usedCount,
    @Default('all') String applicableTo,
    DateTime? validFrom,
    DateTime? validUntil,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _Coupon;

  factory Coupon.fromJson(Map<String, dynamic> json) =>
      _$CouponFromJson(json);
}

@freezed
abstract class RevenueForecast with _$RevenueForecast {
  const factory RevenueForecast({
    required String id,
    required DateTime forecastDate,
    required String forecastType,
    @Default(0) int predictedRevenueCents,
    @Default(0) int predictedAiCostCents,
    @Default(0) int predictedTutorPayoutsCents,
    @Default(0) int predictedProfitCents,
    @Default(0) int predictedSubscriberCount,
    @Default(0.0) double predictedChurnRate,
    @Default(0.5) double confidenceScore,
    int? actualRevenueCents,
    int? actualProfitCents,
    DateTime? createdAt,
  }) = _RevenueForecast;

  factory RevenueForecast.fromJson(Map<String, dynamic> json) =>
      _$RevenueForecastFromJson(json);
}

@freezed
abstract class PlatformFinance with _$PlatformFinance {
  const factory PlatformFinance({
    required String id,
    required DateTime date,
    @Default(0) int platformWalletBalanceCents,
    @Default(0) int availableBalanceCents,
    @Default(0) int pendingBalanceCents,
    @Default(0) int tutorPayablesCents,
    @Default(0) int taxPayablesCents,
    @Default(0) int refundReserveCents,
    @Default(0) int subscriptionRevenueCents,
    @Default(0) int aiCreditRevenueCents,
    @Default(0) int tutorCommissionRevenueCents,
    @Default(0) int adRevenueCents,
    @Default(0) int affiliateRevenueCents,
    @Default(0) int certificateRevenueCents,
    @Default(0) int institutionRevenueCents,
    @Default(0) int sponsoredRevenueCents,
    @Default(0) int marketplaceRevenueCents,
    @Default(0) int aiCostCents,
    @Default(0) int infrastructureCostCents,
    @Default(0) int serverCostCents,
    @Default(0) int storageCostCents,
    @Default(0) int paymentGatewayChargesCents,
    @Default(0) int tutorPayoutCostsCents,
    @Default(0) int refundCostsCents,
    @Default(0) int grossRevenueCents,
    @Default(0) int netRevenueCents,
    @Default(0) int actualProfitCents,
    DateTime? createdAt,
  }) = _PlatformFinance;

  factory PlatformFinance.fromJson(Map<String, dynamic> json) =>
      _$PlatformFinanceFromJson(json);
}

@freezed
abstract class FinancialAuditLog with _$FinancialAuditLog {
  const factory FinancialAuditLog({
    required String id,
    required String action,
    required String entityType,
    String? entityId,
    required String performedBy,
    @Default({}) Map<String, dynamic> oldValues,
    @Default({}) Map<String, dynamic> newValues,
    String? ipAddress,
    String? reason,
    @Default(false) bool requiresApproval,
    DateTime? approvedAt,
    DateTime? createdAt,
    Map<String, dynamic>? userProfiles,
  }) = _FinancialAuditLog;

  factory FinancialAuditLog.fromJson(Map<String, dynamic> json) =>
      _$FinancialAuditLogFromJson(json);
}

@freezed
abstract class RolePermission with _$RolePermission {
  const factory RolePermission({
    required String id,
    required String role,
    required String permissionKey,
    @Default(true) bool isGranted,
    DateTime? createdAt,
  }) = _RolePermission;

  factory RolePermission.fromJson(Map<String, dynamic> json) =>
      _$RolePermissionFromJson(json);
}

@freezed
abstract class SettlementBatch with _$SettlementBatch {
  const factory SettlementBatch({
    required String id,
    required String batchType,
    @Default('pending') String status,
    @Default(0) int totalSettlements,
    @Default(0) int totalAmountCents,
    @Default(0) int totalCommissionCents,
    @Default(0) int totalTutorPayoutsCents,
    String? processedBy,
    DateTime? processedAt,
    DateTime? createdAt,
  }) = _SettlementBatch;

  factory SettlementBatch.fromJson(Map<String, dynamic> json) =>
      _$SettlementBatchFromJson(json);
}

@freezed
abstract class FeatureFlag with _$FeatureFlag {
  const factory FeatureFlag({
    required String id,
    required String flagKey,
    String? description,
    @Default(false) bool isEnabled,
    @Default(0) int rolloutPercentage,
    @Default([]) List<String> targetRoles,
    @Default([]) List<String> targetCountries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FeatureFlag;

  factory FeatureFlag.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagFromJson(json);
}
