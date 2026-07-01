import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart' hide extractApiErrorMessage;
import '../../core/network/api_error.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? role;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.role,
  });

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, String? error, String? role, bool clearError = false}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  
  AuthNotifier(this._ref) : super(AuthState()) {
    _checkToken();
  }

  Future<void> _checkToken() async {
    final storage = _ref.read(apiClientProvider).storage;
    final token = await storage.read(key: 'access_token');
    final role = await storage.read(key: 'admin_role');
    
    if (token != null && role != null && (role == 'ADMIN' || role == 'SUPER_ADMIN')) {
      state = state.copyWith(isAuthenticated: true, role: role);
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dio = _ref.read(apiClientProvider).dio;
      final response = await dio.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });
      
      final userData = response.data['user'];
      final role = userData['role'];
      
      if (role != 'ADMIN' && role != 'SUPER_ADMIN') {
        throw Exception('You are not authorized. Administrators only.');
      }

      final storage = _ref.read(apiClientProvider).storage;
      await storage.write(key: 'access_token', value: response.data['access_token']);
      await storage.write(key: 'admin_role', value: role);

      state = AuthState(isAuthenticated: true, isLoading: false, role: role);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractApiErrorMessage(e));
    }
  }

  Future<void> logout() async {
    final storage = _ref.read(apiClientProvider).storage;
    await storage.deleteAll();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
