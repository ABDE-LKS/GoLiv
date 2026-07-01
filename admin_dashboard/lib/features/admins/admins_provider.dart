import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final adminSearchProvider = StateProvider<String>((ref) => '');

final adminsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final params = <String, dynamic>{'page': 1, 'limit': 50};
  if (ref.watch(adminSearchProvider).isNotEmpty) params['search'] = ref.watch(adminSearchProvider);
  final res = await ref.watch(apiClientProvider).dio.get('/admins', queryParameters: params);
  final data = res.data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {'items': data};
});

class AdminActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  AdminActionNotifier(this._ref) : super(false);
  Future<void> create(Map<String, dynamic> data) async { state = true; try { await _ref.read(apiClientProvider).dio.post('/admins', data: data); _ref.invalidate(adminsProvider); } finally { state = false; } }
  Future<void> update(String id, Map<String, dynamic> data) async { state = true; try { await _ref.read(apiClientProvider).dio.patch('/admins/$id', data: data); _ref.invalidate(adminsProvider); } finally { state = false; } }
  Future<void> delete(String id) async { state = true; try { await _ref.read(apiClientProvider).dio.delete('/admins/$id'); _ref.invalidate(adminsProvider); } finally { state = false; } }
}

final adminActionProvider = StateNotifierProvider<AdminActionNotifier, bool>((ref) => AdminActionNotifier(ref));
