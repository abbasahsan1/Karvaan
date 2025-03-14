import 'dart:developer';
import 'package:karvaan/models/user_model.dart';
import 'package:karvaan/repositories/user_repository.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karvaan/utils/password_hasher.dart';

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
      
      // Hash password before storing
      final hashedPassword = await PasswordHasher.hashPassword(password);
      
      // Create new user with hashed password
      final newUser = UserModel(
        email: email,
        password: hashedPassword,
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
      
      bool passwordValid;
      
      // Check if password is using the old system (plain text) or new (hashed)
      if (PasswordHasher.isPasswordHashed(user.password)) {
        // Verify using the hashing system
        passwordValid = await PasswordHasher.verifyPassword(password, user.password);
      } else {
        // Legacy plain text comparison - should migrate this user's password
        passwordValid = user.password == password;
        
        // Migrate to hashed password if it's still plain text
        if (passwordValid) {
          await _migrateToHashedPassword(user, password);
        }
      }
      
      if (!passwordValid) {
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

  // Migrate a user from plain text to hashed password
  Future<void> _migrateToHashedPassword(UserModel user, String plainTextPassword) async {
    try {
      final hashedPassword = await PasswordHasher.hashPassword(plainTextPassword);
      final updatedUser = user.copyWith(password: hashedPassword);
      await _userRepository.updateUser(updatedUser);
      log('Migrated user ${user.id} to hashed password');
    } catch (e) {
      log('Error migrating user to hashed password: $e');
      // Don't rethrow - this shouldn't break the login flow
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
      
      // Verify current password
      bool passwordValid;
      
      if (PasswordHasher.isPasswordHashed(currentUser.password)) {
        passwordValid = await PasswordHasher.verifyPassword(currentPassword, currentUser.password);
      } else {
        // Legacy plain text comparison
        passwordValid = currentUser.password == currentPassword;
      }
      
      if (!passwordValid) {
        throw Exception('Current password is incorrect');
      }
      
      // Hash the new password
      final hashedNewPassword = await PasswordHasher.hashPassword(newPassword);
      
      final updatedUser = currentUser.copyWith(
        password: hashedNewPassword,
      );
      
      await _userRepository.updateUser(updatedUser);
    } catch (e) {
      log('Error changing password: $e');
      rethrow;
    }
  }
  
  // Reset password for current user
  Future<void> resetPassword(String newPassword) async {
    try {
      final userId = await _userRepository.getCurrentUserId();
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      final currentUser = await _userRepository.getUserById(userId);
      
      if (currentUser == null) {
        throw Exception('User not found');
      }
      
      // Hash the new password
      final hashedNewPassword = await PasswordHasher.hashPassword(newPassword);
      
      final updatedUser = currentUser.copyWith(
        password: hashedNewPassword,
      );
      
      await _userRepository.updateUser(updatedUser);
    } catch (e) {
      log('Error resetting password: $e');
      rethrow;
    }
  }
  
  // Reset password by email (for forgot password flow)
  Future<void> resetPasswordByEmail(String email, String newPassword) async {
    try {
      // Fetch user by email
      final user = await _userRepository.getUserByEmail(email);
      
      if (user == null) {
        throw Exception('User not found');
      }
      
      // Hash the new password
      final hashedNewPassword = await PasswordHasher.hashPassword(newPassword);
      
      final updatedUser = user.copyWith(
        password: hashedNewPassword,
      );
      
      await _userRepository.updateUser(updatedUser);
    } catch (e) {
      log('Error resetting password by email: $e');
      rethrow;
    }
  }
}
