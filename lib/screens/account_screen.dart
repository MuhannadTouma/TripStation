import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:trip_station/api/api_constants.dart';
import 'dart:io'; // Import for File class

import '../api/providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:trip_station/screens/login_screen.dart'; // For navigation after logout

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isLoading = false; // State for loading indicator on submit button
  File? _profileImageFile; // To store the newly selected profile image

  // Reference to AuthProvider, initialized in initState
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available before Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _initializeUserData();
    });
  }

  /// Initializes the text controllers with the current user's data from AuthProvider.
  void _initializeUserData() {
    if (_authProvider.user != null) {
      _fullNameController.text = _authProvider.user!.fullName;
      _emailController.text = _authProvider.user!.email;
      // Passwords are not pre-filled for security reasons.
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    // Watch AuthProvider to get the latest user data (e.g., if profile image updates elsewhere)
    final currentUser = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.accountTab, // Using accountTab for Account Screen Title
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF294FB6),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Profile Picture Section
                    GestureDetector(
                      onTap: _selectProfileImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E5E5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: _profileImageFile != null
                                  ? DecorationImage(
                                image: FileImage(_profileImageFile!),
                                fit: BoxFit.cover,
                                  onError: (_,__){
                                    return;
                                  }
                              )
                                  : (currentUser?.profileImage != null
                                  ? DecorationImage(
                                image: NetworkImage('${ApiConstants.originUrl}${currentUser!.profileImage!}'),
                                fit: BoxFit.cover,
                                onError: (_,__){
                                  return;
                                }
                              )
                                  : null),
                            ),
                            child: _profileImageFile == null && currentUser?.profileImage == null
                                ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[600],
                            )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: const Color(0xFF294FB6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Full Name Field
                    _buildInputField(
                      context,
                      label: s.fullNameLabel,
                      controller: _fullNameController,
                      hintText: s.enterYourNameHint,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return s.nameRequiredError;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    // Old Password Field (optional, for changing password)
                    _buildInputField(
                      context,
                      label: s.oldPasswordLabel,
                      controller: _oldPasswordController,
                      hintText: '••••••••••••••••••••',
                      isPassword: true,
                      isPasswordVisible: _isOldPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isOldPasswordVisible = !_isOldPasswordVisible;
                        });
                      },
                      // Validator only if new password is being set
                      validator: (value) {
                        if (_newPasswordController.text.isNotEmpty && (value == null || value.isEmpty)) {
                          return s.oldPasswordRequiredError;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    // New Password Field (optional)
                    _buildInputField(
                      context,
                      label: s.newPasswordLabel,
                      controller: _newPasswordController,
                      hintText: '••••••••••••••••••••',
                      isPassword: true,
                      isPasswordVisible: _isNewPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return s.passwordLengthError;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    // Email Field
                    _buildInputField(
                      context,
                      label: s.emailLabel,
                      controller: _emailController,
                      hintText: 'sample@mail.com',
                      enabled: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return s.emailRequiredError;
                        }
                        if (!value.contains('@')) {
                          return s.invalidEmailError;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 50),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF294FB6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          s.submitButton,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          s.logoutTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build an input field.
  Widget _buildInputField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required String hintText,
        bool isPassword = false,
        bool isPasswordVisible = false,
        bool enabled = true,
        VoidCallback? onTogglePassword,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator, // Custom validator function
      }) {
    final s = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          enabled: enabled,
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF294FB6), width: 2),
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[500],
              ),
              onPressed: onTogglePassword,
            )
                : null,
          ),
          validator: validator ?? (value) {
            // Default validator if none is provided
            if (value == null || value.isEmpty) {
              return s.requiredFieldError;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Handles picking a profile image from gallery or camera.
  void _selectProfileImage() {
    final s = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        s.cancelButton,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      s.selectImage,
                      style: const TextStyle(
                        color: Color(0xFF294FB6),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt, color: Color(0xFF294FB6)),
                      title: Text(s.takePhoto),
                      onTap: () async {
                        Navigator.pop(context); // Close bottom sheet
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          setState(() {
                            _profileImageFile = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library, color: Color(0xFF294FB6)),
                      title: Text(s.chooseFromGallery),
                      onTap: () async {
                        Navigator.pop(context); // Close bottom sheet
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            _profileImageFile = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handles the form submission for updating user profile.
  void _handleSubmit() async {
    final s = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _authProvider.user;
      if (currentUser == null) {
        _showErrorSnackbar(s.profileUpdateFailed); // User not logged in
        return;
      }

      final Map<String, dynamic> updates = {};
      bool hasChanges = false;

      // Check for changes in full name
      if (_fullNameController.text != currentUser.fullName) {
        updates['fullName'] = _fullNameController.text;
        hasChanges = true;
      }

      // Check for changes in email
      if (_emailController.text != currentUser.email) {
        updates['email'] = _emailController.text;
        hasChanges = true;
      }

      // Handle password changes only if old and new passwords are provided
      if (_oldPasswordController.text.isNotEmpty && _newPasswordController.text.isNotEmpty) {
        updates['oldPassword'] = _oldPasswordController.text;
        updates['newPassword'] = _newPasswordController.text;
        hasChanges = true;
      } else if (_oldPasswordController.text.isNotEmpty || _newPasswordController.text.isNotEmpty) {
        // If only one password field is filled, show an error
        _showErrorSnackbar(s.passwordFieldsRequiredError); // Needs new localization key
        setState(() { _isLoading = false; });
        return;
      }

      // Add profile image if selected
      if (_profileImageFile != null) {
        // The updateUserProfile in AuthService expects File, not the path string directly
        hasChanges = true;
      }

      if (!hasChanges && _profileImageFile == null) {
        _showErrorSnackbar(s.noChangesToUpdate);
        return;
      }

      // Call AuthProvider to update profile
      await _authProvider.updateUserProfile(
        currentUser.id, // User ID is needed by AuthService for update
        updates,
        _profileImageFile, // Pass the File directly
      );

      _showSuccessSnackbar(s.profileUpdatedSuccess);
      // Clear password fields after successful update
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _profileImageFile = null; // Clear selected image
    } catch (e) {
      print('Profile Update Error: $e');
      _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handles the logout process via AuthProvider.
  void _handleLogout() {
    final s = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(s.logoutTitle),
          content: Text(s.logoutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                s.cancelButton,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close the dialog immediately

                final authProvider = Provider.of<AuthProvider>(context, listen: false);

                try {
                  await authProvider.logout();
                  _showSuccessSnackbar(s.loggedOutSuccess);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print('Logout Error: $e');
                  _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
                }
              },
              child: Text(
                s.logoutTitle,
                style: const TextStyle(color: Color(0xFFD32F2F)),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Displays a red snackbar for error messages.
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Displays a success snackbar (blue/green).
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF294FB6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
