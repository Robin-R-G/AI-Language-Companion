import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

/// Dio HTTP client configuration with interceptors and timeout settings.
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.supabaseUrl + AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'apikey': AppConstants.supabaseAnonKey,
        },
      ),
    );

    _dio.interceptors.addAll([_AuthInterceptor(), _LoggingInterceptor()]);
  }

  Dio get client => _dio;
}

/// Interceptor for handling authentication tokens from Supabase session.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired - attempt refresh
      _refreshToken()
          .then((_) {
            // Retry the request with new token
            handler.resolve(err.response!);
          })
          .catchError((_) {
            handler.next(err);
          });
    } else {
      handler.next(err);
    }
  }

  Future<void> _refreshToken() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
    } catch (_) {
      rethrow;
    }
  }
}

/// Interceptor for logging API requests and responses in debug mode.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
