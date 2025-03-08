import 'package:flutter/foundation.dart';
import 'package:karvaan/models/user_model.dart';
import 'package:karvaan/services/auth_service.dart';

/// Provider to manage and distribute current user data
class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  final AuthService _authService = AuthService.instance;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  String get displayName => _currentUser?.name ?? 'Guest';

  // Initialize user data
  Future<void> initialize() async {
    if (_currentUser != null) return;
    await refreshUser();
  }

  // Refresh user data from server
  Future<void> refreshUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      _currentUser = user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register user
  Future<bool> register(String email, String password, {String? name, String? phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(email, password, name: name, phone: phone);
      // Don't set currentUser after registration - redirect to login instead
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(String name, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(name, phone);
      _currentUser = updatedUser;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
