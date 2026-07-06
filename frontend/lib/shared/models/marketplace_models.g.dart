// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorProfileImpl _$$TutorProfileImplFromJson(Map<String, dynamic> json) =>
    _$TutorProfileImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      governmentIdType: json['governmentIdType'] as String?,
      governmentIdUrl: json['governmentIdUrl'] as String?,
      governmentIdVerified: json['governmentIdVerified'] as bool?,
      certificateType: json['certificateType'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      certificateVerified: json['certificateVerified'] as bool?,
      introVideoUrl: json['introVideoUrl'] as String?,
      introVideoVerified: json['introVideoVerified'] as bool?,
      yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt(),
      specializations:
          (json['specializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      languagesSpoken:
          (json['languagesSpoken'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      targetExams:
          (json['targetExams'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      education: json['education'] as String?,
      proposedPriceCents: (json['proposedPriceCents'] as num?)?.toInt(),
      approvedPriceCents: (json['approvedPriceCents'] as num?)?.toInt(),
      priceChangeRequested: json['priceChangeRequested'] as bool?,
      idVerified: json['idVerified'] as bool?,
      certificateUploaded: json['certificateUploaded'] as bool?,
      profilePhotoUploaded: json['profilePhotoUploaded'] as bool?,
      introVideoUploaded: json['introVideoUploaded'] as bool?,
      backgroundCheckPassed: json['backgroundCheckPassed'] as bool?,
      totalStudents: (json['totalStudents'] as num?)?.toInt(),
      totalHoursTaught: (json['totalHoursTaught'] as num?)?.toDouble(),
      totalEarningsCents: (json['totalEarningsCents'] as num?)?.toInt(),
      isFeatured: json['isFeatured'] as bool?,
      isHidden: json['isHidden'] as bool?,
      isBlocked: json['isBlocked'] as bool?,
      blockReason: json['blockReason'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userProfiles: json['userProfiles'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$TutorProfileImplToJson(_$TutorProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'status': instance.status,
      'rejectionReason': instance.rejectionReason,
      'approvedBy': instance.approvedBy,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'governmentIdType': instance.governmentIdType,
      'governmentIdUrl': instance.governmentIdUrl,
      'governmentIdVerified': instance.governmentIdVerified,
      'certificateType': instance.certificateType,
      'certificateUrl': instance.certificateUrl,
      'certificateVerified': instance.certificateVerified,
      'introVideoUrl': instance.introVideoUrl,
      'introVideoVerified': instance.introVideoVerified,
      'yearsOfExperience': instance.yearsOfExperience,
      'specializations': instance.specializations,
      'languagesSpoken': instance.languagesSpoken,
      'targetExams': instance.targetExams,
      'education': instance.education,
      'proposedPriceCents': instance.proposedPriceCents,
      'approvedPriceCents': instance.approvedPriceCents,
      'priceChangeRequested': instance.priceChangeRequested,
      'idVerified': instance.idVerified,
      'certificateUploaded': instance.certificateUploaded,
      'profilePhotoUploaded': instance.profilePhotoUploaded,
      'introVideoUploaded': instance.introVideoUploaded,
      'backgroundCheckPassed': instance.backgroundCheckPassed,
      'totalStudents': instance.totalStudents,
      'totalHoursTaught': instance.totalHoursTaught,
      'totalEarningsCents': instance.totalEarningsCents,
      'isFeatured': instance.isFeatured,
      'isHidden': instance.isHidden,
      'isBlocked': instance.isBlocked,
      'blockReason': instance.blockReason,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userProfiles': instance.userProfiles,
    };

_$TutorDocumentImpl _$$TutorDocumentImplFromJson(Map<String, dynamic> json) =>
    _$TutorDocumentImpl(
      id: json['id'] as String,
      tutorId: json['tutorId'] as String,
      documentType: json['documentType'] as String,
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String?,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      rejectionReason: json['rejectionReason'] as String?,
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$$TutorDocumentImplToJson(_$TutorDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tutorId': instance.tutorId,
      'documentType': instance.documentType,
      'fileUrl': instance.fileUrl,
      'fileName': instance.fileName,
      'fileSizeBytes': instance.fileSizeBytes,
      'mimeType': instance.mimeType,
      'verificationStatus': instance.verificationStatus,
      'rejectionReason': instance.rejectionReason,
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };

_$TutorAvailabilityImpl _$$TutorAvailabilityImplFromJson(
  Map<String, dynamic> json,
) => _$TutorAvailabilityImpl(
  id: json['id'] as String,
  tutorId: json['tutorId'] as String,
  dayOfWeek: (json['dayOfWeek'] as num).toInt(),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$TutorAvailabilityImplToJson(
  _$TutorAvailabilityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'tutorId': instance.tutorId,
  'dayOfWeek': instance.dayOfWeek,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'isActive': instance.isActive,
};

_$TutorReviewImpl _$$TutorReviewImplFromJson(Map<String, dynamic> json) =>
    _$TutorReviewImpl(
      id: json['id'] as String,
      tutorId: json['tutorId'] as String,
      studentId: json['studentId'] as String,
      bookingId: json['bookingId'] as String?,
      rating: (json['rating'] as num).toInt(),
      reviewText: json['reviewText'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      userProfiles: json['userProfiles'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$TutorReviewImplToJson(_$TutorReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tutorId': instance.tutorId,
      'studentId': instance.studentId,
      'bookingId': instance.bookingId,
      'rating': instance.rating,
      'reviewText': instance.reviewText,
      'isAnonymous': instance.isAnonymous,
      'isApproved': instance.isApproved,
      'createdAt': instance.createdAt?.toIso8601String(),
      'userProfiles': instance.userProfiles,
    };

_$BookingImpl _$$BookingImplFromJson(Map<String, dynamic> json) =>
    _$BookingImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      tutorId: json['tutorId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String? ?? 'pending',
      pricePaidCents: (json['pricePaidCents'] as num).toInt(),
      platformCommissionCents:
          (json['platformCommissionCents'] as num?)?.toInt() ?? 0,
      tutorPayoutCents: (json['tutorPayoutCents'] as num?)?.toInt() ?? 0,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      meetingLink: json['meetingLink'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      review: json['review'] as String?,
      refundStatus: json['refundStatus'] as String? ?? 'none',
      refundAmountCents: (json['refundAmountCents'] as num?)?.toInt() ?? 0,
      refundReason: json['refundReason'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      cancellationReason: json['cancellationReason'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      tutorProfiles: json['tutorProfiles'] as Map<String, dynamic>?,
      userProfiles: json['userProfiles'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BookingImplToJson(_$BookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'tutorId': instance.tutorId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'status': instance.status,
      'pricePaidCents': instance.pricePaidCents,
      'platformCommissionCents': instance.platformCommissionCents,
      'tutorPayoutCents': instance.tutorPayoutCents,
      'paymentMethod': instance.paymentMethod,
      'transactionId': instance.transactionId,
      'meetingLink': instance.meetingLink,
      'rating': instance.rating,
      'review': instance.review,
      'refundStatus': instance.refundStatus,
      'refundAmountCents': instance.refundAmountCents,
      'refundReason': instance.refundReason,
      'completedAt': instance.completedAt?.toIso8601String(),
      'cancellationReason': instance.cancellationReason,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'tutorProfiles': instance.tutorProfiles,
      'userProfiles': instance.userProfiles,
    };

_$PaymentSettlementImpl _$$PaymentSettlementImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentSettlementImpl(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  studentId: json['studentId'] as String,
  tutorId: json['tutorId'] as String,
  amountPaidCents: (json['amountPaidCents'] as num).toInt(),
  platformCommissionCents: (json['platformCommissionCents'] as num).toInt(),
  commissionPercent: (json['commissionPercent'] as num).toDouble(),
  taxAmountCents: (json['taxAmountCents'] as num?)?.toInt() ?? 0,
  netTutorAmountCents: (json['netTutorAmountCents'] as num).toInt(),
  platformRevenueCents: (json['platformRevenueCents'] as num).toInt(),
  paymentMethod: json['paymentMethod'] as String?,
  transactionId: json['transactionId'] as String?,
  settlementStatus: json['settlementStatus'] as String? ?? 'pending',
  settledAt: json['settledAt'] == null
      ? null
      : DateTime.parse(json['settledAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  tutorProfiles: json['tutorProfiles'] as Map<String, dynamic>?,
  userProfiles: json['userProfiles'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$PaymentSettlementImplToJson(
  _$PaymentSettlementImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'studentId': instance.studentId,
  'tutorId': instance.tutorId,
  'amountPaidCents': instance.amountPaidCents,
  'platformCommissionCents': instance.platformCommissionCents,
  'commissionPercent': instance.commissionPercent,
  'taxAmountCents': instance.taxAmountCents,
  'netTutorAmountCents': instance.netTutorAmountCents,
  'platformRevenueCents': instance.platformRevenueCents,
  'paymentMethod': instance.paymentMethod,
  'transactionId': instance.transactionId,
  'settlementStatus': instance.settlementStatus,
  'settledAt': instance.settledAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'tutorProfiles': instance.tutorProfiles,
  'userProfiles': instance.userProfiles,
};

_$TutorWalletImpl _$$TutorWalletImplFromJson(
  Map<String, dynamic> json,
) => _$TutorWalletImpl(
  id: json['id'] as String,
  tutorId: json['tutorId'] as String,
  pendingBalanceCents: (json['pendingBalanceCents'] as num?)?.toInt() ?? 0,
  availableBalanceCents: (json['availableBalanceCents'] as num?)?.toInt() ?? 0,
  processingBalanceCents:
      (json['processingBalanceCents'] as num?)?.toInt() ?? 0,
  totalEarnedCents: (json['totalEarnedCents'] as num?)?.toInt() ?? 0,
  totalWithdrawnCents: (json['totalWithdrawnCents'] as num?)?.toInt() ?? 0,
  totalTaxDeductedCents: (json['totalTaxDeductedCents'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$TutorWalletImplToJson(_$TutorWalletImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tutorId': instance.tutorId,
      'pendingBalanceCents': instance.pendingBalanceCents,
      'availableBalanceCents': instance.availableBalanceCents,
      'processingBalanceCents': instance.processingBalanceCents,
      'totalEarnedCents': instance.totalEarnedCents,
      'totalWithdrawnCents': instance.totalWithdrawnCents,
      'totalTaxDeductedCents': instance.totalTaxDeductedCents,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$TutorPayoutMethodImpl _$$TutorPayoutMethodImplFromJson(
  Map<String, dynamic> json,
) => _$TutorPayoutMethodImpl(
  id: json['id'] as String,
  tutorId: json['tutorId'] as String,
  methodType: json['methodType'] as String,
  accountHolderName: json['accountHolderName'] as String,
  accountNumber: json['accountNumber'] as String?,
  ifscCode: json['ifscCode'] as String?,
  branchName: json['branchName'] as String?,
  upiId: json['upiId'] as String?,
  beneficiaryName: json['beneficiaryName'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  isDefault: json['isDefault'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$TutorPayoutMethodImplToJson(
  _$TutorPayoutMethodImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'tutorId': instance.tutorId,
  'methodType': instance.methodType,
  'accountHolderName': instance.accountHolderName,
  'accountNumber': instance.accountNumber,
  'ifscCode': instance.ifscCode,
  'branchName': instance.branchName,
  'upiId': instance.upiId,
  'beneficiaryName': instance.beneficiaryName,
  'isVerified': instance.isVerified,
  'isDefault': instance.isDefault,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$TutorPayoutImpl _$$TutorPayoutImplFromJson(Map<String, dynamic> json) =>
    _$TutorPayoutImpl(
      id: json['id'] as String,
      tutorId: json['tutorId'] as String,
      payoutMethodId: json['payoutMethodId'] as String?,
      amountCents: (json['amountCents'] as num).toInt(),
      chargesCents: (json['chargesCents'] as num?)?.toInt() ?? 0,
      taxDeductedCents: (json['taxDeductedCents'] as num?)?.toInt() ?? 0,
      netAmountCents: (json['netAmountCents'] as num).toInt(),
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejectionReason'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      transactionReference: json['transactionReference'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      tutorPayoutMethods: json['tutorPayoutMethods'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$TutorPayoutImplToJson(_$TutorPayoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tutorId': instance.tutorId,
      'payoutMethodId': instance.payoutMethodId,
      'amountCents': instance.amountCents,
      'chargesCents': instance.chargesCents,
      'taxDeductedCents': instance.taxDeductedCents,
      'netAmountCents': instance.netAmountCents,
      'status': instance.status,
      'rejectionReason': instance.rejectionReason,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'transactionReference': instance.transactionReference,
      'createdAt': instance.createdAt?.toIso8601String(),
      'tutorPayoutMethods': instance.tutorPayoutMethods,
    };

_$PlatformAccountImpl _$$PlatformAccountImplFromJson(
  Map<String, dynamic> json,
) => _$PlatformAccountImpl(
  id: json['id'] as String,
  provider: json['provider'] as String,
  accountName: json['accountName'] as String,
  businessName: json['businessName'] as String?,
  accountNumber: json['accountNumber'] as String?,
  ifscCode: json['ifscCode'] as String?,
  upiId: json['upiId'] as String?,
  beneficiaryName: json['beneficiaryName'] as String?,
  gstNumber: json['gstNumber'] as String?,
  panNumber: json['panNumber'] as String?,
  currency: json['currency'] as String? ?? 'INR',
  isActive: json['isActive'] as bool? ?? true,
  isDefault: json['isDefault'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$PlatformAccountImplToJson(
  _$PlatformAccountImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'provider': instance.provider,
  'accountName': instance.accountName,
  'businessName': instance.businessName,
  'accountNumber': instance.accountNumber,
  'ifscCode': instance.ifscCode,
  'upiId': instance.upiId,
  'beneficiaryName': instance.beneficiaryName,
  'gstNumber': instance.gstNumber,
  'panNumber': instance.panNumber,
  'currency': instance.currency,
  'isActive': instance.isActive,
  'isDefault': instance.isDefault,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$CommissionRuleImpl _$$CommissionRuleImplFromJson(Map<String, dynamic> json) =>
    _$CommissionRuleImpl(
      id: json['id'] as String,
      ruleType: json['ruleType'] as String,
      referenceId: json['referenceId'] as String?,
      commissionPercent: (json['commissionPercent'] as num).toDouble(),
      minCommissionCents: (json['minCommissionCents'] as num?)?.toInt() ?? 0,
      maxCommissionCents: (json['maxCommissionCents'] as num?)?.toInt(),
      isActive: json['isActive'] as bool? ?? true,
      effectiveFrom: json['effectiveFrom'] == null
          ? null
          : DateTime.parse(json['effectiveFrom'] as String),
      effectiveUntil: json['effectiveUntil'] == null
          ? null
          : DateTime.parse(json['effectiveUntil'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CommissionRuleImplToJson(
  _$CommissionRuleImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'ruleType': instance.ruleType,
  'referenceId': instance.referenceId,
  'commissionPercent': instance.commissionPercent,
  'minCommissionCents': instance.minCommissionCents,
  'maxCommissionCents': instance.maxCommissionCents,
  'isActive': instance.isActive,
  'effectiveFrom': instance.effectiveFrom?.toIso8601String(),
  'effectiveUntil': instance.effectiveUntil?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$PricingConfigImpl _$$PricingConfigImplFromJson(Map<String, dynamic> json) =>
    _$PricingConfigImpl(
      id: json['id'] as String,
      configType: json['configType'] as String,
      referenceId: json['referenceId'] as String?,
      minPriceCents: (json['minPriceCents'] as num?)?.toInt() ?? 500,
      maxPriceCents: (json['maxPriceCents'] as num?)?.toInt() ?? 10000,
      defaultPriceCents: (json['defaultPriceCents'] as num?)?.toInt() ?? 2000,
      premiumMultiplier: (json['premiumMultiplier'] as num?)?.toDouble() ?? 1.0,
      currency: json['currency'] as String? ?? 'INR',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PricingConfigImplToJson(_$PricingConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'configType': instance.configType,
      'referenceId': instance.referenceId,
      'minPriceCents': instance.minPriceCents,
      'maxPriceCents': instance.maxPriceCents,
      'defaultPriceCents': instance.defaultPriceCents,
      'premiumMultiplier': instance.premiumMultiplier,
      'currency': instance.currency,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$DisputeImpl _$$DisputeImplFromJson(Map<String, dynamic> json) =>
    _$DisputeImpl(
      id: json['id'] as String,
      disputeType: json['disputeType'] as String,
      filedBy: json['filedBy'] as String,
      againstUser: json['againstUser'] as String?,
      bookingId: json['bookingId'] as String?,
      tutorId: json['tutorId'] as String?,
      subject: json['subject'] as String,
      description: json['description'] as String,
      evidenceUrls:
          (json['evidenceUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'open',
      resolution: json['resolution'] as String?,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      refundAmountCents: (json['refundAmountCents'] as num?)?.toInt() ?? 0,
      refundIssued: json['refundIssued'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'medium',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      userProfiles: json['userProfiles'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$DisputeImplToJson(_$DisputeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'disputeType': instance.disputeType,
      'filedBy': instance.filedBy,
      'againstUser': instance.againstUser,
      'bookingId': instance.bookingId,
      'tutorId': instance.tutorId,
      'subject': instance.subject,
      'description': instance.description,
      'evidenceUrls': instance.evidenceUrls,
      'status': instance.status,
      'resolution': instance.resolution,
      'resolvedBy': instance.resolvedBy,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'refundAmountCents': instance.refundAmountCents,
      'refundIssued': instance.refundIssued,
      'priority': instance.priority,
      'createdAt': instance.createdAt?.toIso8601String(),
      'userProfiles': instance.userProfiles,
    };

_$DisputeMessageImpl _$$DisputeMessageImplFromJson(Map<String, dynamic> json) =>
    _$DisputeMessageImpl(
      id: json['id'] as String,
      disputeId: json['disputeId'] as String,
      senderId: json['senderId'] as String,
      message: json['message'] as String,
      attachmentUrls:
          (json['attachmentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isInternalNote: json['isInternalNote'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      userProfiles: json['userProfiles'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$DisputeMessageImplToJson(
  _$DisputeMessageImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'disputeId': instance.disputeId,
  'senderId': instance.senderId,
  'message': instance.message,
  'attachmentUrls': instance.attachmentUrls,
  'isInternalNote': instance.isInternalNote,
  'createdAt': instance.createdAt?.toIso8601String(),
  'userProfiles': instance.userProfiles,
};

_$BusinessDocumentImpl _$$BusinessDocumentImplFromJson(
  Map<String, dynamic> json,
) => _$BusinessDocumentImpl(
  id: json['id'] as String,
  documentType: json['documentType'] as String,
  referenceId: json['referenceId'] as String?,
  referenceType: json['referenceType'] as String?,
  recipientId: json['recipientId'] as String?,
  documentNumber: json['documentNumber'] as String,
  documentDate: DateTime.parse(json['documentDate'] as String),
  amountCents: (json['amountCents'] as num?)?.toInt(),
  taxCents: (json['taxCents'] as num?)?.toInt(),
  totalCents: (json['totalCents'] as num?)?.toInt(),
  currency: json['currency'] as String? ?? 'INR',
  fileUrl: json['fileUrl'] as String?,
  fileFormat: json['fileFormat'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$BusinessDocumentImplToJson(
  _$BusinessDocumentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'documentType': instance.documentType,
  'referenceId': instance.referenceId,
  'referenceType': instance.referenceType,
  'recipientId': instance.recipientId,
  'documentNumber': instance.documentNumber,
  'documentDate': instance.documentDate.toIso8601String(),
  'amountCents': instance.amountCents,
  'taxCents': instance.taxCents,
  'totalCents': instance.totalCents,
  'currency': instance.currency,
  'fileUrl': instance.fileUrl,
  'fileFormat': instance.fileFormat,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$CouponImpl _$$CouponImplFromJson(Map<String, dynamic> json) => _$CouponImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  description: json['description'] as String?,
  discountType: json['discountType'] as String,
  discountValue: (json['discountValue'] as num).toDouble(),
  minBookingAmountCents: (json['minBookingAmountCents'] as num?)?.toInt() ?? 0,
  maxDiscountCents: (json['maxDiscountCents'] as num?)?.toInt(),
  usageLimit: (json['usageLimit'] as num?)?.toInt(),
  usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
  applicableTo: json['applicableTo'] as String? ?? 'all',
  validFrom: json['validFrom'] == null
      ? null
      : DateTime.parse(json['validFrom'] as String),
  validUntil: json['validUntil'] == null
      ? null
      : DateTime.parse(json['validUntil'] as String),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CouponImplToJson(_$CouponImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'description': instance.description,
      'discountType': instance.discountType,
      'discountValue': instance.discountValue,
      'minBookingAmountCents': instance.minBookingAmountCents,
      'maxDiscountCents': instance.maxDiscountCents,
      'usageLimit': instance.usageLimit,
      'usedCount': instance.usedCount,
      'applicableTo': instance.applicableTo,
      'validFrom': instance.validFrom?.toIso8601String(),
      'validUntil': instance.validUntil?.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$RevenueForecastImpl _$$RevenueForecastImplFromJson(
  Map<String, dynamic> json,
) => _$RevenueForecastImpl(
  id: json['id'] as String,
  forecastDate: DateTime.parse(json['forecastDate'] as String),
  forecastType: json['forecastType'] as String,
  predictedRevenueCents: (json['predictedRevenueCents'] as num?)?.toInt() ?? 0,
  predictedAiCostCents: (json['predictedAiCostCents'] as num?)?.toInt() ?? 0,
  predictedTutorPayoutsCents:
      (json['predictedTutorPayoutsCents'] as num?)?.toInt() ?? 0,
  predictedProfitCents: (json['predictedProfitCents'] as num?)?.toInt() ?? 0,
  predictedSubscriberCount:
      (json['predictedSubscriberCount'] as num?)?.toInt() ?? 0,
  predictedChurnRate: (json['predictedChurnRate'] as num?)?.toDouble() ?? 0.0,
  confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.5,
  actualRevenueCents: (json['actualRevenueCents'] as num?)?.toInt(),
  actualProfitCents: (json['actualProfitCents'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$RevenueForecastImplToJson(
  _$RevenueForecastImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'forecastDate': instance.forecastDate.toIso8601String(),
  'forecastType': instance.forecastType,
  'predictedRevenueCents': instance.predictedRevenueCents,
  'predictedAiCostCents': instance.predictedAiCostCents,
  'predictedTutorPayoutsCents': instance.predictedTutorPayoutsCents,
  'predictedProfitCents': instance.predictedProfitCents,
  'predictedSubscriberCount': instance.predictedSubscriberCount,
  'predictedChurnRate': instance.predictedChurnRate,
  'confidenceScore': instance.confidenceScore,
  'actualRevenueCents': instance.actualRevenueCents,
  'actualProfitCents': instance.actualProfitCents,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$PlatformFinanceImpl _$$PlatformFinanceImplFromJson(
  Map<String, dynamic> json,
) => _$PlatformFinanceImpl(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  platformWalletBalanceCents:
      (json['platformWalletBalanceCents'] as num?)?.toInt() ?? 0,
  availableBalanceCents: (json['availableBalanceCents'] as num?)?.toInt() ?? 0,
  pendingBalanceCents: (json['pendingBalanceCents'] as num?)?.toInt() ?? 0,
  tutorPayablesCents: (json['tutorPayablesCents'] as num?)?.toInt() ?? 0,
  taxPayablesCents: (json['taxPayablesCents'] as num?)?.toInt() ?? 0,
  refundReserveCents: (json['refundReserveCents'] as num?)?.toInt() ?? 0,
  subscriptionRevenueCents:
      (json['subscriptionRevenueCents'] as num?)?.toInt() ?? 0,
  aiCreditRevenueCents: (json['aiCreditRevenueCents'] as num?)?.toInt() ?? 0,
  tutorCommissionRevenueCents:
      (json['tutorCommissionRevenueCents'] as num?)?.toInt() ?? 0,
  adRevenueCents: (json['adRevenueCents'] as num?)?.toInt() ?? 0,
  affiliateRevenueCents: (json['affiliateRevenueCents'] as num?)?.toInt() ?? 0,
  certificateRevenueCents:
      (json['certificateRevenueCents'] as num?)?.toInt() ?? 0,
  institutionRevenueCents:
      (json['institutionRevenueCents'] as num?)?.toInt() ?? 0,
  sponsoredRevenueCents: (json['sponsoredRevenueCents'] as num?)?.toInt() ?? 0,
  marketplaceRevenueCents:
      (json['marketplaceRevenueCents'] as num?)?.toInt() ?? 0,
  aiCostCents: (json['aiCostCents'] as num?)?.toInt() ?? 0,
  infrastructureCostCents:
      (json['infrastructureCostCents'] as num?)?.toInt() ?? 0,
  serverCostCents: (json['serverCostCents'] as num?)?.toInt() ?? 0,
  storageCostCents: (json['storageCostCents'] as num?)?.toInt() ?? 0,
  paymentGatewayChargesCents:
      (json['paymentGatewayChargesCents'] as num?)?.toInt() ?? 0,
  tutorPayoutCostsCents: (json['tutorPayoutCostsCents'] as num?)?.toInt() ?? 0,
  refundCostsCents: (json['refundCostsCents'] as num?)?.toInt() ?? 0,
  grossRevenueCents: (json['grossRevenueCents'] as num?)?.toInt() ?? 0,
  netRevenueCents: (json['netRevenueCents'] as num?)?.toInt() ?? 0,
  actualProfitCents: (json['actualProfitCents'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$PlatformFinanceImplToJson(
  _$PlatformFinanceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'platformWalletBalanceCents': instance.platformWalletBalanceCents,
  'availableBalanceCents': instance.availableBalanceCents,
  'pendingBalanceCents': instance.pendingBalanceCents,
  'tutorPayablesCents': instance.tutorPayablesCents,
  'taxPayablesCents': instance.taxPayablesCents,
  'refundReserveCents': instance.refundReserveCents,
  'subscriptionRevenueCents': instance.subscriptionRevenueCents,
  'aiCreditRevenueCents': instance.aiCreditRevenueCents,
  'tutorCommissionRevenueCents': instance.tutorCommissionRevenueCents,
  'adRevenueCents': instance.adRevenueCents,
  'affiliateRevenueCents': instance.affiliateRevenueCents,
  'certificateRevenueCents': instance.certificateRevenueCents,
  'institutionRevenueCents': instance.institutionRevenueCents,
  'sponsoredRevenueCents': instance.sponsoredRevenueCents,
  'marketplaceRevenueCents': instance.marketplaceRevenueCents,
  'aiCostCents': instance.aiCostCents,
  'infrastructureCostCents': instance.infrastructureCostCents,
  'serverCostCents': instance.serverCostCents,
  'storageCostCents': instance.storageCostCents,
  'paymentGatewayChargesCents': instance.paymentGatewayChargesCents,
  'tutorPayoutCostsCents': instance.tutorPayoutCostsCents,
  'refundCostsCents': instance.refundCostsCents,
  'grossRevenueCents': instance.grossRevenueCents,
  'netRevenueCents': instance.netRevenueCents,
  'actualProfitCents': instance.actualProfitCents,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$FinancialAuditLogImpl _$$FinancialAuditLogImplFromJson(
  Map<String, dynamic> json,
) => _$FinancialAuditLogImpl(
  id: json['id'] as String,
  action: json['action'] as String,
  entityType: json['entityType'] as String,
  entityId: json['entityId'] as String?,
  performedBy: json['performedBy'] as String,
  oldValues: json['oldValues'] as Map<String, dynamic>? ?? const {},
  newValues: json['newValues'] as Map<String, dynamic>? ?? const {},
  ipAddress: json['ipAddress'] as String?,
  reason: json['reason'] as String?,
  requiresApproval: json['requiresApproval'] as bool? ?? false,
  approvedAt: json['approvedAt'] == null
      ? null
      : DateTime.parse(json['approvedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  userProfiles: json['userProfiles'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$FinancialAuditLogImplToJson(
  _$FinancialAuditLogImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'action': instance.action,
  'entityType': instance.entityType,
  'entityId': instance.entityId,
  'performedBy': instance.performedBy,
  'oldValues': instance.oldValues,
  'newValues': instance.newValues,
  'ipAddress': instance.ipAddress,
  'reason': instance.reason,
  'requiresApproval': instance.requiresApproval,
  'approvedAt': instance.approvedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'userProfiles': instance.userProfiles,
};

_$RolePermissionImpl _$$RolePermissionImplFromJson(Map<String, dynamic> json) =>
    _$RolePermissionImpl(
      id: json['id'] as String,
      role: json['role'] as String,
      permissionKey: json['permissionKey'] as String,
      isGranted: json['isGranted'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$RolePermissionImplToJson(
  _$RolePermissionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'role': instance.role,
  'permissionKey': instance.permissionKey,
  'isGranted': instance.isGranted,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$SettlementBatchImpl _$$SettlementBatchImplFromJson(
  Map<String, dynamic> json,
) => _$SettlementBatchImpl(
  id: json['id'] as String,
  batchType: json['batchType'] as String,
  status: json['status'] as String? ?? 'pending',
  totalSettlements: (json['totalSettlements'] as num?)?.toInt() ?? 0,
  totalAmountCents: (json['totalAmountCents'] as num?)?.toInt() ?? 0,
  totalCommissionCents: (json['totalCommissionCents'] as num?)?.toInt() ?? 0,
  totalTutorPayoutsCents:
      (json['totalTutorPayoutsCents'] as num?)?.toInt() ?? 0,
  processedBy: json['processedBy'] as String?,
  processedAt: json['processedAt'] == null
      ? null
      : DateTime.parse(json['processedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$SettlementBatchImplToJson(
  _$SettlementBatchImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'batchType': instance.batchType,
  'status': instance.status,
  'totalSettlements': instance.totalSettlements,
  'totalAmountCents': instance.totalAmountCents,
  'totalCommissionCents': instance.totalCommissionCents,
  'totalTutorPayoutsCents': instance.totalTutorPayoutsCents,
  'processedBy': instance.processedBy,
  'processedAt': instance.processedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$FeatureFlagImpl _$$FeatureFlagImplFromJson(Map<String, dynamic> json) =>
    _$FeatureFlagImpl(
      id: json['id'] as String,
      flagKey: json['flagKey'] as String,
      description: json['description'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? false,
      rolloutPercentage: (json['rolloutPercentage'] as num?)?.toInt() ?? 0,
      targetRoles:
          (json['targetRoles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      targetCountries:
          (json['targetCountries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$FeatureFlagImplToJson(_$FeatureFlagImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flagKey': instance.flagKey,
      'description': instance.description,
      'isEnabled': instance.isEnabled,
      'rolloutPercentage': instance.rolloutPercentage,
      'targetRoles': instance.targetRoles,
      'targetCountries': instance.targetCountries,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
