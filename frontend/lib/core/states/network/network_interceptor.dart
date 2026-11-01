import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_constants.dart';
import '../errors/app_error.dart';

class NetworkInterceptor extends Interceptor {
  final Dio dio;
  Completer<String?>? _refreshCompleter;

  NetworkInterceptor({required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final tenantId = prefs.getString('tenant_id');
    final branchId = prefs.getString('branch_id');

    if (token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (tenantId != null && !options.headers.containsKey('X-Tenant-Id')) {
      options.headers['X-Tenant-Id'] = tenantId;
    }
    if (branchId != null && !options.headers.containsKey('X-Branch-Id')) {
      options.headers['X-Branch-Id'] = branchId;
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // 1. Handle 401 Unauthorized (Avoid loop if already calling auth endpoints)
    if (statusCode == 401 &&
        !path.contains('/auth/login') &&
        !path.contains('/auth/refresh-token')) {
      final newToken = await _handleTokenRefresh();
      if (newToken != null) {
        // Retry the original request with the new token
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        } catch (retryError) {
          if (retryError is DioException) {
            return handler.next(retryError);
          }
        }
      }
    }

    // 2. Safe Auto-Retry for Idempotent Requests (GET / HEAD) on temporary 503/timeout
    final isIdempotent = err.requestOptions.method == 'GET' ||
        err.requestOptions.method == 'HEAD' ||
        err.requestOptions.method == 'OPTIONS';

    final isTransient = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        statusCode == 503;

    final retryCount = (err.requestOptions.extra['retry_count'] as int?) ?? 0;

    if (isIdempotent && isTransient && retryCount < 2) {
      err.requestOptions.extra['retry_count'] = retryCount + 1;
      await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
      try {
        final retryResponse = await dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        // Proceed to error handler if retry also fails
      }
    }

    // 3. Attach standard AppError
    final appError = AppError.fromDioException(err);
    final enrichedException = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: appError,
      message: appError.message,
    );

    return handler.next(enrichedException);
  }

  Future<String?> _handleTokenRefresh() async {
    // If a refresh is already in progress, wait for it instead of firing concurrent requests
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      final accessToken = prefs.getString('access_token');

      if (refreshToken == null || accessToken == null) {
        _refreshCompleter!.complete(null);
        _refreshCompleter = null;
        return null;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 8),
      ));

      final response = await refreshDio.post(
        '/auth/refresh-token',
        data: {
          'accessToken': accessToken,
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['accessToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (newAccessToken != null) {
          await prefs.setString('access_token', newAccessToken);
          if (newRefreshToken != null) {
            await prefs.setString('refresh_token', newRefreshToken);
          }
          _refreshCompleter!.complete(newAccessToken);
          _refreshCompleter = null;
          return newAccessToken;
        }
      }

      _refreshCompleter!.complete(null);
      _refreshCompleter = null;
      return null;
    } catch (_) {
      _refreshCompleter?.complete(null);
      _refreshCompleter = null;
      return null;
    }
  }
}
