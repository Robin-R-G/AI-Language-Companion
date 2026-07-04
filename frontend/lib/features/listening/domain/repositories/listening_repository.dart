import '../../../../core/errors/result.dart';
import '../entities/listening_exercise.dart';

abstract class ListeningRepository {
  Future<Result<List<ListeningExercise>>> getExercises({String? difficulty, int limit = 20});
  Future<Result<ListeningExercise>> getExercise(String id);
}
