import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/authentication_service.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final AuthenticationService _authService = AuthenticationService.instance;
  
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;

  Future<void> loadAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
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
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.registerUser(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        role: role,
        department: department,
      );
      await loadAllUsers();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateUser(user);
      await loadAllUsers();
      
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

  Future<void> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteUser(userId);
      await loadAllUsers();
      
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

