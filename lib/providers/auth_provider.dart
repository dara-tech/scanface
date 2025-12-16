import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get token => _token;
  SocketService get socketService => _socketService;

  // Load auth state from storage
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedUserId = prefs.getString(AppConstants.prefCurrentUserId);

      if (savedToken != null && savedUserId != null) {
        _token = savedToken;
        _apiService.setToken(savedToken);
        
        // Verify token by getting current user
        try {
          final response = await _apiService.getCurrentUser();
          if (response.statusCode == 200) {
            _currentUser = User.fromMap(response.data['user']);
            
            // Connect WebSocket
            _connectWebSocket();
          }
        } catch (e) {
          // Token invalid, clear storage
          await _clearAuth();
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with backend API
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      if (response.statusCode == 200) {
        _token = response.data['token'];
        _currentUser = User.fromMap(response.data['user']);
        
        // Save to storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString(AppConstants.prefCurrentUserId, _currentUser!.id);
        await prefs.setBool(AppConstants.prefIsLoggedIn, true);
        await prefs.setString(AppConstants.prefCurrentUserRole, _currentUser!.role);
        
        // Set token for API calls
        _apiService.setToken(_token!);
        
        // Connect WebSocket
        _connectWebSocket();
      } else {
        throw Exception(response.data['error'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      // Extract error message from DioException
      String errorMessage = _apiService.getErrorMessage(e);
      
      // Provide more helpful message for authentication errors
      if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email or password. Please check your credentials or register a new account.';
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Unable to connect to server. Please check your network connection.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String role = 'employee',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        role: role,
      );
      
      if (response.statusCode == 201) {
        _token = response.data['token'];
        _currentUser = User.fromMap(response.data['user']);
        
        // Save to storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString(AppConstants.prefCurrentUserId, _currentUser!.id);
        await prefs.setBool(AppConstants.prefIsLoggedIn, true);
        await prefs.setString(AppConstants.prefCurrentUserRole, _currentUser!.role);
        
        // Set token for API calls
        _apiService.setToken(_token!);
        
        // Connect WebSocket
        _connectWebSocket();
      } else {
        throw Exception(response.data['error'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      // Extract error message from DioException
      String errorMessage = _apiService.getErrorMessage(e);
      
      // Provide more helpful message for registration errors
      if (e.response?.statusCode == 400) {
        final serverError = e.response?.data['error'] ?? '';
        if (serverError.toLowerCase().contains('email') && 
            serverError.toLowerCase().contains('exist')) {
          errorMessage = 'This email is already registered. Please login instead.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Unable to connect to server. Please check your network connection.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Connect WebSocket after login
  void _connectWebSocket() {
    if (_token != null && _currentUser != null) {
      _socketService.connect(
        '', // Empty string will use ApiConfig.socketUrl
        _token!,
        _currentUser!.id,
        organizationId: _currentUser!.organizationId,
      );
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Disconnect WebSocket
      _socketService.disconnect();
      
      // Call logout API (optional)
      try {
        await _apiService.logout();
      } catch (e) {
        print('Logout API error: $e');
      }
      
      // Clear local state
      await _clearAuth();
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear authentication data
  Future<void> _clearAuth() async {
    _currentUser = null;
    _token = null;
    _apiService.clearToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove(AppConstants.prefCurrentUserId);
    await prefs.remove(AppConstants.prefIsLoggedIn);
    await prefs.remove(AppConstants.prefCurrentUserRole);
  }
}
