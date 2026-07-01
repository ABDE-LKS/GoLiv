import 'dart:io';
import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Maps Dio errors to user-friendly Arabic messages.
ApiException mapDioError(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return ApiException(message: 'انتهت مهلة الاتصال بالخادم.');
  }

  if (error.error is SocketException) {
    final socketError = error.error as SocketException;
    if (socketError.message.contains('Connection refused') || socketError.message.contains('Network is unreachable')) {
      return ApiException(message: 'تعذر الاتصال بالخادم. تأكد من تشغيل الخلفية.');
    }
    return ApiException(message: 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.');
  }

  if (error.type == DioExceptionType.connectionError) {
    return ApiException(message: 'خطأ في الاتصال. تعذر الوصول إلى الخادم.');
  }

  if (error.response != null) {
    final statusCode = error.response!.statusCode;
    final backendMessage = _extractBackendMessage(error.response!.data);

    switch (statusCode) {
      case 400:
        return ApiException(message: backendMessage ?? 'البيانات المدخلة غير صحيحة.', statusCode: 400);
      case 401:
        return ApiException(message: backendMessage ?? 'رقم الهاتف أو كلمة المرور غير صحيحة.', statusCode: 401);
      case 403:
        return ApiException(message: 'ليس لديك صلاحية.', statusCode: 403);
      case 404:
        return ApiException(message: backendMessage ?? 'المورد غير موجود.', statusCode: 404);
      case 409:
        return ApiException(message: backendMessage ?? 'رقم الهاتف أو البريد الإلكتروني مستخدم بالفعل.', statusCode: 409);
      case 422:
        return ApiException(message: backendMessage ?? 'البيانات المدخلة غير صحيحة.', statusCode: 422);
      case 500:
      case 502:
      case 503:
        return ApiException(message: backendMessage ?? 'حدث خطأ في الخادم، حاول مرة أخرى.', statusCode: statusCode);
      default:
        return ApiException(message: backendMessage ?? 'حدث خطأ غير متوقع.', statusCode: statusCode);
    }
  }

  return ApiException(message: error.message ?? 'حدث خطأ غير متوقع.');
}

String? _extractBackendMessage(dynamic data) {
  if (data is! Map) return null;
  final msg = data['message'];
  if (msg == null) return null;
  if (msg is List) return msg.join('\n');
  return msg.toString();
}

String extractErrorMessage(Object error) {
  if (error is ApiException) return error.message;
  if (error is DioException) {
    if (error.error is ApiException) return (error.error as ApiException).message;
    return mapDioError(error).message;
  }
  final text = error.toString();
  if (text.startsWith('Exception: ')) return text.substring(11);
  return text;
}
