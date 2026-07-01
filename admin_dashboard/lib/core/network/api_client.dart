import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'audit_interceptor.dart';
import 'network_config.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient({required this.dio, required this.storage}) {
    dio.options.baseUrl = NetworkConfig.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);

    if (kDebugMode) {
      debugPrint('🚀 [ADMIN API INITIALIZED] Base URL: ${NetworkConfig.baseUrl}');
    }

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
        if (e.response?.statusCode == 401) {
          await storage.delete(key: 'access_token');
          await storage.delete(key: 'admin_role');
        }
        final message = _mapError(e);
        return handler.next(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: message,
          message: message,
        ));
      },
    ));
  }

  String _mapError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة الاتصال بالخادم.';
    }

    if (error.error is SocketException) {
      final socketError = error.error as SocketException;
      if (socketError.message.contains('Connection refused') || socketError.message.contains('Network is unreachable')) {
        return 'تعذر الاتصال بالخادم. تأكد من تشغيل الخلفية.';
      }
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'خطأ في الاتصال. تعذر الوصول إلى الخادم.';
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final backendMessage = _extractBackendMessage(error.response!.data);

      switch (statusCode) {
        case 400:
          return backendMessage ?? 'البيانات المدخلة غير صحيحة.';
        case 401:
          return backendMessage ?? 'رقم الهاتف أو كلمة المرور غير صحيحة.';
        case 403:
          return 'ليس لديك صلاحية.';
        case 404:
          return backendMessage ?? 'المورد غير موجود.';
        case 409:
          return backendMessage ?? 'رقم الهاتف أو البريد الإلكتروني مستخدم بالفعل.';
        case 422:
          return backendMessage ?? 'البيانات المدخلة غير صحيحة.';
        case 500:
        case 502:
        case 503:
          return backendMessage ?? 'حدث خطأ في الخادم، حاول مرة أخرى.';
        default:
          return backendMessage ?? 'حدث خطأ غير متوقع.';
      }
    }

    return error.message ?? 'حدث خطأ غير متوقع';
  }

  String? _extractBackendMessage(dynamic data) {
    if (data is! Map) return null;
    final msg = data['message'];
    if (msg == null) return null;
    if (msg is List) return msg.join('\n');
    return msg.toString();
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    dio: Dio(),
    storage: const FlutterSecureStorage(),
  );
});

String parseApiError(Object error) => extractApiErrorMessage(error);

String extractApiErrorMessage(Object error) {
  if (error is DioException) {
    if (error.message != null && error.message!.isNotEmpty) return error.message!;
    if (error.error is String) return error.error as String;
  }
  final text = error.toString();
  if (text.startsWith('Exception: ')) return text.substring(11);
  return text;
}
