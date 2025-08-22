import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:trip_station/l10n/app_localizations.dart'; // Import for localization
import 'package:trip_station/screens/favorite_screen.dart';
import 'package:trip_station/screens/home_screen.dart';
import 'package:trip_station/screens/settings_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  late PageController _pageController;
  // --- 1. Add the GlobalKey for accessing the HomeScreen's state ---
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Shows a confirmation dialog before exiting the app.
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final s = AppLocalizations.of(context)!;
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.exitAppConfirmationTitle),
        content: Text(s.exitAppConfirmationContent),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // User stays
            child: Text(s.stayButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // User exits
            child: Text(s.exitButton, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false; // If dialog is dismissed, default to not exiting (false)
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the Scaffold with PopScope to intercept the back button press
    return PopScope(
      canPop: false, // Prevents the app from closing automatically
      onPopInvokedWithResult: (didPop, _) async {
        // This callback is triggered when a pop is attempted.
        if (didPop) {
          return; // If a pop happened for another reason, do nothing.
        }
        // Show our custom dialog.
        final bool shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit) {
          // If the user confirms, close the app.
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(), // Disable swiping between pages
          children: [
            // --- 2. Pass the key to the HomeScreen instance ---
            HomeScreen(key: _homeScreenKey),
            const FavoritesScreen(),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: SafeArea( // Ensures the content is not obscured by system UI
          child: Container(
            height: 45, // Adjusted height for better visual balance
            decoration: BoxDecoration(
              color: const Color(0xFF294FB6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              selectedFontSize: 1, // Keep font size small as labels are empty
              currentIndex: _currentIndex,
              onTap: (index) {
                // --- 3. Unfocus the search bar when navigating away from home ---
                if (_currentIndex == 0 && index != 0) {
                  _homeScreenKey.currentState?.unfocusSearchBar();
                }
                setState(() {
                  _currentIndex = index;
                  _pageController.jumpToPage(index); // Use jumpToPage to immediately switch tabs
                });
              },
              type: BottomNavigationBarType.fixed, // Ensures all items are visible
              backgroundColor: Colors.transparent, // Make background transparent
              selectedItemColor: const Color(0xFFF89234),
              unselectedItemColor: Colors.white,
              elevation: 0, // Remove default elevation
              items: [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(Icons.home, size: 25),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(Icons.favorite_border, size: 25),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(Icons.person_outline, size: 25),
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}