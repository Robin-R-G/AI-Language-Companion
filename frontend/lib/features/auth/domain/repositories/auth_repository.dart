// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<User?> signUp(String email, String password);
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  User? get currentUser;
  Stream<AuthState> get authStateChanges;
}
