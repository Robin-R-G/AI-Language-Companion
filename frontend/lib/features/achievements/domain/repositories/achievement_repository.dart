import '../../../../core/errors/result.dart';
import '../entities/achievement.dart';

abstract class AchievementRepository {
  Future<Result<List<Achievement>>> getAchievements();
  Future<Result<List<AchievementProgress>>> getProgress();
  Future<Result<Achievement>> checkAndAward(String achievementId);
}
