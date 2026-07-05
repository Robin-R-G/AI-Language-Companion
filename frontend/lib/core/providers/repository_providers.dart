// lib/core/providers/repository_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

part 'repository_providers.g.dart';

// ─── Auth ────────────────────────────────────────────────────────────────────

@riverpod
AuthRepository authRepositoryInst(AuthRepositoryInstRef ref) {
  return AuthRepositoryImpl();
}

// ─── Profile ─────────────────────────────────────────────────────────────────

@riverpod
ProfileRepository profileRepositoryInst(ProfileRepositoryInstRef ref) {
  return ProfileRepositoryImpl();
}
