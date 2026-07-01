class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Thrown when the device actually has no internet connection
class NetworkException extends ApiException {
  NetworkException() : super(message: 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.');
}

/// Thrown when the server port is closed or the URL is wrong (SocketException)
class ServerUnreachableException extends ApiException {
  ServerUnreachableException() : super(message: 'تعذر الاتصال بالخادم. يرجى التأكد من تشغيل الـ Backend.');
}

/// Thrown for 401 errors
class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'رقم الهاتف أو كلمة المرور غير صحيحة.'})
      : super(message: message, statusCode: 401);
}

/// Thrown for 500+ errors
class ServerException extends ApiException {
  ServerException({int? statusCode, dynamic data, String message = 'حدث خطأ في الخادم. حاول مرة أخرى.'})
      : super(message: message, statusCode: statusCode, data: data);
}

/// Thrown for 422 or 400 errors
class ValidationException extends ApiException {
  ValidationException(String message, {dynamic data}) : super(message: message, statusCode: 422, data: data);
}
