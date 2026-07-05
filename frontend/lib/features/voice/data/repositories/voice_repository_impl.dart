// lib/features/voice/data/repositories/voice_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/exam.dart';
import '../../domain/repositories/voice_repository.dart';
import '../datasources/voice_remote_datasource.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  final VoiceRemoteDataSource _remoteDataSource;

  VoiceRepositoryImpl({VoiceRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? VoiceRemoteDataSourceImpl();

  @override
  Future<Result<VoiceSessionResult>> startSession({
    required String language,
    String? persona,
  }) {
    return _remoteDataSource.startSession(
      language: language,
      persona: persona,
    );
  }

  @override
  Future<Result<VoiceSession>> endSession(String sessionId) {
    return _remoteDataSource.endSession(sessionId);
  }
}
