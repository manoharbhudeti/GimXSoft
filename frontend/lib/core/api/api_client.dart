import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio dio;
  String? _accessToken;
  String? _tenantId;
  String? _branchId;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken == null) {
            final prefs = await SharedPreferences.getInstance();
            _accessToken = prefs.getString('access_token');
            _tenantId = prefs.getString('tenant_id');
            _branchId = prefs.getString('branch_id');
          }

          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          if (_tenantId != null) {
            options.headers['X-Tenant-Id'] = _tenantId;
          }
          if (_branchId != null) {
            options.headers['X-Branch-Id'] = _branchId;
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Format user-friendly error message
          return handler.next(error);
        },
      ),
    );
  }

  void updateCredentials({String? token, String? tenantId, String? branchId}) {
    _accessToken = token;
    _tenantId = tenantId;
    _branchId = branchId;
  }

  void setBranchId(String? branchId) {
    _branchId = branchId;
  }

  Future<void> clearCredentials() async {
    _accessToken = null;
    _tenantId = null;
    _branchId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('tenant_id');
    await prefs.remove('branch_id');
    await prefs.remove('user_data');
    await prefs.remove('tenant_data');
  }
}

