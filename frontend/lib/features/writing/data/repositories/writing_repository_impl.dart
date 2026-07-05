// lib/features/writing/data/repositories/writing_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../../data/datasources/writing_remote_datasource.dart';
import '../../domain/repositories/writing_repository.dart';

class WritingRepositoryImpl implements WritingRepository {
  final WritingRemoteDataSource _remoteDataSource;

  WritingRepositoryImpl({WritingRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? WritingRemoteDataSourceImpl();

  @override
  Future<Result<WritingEvaluation>> evaluateEssay(String essayText) {
    return _remoteDataSource.evaluateEssay(essayText);
  }
}
