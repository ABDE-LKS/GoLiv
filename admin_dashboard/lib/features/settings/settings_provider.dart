import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final settingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final res = await ref.watch(apiClientProvider).dio.get('/settings');
  return Map<String, dynamic>.from(res.data as Map);
});

class SettingsActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  SettingsActionNotifier(this._ref) : super(false);
  Future<void> save(Map<String, dynamic> data) async {
    state = true;
    try { await _ref.read(apiClientProvider).dio.patch('/settings', data: data); _ref.invalidate(settingsProvider); } finally { state = false; }
  }
}

final settingsActionProvider = StateNotifierProvider<SettingsActionNotifier, bool>((ref) => SettingsActionNotifier(ref));
