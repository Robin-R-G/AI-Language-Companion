import '../../../../core/errors/result.dart';
import '../entities/progress_stats.dart';

abstract class ProgressRepository {
  Future<Result<ProgressStats>> getStats({String? period});
}
