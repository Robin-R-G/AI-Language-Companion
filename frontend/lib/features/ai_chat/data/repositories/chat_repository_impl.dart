// lib/features/ai_chat/data/repositories/chat_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl({ChatRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ChatRemoteDataSourceImpl();

  @override
  Future<Result<AIConversation>> createConversation({
    required String title,
    String? provider,
    String? model,
  }) {
    return _remoteDataSource.createConversation(
      title: title,
      provider: provider,
      model: model,
    );
  }

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String conversationId,
    required String message,
    bool stream = false,
  }) {
    return _remoteDataSource.sendMessage(
      conversationId: conversationId,
      message: message,
      stream: stream,
    );
  }

  @override
  Future<Result<List<ChatMessage>>> getMessages(String conversationId) {
    return _remoteDataSource.getMessages(conversationId);
  }
}
