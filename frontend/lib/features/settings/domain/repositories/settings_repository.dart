import '../../../../core/errors/result.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<Result<AppSettings>> getSettings();
  Future<Result<AppSettings>> updateSettings(AppSettings settings);
}
