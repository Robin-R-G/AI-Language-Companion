import '../../../../core/errors/result.dart';
import '../entities/writing_prompt.dart';

abstract class WritingRepository {
  Future<Result<List<WritingPrompt>>> getPrompts({String? difficulty, String? category});
  Future<Result<WritingSubmission>> submitWriting(String promptId, String content);
}
