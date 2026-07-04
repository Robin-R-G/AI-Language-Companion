import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/dio_client.dart';

part 'repository_providers.g.dart';

@riverpod
DioClient dioClient(DioClientRef ref) {
  return DioClient();
}
