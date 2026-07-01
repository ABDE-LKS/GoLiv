import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/dashboard/stats');
  // Data is automatically unwrapped by our global interceptor if it follows the standard { success, data } format.
  return response.data as Map<String, dynamic>;
});
