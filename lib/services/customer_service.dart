import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/customer.dart';
import '../config/app_config.dart';
import '../utils/error_handler.dart';

class CustomerResponse {
  final List<Customer> customers;
  final int totalCount;
  final String? nextUrl;
  final String? previousUrl;

  CustomerResponse({
    required this.customers,
    required this.totalCount,
    this.nextUrl,
    this.previousUrl,
  });

  bool get hasNext => nextUrl != null;
  bool get hasPrevious => previousUrl != null;

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      customers: (json['results'] as List)
          .map((item) => Customer.fromJson(item))
          .toList(),
      totalCount: json['count'] as int,
      nextUrl: json['next'] as String?,
      previousUrl: json['previous'] as String?,
    );
  }
}

class CustomerService {
  final ApiService _apiService = ApiService();

  Future<CustomerResponse> getCustomers({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('DEBUG: getCustomers called with search: $search, page: $page, pageSize: $pageSize');
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      print('DEBUG: Making API request to ${AppConfig.apiPath}/customers/');
      final response = await _apiService.dio.get(
        '${AppConfig.apiPath}/customers/',
        queryParameters: queryParams,
      );

      print('DEBUG: Got response: ${response.data}');
      final customerResponse = CustomerResponse.fromJson(response.data);
      print('DEBUG: Parsed ${customerResponse.customers.length} customers out of ${customerResponse.totalCount} total');
      return customerResponse;
    } on DioException catch (e) {
      print('DEBUG: DioException in getCustomers: $e');
      throw ErrorHandler.parseError(e);
    } catch (e) {
      print('DEBUG: Error in getCustomers: $e');
      throw ErrorHandler.parseError(e);
    }
  }

  Future<Customer> getCustomer(int id) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConfig.apiPath}/customers/$id/',
      );
      return Customer.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }
}
