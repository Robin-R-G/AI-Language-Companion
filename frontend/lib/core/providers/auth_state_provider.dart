import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../enums/user_role.dart';

// ── State model ──────────────────────────────────────────────────────────────

/// Holds the current authenticated user's session & role.
class AuthState {
  const AuthState({
    this.user,
    this.role = UserRole.student,
    this.isLoading = false,
    this.error,
  });

  final User? user;
  final UserRole role;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    UserRole? role,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState(isLoading: true)) {
    _init();
  }

  final SupabaseClient _client = Supabase.instance.client;

  /// Listen to Supabase auth state changes.
  void _init() {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      _loadUserRole(currentUser);
    } else {
      state = const AuthState();
    }

    _client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        _loadUserRole(user);
      } else {
        state = const AuthState();
      }
    });
  }

  /// Fetch the user's role from `user_profiles` table.
  Future<void> _loadUserRole(User user) async {
    state = AuthState(user: user, isLoading: true);
    try {
      final response = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final roleStr = response?['role'] as String?;
      final role = UserRole.fromString(roleStr);
      state = AuthState(user: user, role: role);
    } catch (e) {
      // Default to student if lookup fails
      state = AuthState(user: user, role: UserRole.student);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    state = const AuthState();
  }

  /// Force-refresh the role (e.g. after admin promotes a user).
  Future<void> refreshRole() async {
    final user = state.user;
    if (user != null) await _loadUserRole(user);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});

/// Shortcut provider: current user role.
final currentRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(authStateProvider).role;
});

/// Shortcut provider: is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

/// Shortcut provider: is staff member (any admin role).
final isStaffProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider).isStaff;
});
