import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:trip_station/screens/signup_screen.dart';
import '../api/providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

import 'home_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // No longer directly instantiate AuthService here, use AuthProvider

  @override
  Widget build(BuildContext context) {
    // Access localized strings at the start of the build method
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Const for performance
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue header section with curved bottom
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration( // Const for performance
                color: Color(0xFF294FB6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea( // Changed to non-const because its child is not const
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60, bottom: 60), // Const for performance
                    child: Text(
                      s.loginTitle, // Localized: "Login"
                      style: const TextStyle(color: Colors.white, fontSize: 32), // Const for performance
                    ),
                  ),
                ),
              ),
            ),

            // White card with form - overlapping the blue section
            Transform.translate(
              offset: const Offset(0, -50), // Const for performance
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20), // Const for performance
                padding: const EdgeInsets.all(35), // Const for performance
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 8), // Const for performance
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20), // Const for performance

                      // Email field
                      _buildInputField(
                        context, // Pass context to access localization in _buildInputField
                        label: s.emailLabel, // Localized: "Email"
                        controller: _emailController,
                        hintText: 'sample@mail.com', // Keep email hint hardcoded or localize specifically
                        keyboardType: TextInputType.emailAddress,
                        isPassword: false,
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

                      const SizedBox(height: 25), // Const for performance

                      // Password field
                      _buildInputField(
                        context, // Pass context
                        label: s.passwordLabel, // Localized: "Password"
                        controller: _passwordController,
                        hintText: s.enterPasswordHint, // Localized: "Enter Password"
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onTogglePassword: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return s.passwordRequiredError;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 50), // Const for performance

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF294FB6), // Const for performance
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: _isLoading
                              ? const SizedBox( // Const for performance
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            s.loginButton, // Localized: "Login"
                            style: const TextStyle( // Const for performance
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40), // Const for performance

                      // Sign up link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.createAccountText, // Localized: "Don't have an account?"
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: _navigateToSignUp,
                              child: Text(
                                s.signUpLink, // Localized: "Sign Up"
                                style: const TextStyle( // Const for performance
                                  color: Color(0xFF294FB6),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20), // Const for performance
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

  /// Helper method to build a reusable text input field with optional password visibility toggle and custom validation.
  Widget _buildInputField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required String hintText,
        required bool isPassword,
        bool isPasswordVisible = false,
        VoidCallback? onTogglePassword,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator, // Accept a custom validator
      }) {
    final s = AppLocalizations.of(context)!; // Access localized strings in this method

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
        const SizedBox(height: 8), // Const for performance
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFF8F9FA), // Const for performance
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF294FB6), width: 2), // Const for performance
            ),
            errorStyle: const TextStyle( // Const for performance
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2), // Const for performance
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2), // Const for performance
            ),
            contentPadding: const EdgeInsets.symmetric( // Const for performance
              horizontal: 15,
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
          validator: validator ?? (value) {
            // Default validator if none is provided
            if (value == null || value.isEmpty) {
              return s.requiredFieldError; // Generic required field error
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Handles the login process, including form validation and API call.
  void _handleLogin() async {
    final s = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Use the AuthProvider to login
        await Provider.of<AuthProvider>(context, listen: false).login(
          _emailController.text,
          _passwordController.text,
          'user', // Assuming 'user' role for login from this screen
        );

        print('Login successful via AuthProvider!');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.loginSuccessful),
            backgroundColor: const Color(0xFF294FB6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Navigate to home view and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        // Catch any exceptions thrown by AuthProvider (which rethrows AuthService exceptions)
        print('Login Error: $e'); // Print the full error for debugging
        _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Displays a red snackbar with an error message.
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

  /// Navigates to the SignUpScreen.
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()), // Ensure const for SignUpScreen
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
