// lib/features/profile/presentation/controllers/profile_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../../shared/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_controller.g.dart';

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepositoryImpl();
}

@riverpod
class ProfileController extends _$ProfileController {
  @override
  AsyncValue<UserProfile?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getProfile(userId);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.updateProfile(userId, updates);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }
}

@riverpod
class ProgressController extends _$ProgressController {
  @override
  AsyncValue<UserProgress?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> loadProgress() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getProgress(userId);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (progress) => state = AsyncValue.data(progress),
    );
  }
}

@riverpod
class StreakController extends _$StreakController {
  @override
  AsyncValue<UserStreak?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> loadStreak() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getStreak(userId);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (streak) => state = AsyncValue.data(streak),
    );
  }
}
