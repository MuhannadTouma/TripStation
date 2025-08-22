import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @locName.
  ///
  /// In en, this message translates to:
  /// **'ar'**
  String get locName;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Trip Station'**
  String get appName;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @tripsLabel.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get tripsLabel;

  /// No description provided for @favoritesTab.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTab;

  /// No description provided for @accountTab.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'One-Stop-Shop For All Your Travel Needs!'**
  String get tagline;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @enterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @createAccountText.
  ///
  /// In en, this message translates to:
  /// **'Create an Account '**
  String get createAccountText;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// No description provided for @emailRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailRequiredError;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmailError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get passwordLengthError;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @enterYourNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Name'**
  String get enterYourNameHint;

  /// No description provided for @rePasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Re-Password'**
  String get rePasswordLabel;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatchError;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccountText.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccountText;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// No description provided for @noFavoritesDescription.
  ///
  /// In en, this message translates to:
  /// **'Start exploring and add activities\nto your favorites!'**
  String get noFavoritesDescription;

  /// No description provided for @exploreActivitiesButton.
  ///
  /// In en, this message translates to:
  /// **'Explore Activities'**
  String get exploreActivitiesButton;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @internationalTab.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get internationalTab;

  /// No description provided for @localTab.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get localTab;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @advertisementsSection.
  ///
  /// In en, this message translates to:
  /// **'Advertisements'**
  String get advertisementsSection;

  /// No description provided for @activitiesSection.
  ///
  /// In en, this message translates to:
  /// **'Activities :'**
  String get activitiesSection;

  /// No description provided for @noActivitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No activities found.'**
  String get noActivitiesFound;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @whereQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where?'**
  String get whereQuestion;

  /// No description provided for @exMyLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: My Location'**
  String get exMyLocationHint;

  /// No description provided for @useMapButton.
  ///
  /// In en, this message translates to:
  /// **'Use MAP'**
  String get useMapButton;

  /// No description provided for @ratingsSection.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratingsSection;

  /// No description provided for @priceRangesSection.
  ///
  /// In en, this message translates to:
  /// **'Price Ranges'**
  String get priceRangesSection;

  /// No description provided for @applyButton.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get applyButton;

  /// No description provided for @companyNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'company name'**
  String get companyNamePlaceholder;

  /// No description provided for @activityDetailsLocation.
  ///
  /// In en, this message translates to:
  /// **'Karang Mas Estate, Jimbaran, Bali, Indonesia'**
  String get activityDetailsLocation;

  /// No description provided for @addToBookButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Book'**
  String get addToBookButton;

  /// No description provided for @contactUsButton.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsButton;

  /// No description provided for @shareFunctionality.
  ///
  /// In en, this message translates to:
  /// **'Share functionality'**
  String get shareFunctionality;

  /// No description provided for @addedToBookingList.
  ///
  /// In en, this message translates to:
  /// **'Added to booking list!'**
  String get addedToBookingList;

  /// No description provided for @contactOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Options'**
  String get contactOptionsTitle;

  /// No description provided for @callOption.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callOption;

  /// No description provided for @emailOption.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailOption;

  /// No description provided for @messageOption.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageOption;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @loggedOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccess;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. We collect minimal data for app functionality and improvement.'**
  String get privacyPolicyContent;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @aboutUsContent.
  ///
  /// In en, this message translates to:
  /// **'Trip Station helps you find the best travel experiences around the world. Built with passion and dedication.'**
  String get aboutUsContent;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @oldPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccessful;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed!'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Register failed!'**
  String get registerFailed;

  /// No description provided for @requiredFieldError.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredFieldError;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Full Name is required.'**
  String get nameRequiredError;

  /// No description provided for @passwordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordRequiredError;

  /// No description provided for @rePasswordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password is required.'**
  String get rePasswordRequiredError;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed. Please try again.'**
  String get logoutFailed;

  /// No description provided for @logoutNoTokenError.
  ///
  /// In en, this message translates to:
  /// **'Authentication token not found. Please log in again.'**
  String get logoutNoTokenError;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile. Please try again.'**
  String get profileUpdateFailed;

  /// No description provided for @oldPasswordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Old password is required to change password.'**
  String get oldPasswordRequiredError;

  /// No description provided for @passwordFieldsRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Both old and new password fields are required to change password.'**
  String get passwordFieldsRequiredError;

  /// No description provided for @noChangesToUpdate.
  ///
  /// In en, this message translates to:
  /// **'No changes detected to update.'**
  String get noChangesToUpdate;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites!'**
  String get addedToFavorites;

  /// No description provided for @errorLoadingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to load favorites.'**
  String get errorLoadingFavorites;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @favoriteToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite status.'**
  String get favoriteToggleFailed;

  /// No description provided for @loadingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Loading favorites...'**
  String get loadingFavorites;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// The message to be shared for a trip.
  ///
  /// In en, this message translates to:
  /// **'Check out the \'{activityName}\' trip on the TripStation app!\nOffered by {companyName}\nin {location}\nFor only {price} SAR.'**
  String shareTripMessage(String activityName, String companyName, String location, String price);

  /// No description provided for @shareSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Trip'**
  String get shareSheetTitle;

  /// No description provided for @messageOptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a direct message'**
  String get messageOptionSubtitle;

  /// No description provided for @removeFavoriteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites?'**
  String get removeFavoriteConfirmationTitle;

  /// No description provided for @removeFavoriteConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this item from your favorites?'**
  String get removeFavoriteConfirmationContent;

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @exitAppConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit App?'**
  String get exitAppConfirmationTitle;

  /// No description provided for @exitAppConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get exitAppConfirmationContent;

  /// No description provided for @exitButton.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitButton;

  /// No description provided for @stayButton.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stayButton;

  /// No description provided for @noAdsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No Advertisements'**
  String get noAdsFoundTitle;

  /// No description provided for @noAdsFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There are no special offers available at the moment.'**
  String get noAdsFoundSubtitle;

  /// No description provided for @noTripsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No Trips Found'**
  String get noTripsFoundTitle;

  /// No description provided for @noTripsFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any trips. Please check back later.'**
  String get noTripsFoundSubtitle;

  /// No description provided for @noResultsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResultsFoundTitle;

  /// No description provided for @noResultsFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter to find what you\'re looking for.'**
  String get noResultsFoundSubtitle;

  /// No description provided for @clearFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFiltersButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
