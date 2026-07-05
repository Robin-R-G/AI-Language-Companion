// lib/features/listening/presentation/controllers/listening_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/listening_remote_datasource.dart';

part 'listening_controller.g.dart';

@riverpod
ListeningRemoteDataSource listeningDataSource(ListeningDataSourceRef ref) {
  return ListeningRemoteDataSourceImpl();
}

@riverpod
class ListeningController extends _$ListeningController {
  @override
  AsyncValue<ListeningExercise?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> generateExercise(String topic) async {
    state = const AsyncValue.loading();
    final dataSource = ref.read(listeningDataSourceProvider);
    final result = await dataSource.generateExercise(topic);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (exercise) => state = AsyncValue.data(exercise),
    );
  }

  void clearExercise() {
    state = const AsyncValue.data(null);
  }
}
