import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../utils/error_handler.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  AppError? _error;
  bool _mounted = true;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  String? get errorMessage => _error?.messageAr; // For backward compatibility
  bool get mounted => _mounted;

  // Check if current user is a branch user (staff member with view-only access)
  bool get isBranchUser => _user?.isBranchUser ?? false;

  // Check if current user is a delegate (regular user)
  bool get isDelegate => _user?.isDelegate ?? false;

  // Check if current user is admin (superuser)
  bool get isAdmin => _user?.isSuperuser ?? false;

  // Check if app is in read-only mode (for branch users)
  bool get isReadOnly => isBranchUser;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadToken() async {
    try {
      final isAuth = await _apiService.isAuthenticated();
      _isAuthenticated = isAuth;

      // Fetch user data if authenticated
      if (_isAuthenticated) {
        await _fetchUserData();
      }

      Future.microtask(() {
        if (_mounted) {
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      Future.microtask(() {
        if (_mounted) {
          _isLoading = false;
          notifyListeners();
        }
      });
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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

      await _apiService.setTokens(accessToken, refreshToken);

      // Fetch user data to get actual role from backend
      await _fetchUserData();

      _isAuthenticated = true;
      _isLoading = false;
      _error = null;

      Future.microtask(() {
        if (_mounted) {
          notifyListeners();
        }
      });

      return true;
    } catch (e) {
      Future.microtask(() {
        if (_mounted) {
          _error = ErrorHandler.parseError(e);
          _isAuthenticated = false;
          _isLoading = false;
          notifyListeners();
        }
      });

      return false;
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await _apiService.dio.get('/api/auth/me/');
      _user = User.fromJson(response.data);
    } catch (e) {
      // If we can't fetch user data, continue without it
      print('Error fetching user data: $e');
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.changePassword(oldPassword, newPassword);

      _isLoading = false;
      _error = null;

      Future.microtask(() {
        if (_mounted) {
          notifyListeners();
        }
      });

      return response['success'] == true;
    } catch (e) {
      Future.microtask(() {
        if (_mounted) {
          _error = ErrorHandler.parseError(e);
          _isLoading = false;
          notifyListeners();
        }
      });

      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.clearTokens();
      _isAuthenticated = false;
      _user = null;
    } catch (e) {
      _error = ErrorHandler.parseError(e);
    } finally {
      Future.microtask(() {
        if (_mounted) {
          _isLoading = false;
          notifyListeners();
        }
      });
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
