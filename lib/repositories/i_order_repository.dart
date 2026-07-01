import '../models/order_model.dart';
import '../models/category_model.dart';

abstract class IOrderRepository {
  Future<List<OrderModel>> getOrders();
  Future<List<CategoryModel>> getCategories();
  Future<OrderModel> getOrderById(String id);
  Future<void> createOrder(OrderModel order);
}
