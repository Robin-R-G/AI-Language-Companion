import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/audit_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

final auditServiceProvider = Provider<AuditService>((ref) {
  return AuditService.instance;
});

final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final userRoleProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getUserRole();
});

final themeModeProvider = StateProvider<bool>((ref) => true);
