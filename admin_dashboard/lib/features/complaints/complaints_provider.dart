import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final complaintStatusFilterProvider = StateProvider<String>((ref) => 'all');
final complaintSearchProvider = StateProvider<String>((ref) => '');

final complaintsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final params = <String, dynamic>{'page': 1, 'limit': 50};
  if (ref.watch(complaintSearchProvider).isNotEmpty) params['search'] = ref.watch(complaintSearchProvider);
  if (ref.watch(complaintStatusFilterProvider) != 'all') params['status'] = ref.watch(complaintStatusFilterProvider);
  final res = await api.dio.get('/complaints', queryParameters: params);
  final data = res.data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {'items': data};
});

class ComplaintActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  ComplaintActionNotifier(this._ref) : super(false);
  Future<void> update(String id, Map<String, dynamic> data) async {
    state = true;
    try { await _ref.read(apiClientProvider).dio.patch('/complaints/$id', data: data); _ref.invalidate(complaintsProvider); } finally { state = false; }
  }
}

final complaintActionProvider = StateNotifierProvider<ComplaintActionNotifier, bool>((ref) => ComplaintActionNotifier(ref));
