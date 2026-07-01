import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

// --- Filter State ---
final orderSearchProvider = StateProvider<String>((ref) => '');
final orderStatusFilterProvider = StateProvider<String>((ref) => 'all');

// --- Orders List ---
final ordersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final search = ref.watch(orderSearchProvider);
  final status = ref.watch(orderStatusFilterProvider);

  final queryParams = <String, dynamic>{};
  if (status != 'all') queryParams['status'] = status;
  if (search.isNotEmpty) queryParams['search'] = search;

  final response = await apiClient.dio.get('/orders', queryParameters: queryParams);
  return response.data as List<dynamic>;
});

// --- Single Order Detail ---
final orderDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, orderId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/orders/$orderId');
  return response.data as Map<String, dynamic>;
});

// --- Available Drivers for Assignment ---
final availableDriversProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/orders/meta/available-drivers');
  return response.data as List<dynamic>;
});

// --- Order Action Notifier ---
class OrderActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  OrderActionNotifier(this._ref) : super(false);

  Future<void> updateStatus(String orderId, String status) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.patch('/orders/$orderId/status', data: {'status': status});
      _ref.invalidate(ordersProvider);
      _ref.invalidate(orderDetailProvider(orderId));
    } finally {
      state = false;
    }
  }

  Future<void> assignDriver(String orderId, String driverId) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.patch('/orders/$orderId/assign-driver', data: {'driverId': driverId});
      _ref.invalidate(ordersProvider);
      _ref.invalidate(orderDetailProvider(orderId));
    } finally {
      state = false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.patch('/orders/$orderId/cancel');
      _ref.invalidate(ordersProvider);
      _ref.invalidate(orderDetailProvider(orderId));
    } finally {
      state = false;
    }
  }
}

final orderActionProvider = StateNotifierProvider<OrderActionNotifier, bool>((ref) {
  return OrderActionNotifier(ref);
});
