import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/network/api_client.dart';
import 'package:wassali/models/service_model.dart';
import 'dart:developer';

class ServiceRepository {
  final ApiClient _apiClient;

  ServiceRepository(this._apiClient);

  Future<List<ServiceCategoryModel>> getCategories() async {
    final response = await _apiClient.dio.get('/services/categories');
    final data = response.data as List;
    return data.map((e) => ServiceCategoryModel.fromJson(e)).toList();
  }

  Future<List<ServiceModel>> fetchServices({
    String? categoryId,
    String? city,
    String? search,
    int page = 1,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page};
    if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.dio.get('/services', queryParameters: queryParams);
    final data = response.data['data'] as List;
    return data.map((item) => ServiceModel.fromJson(item)).toList();
  }

  Future<ServiceModel> getServiceDetails(String id) async {
    final response = await _apiClient.dio.get('/services/$id');
    return ServiceModel.fromJson(response.data);
  }

  Future<List<ServiceModel>> getMyServices() async {
    final response = await _apiClient.dio.get('/services/my');
    final data = response.data as List;
    return data.map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<void> toggleFavorite(String serviceId) async {
    try {
      await _apiClient.dio.post('/services/$serviceId/favorite');
    } catch (e) {
      log('Failed to toggle favorite: $e');
      rethrow;
    }
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(ref.watch(apiClientProvider));
});
