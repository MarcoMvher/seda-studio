import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/order.dart';
import '../config/app_config.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getOrdersForCustomer(int customerId) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConfig.apiPath}/customers/$customerId/orders/',
      );

      final List<dynamic> ordersData = response.data['orders'];
      final List<dynamic> completedOrdersData = response.data['completed_orders'] ?? [];

      final orders = ordersData.map((json) => Order.fromJson(json)).toList();
      final completedOrderNumbers = completedOrdersData.map((id) => id as int).toSet();

      return {
        'orders': orders,
        'completed_orders': completedOrderNumbers,
      };
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
}
