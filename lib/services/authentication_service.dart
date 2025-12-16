import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class AuthenticationService {
  final DatabaseService _databaseService = DatabaseService.instance;
  final _uuid = const Uuid();
  static final AuthenticationService instance = AuthenticationService._init();
  
  AuthenticationService._init();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  }

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefCurrentUserId);
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;
    return await _databaseService.getUserById(userId);
  }

  // Login
  Future<User> login(String email, String password) async {
    // Simple authentication - in production, use proper password hashing
    final user = await _databaseService.getUserByEmail(email);
    
    if (user == null) {
      throw Exception('User not found');
    }

    if (!user.isActive) {
      throw Exception('User account is inactive');
    }

    // For demo purposes, we'll use email as password
    // In production, implement proper password hashing (bcrypt, etc.)
    // For now, we'll skip password check for MVP

    // Save login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await prefs.setString(AppConstants.prefCurrentUserId, user.id);
    await prefs.setString(AppConstants.prefCurrentUserRole, user.role);

    return user;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, false);
    await prefs.remove(AppConstants.prefCurrentUserId);
    await prefs.remove(AppConstants.prefCurrentUserRole);
  }

  // Register new user (admin only)
  Future<User> registerUser({
    required String name,
    required String email,
    String? phoneNumber,
    required String role,
    String? department,
  }) async {
    // Check if email already exists
    final existingUser = await _databaseService.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('User with this email already exists');
    }

    final user = User(
      id: _uuid.v4(),
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      department: department,
      createdAt: DateTime.now(),
      isActive: true,
    );

    await _databaseService.insertUser(user);
    return user;
  }

  // Create admin user (first time setup)
  Future<User> createAdminUser({
    required String name,
    required String email,
    String? phoneNumber,
  }) async {
    return await registerUser(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: AppConstants.roleAdmin,
    );
  }

  // Check if admin exists
  Future<bool> adminExists() async {
    final users = await _databaseService.getAllUsers();
    return users.any((user) => user.role == AppConstants.roleAdmin);
  }
}

