import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

/// Extracts list items from API response (array or paginated object).
List<dynamic> extractListItems(dynamic data) {
  if (data is List) return data;
  if (data is Map && data['items'] is List) return data['items'] as List;
  return [];
}

int extractTotal(dynamic data, {int fallback = 0}) {
  if (data is Map && data['total'] is int) return data['total'] as int;
  if (data is List) return data.length;
  return fallback;
}

// --- Filter State ---
final categorySearchProvider = StateProvider<String>((ref) => '');
final categoryStatusFilterProvider = StateProvider<String>((ref) => 'all');
final categoryPageProvider = StateProvider<int>((ref) => 1);

// --- Categories List (for dropdowns - active only) ---
final categoriesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/categories', queryParameters: {'status': 'active'});
  return extractListItems(response.data);
});

// --- Paginated Categories List (admin screen) ---
final categoriesListProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final search = ref.watch(categorySearchProvider);
  final status = ref.watch(categoryStatusFilterProvider);
  final page = ref.watch(categoryPageProvider);

  final queryParams = <String, dynamic>{'page': page, 'limit': 20};
  if (search.isNotEmpty) queryParams['search'] = search;
  if (status != 'all') queryParams['status'] = status;

  final response = await apiClient.dio.get('/categories', queryParameters: queryParams);
  final data = response.data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {'items': data, 'total': extractListItems(data).length, 'page': 1, 'limit': 20, 'totalPages': 1};
});

// --- Category Actions ---
class CategoryActionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  CategoryActionNotifier(this._ref) : super(false);

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.dio.post('/categories', data: data);
      _ref.invalidate(categoriesProvider);
      _ref.invalidate(categoriesListProvider);
      return Map<String, dynamic>.from(response.data as Map);
    } finally {
      state = false;
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.patch('/categories/$id', data: data);
      _ref.invalidate(categoriesProvider);
      _ref.invalidate(categoriesListProvider);
    } finally {
      state = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    state = true;
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.dio.delete('/categories/$id');
      _ref.invalidate(categoriesProvider);
      _ref.invalidate(categoriesListProvider);
    } finally {
      state = false;
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await updateCategory(id, {'isActive': isActive});
  }
}

final categoryActionProvider = StateNotifierProvider<CategoryActionNotifier, bool>((ref) {
  return CategoryActionNotifier(ref);
});
