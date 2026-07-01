import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../categories/categories_provider.dart';

final productSearchProvider = StateProvider<String>((ref) => '');
final productStatusFilterProvider = StateProvider<String>((ref) => 'all');
final productStoreFilterProvider = StateProvider<String?>((ref) => null);
final productPageProvider = StateProvider<int>((ref) => 1);

final productsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final search = ref.watch(productSearchProvider);
  final status = ref.watch(productStatusFilterProvider);
  final storeId = ref.watch(productStoreFilterProvider);
  final page = ref.watch(productPageProvider);

  final params = <String, dynamic>{'page': page, 'limit': 20};
  if (search.isNotEmpty) params['search'] = search;
  if (status != 'all') params['status'] = status;
  if (storeId != null) params['storeId'] = storeId;

  final response = await apiClient.dio.get('/products', queryParameters: params);
  final data = response.data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {'items': data, 'total': extractListItems(data).length, 'page': 1, 'totalPages': 1};
});

class ProductActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  ProductActionNotifier(this._ref) : super(false);

  Future<void> createProduct(Map<String, dynamic> data) async {
    state = true;
    try {
      await _ref.read(apiClientProvider).dio.post('/products', data: data);
      _ref.invalidate(productsProvider);
    } finally {
      state = false;
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    state = true;
    try {
      await _ref.read(apiClientProvider).dio.patch('/products/$id', data: data);
      _ref.invalidate(productsProvider);
    } finally {
      state = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    state = true;
    try {
      await _ref.read(apiClientProvider).dio.delete('/products/$id');
      _ref.invalidate(productsProvider);
    } finally {
      state = false;
    }
  }
}

final productActionProvider = StateNotifierProvider<ProductActionNotifier, bool>((ref) => ProductActionNotifier(ref));
