import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../categories/categories_provider.dart';

final customerSearchProvider = StateProvider<String>((ref) => '');
final customerPageProvider = StateProvider<int>((ref) => 1);

final customersProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final params = <String, dynamic>{'page': ref.watch(customerPageProvider), 'limit': 20};
  final search = ref.watch(customerSearchProvider);
  if (search.isNotEmpty) params['search'] = search;
  final res = await api.dio.get('/customers', queryParameters: params);
  final data = res.data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {'items': data, 'total': extractListItems(data).length, 'page': 1, 'totalPages': 1};
});

final customerDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final res = await ref.watch(apiClientProvider).dio.get('/customers/$id');
  return Map<String, dynamic>.from(res.data as Map);
});

class CustomerActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  CustomerActionNotifier(this._ref) : super(false);
  Future<void> delete(String id) async {
    state = true;
    try { await _ref.read(apiClientProvider).dio.delete('/customers/$id'); _ref.invalidate(customersProvider); } finally { state = false; }
  }
}

final customerActionProvider = StateNotifierProvider<CustomerActionNotifier, bool>((ref) => CustomerActionNotifier(ref));
