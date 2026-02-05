import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const _currentUserKey = 'current_user';
  static const _usersKey = 'users';
  static const _rememberMeKey = 'remember_me';

  User? _currentUser;
  
  // Fallback storage when SharedPreferences fails (e.g., on web in Dreamflow)
  static final Map<String, String> _memoryStorage = {};
  static bool _useMemoryStorage = false;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    try {
      debugPrint('🔧 AuthService: Starting initialization...');
      final prefs = await SharedPreferences.getInstance();
      debugPrint('✅ AuthService: SharedPreferences instance obtained');
      
      // Check if "Remember me" was enabled
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
      debugPrint('🔐 AuthService: Remember me: $rememberMe');
      
      if (rememberMe) {
        final userJson = prefs.getString(_currentUserKey);
        debugPrint('📖 AuthService: Current user data: ${userJson ?? "null"}');
        
        if (userJson != null) {
          try {
            _currentUser = User.fromJson(jsonDecode(userJson));
            debugPrint('✅ AuthService: User auto-logged in - ${_currentUser?.email}');
          } catch (e) {
            debugPrint('❌ AuthService: Error parsing user data: $e');
            await prefs.remove(_currentUserKey);
          }
        } else {
          debugPrint('ℹ️ AuthService: No saved user found');
        }
      } else {
        debugPrint('ℹ️ AuthService: Remember me disabled, skipping auto-login');
      }
    } catch (e) {
      debugPrint('⚠️ AuthService: SharedPreferences failed, using memory storage: $e');
      _useMemoryStorage = true;
      
      // Try to load from memory storage
      final rememberMe = _memoryStorage[_rememberMeKey] == 'true';
      debugPrint('🔐 AuthService: Remember me (memory): $rememberMe');
      
      if (rememberMe) {
        final userJson = _memoryStorage[_currentUserKey];
        if (userJson != null) {
          try {
            _currentUser = User.fromJson(jsonDecode(userJson));
            debugPrint('✅ AuthService: User auto-logged in from memory - ${_currentUser?.email}');
          } catch (e) {
            debugPrint('❌ AuthService: Error parsing user data from memory: $e');
            _memoryStorage.remove(_currentUserKey);
          }
        }
      }
    }
  }
  
  Future<String?> _getString(String key) async {
    if (_useMemoryStorage) {
      return _memoryStorage[key];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      debugPrint('⚠️ Falling back to memory storage for key: $key');
      _useMemoryStorage = true;
      return _memoryStorage[key];
    }
  }
  
  Future<void> _setString(String key, String value) async {
    if (_useMemoryStorage) {
      _memoryStorage[key] = value;
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('⚠️ Falling back to memory storage for key: $key');
      _useMemoryStorage = true;
      _memoryStorage[key] = value;
    }
  }
  
  Future<void> _remove(String key) async {
    if (_useMemoryStorage) {
      _memoryStorage.remove(key);
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      debugPrint('⚠️ Falling back to memory storage for key: $key');
      _useMemoryStorage = true;
      _memoryStorage.remove(key);
    }
  }
  
  Future<void> _setBool(String key, bool value) async {
    if (_useMemoryStorage) {
      _memoryStorage[key] = value.toString();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('⚠️ Falling back to memory storage for key: $key');
      _useMemoryStorage = true;
      _memoryStorage[key] = value.toString();
    }
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    required bool termsAccepted,
    required bool privacyAccepted,
  }) async {
    try {
      debugPrint('🔐 AuthService: Starting signup for $email');
      
      // Check if email already exists
      final users = await _getAllUsers();
      debugPrint('📋 AuthService: Checking ${users.length} existing users');
      
      if (users.any((u) => u.email == email)) {
        debugPrint('❌ AuthService: Email $email already exists');
        throw Exception('Email already exists');
      }

      final now = DateTime.now();
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        phone: phone,
        name: name,
        termsAccepted: termsAccepted,
        privacyAccepted: privacyAccepted,
        createdAt: now,
        updatedAt: now,
      );
      debugPrint('👤 AuthService: Created new user object');

      // Save user to users list
      users.add(user);
      await _saveAllUsers(users);
      debugPrint('✅ AuthService: Saved user to users list');

      // Save password separately (in production, use proper encryption)
      final passwords = await _getPasswords();
      passwords[email] = password;
      await _savePasswords(passwords);
      debugPrint('✅ AuthService: Saved password');

      // Set as current user and enable "Remember me" by default
      _currentUser = user;
      await _setString(_currentUserKey, jsonEncode(user.toJson()));
      await _setBool(_rememberMeKey, true);
      debugPrint('✅ AuthService: Set as current user with Remember me enabled - Signup complete!');

      return user;
    } catch (e) {
      debugPrint('❌ AuthService: Signup failed: $e');
      rethrow;
    }
  }

  Future<User> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      debugPrint('🔐 AuthService: Starting login for $email (rememberMe: $rememberMe)');
      
      // Check for hardcoded demo credentials
      if (email == 'demo@gmail.com' && password == 'password') {
        debugPrint('🎭 AuthService: Demo credentials detected, creating demo user');
        final now = DateTime.now();
        final demoUser = User(
          id: 'demo-user-123',
          email: 'demo@gmail.com',
          name: 'Demo User',
          phone: '+1234567890',
          termsAccepted: true,
          privacyAccepted: true,
          createdAt: now,
          updatedAt: now,
        );
        
        _currentUser = demoUser;
        
        // Save demo user session if "Remember me" is checked
        if (rememberMe) {
          await _setString(_currentUserKey, jsonEncode(demoUser.toJson()));
          await _setBool(_rememberMeKey, true);
          debugPrint('✅ AuthService: Demo session saved - user will be auto-logged in');
        } else {
          await _setBool(_rememberMeKey, false);
          debugPrint('ℹ️ AuthService: Demo session not saved - user will need to login again');
        }
        
        debugPrint('✅ AuthService: Demo login complete!');
        return demoUser;
      }
      
      // Check credentials for regular users
      final users = await _getAllUsers();
      debugPrint('📋 AuthService: Checking against ${users.length} users');
      
      final user = users.firstWhere(
        (u) => u.email == email,
        orElse: () {
          debugPrint('❌ AuthService: User $email not found');
          throw Exception('Invalid email or password');
        },
      );
      debugPrint('👤 AuthService: User found');

      final passwords = await _getPasswords();
      if (passwords[email] != password) {
        debugPrint('❌ AuthService: Invalid password for $email');
        throw Exception('Invalid email or password');
      }
      debugPrint('✅ AuthService: Password verified');

      _currentUser = user;
      
      // Save user session if "Remember me" is checked
      if (rememberMe) {
        await _setString(_currentUserKey, jsonEncode(user.toJson()));
        await _setBool(_rememberMeKey, true);
        debugPrint('✅ AuthService: Session saved - user will be auto-logged in');
      } else {
        await _setBool(_rememberMeKey, false);
        debugPrint('ℹ️ AuthService: Session not saved - user will need to login again');
      }
      
      debugPrint('✅ AuthService: Login complete!');

      return user;
    } catch (e) {
      debugPrint('❌ AuthService: Login failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    debugPrint('🚪 AuthService: Logging out user ${_currentUser?.email}');
    await _remove(_currentUserKey);
    await _remove(_rememberMeKey);
    _currentUser = null;
    debugPrint('✅ AuthService: Logout complete');
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final users = await _getAllUsers();
    final userExists = users.any((u) => u.email == email);
    
    if (!userExists) {
      throw Exception('Email not found');
    }

    final passwords = await _getPasswords();
    passwords[email] = newPassword;
    await _savePasswords(passwords);
  }

  Future<User> updateProfile({
    String? name,
    String? photoUrl,
    String? language,
  }) async {
    if (_currentUser == null) throw Exception('Not authenticated');

    final updatedUser = _currentUser!.copyWith(
      name: name,
      photoUrl: photoUrl,
      language: language,
      updatedAt: DateTime.now(),
    );

    // Update in users list
    final users = await _getAllUsers();
    final index = users.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      users[index] = updatedUser;
      await _saveAllUsers(users);
    }

    // Update current user
    _currentUser = updatedUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));

    return updatedUser;
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) throw Exception('Not authenticated');

    final users = await _getAllUsers();
    users.removeWhere((u) => u.id == _currentUser!.id);
    await _saveAllUsers(users);

    // Remove password
    final passwords = await _getPasswords();
    passwords.remove(_currentUser!.email);
    await _savePasswords(passwords);

    await logout();
  }

  Future<void> addFavoriteCourse(String courseId) async {
    if (_currentUser == null) throw Exception('Not authenticated');

    final favorites = List<String>.from(_currentUser!.favoriteCourses);
    if (!favorites.contains(courseId)) {
      favorites.add(courseId);
      await _updateCurrentUser(_currentUser!.copyWith(
        favoriteCourses: favorites,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> removeFavoriteCourse(String courseId) async {
    if (_currentUser == null) throw Exception('Not authenticated');

    final favorites = List<String>.from(_currentUser!.favoriteCourses);
    favorites.remove(courseId);
    await _updateCurrentUser(_currentUser!.copyWith(
      favoriteCourses: favorites,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> addPurchasedCourse(String courseId) async {
    if (_currentUser == null) throw Exception('Not authenticated');

    final purchased = List<String>.from(_currentUser!.purchasedCourses);
    if (!purchased.contains(courseId)) {
      purchased.add(courseId);
      await _updateCurrentUser(_currentUser!.copyWith(
        purchasedCourses: purchased,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _updateCurrentUser(User user) async {
    _currentUser = user;
    
    final users = await _getAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
      await _saveAllUsers(users);
    }

    await _setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  Future<List<User>> _getAllUsers() async {
    try {
      debugPrint('📖 AuthService: Getting all users');
      final usersJson = await _getString(_usersKey);
      
      if (usersJson == null) {
        debugPrint('ℹ️ AuthService: No users found, returning empty list');
        return [];
      }
      
      final List<dynamic> usersList = jsonDecode(usersJson);
      final users = usersList.map((json) => User.fromJson(json)).toList();
      debugPrint('✅ AuthService: Loaded ${users.length} users');
      return users;
    } catch (e) {
      debugPrint('❌ AuthService: Error getting users: $e');
      return [];
    }
  }

  Future<void> _saveAllUsers(List<User> users) async {
    try {
      debugPrint('💾 AuthService: Saving ${users.length} users');
      final usersJson = jsonEncode(users.map((u) => u.toJson()).toList());
      await _setString(_usersKey, usersJson);
      debugPrint('✅ AuthService: Users saved successfully');
    } catch (e) {
      debugPrint('❌ AuthService: Error saving users: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> _getPasswords() async {
    try {
      debugPrint('📖 AuthService: Getting passwords');
      final passwordsJson = await _getString('passwords');
      
      if (passwordsJson == null) {
        debugPrint('ℹ️ AuthService: No passwords found');
        return {};
      }
      
      final Map<String, dynamic> decoded = jsonDecode(passwordsJson);
      final passwords = decoded.map((key, value) => MapEntry(key, value.toString()));
      debugPrint('✅ AuthService: Loaded ${passwords.length} passwords');
      return passwords;
    } catch (e) {
      debugPrint('❌ AuthService: Error getting passwords: $e');
      return {};
    }
  }

  Future<void> _savePasswords(Map<String, String> passwords) async {
    try {
      debugPrint('💾 AuthService: Saving ${passwords.length} passwords');
      await _setString('passwords', jsonEncode(passwords));
      debugPrint('✅ AuthService: Passwords saved successfully');
    } catch (e) {
      debugPrint('❌ AuthService: Error saving passwords: $e');
      rethrow;
    }
  }
}
