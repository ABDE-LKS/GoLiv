import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_error_mapper.dart';
import 'auth_repository.dart';

enum UserRole { customer, driver, admin }

class AuthState {
  final UserRole? role;
  final String? userId;
  final String? name;
  final String? phone;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.role,
    this.userId,
    this.name,
    this.phone,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserRole? role,
    String? userId,
    String? name,
    String? phone,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      role: role ?? this.role,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState()) {
    init();
  }

  Future<void> init() async {
    try {
      state = state.copyWith(isLoading: true);
      final storage = _ref.read(apiClientProvider).storage;
      final token = await storage.read(key: 'access_token');
      
      if (token != null) {
        try {
          final response = await _ref.read(apiClientProvider).dio.get('/auth/profile');
          final userData = response.data;
          state = AuthState(
            role: _mapRole(userData['role']),
            userId: userData['id'],
            name: '${userData['firstName']} ${userData['lastName']}',
            phone: userData['phone'],
            isAuthenticated: true,
            isLoading: false,
          );
        } catch (e) {
          debugPrint('Session expired or invalid: $e');
          await storage.delete(key: 'access_token');
          await storage.delete(key: 'refresh_token');
          state = state.copyWith(isLoading: false, isAuthenticated: false);
        }
      } else {
        state = state.copyWith(isLoading: false, isAuthenticated: false);
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> login(String phone, String password) async {
    debugPrint('🔎 [TRACE] 3. AuthNotifier.login() called');
    state = state.copyWith(isLoading: true, error: null, clearError: true);
    try {
      debugPrint('🔎 [TRACE] 4. Calling AuthRepository.login()');
      final response = await _repository.login(phone, password);
      debugPrint('🔎 [TRACE] 8. AuthRepository.login() success');
      final userData = response['user'];
      state = AuthState(
        role: _mapRole(userData['role']),
        userId: userData['id'],
        name: '${userData['firstName']} ${userData['lastName']}',
        phone: userData['phone'],
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractErrorMessage(e),
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, clearError: true);
    try {
      final response = await _repository.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
      );
      final userData = response['user'] ?? {};
      state = AuthState(
        role: _mapRole(userData['role'] ?? 'CUSTOMER'),
        userId: userData['id'],
        name: '${userData['firstName']} ${userData['lastName']}',
        phone: userData['phone'],
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: extractErrorMessage(e),
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  UserRole _mapRole(String? role) {
    if (role == null) return UserRole.customer;
    switch (role.toUpperCase()) {
      case 'DRIVER': return UserRole.driver;
      case 'ADMIN': return UserRole.admin;
      default: return UserRole.customer;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});

