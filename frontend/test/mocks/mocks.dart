import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Dio Mocks ───────────────────────────────────────────────────────────────

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}

class MockRequestOptions extends Mock implements RequestOptions {}

class MockDioException extends Mock implements DioException {}

// ─── Supabase Mocks ──────────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseAuth extends Mock implements GoTrueClient {}

class MockSupabaseDatabase extends Mock implements SupabaseQueryBuilder {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<dynamic> {}

class MockGoTrueAdminAPI extends Mock implements GoTrueAdminAPI {}

class MockSupabaseQueryBuilder extends Mock
    implements SupabaseQueryBuilder {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

// ─── Register Fallback Values ────────────────────────────────────────────────

void registerFallbackValues() {
  registerFallbackValue(RequestOptions());
  registerFallbackValue(const Duration(seconds: 10));
}
