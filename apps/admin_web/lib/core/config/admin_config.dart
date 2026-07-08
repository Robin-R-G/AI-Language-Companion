class AdminConfig {
  AdminConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://tuashfxoiwyyglmrchjn.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1YXNoZnhvaXd5eWdsbXJjaGpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMxNTY0NjEsImV4cCI6MjA5ODczMjQ2MX0.VGPNy7pTrdGe0su2rBF4jCws715AzFVgcAoUjPzOByI',
  );

  static const String appName = 'AI Language Coach Admin';
  static const String appVersion = '1.0.0';

  static const List<String> superAdminRoles = [
    'super_admin',
  ];

  static const List<String> adminRoles = [
    'super_admin',
    'admin',
    'finance_manager',
    'support_manager',
    'content_manager',
    'tutor_manager',
    'marketing_manager',
    'developer',
    'analytics_manager',
  ];

  static bool hasPermission(String userRole, String requiredRole) {
    if (userRole == 'super_admin' || userRole == 'admin') return true;
    return userRole == requiredRole;
  }
}
