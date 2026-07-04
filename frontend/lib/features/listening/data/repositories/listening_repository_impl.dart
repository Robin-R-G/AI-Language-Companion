import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/listening_exercise.dart';
import '../../domain/repositories/listening_repository.dart';

class ListeningRepositoryImpl implements ListeningRepository {
  final Dio _dio;

  ListeningRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<List<ListeningExercise>>> getExercises({String? difficulty, int limit = 20}) async {
    try {
      final response = await _dio.get('/listening', queryParameters: {'limit': limit, if (difficulty != null) 'difficulty': difficulty});
      final data = response.data;
      if (data is List) {
        return Result.success(data.map((e) => ListeningExercise.fromJson(e as Map<String, dynamic>)).toList());
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(DatabaseFailure(e.message ?? 'Failed to fetch exercises', code: e.response?.statusCode?.toString()));
    }
  }

  @override
  Future<Result<ListeningExercise>> getExercise(String id) async {
    try {
      final response = await _dio.get('/listening/$id');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(ListeningExercise.fromJson(data));
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(DatabaseFailure(e.message ?? 'Failed to fetch exercise', code: e.response?.statusCode?.toString()));
    }
  }
}
