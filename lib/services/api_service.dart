import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';

class ApiService {
  late final Dio _dio;
  late final _StorageWrapper _storage;

  ApiService() {
    // Initialize storage based on platform
    _storage = _StorageWrapper();

    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add JWT token to header
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('API Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('API Response: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('API Error: ${error.message} - ${error.requestOptions.uri}');
        print('Error Response: ${error.response?.statusCode}');
      onError: (error, handler) async {
        // Try to refresh token on 401
        if (error.response?.statusCode == 401) {
          try {
            await _refreshToken();
            // Retry the original request
            final token = await _storage.read(key: 'access_token');
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            // Refresh failed, clear tokens and let the error propagate
            print('DEBUG: Token refresh failed, clearing tokens');
            await _storage.delete(key: 'access_token');
            await _storage.delete(key: 'refresh_token');
          }
        }
        return handler.next(error);
      },
    ));

    // Add logger in debug mode
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }

  Dio get dio => _dio;

  Future<void> _refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _dio.post(
      '${AppConfig.authPath}/refresh/',
      data: {'refresh': refreshToken},
    );

    final accessToken = response.data['access'];
    await _storage.write(key: 'access_token', value: accessToken);

    // Update refresh token if rotated
    if (response.data['refresh'] != null) {
      await _storage.write(key: 'refresh_token', value: response.data['refresh']);
    }
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}

// Wrapper class for web-compatible storage
class _StorageWrapper {
  late final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;
  bool _prefsInitialized = false;

  _StorageWrapper() {
    if (!kIsWeb) {
      // Use FlutterSecureStorage for mobile
      _secureStorage = const FlutterSecureStorage();
    }
  }

  Future<void> _initPrefs() async {
    if (!_prefsInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _prefsInitialized = true;
    }
  }

  Future<String?> read({required String key}) async {
    if (kIsWeb) {
      await _initPrefs();
      return _prefs?.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<void> delete({required String key}) async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs?.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }
}
