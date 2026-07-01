import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final notificationsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final res = await ref.watch(apiClientProvider).dio.get('/notifications', queryParameters: {'page': 1, 'limit': 50});
  final data = res.data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {'items': data};
});

class NotificationActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  NotificationActionNotifier(this._ref) : super(false);
  Future<Map<String, dynamic>> broadcast(Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await _ref.read(apiClientProvider).dio.post('/notifications/broadcast', data: data);
      _ref.invalidate(notificationsProvider);
      return Map<String, dynamic>.from(res.data as Map);
    } finally { state = false; }
  }
}

final notificationActionProvider = StateNotifierProvider<NotificationActionNotifier, bool>((ref) => NotificationActionNotifier(ref));
