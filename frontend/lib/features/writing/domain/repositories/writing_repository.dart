// lib/features/writing/domain/repositories/writing_repository.dart
import '../../../../core/errors/result.dart';
import '../../data/datasources/writing_remote_datasource.dart';

abstract class WritingRepository {
  Future<Result<WritingEvaluation>> evaluateEssay(String essayText);
}
