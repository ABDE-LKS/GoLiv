import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final auditSearchProvider = StateProvider<String>((ref) => '');
final auditPageProvider = StateProvider<int>((ref) => 1);

final auditLogsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final params = <String, dynamic>{'page': ref.watch(auditPageProvider), 'limit': 30};
  if (ref.watch(auditSearchProvider).isNotEmpty) params['search'] = ref.watch(auditSearchProvider);
  final res = await api.dio.get('/audit-logs', queryParameters: params);
  final data = res.data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {'items': data};
});
