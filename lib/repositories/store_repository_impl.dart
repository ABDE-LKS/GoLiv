import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/utils/product_mapper.dart';
import '../core/utils/store_mapper.dart';
import '../core/utils/category_mapper.dart';
import 'package:wassali/models/store_model.dart';
import 'package:wassali/models/category_model.dart';
import 'package:wassali/models/product_model.dart';
import 'package:wassali/models/offer_model.dart';
import 'i_store_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreRepositoryImpl implements IStoreRepository {
  final ApiClient _apiClient;

  StoreRepositoryImpl(this._apiClient);

  @override
  Future<List<StoreModel>> getAllStores({String? search}) async {
    try {
      final response = await _apiClient.dio.get('/stores', queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      });
      final List data = response.data is List ? response.data : [];
      return data.map((e) => mapStoreFromBackend(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'تعذر تحميل المتاجر');
    }
  }

  Future<StoreModel> getStoreById(String id) async {
    try {
      final response = await _apiClient.dio.get('/stores/$id');
      return mapStoreFromBackend(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'تعذر تحميل المتجر');
    }
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _apiClient.dio.get('/categories');
      final List data = response.data is List ? response.data : [];
      return data.map((e) => mapCategoryFromBackend(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'تعذر تحميل الأقسام');
    }
  }

  @override
  Future<List<ProductModel>> getStoreProducts(String storeId) async {
    try {
      final response = await _apiClient.dio.get('/products', queryParameters: {'storeId': storeId});
      final dynamic raw = response.data;
      final List data = raw is List ? raw : (raw is Map ? (raw['items'] as List? ?? []) : []);
      return data.map((e) => mapProductFromBackend(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'تعذر تحميل المنتجات');
    }
  }

  Future<List<OfferModel>> getTodayOffers() async {
    try {
      final response = await _apiClient.dio.get('/offers/today');
      final List data = response.data is List ? response.data : [];
      return data.map((e) => OfferModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'تعذر تحميل العروض');
    }
  }
}

final storeRepositoryProvider = Provider<StoreRepositoryImpl>((ref) {
  return StoreRepositoryImpl(ref.watch(apiClientProvider));
});

final storesFutureProvider = FutureProvider<List<StoreModel>>((ref) {
  return ref.watch(storeRepositoryProvider).getAllStores();
});

final categoriesFutureProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(storeRepositoryProvider).getAllCategories();
});

final todayOffersFutureProvider = FutureProvider<List<OfferModel>>((ref) {
  return ref.watch(storeRepositoryProvider).getTodayOffers();
});
