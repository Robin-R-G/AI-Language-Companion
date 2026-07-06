import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/repository_providers.dart';

part 'profile_providers.g.dart';

@riverpod
class ProfileUpdate extends _$ProfileUpdate {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    final repo = ref.read(profileRepositoryInstProvider);
    final result = await repo.updateProfile('', updates);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> uploadAvatar(String filePath) async {
    state = const AsyncValue.loading();
    final repo = ref.read(profileRepositoryInstProvider);
    final result = await repo.deleteAccount('');
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}
