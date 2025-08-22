// api/services/auth_service.dart
import 'dart:io'; // Required for File type

import 'package:trip_station/models/user_model.dart'; // Import the User model
import '../utils/send_request.dart'; // Import the centralized API request function

/// Service class for handling authentication-related API calls.
/// This service depends on the centralized `sendApiRequest` utility for all network operations.
class AuthService {
  /// Authenticates a user with the provided email, password, and role.
  ///
  /// [email]: The user's email address.
  /// [password]: The user's password.
  /// [role]: The role of the user (e.g., 'user', 'admin').
  ///
  /// Returns a Future that resolves to a Map containing the parsed UserModel and access token.
  /// Throws an Exception if login fails.
  Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    final response = await sendApiRequest(
      'auth/login',
      method: 'POST',
      body: {
        'email': email,
        'password': password,
        'role': role,
      },
    );

    // After getting the raw response, parse the specific data model here.
    if (response['success'] == true && response['data'] != null) {
      final UserModel user =
      UserModel.fromJson(response['data']['user'] as Map<String, dynamic>);
      final String accessToken = response['data']['accessToken'];

      return {
        'user': user,
        'accessToken': accessToken,
      };
    } else {
      throw Exception(response['message'] ?? 'Login failed unexpectedly.');
    }
  }

  /// Registers a new user.
  ///
  /// [fullName]: The full name of the user.
  /// [email]: The user's email.
  /// [password]: The user's password.
  /// [profileImageFile]: Optional image file for the user's profile.
  ///
  /// Returns a Future that resolves to a Map containing the new user data (UserModel) and access token.
  /// Throws an Exception if registration fails.
  Future<Map<String, dynamic>> registerUser(
      String fullName, String email, String password, String rePassword,
      {File? profileImageFile}) async {
    final Map<String, dynamic> body = {
      'fullName': fullName,
      'email': email,
      'password': password,
      'rePassword': rePassword,
    };

    final response = await sendApiRequest(
      'auth/user/register',
      method: 'POST',
      body: body,
      imageFile: profileImageFile,
    );

    if (response['success'] == true && response['data'] != null) {
      final UserModel user =
      UserModel.fromJson(response['data']['user'] as Map<String, dynamic>);
      final String accessToken = response['data']['accessToken'];
      return {
        'user': user,
        'accessToken': accessToken,
      };
    } else {
      print(response['message']);
      throw Exception(
          response['message'] ?? 'Registration failed unexpectedly.');
    }
  }

  /// Updates the user's profile.
  ///
  /// [userId]: The ID of the user to update.
  /// [updates]: A map of fields to update.
  /// [token]: The user's authentication token.
  /// [profileImageFile]: Optional new profile image file.
  ///
  /// Returns a Future that resolves to the updated UserModel.
  /// Throws an Exception if the update fails.
  Future<UserModel> updateUserProfile(
      String userId, Map<String, dynamic> updates, String token,
      {File? profileImageFile}) async {
    final response = await sendApiRequest(
      'auth/user/update-profile',
      method: 'PUT',
      body: updates,
      imageFile: profileImageFile,
      token: token,
    );

    if (response['success'] == true) {
      // The user object might be nested under 'data' or be at the root.
      // This parsing logic now correctly resides within the service method.
      if (response['data'] != null && response['data']['user'] != null) {
        return UserModel.fromJson(
            response['data']['user'] as Map<String, dynamic>);
      } else if (response['user'] != null) {
        return UserModel.fromJson(response['user'] as Map<String, dynamic>);
      } else {
        throw Exception('User data not found in the profile update response.');
      }
    } else {
      throw Exception(response['message'] ?? 'Profile update failed.');
    }
  }

  /// Logs out the current user.
  ///
  /// [token]: The user's authentication token.
  ///
  /// Returns a Future that resolves to true if logout is successful.
  /// Throws an Exception if logout fails.
  Future<bool> logout(String token) async {
    final response = await sendApiRequest(
      'auth/logout',
      method: 'POST',
      token: token,
      body: {}, // Empty body if no data is expected by backend for logout
    );

    if (response['success'] == true) {
      return true;
    } else {
      throw Exception(response['message'] ?? 'Logout failed.');
    }
  }
}