import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'auth_models.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? user;
  final TenantModel? tenant;
  final List<BranchModel> branches;
  final BranchModel? selectedBranch;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.tenant,
    this.branches = const [],
    this.selectedBranch,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? user,
    TenantModel? tenant,
    List<BranchModel>? branches,
    BranchModel? selectedBranch,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      tenant: tenant ?? this.tenant,
      branches: branches ?? this.branches,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final ApiClient _apiClient;

  @override
  AuthState build() {
    _apiClient = ref.watch(apiClientProvider);
    _checkAuthSession();
    return const AuthState(isLoading: true);
  }

  Future<void> _checkAuthSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userJson = prefs.getString('user_data');
      final tenantJson = prefs.getString('tenant_data');
      final branchId = prefs.getString('branch_id');

      if (token != null && userJson != null && tenantJson != null) {
        final user = UserModel.fromJson(jsonDecode(userJson));
        final tenant = TenantModel.fromJson(jsonDecode(tenantJson));
        _apiClient.updateCredentials(token: token, tenantId: tenant.id, branchId: branchId);

        try {
          final res = await _apiClient.dio.get(ApiConstants.branches);
          final branchesList = (res.data as List)
              .map((b) => BranchModel.fromJson(b))
              .toList();

          BranchModel? selected;
          if (branchId != null) {
            selected = branchesList.cast<BranchModel?>().firstWhere(
                  (b) => b?.id == branchId,
                  orElse: () => branchesList.isNotEmpty ? branchesList.first : null,
                );
          } else if (branchesList.isNotEmpty) {
            selected = branchesList.first;
          }

          state = AuthState(
            isAuthenticated: true,
            isLoading: false,
            user: user,
            tenant: tenant,
            branches: branchesList,
            selectedBranch: selected,
          );
          return;
        } catch (_) {}

        state = AuthState(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          tenant: tenant,
        );
        return;
      }
    } catch (_) {}

    state = const AuthState(isAuthenticated: false, isLoading: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email.trim(), 'password': password},
      );

      final data = res.data;
      final token = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final user = UserModel.fromJson(data['user']);
      final tenant = TenantModel.fromJson(data['tenant']);
      final branches = (data['branches'] as List)
          .map((b) => BranchModel.fromJson(b))
          .toList();

      final selectedBranch = branches.isNotEmpty ? branches.first : null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('tenant_id', tenant.id);
      if (selectedBranch != null) {
        await prefs.setString('branch_id', selectedBranch.id);
      }
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      await prefs.setString('tenant_data', jsonEncode(tenant.toJson()));

      _apiClient.updateCredentials(
        token: token,
        tenantId: tenant.id,
        branchId: selectedBranch?.id,
      );

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        tenant: tenant,
        branches: branches,
        selectedBranch: selectedBranch,
      );
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Login failed. Please check your credentials.';
      state = state.copyWith(isLoading: false, errorMessage: msg.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Network error. Backend unreachable.');
      return false;
    }
  }

  Future<bool> registerTenant({
    required String gymName,
    required String slug,
    required String adminFullName,
    required String adminEmail,
    required String adminPassword,
    required String branchName,
    String? branchCity,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _apiClient.dio.post(
        ApiConstants.registerTenant,
        data: {
          'gymName': gymName.trim(),
          'slug': slug.trim().toLowerCase(),
          'adminFullName': adminFullName.trim(),
          'adminEmail': adminEmail.trim(),
          'adminPassword': adminPassword,
          'branchName': branchName.trim(),
          'branchCity': branchCity ?? '',
          'phone': phone ?? '',
        },
      );

      final data = res.data;
      final token = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final user = UserModel.fromJson(data['user']);
      final tenant = TenantModel.fromJson(data['tenant']);
      final branches = (data['branches'] as List)
          .map((b) => BranchModel.fromJson(b))
          .toList();

      final selectedBranch = branches.isNotEmpty ? branches.first : null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('tenant_id', tenant.id);
      if (selectedBranch != null) {
        await prefs.setString('branch_id', selectedBranch.id);
      }
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      await prefs.setString('tenant_data', jsonEncode(tenant.toJson()));

      _apiClient.updateCredentials(
        token: token,
        tenantId: tenant.id,
        branchId: selectedBranch?.id,
      );

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        user: user,
        tenant: tenant,
        branches: branches,
        selectedBranch: selectedBranch,
      );
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Registration failed.';
      state = state.copyWith(isLoading: false, errorMessage: msg.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Unexpected error occurred.');
      return false;
    }
  }

  void switchBranch(BranchModel branch) async {
    _apiClient.setBranchId(branch.id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('branch_id', branch.id);
    state = state.copyWith(selectedBranch: branch);
  }

  Future<void> logout() async {
    await _apiClient.clearCredentials();
    state = const AuthState(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
