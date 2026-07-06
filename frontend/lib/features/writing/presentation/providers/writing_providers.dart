import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';

final writingPromptsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return <Map<String, dynamic>>[];
});
