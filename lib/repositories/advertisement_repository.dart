import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/network/api_client.dart';
import 'package:wassali/models/advertisement_model.dart';

class AdvertisementRepository {
  final ApiClient _apiClient;

  AdvertisementRepository(this._apiClient);

  Future<List<AdvertisementModel>> getAdvertisements({
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? status,
    String? sellerId,
  }) async {
    final response = await _apiClient.dio.get('/advertisements', queryParameters: {
      if (categoryId != null) 'categoryId': categoryId,
      if (search != null) 'search': search,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (sellerId != null) 'sellerId': sellerId,
      if (status != null) 'status': status,
    });

    final List data = response.data;
    return data.map((e) => AdvertisementModel.fromJson(e)).toList();
  }

  Future<AdvertisementModel> getAdvertisement(String id) async {
    final response = await _apiClient.dio.get('/advertisements/$id');
    return AdvertisementModel.fromJson(response.data);
  }

  Future<AdvertisementModel> createAdvertisement(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post('/advertisements', data: data);
    return AdvertisementModel.fromJson(response.data);
  }

  Future<void> toggleFavorite(String adId) async {
    await _apiClient.dio.post('/favorites/toggle/$adId');
  }

  Future<void> updateAdvertisement(String id, Map<String, dynamic> data) async {
    await _apiClient.dio.patch('/advertisements/$id', data: data);
  }

  Future<void> deleteAdvertisement(String id) async {
    await _apiClient.dio.delete('/advertisements/$id');
  }

  Future<List<AdvertisementModel>> getFavorites() async {
    final response = await _apiClient.dio.get('/favorites');
    final List data = response.data;
    return data.map((e) => AdvertisementModel.fromJson(e)).toList();
  }
}

final advertisementRepositoryProvider = Provider<AdvertisementRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdvertisementRepository(apiClient);
});

final advertisementsProvider = FutureProvider.family<List<AdvertisementModel>, Map<String, dynamic>?>((ref, params) {
  final repository = ref.watch(advertisementRepositoryProvider);
  return repository.getAdvertisements(
    categoryId: params?['categoryId'],
    search: params?['search'],
    minPrice: params?['minPrice'],
    maxPrice: params?['maxPrice'],
  );
});
