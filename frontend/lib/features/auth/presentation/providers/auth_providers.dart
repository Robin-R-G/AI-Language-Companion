import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/repository_providers.dart';

part 'auth_providers.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<AppUser?> build() {
    _checkCurrentUser();
    return const AsyncValue.data(null);
  }

  Future<void> _checkCurrentUser() async {
    final repo = ref.read(authRepositoryInstProvider);
    final result = await repo.getCurrentUser();
    result.fold(
      (failure) => const AsyncValue.data(null),
      (user) {
        if (user != null) {
          state = AsyncValue.data(user);
        }
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final repo = ref.read(authRepositoryInstProvider);
    final result = await repo.signIn(email, password);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    final repo = ref.read(authRepositoryInstProvider);
    final result = await repo.signUp(email, password);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryInstProvider);
    final result = await repo.signOut();
    result.fold((failure) {}, (_) => state = const AsyncValue.data(null));
  }
}
