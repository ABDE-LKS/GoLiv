import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/network/api_client.dart';

final homeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/home');
  // Data is already unwrapped by our TransformInterceptor
  return response.data as Map<String, dynamic>;
});
