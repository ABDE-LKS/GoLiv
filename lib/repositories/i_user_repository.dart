import '../models/favorite_template_model.dart';
import '../models/notification_model.dart';

abstract class IUserRepository {
  Future<List<FavoriteTemplateModel>> getFavorites();
  Future<List<NotificationModel>> getNotifications();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
}
