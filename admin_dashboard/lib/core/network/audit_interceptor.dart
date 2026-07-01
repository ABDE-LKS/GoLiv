import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuditInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final String fullUrl = '${options.baseUrl}${options.path}';
      final bool isEmulatorIp = options.baseUrl.contains('10.0.2.2');

      debugPrint('=============================================');
      debugPrint('🚀 [ADMIN NETWORK CALL] START');
      debugPrint('FULL URL: $fullUrl');
      if (isEmulatorIp) {
        debugPrint('⚠️  WARNING: Using 10.0.2.2 (Emulator IP).');
        debugPrint('   If you are on a REAL DEVICE, this will fail.');
        debugPrint('   Run with --dart-define=API_HOST=your.pc.ip');
      }
      debugPrint('METHOD:   ${options.method}');
      if (options.data != null) debugPrint('BODY:     ${options.data}');
      debugPrint('=============================================');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('========== RESPONSE =========');
      debugPrint('Status:  ${response.statusCode}');
      debugPrint('Body:    ${response.data}');
      debugPrint('=============================');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('========== ERROR ============');
      debugPrint('Status:  ${err.response?.statusCode}');
      debugPrint('Message: ${err.message}');
      debugPrint('Type:    ${err.type}');
      debugPrint('Response Body: ${err.response?.data}');
      debugPrint('Stack:   ${err.stackTrace}');
      debugPrint('=============================');
    }
    super.onError(err, handler);
  }
}
