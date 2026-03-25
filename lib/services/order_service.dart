import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/order.dart';
import '../config/app_config.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<List<Order>> getOrdersForCustomer(int customerId) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConfig.apiPath}/customers/$customerId/orders/',
      );

      final List<dynamic> ordersData = response.data['orders'];
      return ordersData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
}
