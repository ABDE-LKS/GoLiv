import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final liveOperationsProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) async* {
  final apiClient = ref.watch(apiClientProvider);

  // Initial fetch
  try {
    final response = await apiClient.dio.get('/dashboard/live-orders');
    yield response.data as Map<String, dynamic>;
  } catch (e) {
    // Optionally yield an error map or just surface the error
    throw e;
  }

  // Polling every 5 seconds
  while (true) {
    await Future.delayed(const Duration(seconds: 5));
    try {
      final response = await apiClient.dio.get('/dashboard/live-orders');
      yield response.data as Map<String, dynamic>;
    } catch (e) {
      // If a single poll fails, we just skip it to maintain UX stability
      print("Live Ops polling error: $e");
    }
  }
});
