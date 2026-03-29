import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:dio/dio.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/error_handler.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  AppError? _error;
  bool _mounted = true;

  // Pagination state
  int _currentPage = 1;
  int _totalCount = 0;
  int _pageSize = 20;
  String? _currentSearch;
  bool _hasNextPage = false;

  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  AppError? get error => _error;
  String? get errorMessage => _error?.messageEn; // For backward compatibility
  bool get mounted => _mounted;
  bool get hasNextPage => _hasNextPage;
  bool get canLoadMore => _hasNextPage && !_isLoadingMore;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadCustomers({String? search, bool refresh = false}) async {
    print('DEBUG CustomerProvider: loadCustomers called with search: $search, refresh: $refresh');

    if (refresh) {
      _currentPage = 1;
      _customers = [];
    } else {
      _currentPage = 1;
    }
    _currentSearch = search;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('DEBUG CustomerProvider: Calling customer service...');
      final response = await _customerService.getCustomers(
        search: search,
        page: _currentPage,
        pageSize: _pageSize,
      );

      print('DEBUG CustomerProvider: Got ${response.customers.length} customers, total: ${response.totalCount}');
      _customers = response.customers;
      _totalCount = response.totalCount;
      _hasNextPage = response.hasNext;

      if (_mounted) {
        _isLoading = false;
        _error = null;
        print('DEBUG CustomerProvider: Notifying listeners with ${_customers.length} customers');
        notifyListeners();
      }
    } catch (e) {
      print('DEBUG CustomerProvider: Error loading customers: $e');
      if (_mounted) {
        _isLoading = false;
        _error = e is DioException
            ? ErrorHandler.parseError(e)
            : AppError.fromException(e as Exception);
        print('DEBUG CustomerProvider: Error set to $_error');
        notifyListeners();
      }
    }
  }

  Future<void> loadMoreCustomers() async {
    if (!_hasNextPage || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      final response = await _customerService.getCustomers(
        search: _currentSearch,
        page: _currentPage,
        pageSize: _pageSize,
      );

      _customers.addAll(response.customers);
      _hasNextPage = response.hasNext;

      if (_mounted) {
        _isLoadingMore = false;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      // Revert page number on error
      _currentPage--;
      if (_mounted) {
        _isLoadingMore = false;
        _error = e is DioException
            ? ErrorHandler.parseError(e)
            : AppError.fromException(e as Exception);
        notifyListeners();
      }
    }
  }

  Future<void> loadCustomer(int id) async {
    try {
      _selectedCustomer = await _customerService.getCustomer(id);

      if (_mounted) {
        _isLoading = false;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      if (_mounted) {
        _isLoading = false;
        _error = e is DioException
            ? ErrorHandler.parseError(e)
            : AppError.fromException(e as Exception);
        notifyListeners();
      }
    }
  }

  void selectCustomer(Customer customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  String toString() {
    return 'CustomerProvider(customers: ${_customers.length}, isLoading: $_isLoading, error: $_error)';
  }
}
