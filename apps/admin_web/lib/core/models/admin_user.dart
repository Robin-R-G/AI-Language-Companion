enum AdminRole {
  superAdmin('super_admin', 'Super Admin'),
  admin('admin', 'Admin'),
  financeManager('finance_manager', 'Finance Manager'),
  supportManager('support_manager', 'Support Manager'),
  contentManager('content_manager', 'Content Manager'),
  tutorManager('tutor_manager', 'Tutor Manager'),
  marketingManager('marketing_manager', 'Marketing Manager'),
  developer('developer', 'Developer'),
  analyticsManager('analytics_manager', 'Analytics Manager');

  final String value;
  final String label;
  const AdminRole(this.value, this.label);

  static AdminRole fromString(String value) {
    return AdminRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => AdminRole.admin,
    );
  }
}

class AdminUser {
  final String id;
  final String email;
  final String fullName;
  final AdminRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  const AdminUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['email'] ?? '',
      role: AdminRole.fromString(json['role'] ?? 'admin'),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role.value,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'last_login_at': lastLoginAt?.toIso8601String(),
        'metadata': metadata,
      };

  bool get isSuperAdmin => role == AdminRole.superAdmin;
  bool get canManageUsers => isSuperAdmin || role == AdminRole.admin;
  bool get canManageFinance => isSuperAdmin || role == AdminRole.financeManager;
  bool get canManageContent => isSuperAdmin || role == AdminRole.contentManager;
  bool get canManageTutors => isSuperAdmin || role == AdminRole.tutorManager;
  bool get canViewAnalytics => isSuperAdmin || role == AdminRole.analyticsManager;
}

class AdminSession {
  final AdminUser user;
  final String token;
  final DateTime expiresAt;

  const AdminSession({
    required this.user,
    required this.token,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isExpired;
}

class AuditLogEntry {
  final String id;
  final String adminId;
  final String adminEmail;
  final String action;
  final String targetType;
  final String? targetId;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final DateTime createdAt;

  const AuditLogEntry({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.action,
    required this.targetType,
    this.targetId,
    this.details,
    this.ipAddress,
    required this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] ?? '',
      adminId: json['admin_id'] ?? '',
      adminEmail: json['admin_email'] ?? '',
      action: json['action'] ?? '',
      targetType: json['target_type'] ?? '',
      targetId: json['target_id'],
      details: json['details'],
      ipAddress: json['ip_address'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
