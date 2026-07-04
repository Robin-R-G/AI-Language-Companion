import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/listening_exercise.dart';

final listeningExercisesProvider = FutureProvider.autoDispose<List<ListeningExercise>>((ref) async {
  final repo = ref.watch(listeningRepositoryProvider);
  final result = await repo.getExercises();
  if (result.isSuccess) return result.value;
  throw result.failure;
});
