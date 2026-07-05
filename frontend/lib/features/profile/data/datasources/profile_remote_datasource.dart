// lib/features/profile/data/datasources/profile_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../shared/models/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<Result<UserProfile>> getProfile(String userId);
  Future<Result<UserProfile>> updateProfile(String userId, Map<String, dynamic> updates);
  Future<Result<UserProgress>> getProgress(String userId);
  Future<Result<UserStreak>> getStreak(String userId);
  Future<Result<void>> deleteAccount(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;

  ProfileRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<UserProfile>> getProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('auth_user_id', userId)
          .maybeSingle();

      if (response == null) {
        return const Result.error(DatabaseFailure('Profile not found'));
      }

      return Result.success(UserProfile.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to load profile: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('user_profiles')
          .update(updates)
          .eq('auth_user_id', userId)
          .select()
          .single();

      return Result.success(UserProfile.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to update profile: $e'));
    }
  }

  @override
  Future<Result<UserProgress>> getProgress(String userId) async {
    try {
      final response = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return const Result.error(DatabaseFailure('Progress not found'));
      }

      return Result.success(UserProgress.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to load progress: $e'));
    }
  }

  @override
  Future<Result<UserStreak>> getStreak(String userId) async {
    try {
      final response = await _client
          .from('streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return const Result.error(DatabaseFailure('Streak not found'));
      }

      return Result.success(UserStreak.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to load streak: $e'));
    }
  }

  @override
  Future<Result<void>> deleteAccount(String userId) async {
    try {
      await _client.rpc('delete_user_cascade', params: {'target_user_id': userId});
      return const Result.success(null);
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to delete account: $e'));
    }
  }
}
