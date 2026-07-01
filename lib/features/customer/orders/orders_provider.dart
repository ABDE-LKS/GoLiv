import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_error_mapper.dart';
import '../../../models/order_model.dart';
import '../../../repositories/order_repository_impl.dart';
import 'package:collection/collection.dart';

final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(orderRepositoryProvider).getMyOrders();
});

final recentOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final orders = await ref.watch(orderRepositoryProvider).getMyOrders();
  return orders.take(3).toList();
});

final activeOrderProvider = Provider<OrderModel?>((ref) {
  final ordersAsync = ref.watch(ordersProvider);
  return ordersAsync.when(
    data: (orders) => orders.firstWhereOrNull((o) => o.isActive),
    loading: () => null,
    error: (_, __) => null,
  );
});

String ordersErrorMessage(Object error) => extractErrorMessage(error);
