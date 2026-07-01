import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationRepositoryImpl implements INotificationRepository {
  final ApiClient _apiClient;

  NotificationRepositoryImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get('/notifications');
      final List data = response.data;
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'تعذر تحميل التنبيهات');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'فشل في تحديث التنبيه');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.post('/notifications/mark-all-read');
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'فشل في تحديث التنبيهات');
    }
  }
}

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(apiClientProvider));
});
