import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IOrderRepository {
  Future<List<OrderModel>> getMyOrders();
  Future<OrderModel> getOrderDetails(String id);
  Future<OrderModel> createOrder(Map<String, dynamic> data);
}

class OrderRepositoryImpl implements IOrderRepository {
  final ApiClient _apiClient;

  OrderRepositoryImpl(this._apiClient);

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _apiClient.dio.get('/orders/my');
      final List data = response.data is List ? response.data : [];
      return data.map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'تعذر تحميل الطلبات');
    }
  }

  @override
  Future<OrderModel> getOrderDetails(String id) async {
    try {
      final response = await _apiClient.dio.get('/orders/$id');
      return OrderModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'تعذر تحميل تفاصيل الطلب');
    }
  }

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/orders/custom-request', data: data);
      return OrderModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: 'فشل في إنشاء الطلب');
    }
  }
}

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(apiClientProvider));
});
