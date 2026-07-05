// lib/features/auth/domain/entities/auth_user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    String? fullName,
    String? avatarUrl,
    @Default(false) bool isOnboardingCompleted,
  }) = _AuthUser;
}
