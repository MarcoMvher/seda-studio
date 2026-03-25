import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _mounted = true;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadOrdersForCustomer(int customerId) async {
    print('DEBUG: Loading orders for customer $customerId');

    // Don't set loading state initially to avoid build-phase issues

    try {
      final orders = await _orderService.getOrdersForCustomer(customerId);
      print('DEBUG: Loaded ${orders.length} orders');

      if (_mounted) {
        _orders = orders;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      print('DEBUG: Error loading orders: $e');
      if (_mounted) {
        _isLoading = false;
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
