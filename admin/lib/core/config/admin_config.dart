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
}
