import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:url_launcher/url_launcher.dart';
import '../api/providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:trip_station/main.dart'; // To access the global LocaleNotifier
import 'package:trip_station/screens/account_screen.dart';

import 'login_screen.dart'; // For navigation after logout

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale? _currentSelectedLocale;

  @override
  void initState() {
    super.initState();
    _currentSelectedLocale = localeNotifier.locale;
  }

  @override
  Widget build(BuildContext context) {
    var s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF294FB6),
        title: Text(
          s.settingsTab,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: ListView(
          children: [
            // 1. Profile
            _buildSettingsTile(
              context,
              icon: Icons.person_outline,
              title: s.accountTab,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                );
              },
            ),

            // 2. Change Language
            _buildSettingsTile(
              context,
              icon: Icons.language,
              title: s.selectLanguage,
              onTap: () => _showLanguageChangeDialog(context),
            ),

            // 3. Privacy Policy
            _buildSettingsTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: s.privacyPolicy,
              onTap: () {
                _showInfoDialog(context, s.privacyPolicy, s.privacyPolicyContent);
              },
            ),

            // 4. Contact Us
            _buildSettingsTile(
              context,
              icon: Icons.contact_support_outlined,
              title: s.contactUsButton,
              onTap: () {
                _showContactUsOptions(context);
              },
            ),

            // 5. About Us
            _buildSettingsTile(
              context,
              icon: Icons.info_outline,
              title: s.aboutUs,
              onTap: () {
                _showInfoDialog(context, s.aboutUs, s.aboutUsContent);
              },
            ),

            // 6. Logout
            _buildSettingsTile(
              context,
              icon: Icons.logout,
              title: s.logoutTitle,
              onTap: () => _showLogoutConfirmationDialog(context),
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a settings list tile.
  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Color? textColor,
        Color? iconColor,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? const Color(0xFF294FB6),
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.grey[800],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  /// Pop-up for changing language.
  void _showLanguageChangeDialog(BuildContext context) {
    var s = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(s.selectLanguage),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<Locale>(
                      value: _currentSelectedLocale,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF294FB6)),
                      elevation: 16,
                      style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          setState(() {
                            _currentSelectedLocale = newLocale;
                          });
                          localeNotifier.setLocale(newLocale);
                          Navigator.of(context).pop();
                        }
                      },
                      items: AppLocalizations.supportedLocales.map<DropdownMenuItem<Locale>>((Locale locale) {
                        return DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(
                            locale.languageCode == 'en' ? 'English' : 'العربية',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Generic info dialog.
  void _showInfoDialog(BuildContext context, String title, String content) {
    var s = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.okButton),
            ),
          ],
        );
      },
    );
  }

  /// A helper function to safely launch URLs and show an error if it fails.
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        _showErrorSnackbar('Could not launch $url');
      }
    }
  }

  /// Contact Us options modal sheet with functional buttons.
  void _showContactUsOptions(BuildContext context) {
    var s = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.contactOptionsTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 20),
              ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFF294FB6)),
                title: Text(s.callOption),
                subtitle: const Text('+1 234 567 8900'),
                onTap: () {
                  Navigator.pop(context);
                  final Uri phoneUri = Uri(scheme: 'tel', path: '+12345678900');
                  _launchUrl(phoneUri);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF294FB6)),
                title: Text(s.emailOption),
                subtitle: const Text('info@company.com'),
                onTap: () {
                  Navigator.pop(context);
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'info@company.com',
                    query: 'subject=Inquiry from TripStation App',
                  );
                  _launchUrl(emailUri);
                },
              ),
              ListTile(
                leading: const Icon(Icons.message, color: Color(0xFF294FB6)),
                title: Text(s.messageOption),
                subtitle: Text(s.messageOptionSubtitle),
                onTap: () {
                  Navigator.pop(context);
                  final Uri smsUri = Uri(scheme: 'sms', path: '+12345678900');
                  _launchUrl(smsUri);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a confirmation dialog for logout and handles the logout process via AuthProvider.
  void _showLogoutConfirmationDialog(BuildContext context) {
    var s = AppLocalizations.of(context)!;
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

                // Get the AuthProvider instance using Provider.of
                // listen: false because we are just calling a method, not rebuilding based on changes.
                final authProvider = Provider.of<AuthProvider>(context, listen: false);

                try {
                  // Call the logout method from AuthProvider.
                  // AuthProvider handles the API call and clearing of local storage (SharedPreferences).
                  await authProvider.logout();

                  _showSuccessSnackbar(s.loggedOutSuccess);

                  // Navigate to LoginScreen after successful logout and remove all previous routes.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  // Catch any exceptions thrown by AuthProvider (which rethrows AuthService exceptions).
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
        backgroundColor: const Color(0xFF294FB6), // Using your primary blue color for success
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
