import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_station/api/providers/ad_provider.dart';
import 'package:trip_station/screens/welcome_screen.dart';

import 'api/providers/auth_provider.dart';
import 'api/providers/country_provider.dart';
import 'api/services/auth_service.dart';
import 'api/services/activity_service.dart'; // Import ActivityService
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/home_view.dart'; // Assuming HomeView is your main authenticated screen

/// A ChangeNotifier to manage the app's locale globally.
class LocaleNotifier extends ChangeNotifier {
  Locale _locale;

  // Constructor initializes the locale based on the device's current locale.
  LocaleNotifier() : _locale = _getInitialLocale();

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  /// Determines the initial locale for the app based on the device's locale.
  /// If the device locale is English ('en') or Arabic ('ar'), it uses that.
  /// Otherwise, it defaults to English ('en').
  static Locale _getInitialLocale() {
    final deviceLocale = WidgetsBinding.instance.window.locale;
    final String languageCode = deviceLocale.languageCode;

    if (languageCode == 'en' || languageCode == 'ar') {
      return Locale(languageCode);
    } else {
      return const Locale('en');
    }
  }
}

// Global instance of LocaleNotifier
final LocaleNotifier localeNotifier = LocaleNotifier();
bool isFirstTimeAppOpen = true;

void main() async {
  // Ensure Flutter engine is initialized before accessing platform features like device locale.
  WidgetsFlutterBinding.ensureInitialized();

  // Create an instance of AuthService, which handles API calls.
  final authService = AuthService();

  // Create an instance of AuthProvider asynchronously.
  // This provider manages authentication state, including loading user data and token from storage.
  final authProvider = await AuthProvider.create(authService);



  // Create an instance of ActivityService, depending on AuthService for authenticated requests.
  final activityService = ActivityService(authService);

  final prefs = await SharedPreferences.getInstance();
  isFirstTimeAppOpen = prefs.getBool('first_time_app_open') ?? true;

  runApp(
    // MultiProvider is used to provide multiple ChangeNotifier instances to the widget tree.
    MultiProvider(
      providers: [
        // Provides the global LocaleNotifier to manage language changes.
        ChangeNotifierProvider<LocaleNotifier>.value(value: localeNotifier),
        // Provides the AuthProvider to manage user authentication state.
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        // Provides the ActivityService, making it accessible to widgets.
        Provider<ActivityService>.value(value: activityService),
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider())
      ],
      // The root widget of your application.
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer/Provider.of is used to listen to changes in LocaleNotifier
    // and rebuild the MaterialApp when the locale changes.
    final currentLocale = Provider.of<LocaleNotifier>(context).locale;

    // Consumer/Provider.of is used to listen to changes in AuthProvider
    // to determine whether the user is authenticated and navigate accordingly.
    final authProvider = Provider.of<AuthProvider>(context);

    Widget initialScreen;
    if (isFirstTimeAppOpen) {
      initialScreen = const WelcomeScreen();
    } else {
      initialScreen = authProvider.isAuthenticated ? const HomeView() : const LoginScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Set to false for production to hide the debug banner.
      title: 'Trip Station', // Title for the app in the task switcher.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Defines the primary color palette.
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts UI density across platforms.
      ),
      locale: currentLocale, // Set the app's current locale.
      // Define delegates for localization, including those from Flutter material and widgets.
      localizationsDelegates: const [
        AppLocalizations.delegate, // Your custom app localizations delegate.
        GlobalMaterialLocalizations.delegate, // Provides localized strings for Material widgets.
        GlobalWidgetsLocalizations.delegate, // Provides localized strings for Widgets.
        GlobalCupertinoLocalizations.delegate, // Provides localized strings for Cupertino widgets.
      ],
      // List of locales your app officially supports.
      supportedLocales: AppLocalizations.supportedLocales,
      // Determine the initial screen based on the authentication status.
      // If authenticated, navigate to HomeView; otherwise, go to LoginScreen.

      home: initialScreen,
      // Consider adding a splash screen or loading indicator while AuthProvider loads state
      // (e.g., using a FutureBuilder around a loading screen or checking a loading state in AuthProvider)
    );
  }
}
