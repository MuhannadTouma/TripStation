import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),

              // Welcome Text
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF1976D2), // Blue color matching the design
                  fontFamily: 'Cursive',
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/logo.jpg', // Add your logo image to assets/images/
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              // Tagline
              Text(
                'One-Stop-Shop For All Your\n Travel Needs!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const Spacer(),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                        (_) => false
                    );
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('first_time_app_open', false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF294FB6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
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
    );
  }
}
