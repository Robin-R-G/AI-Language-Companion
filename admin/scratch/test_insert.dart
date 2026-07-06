import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient(
    'https://tuashfxoiwyyglmrchjn.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1YXNoZnhvaXd5eWdsbXJjaGpuIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzE1NjQ2MSwiZXhwIjoyMDk4NzMyNDYxfQ.HPLPU9NIRao85u6Sc_jun-yoJvmyFz8_5Kl54gpgX7w',
  );

  try {
    final res = await client.auth.admin.createUser(
      AdminUserAttributes(
        email: 'test_admin_${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'Password123!',
        emailConfirm: true,
      ),
    );
    print('SUCCESS: ${res.user?.id}');
  } catch (e) {
    print('ERROR_DETAILS: $e');
  }
}
