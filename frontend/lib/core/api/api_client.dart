import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import '../states/network/network_interceptor.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio dio;

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

    // Attach our robust NetworkInterceptor (handles headers, token refresh mutex, safe idempotent retry, RFC 9457 errors)
    dio.interceptors.add(NetworkInterceptor(dio: dio));
  }

  Future<void> updateCredentials({String? token, String? tenantId, String? branchId}) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) await prefs.setString('access_token', token);
    if (tenantId != null) await prefs.setString('tenant_id', tenantId);
    if (branchId != null) await prefs.setString('branch_id', branchId);
  }

  Future<void> setBranchId(String? branchId) async {
    final prefs = await SharedPreferences.getInstance();
    if (branchId != null) {
      await prefs.setString('branch_id', branchId);
    } else {
      await prefs.remove('branch_id');
    }
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('tenant_id');
    await prefs.remove('branch_id');
    await prefs.remove('user_data');
    await prefs.remove('tenant_data');
  }
}
