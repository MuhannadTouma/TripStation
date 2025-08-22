import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:trip_station/api/services/auth_service.dart';
import 'package:trip_station/models/user_model.dart';
import 'home_view.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import for File class

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isRePasswordVisible = false;
  bool _isLoading = false;

  File? _profileImage; // Variable to store the selected image file

  final AuthService _authService = AuthService();

  /// Picks an image from the gallery or camera.
  ///
  /// Shows a modal bottom sheet allowing the user to choose between
  /// taking a photo or selecting one from the gallery.
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
    // Close the bottom sheet after picking an image
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Shows a modal bottom sheet for image selection options.
  void _showImageSourceActionSheet(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
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
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
                    const SizedBox(width: 50), // For alignment
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF294FB6),
                      ),
                      title: Text(s.takePhoto),
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.photo_library,
                        color: Color(0xFF294FB6),
                      ),
                      title: Text(s.chooseFromGallery),
                      onTap: () => _pickImage(ImageSource.gallery),
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

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF294FB6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Center(
                    child: Text(
                      s.signUpTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -75),
                        child: GestureDetector(
                          onTap: () => _showImageSourceActionSheet(context),
                          // Call image selection sheet
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
                                  // Display selected image if available
                                  image: _profileImage != null
                                      ? DecorationImage(
                                          image: FileImage(_profileImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _profileImage == null
                                    ? Icon(
                                        Icons.person,
                                        size: 45,
                                        color: Colors.grey[600],
                                      )
                                    : null, // Hide icon if image is selected
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
                      ),

                      const SizedBox(height: 10),

                      _buildInputField(
                        context,
                        label: s.fullNameLabel,
                        controller: _nameController,
                        hintText: s.enterYourNameHint,
                        isPassword: false,
                      ),

                      const SizedBox(height: 20),

                      _buildInputField(
                        context,
                        label: s.emailLabel,
                        controller: _emailController,
                        hintText: 'sample@mail.com',
                        isPassword: false,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      _buildInputField(
                        context,
                        label: s.passwordLabel,
                        controller: _passwordController,
                        hintText: '••••••••••••',
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onTogglePassword: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildInputField(
                        context,
                        label: s.rePasswordLabel,
                        controller: _rePasswordController,
                        hintText: '••••••••••••',
                        isPassword: true,
                        isPasswordVisible: _isRePasswordVisible,
                        onTogglePassword: () {
                          setState(() {
                            _isRePasswordVisible = !_isRePasswordVisible;
                          });
                        },
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF294FB6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
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
                                  s.registerButton,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.alreadyHaveAccountText,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: _navigateToLogin,
                            child: Text(
                              s.loginButton,
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF294FB6),
                                color: Color(0xFF294FB6),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
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
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey[500],
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return s.emailRequiredError;
            }
            if (label == s.emailLabel && !value.contains('@')) {
              return s.invalidEmailError;
            }
            if (label == s.passwordLabel && value.length < 6) {
              return s.passwordLengthError;
            }
            if (label == s.rePasswordLabel &&
                value != _passwordController.text) {
              return s.passwordsDoNotMatchError;
            }
            return null;
          },
        ),
      ],
    );
  }

  void _handleRegister() async {
    final s = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<AuthProvider>(context, listen: false).registerUser(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          _rePasswordController.text,
          profileImageFile: _profileImage, // Pass the selected image file
        );
        // final response = await _authService.registerUser(
        //   _nameController.text,
        //   _emailController.text,
        //   _passwordController.text,
        //   _rePasswordController.text,
        //   profileImageFile: _profileImage, // Pass the selected image file
        // );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.registrationSuccessful),
            backgroundColor: const Color(0xFF294FB6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
          (_) => false,
        );
      } catch (e) {
        _showErrorSnackbar(e.toString().split(':').map((s) => s.trim()).lastWhere((s) => s.isNotEmpty));
        // _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pop(context);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const LoginScreen()),
    // );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }
}
