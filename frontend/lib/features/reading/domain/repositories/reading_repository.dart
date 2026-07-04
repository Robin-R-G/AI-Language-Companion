import '../../../../core/errors/result.dart';
import '../entities/reading_passage.dart';

abstract class ReadingRepository {
  Future<Result<List<ReadingPassage>>> getPassages({String? difficulty, int limit = 20});
  Future<Result<ReadingPassage>> getPassage(String id);
}
