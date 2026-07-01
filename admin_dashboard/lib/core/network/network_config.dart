import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkConfig {
  static const int port = 3000;
  static const String apiVersion = 'v1';

  static String get host {
    const String envHost = String.fromEnvironment('API_HOST');
    if (envHost.isNotEmpty) return envHost;

    if (kIsWeb) return '127.0.0.1';

    try {
      if (Platform.isAndroid) return '10.0.2.2';
      return '127.0.0.1';
    } catch (_) {
      return '127.0.0.1';
    }
  }

  static String get baseUrl => 'http://$host:$port/api/$apiVersion';
  static String get socketUrl => 'http://$host:$port';
}
