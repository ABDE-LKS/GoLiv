import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkConfig {
  static const int port = 3000;
  static const String apiVersion = 'v1';

  /// The logic for resolving the host:
  /// 1. Prioritize --dart-define=API_HOST=xxx.xxx.xxx.xxx
  /// 2. If browser (Web), use 127.0.0.1
  /// 3. For Android, we check if we should use 10.0.2.2 (Emulator) 
  ///    but we prefer the user to provide their local machine IP.
  static String get host {
    const String envHost = String.fromEnvironment('API_HOST');
    if (envHost.isNotEmpty) return envHost;

    if (kIsWeb) return '127.0.0.1';

    try {
      if (Platform.isAndroid) {
        // We no longer hardcode 10.0.2.2 as the sole truth.
        // If you are on a real device, you MUST use --dart-define=API_HOST=YOUR_IP
        // We default to 10.0.2.2 ONLY if no other info is available, 
        // but we'll print a warning.
        return '10.0.2.2'; 
      }
      return '127.0.0.1';
    } catch (_) {
      return '127.0.0.1';
    }
  }

  static String get baseUrl => 'http://$host:$port/api/$apiVersion';
  static String get socketUrl => 'http://$host:$port';
}
