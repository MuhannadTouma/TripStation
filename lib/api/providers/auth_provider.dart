import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_station/api/services/auth_service.dart';
import 'package:trip_station/models/user_model.dart';
import 'dart:convert'; // For json.encode and json.decode
import 'dart:io'; // For File

/// Manages the user's authentication state, including token and user data.
/// Uses SharedPreferences for persistent storage.
class AuthProvider with ChangeNotifier {
  String? _userToken;
  UserModel? _user;
  final AuthService _authService; // AuthService dependency

  // Private constructor
  AuthProvider._(this._authService);

  // Factory constructor for async initialization
  static Future<AuthProvider> create(AuthService authService) async {
    final provider = AuthProvider._(authService);
    await provider._loadTokenAndUser(); // Load token and user from storage on startup
    return provider;
  }

  String? get userToken => _userToken;
  UserModel? get user => _user;
  bool get isAuthenticated => _userToken != null && _user != null;

  /// Logs in the user, saves token and user data, and notifies listeners.
  /// The 'lang' parameter is automatically handled by the underlying AuthService and sendApiRequest utility.
  Future<void> login(String email, String password, String role) async {
    try {
      final response = await _authService.login(email, password, role);
      final String token = response['accessToken'] as String;
      final UserModel currentUser = response['user'] as UserModel;

      _userToken = token;
      _user = currentUser;

      await _saveTokenAndUser(token, currentUser); // Save to SharedPreferences
      notifyListeners(); // Notify widgets listening to changes
    } catch (e) {
      // Rethrow the exception so the UI can handle it
      rethrow;
    }
  }

  /// Registers a new user, saves token and user data, and notifies listeners.
  /// The 'lang' parameter is automatically handled by the underlying AuthService and sendApiRequest utility.
  Future<void> registerUser(
      String fullName, String email, String password, String rePassword, {File? profileImageFile}) async {
    try {
      final response = await _authService.registerUser(
          fullName, email, password, rePassword, profileImageFile: profileImageFile);
      final String token = response['accessToken'] as String;
      final UserModel newUser = response['user'] as UserModel;

      _userToken = token;
      _user = newUser;

      await _saveTokenAndUser(token, newUser);
      notifyListeners();
    } catch (e) {
      // print(e.toString());
      rethrow;
    }
  }

  /// Updates the user's profile, updates local state, and notifies listeners.
  /// The 'lang' parameter is automatically handled by the underlying AuthService and sendApiRequest utility.
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates, File? profileImageFile) async {
    if (_userToken == null) {
      throw Exception('User not authenticated. Cannot update profile.');
    }
    try {
      final UserModel updatedUser = await _authService.updateUserProfile(
        userId,
        updates,
        _userToken!,
        profileImageFile: profileImageFile,
      );
      _user = updatedUser; // Update local user model
      await _saveTokenAndUser(_userToken!, updatedUser); // Save updated user to SharedPreferences
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Logs out the user by calling the backend to invalidate the token,
  /// then clears local token and user data, and notifies listeners.
  Future<void> logout() async {
    // If there's no token, the user is already logged out locally.
    if (_userToken == null) {
      await _clearTokenAndUser();
      notifyListeners();
      return;
    }

    try {
      // Attempt to invalidate the token on the backend.
      // The 'lang' parameter is automatically handled by the underlying AuthService.
      await _authService.logout(_userToken!);
    } catch (e) {
      // Even if the API call fails (e.g., network error),
      // we should still log the user out on the client side for a good UX.
      print('Logout API call failed, but logging out locally: $e');
    } finally {
      // Always clear local data and notify listeners to ensure the user is logged out in the app.
      await _clearTokenAndUser();
      notifyListeners();
    }
  }

  /// Saves the user's token and user data to SharedPreferences.
  Future<void> _saveTokenAndUser(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    await prefs.setString('userData', json.encode(user.toJson())); // Store user as JSON string
  }

  /// Loads the user's token and user data from SharedPreferences.
  Future<void> _loadTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('accessToken');
    final userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        _user = UserModel.fromJson(json.decode(userDataString));
      } catch (e) {
        // Handle potential parsing errors if stored data is corrupt
        print('Error loading user data from SharedPreferences: $e');
        _user = null; // Clear invalid user data
      }
    }
  }

  /// Clears the user's token and user data from SharedPreferences.
  Future<void> _clearTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('userData');
    _userToken = null;
    _user = null;
  }
}