// lib/features/auth/presentation/controllers/auth_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_controller.g.dart';

@riverpod
AuthRepositoryImpl authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl();
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<AuthUser?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final useCase = SignInUseCase(repository);
    final result = await useCase.call(email: email, password: password);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final useCase = SignUpUseCase(repository);
    final result = await useCase.call(
      email: email,
      password: password,
      name: name,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    final useCase = SignOutUseCase(repository);
    await useCase.call();
    state = const AsyncValue.data(null);
  }

  Future<void> checkCurrentUser() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final useCase = GetCurrentUserUseCase(repository);
    final result = await useCase.call();

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }
}
