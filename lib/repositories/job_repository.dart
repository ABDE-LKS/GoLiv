import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/network/api_client.dart';
import 'package:wassali/models/job_model.dart';
import 'dart:developer';

class JobRepository {
  final ApiClient _apiClient;

  JobRepository(this._apiClient);

  Future<List<JobCategoryModel>> getCategories() async {
    final response = await _apiClient.dio.get('/jobs/categories');
    final data = response.data as List;
    return data.map((e) => JobCategoryModel.fromJson(e)).toList();
  }

  Future<List<JobModel>> fetchJobs({
    String? categoryId,
    String? location,
    String? search,
    String? employmentType,
    int page = 1,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page};
    if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;
    if (location != null && location.isNotEmpty) queryParams['location'] = location;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (employmentType != null && employmentType.isNotEmpty) queryParams['employmentType'] = employmentType;

    final response = await _apiClient.dio.get('/jobs', queryParameters: queryParams);
    final data = response.data['data'] as List;
    return data.map((item) => JobModel.fromJson(item)).toList();
  }

  Future<JobModel> getJobDetails(String id) async {
    final response = await _apiClient.dio.get('/jobs/$id');
    return JobModel.fromJson(response.data);
  }

  Future<List<JobModel>> getMyJobs() async {
    final response = await _apiClient.dio.get('/jobs/my');
    final data = response.data as List;
    return data.map((e) => JobModel.fromJson(e)).toList();
  }

  Future<void> toggleSave(String jobId) async {
    try {
      await _apiClient.dio.post('/jobs/$jobId/save');
    } catch (e) {
      log('Failed to save job: $e');
      rethrow;
    }
  }
}

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(ref.watch(apiClientProvider));
});
