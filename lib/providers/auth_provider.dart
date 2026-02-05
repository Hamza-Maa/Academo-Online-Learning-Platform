import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      await _authService.initialize();
    } catch (e) {
      debugPrint('Error initializing AuthProvider: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    required bool termsAccepted,
    required bool privacyAccepted,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        termsAccepted: termsAccepted,
        privacyAccepted: privacyAccepted,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email: email, newPassword: newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? photoUrl,
    String? language,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateProfile(
        name: name,
        photoUrl: photoUrl,
        language: language,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.deleteAccount();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> addPurchasedCourse(String courseId) async {
    await _authService.addPurchasedCourse(courseId);
    notifyListeners();
  }

  Future<void> toggleFavorite(String courseId) async {
    if (currentUser == null) return;

    if (currentUser!.favoriteCourses.contains(courseId)) {
      await _authService.removeFavoriteCourse(courseId);
    } else {
      await _authService.addFavoriteCourse(courseId);
    }
    notifyListeners();
  }

  bool isFavorite(String courseId) {
    return currentUser?.favoriteCourses.contains(courseId) ?? false;
  }

  bool hasPurchased(String courseId) {
    return currentUser?.purchasedCourses.contains(courseId) ?? false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
