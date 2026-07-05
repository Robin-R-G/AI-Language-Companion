// lib/features/reading/presentation/controllers/reading_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/reading_remote_datasource.dart';

part 'reading_controller.g.dart';

@riverpod
ReadingRemoteDataSource readingDataSource(ReadingDataSourceRef ref) {
  return ReadingRemoteDataSourceImpl();
}

@riverpod
class ReadingController extends _$ReadingController {
  @override
  AsyncValue<ReadingLesson?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> generateLesson(String topic) async {
    state = const AsyncValue.loading();
    final dataSource = ref.read(readingDataSourceProvider);
    final result = await dataSource.generateLesson(topic);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (lesson) => state = AsyncValue.data(lesson),
    );
  }

  void clearLesson() {
    state = const AsyncValue.data(null);
  }
}
