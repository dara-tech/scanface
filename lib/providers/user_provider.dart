import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/authentication_service.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final AuthenticationService _authService = AuthenticationService.instance;
  final ApiService _apiService = ApiService();
  
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;

  Future<void> loadAllUsers({BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from API first (if context provided for auth token)
      if (context != null) {
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.token != null) {
            _apiService.setToken(authProvider.token!);
            
            final response = await _apiService.getAllUsers();
            if (response.statusCode == 200) {
              final usersData = response.data['users'] as List?;
              if (usersData != null) {
                _users = usersData.map((userData) => User.fromMap(userData)).toList();
                notifyListeners();
                _isLoading = false;
                notifyListeners();
                return; // Success, exit early
              }
            }
          }
        } catch (e) {
          print('Error loading users from API: $e');
          // Fall back to local database
        }
      }
      
      // Fallback to local database
      _users = await _databaseService.getAllUsers();
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    String? phoneNumber,
    required String role,
    String? department,
    required BuildContext context, // Need context to get auth token
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get auth token from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _apiService.setToken(authProvider.token!);
      } else {
        throw Exception('Authentication required. Please login again.');
      }

      // Generate a temporary password for the user
      // User will need to reset it on first login
      final tempPassword = _generateTempPassword();
      
      // Create user via API (requires password)
      final response = await _apiService.register(
        name: name,
        email: email,
        password: tempPassword,
        phoneNumber: phoneNumber,
        role: role,
      );

      if (response.statusCode == 201) {
        // User created successfully
        // Reload users from API
        await loadAllUsers(context: context);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create user');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate a temporary password
  String _generateTempPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      12, (_) => chars.codeUnitAt(random.nextInt(chars.length))
    ));
  }

  Future<void> updateUser(User user, {BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try API first if context provided
      if (context != null) {
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.token != null) {
            _apiService.setToken(authProvider.token!);
            
            await _apiService.updateUser(
              userId: user.id,
              name: user.name,
              email: user.email,
              phoneNumber: user.phoneNumber,
              role: user.role,
              department: user.department,
              isActive: user.isActive,
            );
            
            // Reload users
            await loadAllUsers(context: context);
            
            // Update selected user if it's the same
            if (_selectedUser?.id == user.id) {
              _selectedUser = user;
            }
            return; // Success, exit early
          }
        } catch (e) {
          print('Error updating user via API: $e');
          // Fall back to local database
        }
      }
      
      // Fallback to local database
      await _databaseService.updateUser(user);
      await loadAllUsers(context: context);
      
      // Update selected user if it's the same
      if (_selectedUser?.id == user.id) {
        _selectedUser = user;
      }
    } catch (e) {
      print('Error updating user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId, {BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try API first if context provided
      if (context != null) {
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.token != null) {
            _apiService.setToken(authProvider.token!);
            
            await _apiService.deleteUser(userId);
            
            // Reload users
            await loadAllUsers(context: context);
            
            if (_selectedUser?.id == userId) {
              _selectedUser = null;
            }
            return; // Success, exit early
          }
        } catch (e) {
          print('Error deleting user via API: $e');
          // Fall back to local database
        }
      }
      
      // Fallback to local database
      await _databaseService.deleteUser(userId);
      await loadAllUsers(context: context);
      
      if (_selectedUser?.id == userId) {
        _selectedUser = null;
      }
    } catch (e) {
      print('Error deleting user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedUser(User? user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearData() {
    _users = [];
    _selectedUser = null;
    notifyListeners();
  }
}

