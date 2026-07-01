import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

// --- Filter State Providers ---
final storeSearchProvider = StateProvider<String>((ref) => '');
final storeCategoryFilterProvider = StateProvider<String?>((ref) => null);
final storeStatusFilterProvider = StateProvider<String>((ref) => 'all');

// --- Store List Provider (all stores for dropdowns) ---
final allStoresProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/stores', queryParameters: {'status': 'all'});
  return response.data as List<dynamic>;
});

// --- Store List Provider ---
final storesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final search = ref.watch(storeSearchProvider);
  final categoryId = ref.watch(storeCategoryFilterProvider);
  final status = ref.watch(storeStatusFilterProvider);

  final queryParams = <String, dynamic>{'status': status};
  if (search.isNotEmpty) queryParams['search'] = search;
  if (categoryId != null) queryParams['categoryId'] = categoryId;

  final response = await apiClient.dio.get('/stores', queryParameters: queryParams);
  return response.data as List<dynamic>;
});

// --- Single Store Detail Provider ---
final storeDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, storeId) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/stores/$storeId');
  return response.data as Map<String, dynamic>;
});

// --- Store Action Notifier ---
class StoreActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  StoreActionNotifier(this._ref) : super(false);

  Future<void> createStore(Map<String, dynamic> data) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.post('/stores', data: data);
      _ref.invalidate(storesProvider);
    } finally {
      state = false;
    }
  }

  Future<void> updateStore(String storeId, Map<String, dynamic> data) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.patch('/stores/$storeId', data: data);
      _ref.invalidate(storesProvider);
      _ref.invalidate(storeDetailProvider(storeId));
    } finally {
      state = false;
    }
  }

  Future<void> suspendStore(String storeId, bool activate) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.patch('/stores/$storeId', data: {'isActive': activate});
      _ref.invalidate(storesProvider);
    } finally {
      state = false;
    }
  }

  Future<void> featureStore(String storeId, bool feature) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.patch('/stores/$storeId', data: {'isFeatured': feature});
      _ref.invalidate(storesProvider);
    } finally {
      state = false;
    }
  }

  Future<void> deleteStore(String storeId) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.delete('/stores/$storeId');
      _ref.invalidate(storesProvider);
    } finally {
      state = false;
    }
  }
}

final storeActionProvider = StateNotifierProvider<StoreActionNotifier, bool>((ref) {
  return StoreActionNotifier(ref);
});
