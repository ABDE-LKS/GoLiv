import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../categories/categories_provider.dart';

final driverSearchProvider = StateProvider<String>((ref) => '');
final driverStatusFilterProvider = StateProvider<String>((ref) => 'all');
final driverPageProvider = StateProvider<int>((ref) => 1);

final driversProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final params = <String, dynamic>{'page': ref.watch(driverPageProvider), 'limit': 20};
  final search = ref.watch(driverSearchProvider);
  final status = ref.watch(driverStatusFilterProvider);
  if (search.isNotEmpty) params['search'] = search;
  if (status != 'all') params['status'] = status;
  final res = await api.dio.get('/drivers', queryParameters: params);
  final data = res.data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {'items': data, 'total': extractListItems(data).length, 'page': 1, 'totalPages': 1};
});

class DriverActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  DriverActionNotifier(this._ref) : super(false);

  Future<void> create(Map<String, dynamic> data) async {
    state = true;
    try { await _ref.read(apiClientProvider).dio.post('/drivers', data: data); _ref.invalidate(driversProvider); } finally { state = false; }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    state = true;
    try { await _ref.read(apiClientProvider).dio.patch('/drivers/$id', data: data); _ref.invalidate(driversProvider); } finally { state = false; }
  }

  Future<void> suspend(String id) async {
    state = true;
    try { await _ref.read(apiClientProvider).dio.patch('/drivers/$id/suspend'); _ref.invalidate(driversProvider); } finally { state = false; }
  }

  Future<void> activate(String id) async {
    state = true;
    try { await _ref.read(apiClientProvider).dio.patch('/drivers/$id/activate'); _ref.invalidate(driversProvider); } finally { state = false; }
  }

  Future<void> delete(String id) async {
    state = true;
    try { await _ref.read(apiClientProvider).dio.delete('/drivers/$id'); _ref.invalidate(driversProvider); } finally { state = false; }
  }
}

final driverActionProvider = StateNotifierProvider<DriverActionNotifier, bool>((ref) => DriverActionNotifier(ref));
