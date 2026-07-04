import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/app_settings.dart';

final appSettingsProvider = FutureProvider.autoDispose<AppSettings>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  final result = await repo.getSettings();
  return result.fold((f) => throw f, (v) => v);
});
