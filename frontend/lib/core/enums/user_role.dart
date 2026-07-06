/// Application user roles for RBAC.
enum UserRole {
  student,
  tutor,
  admin,
  superAdmin,
  financeManager,
  tutorManager,
  supportManager,
  contentManager,
  marketingManager;

  /// Parses a role string from Supabase JWT claims or DB.
  static UserRole fromString(String? value) {
    switch (value) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'finance_manager':
        return UserRole.financeManager;
      case 'tutor_manager':
        return UserRole.tutorManager;
      case 'support_manager':
        return UserRole.supportManager;
      case 'content_manager':
        return UserRole.contentManager;
      case 'marketing_manager':
        return UserRole.marketingManager;
      case 'tutor':
        return UserRole.tutor;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  /// Returns the raw DB value for this role.
  String get dbValue {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.admin:
        return 'admin';
      case UserRole.financeManager:
        return 'finance_manager';
      case UserRole.tutorManager:
        return 'tutor_manager';
      case UserRole.supportManager:
        return 'support_manager';
      case UserRole.contentManager:
        return 'content_manager';
      case UserRole.marketingManager:
        return 'marketing_manager';
      case UserRole.tutor:
        return 'tutor';
      case UserRole.student:
        return 'student';
    }
  }

  /// Human‑readable display name.
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.financeManager:
        return 'Finance Manager';
      case UserRole.tutorManager:
        return 'Tutor Manager';
      case UserRole.supportManager:
        return 'Support Manager';
      case UserRole.contentManager:
        return 'Content Manager';
      case UserRole.marketingManager:
        return 'Marketing Manager';
      case UserRole.tutor:
        return 'Tutor';
      case UserRole.student:
        return 'Student';
    }
  }

  // ── Permission helpers ────────────────────────────────────────────────

  bool get isAdminOrAbove =>
      this == UserRole.superAdmin || this == UserRole.admin;

  bool get isStaff =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.financeManager ||
      this == UserRole.tutorManager ||
      this == UserRole.supportManager ||
      this == UserRole.contentManager ||
      this == UserRole.marketingManager;

  bool get canAccessFinance =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.financeManager;

  bool get canManageTutors =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.tutorManager;

  bool get canManageContent =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.contentManager;

  bool get canManageMarketing =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.marketingManager;

  bool get canAccessSupport =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.supportManager;

  bool get canToggleFeatureFlags => this == UserRole.superAdmin;

  bool get canManageTenants => this == UserRole.superAdmin;

  bool get requiresMfa => isStaff;
}
