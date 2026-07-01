import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../categories/categories_provider.dart';

final offerSearchProvider = StateProvider<String>((ref) => '');
final offerStatusFilterProvider = StateProvider<String>((ref) => 'all');

final offersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final params = <String, dynamic>{'page': 1, 'limit': 50};
  if (ref.watch(offerSearchProvider).isNotEmpty) params['search'] = ref.watch(offerSearchProvider);
  if (ref.watch(offerStatusFilterProvider) != 'all') params['status'] = ref.watch(offerStatusFilterProvider);
  final res = await api.dio.get('/offers', queryParameters: params);
  return extractListItems(res.data);
});

class OfferActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  OfferActionNotifier(this._ref) : super(false);

  Future<void> create(Map<String, dynamic> data) async {
    state = true;
    try {
      await _ref.read(apiClientProvider).dio.post('/offers', data: data);
      _ref.invalidate(offersProvider);
    } finally {
      state = false;
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    state = true;
    try {
      await _ref.read(apiClientProvider).dio.patch('/offers/$id', data: data);
      _ref.invalidate(offersProvider);
    } finally {
      state = false;
    }
  }

  Future<void> delete(String id) async {
    state = true;
    try {
      await _ref.read(apiClientProvider).dio.delete('/offers/$id');
      _ref.invalidate(offersProvider);
    } finally {
      state = false;
    }
  }
}

final offerActionProvider = StateNotifierProvider<OfferActionNotifier, bool>((ref) => OfferActionNotifier(ref));
