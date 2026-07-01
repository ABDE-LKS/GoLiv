import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_error_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String phone, String password) async {
    debugPrint('🔎 [TRACE] 5. AuthRepository.login() entering try block');
    try {
      debugPrint('🔎 [TRACE] 6. Executing dio.post()');
      final response = await _apiClient.dio.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });
      debugPrint('🔎 [TRACE] 7. dio.post() returned status: ${response.statusCode}');

      final data = response.data as Map<String, dynamic>;
      await _saveTokens(data);
      return data;
    } on DioException catch (e) {
      debugPrint('🔎 [TRACE] AuthRepository.login() error: $e');
      throw extractErrorMessage(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post('/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      await _saveTokens(data);
      return data;
    } on DioException catch (e) {
      debugPrint('🔎 [TRACE] AuthRepository.register() error: $e');
      throw extractErrorMessage(e);
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    if (data['access_token'] != null) {
      await _apiClient.storage.write(key: 'access_token', value: data['access_token']);
    }
    if (data['refresh_token'] != null) {
      await _apiClient.storage.write(key: 'refresh_token', value: data['refresh_token']);
    }
  }

  Future<void> logout() async {
    await _apiClient.storage.delete(key: 'access_token');
    await _apiClient.storage.delete(key: 'refresh_token');
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});
