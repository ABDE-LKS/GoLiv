import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audit_interceptor.dart';
import 'api_error_mapper.dart';

import 'network_config.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient({required this.dio, required this.storage}) {
    dio.options.baseUrl = NetworkConfig.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);

    if (kDebugMode) {
      debugPrint('🚀 [API INITIALIZED] Base URL: ${NetworkConfig.baseUrl}');
    }

    // Add logging and authentication interceptors
    dio.interceptors.add(AuditInterceptor());
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          final dataMap = response.data as Map<String, dynamic>;
          if (dataMap.containsKey('success') && dataMap['success'] == true && dataMap.containsKey('data')) {
            response.data = dataMap['data'];
          }
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && 
            e.requestOptions.path != '/auth/login' && 
            e.requestOptions.path != '/auth/refresh') {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            try {
              final options = e.requestOptions;
              final token = await storage.read(key: 'access_token');
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              final retry = await dio.fetch(options);
              return handler.resolve(retry);
            } catch (_) {}
          }
          await storage.delete(key: 'access_token');
          await storage.delete(key: 'refresh_token');
        }

        final apiError = mapDioError(e);
        return handler.next(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: apiError,
          message: apiError.message,
        ));
      },
    ));
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;
    try {
      final response = await dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
      final data = response.data;
      if (data is Map && data['access_token'] != null) {
        await storage.write(key: 'access_token', value: data['access_token']);
        if (data['refresh_token'] != null) {
          await storage.write(key: 'refresh_token', value: data['refresh_token']);
        }
        return true;
      }
    } catch (_) {}
    return false;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio();
  const storage = FlutterSecureStorage();
  return ApiClient(dio: dio, storage: storage);
});
