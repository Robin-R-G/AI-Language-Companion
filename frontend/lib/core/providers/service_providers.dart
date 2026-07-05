// lib/core/providers/service_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../network/dio_client.dart';

part 'service_providers.g.dart';

@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}

@riverpod
Dio dioClient(DioClientRef ref) {
  final env = ref.watch(environmentProvider);
  return createDioClient(baseUrl: env.apiUrl);
}

@riverpod
Environment environment(EnvironmentRef ref) {
  return const Environment.development();
}
