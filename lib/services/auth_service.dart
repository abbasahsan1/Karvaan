import 'dart:developer';
import 'package:karvaan/models/user_model.dart';
import 'package:karvaan/repositories/user_repository.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final UserRepository _userRepository = UserRepository.instance;
  
  // Singleton pattern
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  static AuthService get instance => _instance;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final userId = await _userRepository.getCurrentUserId();
    return userId != null;
  }

  // Register new user
  Future<UserModel> register(String email, String password, {String? name, String? phone}) async {
    try {
      // Check if user with this email already exists
      final existingUser = await _userRepository.getUserByEmail(email);
      
      if (existingUser != null) {
        throw Exception('Email is already registered');
      }
      
      // Create new user
      // In a real app, you'd hash the password before storing it
      final newUser = UserModel(
        email: email,
        password: password, // Should be hashed in a real app
        name: name,
        phone: phone,
      );
      
      return await _userRepository.createUser(newUser);
    } catch (e) {
      log('Error registering user: $e');
      rethrow;
    }
  }

  // Login user
  Future<UserModel> login(String email, String password) async {
    try {
      // Fetch user by email
      final user = await _userRepository.getUserByEmail(email);
      
      if (user == null) {
        throw Exception('User not found');
      }
      
      // In a real app, you'd compare hash of the password
      if (user.password != password) {
        throw Exception('Invalid password');
      }
      
      // Save user ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id!.toHexString());
      
      return user;
    } catch (e) {
      log('Error logging in: $e');
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _userRepository.clearCurrentUserId();
    } catch (e) {
      log('Error logging out: $e');
      rethrow;
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await _userRepository.getCurrentUserId();
      
      if (userId == null) {
        return null;
      }
      
      return await _userRepository.getUserById(userId);
    } catch (e) {
      log('Error getting current user: $e');
      return null;
    }
  }

  // Update user profile
  Future<UserModel> updateProfile(String name, String phone) async {
    try {
      final userId = await _userRepository.getCurrentUserId();
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      final currentUser = await _userRepository.getUserById(userId);
      
      if (currentUser == null) {
        throw Exception('User not found');
      }
      
      final updatedUser = currentUser.copyWith(
        name: name,
        phone: phone,
      );
      
      return await _userRepository.updateUser(updatedUser);
    } catch (e) {
      log('Error updating profile: $e');
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final userId = await _userRepository.getCurrentUserId();
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      final currentUser = await _userRepository.getUserById(userId);
      
      if (currentUser == null) {
        throw Exception('User not found');
      }
      
      // In a real app, you'd compare hash of the password
      if (currentUser.password != currentPassword) {
        throw Exception('Current password is incorrect');
      }
      
      // In a real app, you'd hash the new password
      final updatedUser = currentUser.copyWith(
        password: newPassword,
      );
      
      await _userRepository.updateUser(updatedUser);
    } catch (e) {
      log('Error changing password: $e');
      rethrow;
    }
  }
}
