import 'package:dio/dio.dart';
import 'api_service.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../utils/error_handler.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/api/auth/login/',
        data: {
          'username': username,
          'password': password,
        },
      );

      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];

      // Store tokens
      await _apiService.setTokens(accessToken, refreshToken);

      // Fetch user details
      final userResponse = await _apiService.dio.get('/auth/users/me/');
      final user = User.fromJson(userResponse.data);

      return {
        'success': true,
        'user': user,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['detail'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred',
      };
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.dio.post(
        '/api/auth/change-password/',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Password changed successfully',
      };
    } on DioException catch (e) {
      final error = ErrorHandler.parseError(e);
      return {
        'success': false,
        'error': error.messageAr,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred',
      };
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _apiService.dio.options.headers['refresh_token'];
      await _apiService.dio.post(
        '/api/auth/logout/',
        data: {'refresh': refreshToken},
      );
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _apiService.clearTokens();
    }
  }
}
