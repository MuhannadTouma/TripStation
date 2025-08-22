// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get locName => 'ar';

  @override
  String get appName => 'Trip Station';

  @override
  String get homeTab => 'Home';

  @override
  String get tripsLabel => 'Trips';

  @override
  String get favoritesTab => 'Favorites';

  @override
  String get accountTab => 'Account';

  @override
  String get settingsTab => 'Settings';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get tagline => 'One-Stop-Shop For All Your Travel Needs!';

  @override
  String get getStartedButton => 'Get Started';

  @override
  String get loginTitle => 'Login';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get enterPasswordHint => 'Enter Password';

  @override
  String get loginButton => 'Login';

  @override
  String get createAccountText => 'Create an Account ';

  @override
  String get signUpLink => 'Sign Up';

  @override
  String get emailRequiredError => 'Email is required.';

  @override
  String get invalidEmailError => 'Please enter a valid email address.';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters long.';

  @override
  String get signUpTitle => 'Sign Up';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get enterYourNameHint => 'Enter Your Name';

  @override
  String get rePasswordLabel => 'Re-Password';

  @override
  String get passwordsDoNotMatchError => 'Passwords do not match.';

  @override
  String get registerButton => 'Register';

  @override
  String get alreadyHaveAccountText => 'Already have an account? ';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get noFavoritesYet => 'No Favorites Yet';

  @override
  String get noFavoritesDescription => 'Start exploring and add activities\nto your favorites!';

  @override
  String get exploreActivitiesButton => 'Explore Activities';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get undoAction => 'Undo';

  @override
  String get internationalTab => 'International';

  @override
  String get localTab => 'Local';

  @override
  String get searchHint => 'Search';

  @override
  String get advertisementsSection => 'Advertisements';

  @override
  String get activitiesSection => 'Activities :';

  @override
  String get noActivitiesFound => 'No activities found.';

  @override
  String get filterTitle => 'Filter';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get resetButton => 'Reset';

  @override
  String get whereQuestion => 'Where?';

  @override
  String get exMyLocationHint => 'Ex: My Location';

  @override
  String get useMapButton => 'Use MAP';

  @override
  String get ratingsSection => 'Ratings';

  @override
  String get priceRangesSection => 'Price Ranges';

  @override
  String get applyButton => 'APPLY';

  @override
  String get companyNamePlaceholder => 'company name';

  @override
  String get activityDetailsLocation => 'Karang Mas Estate, Jimbaran, Bali, Indonesia';

  @override
  String get addToBookButton => 'Add to Book';

  @override
  String get contactUsButton => 'Contact Us';

  @override
  String get shareFunctionality => 'Share functionality';

  @override
  String get addedToBookingList => 'Added to booking list!';

  @override
  String get contactOptionsTitle => 'Contact Options';

  @override
  String get callOption => 'Call';

  @override
  String get emailOption => 'Email';

  @override
  String get messageOption => 'Message';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get loggedOutSuccess => 'Logged out successfully';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get selectImage => 'Select Image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get loginSuccessful => 'Login successful!';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyContent => 'Your privacy is important to us. We collect minimal data for app functionality and improvement.';

  @override
  String get aboutUs => 'About Us';

  @override
  String get aboutUsContent => 'Trip Station helps you find the best travel experiences around the world. Built with passion and dedication.';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get okButton => 'OK';

  @override
  String get oldPasswordLabel => 'Old Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get submitButton => 'Submit';

  @override
  String get registrationSuccessful => 'Registration successful!';

  @override
  String get loginFailed => 'Login failed!';

  @override
  String get registerFailed => 'Register failed!';

  @override
  String get requiredFieldError => 'This field is required.';

  @override
  String get nameRequiredError => 'Full Name is required.';

  @override
  String get passwordRequiredError => 'Password is required.';

  @override
  String get rePasswordRequiredError => 'Confirm Password is required.';

  @override
  String get logoutFailed => 'Logout failed. Please try again.';

  @override
  String get logoutNoTokenError => 'Authentication token not found. Please log in again.';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get profileUpdateFailed => 'Failed to update profile. Please try again.';

  @override
  String get oldPasswordRequiredError => 'Old password is required to change password.';

  @override
  String get passwordFieldsRequiredError => 'Both old and new password fields are required to change password.';

  @override
  String get noChangesToUpdate => 'No changes detected to update.';

  @override
  String get addedToFavorites => 'Added to favorites!';

  @override
  String get errorLoadingFavorites => 'Failed to load favorites.';

  @override
  String get retryButton => 'Retry';

  @override
  String get favoriteToggleFailed => 'Failed to update favorite status.';

  @override
  String get loadingFavorites => 'Loading favorites...';

  @override
  String get days => 'Days';

  @override
  String shareTripMessage(String activityName, String companyName, String location, String price) {
    return 'Check out the \'$activityName\' trip on the TripStation app!\nOffered by $companyName\nin $location\nFor only $price SAR.';
  }

  @override
  String get shareSheetTitle => 'Share Trip';

  @override
  String get messageOptionSubtitle => 'Send a direct message';

  @override
  String get removeFavoriteConfirmationTitle => 'Remove from Favorites?';

  @override
  String get removeFavoriteConfirmationContent => 'Are you sure you want to remove this item from your favorites?';

  @override
  String get removeButton => 'Remove';

  @override
  String get exitAppConfirmationTitle => 'Exit App?';

  @override
  String get exitAppConfirmationContent => 'Are you sure you want to exit the app?';

  @override
  String get exitButton => 'Exit';

  @override
  String get stayButton => 'Stay';

  @override
  String get noAdsFoundTitle => 'No Advertisements';

  @override
  String get noAdsFoundSubtitle => 'There are no special offers available at the moment.';

  @override
  String get noTripsFoundTitle => 'No Trips Found';

  @override
  String get noTripsFoundSubtitle => 'We couldn\'t find any trips. Please check back later.';

  @override
  String get noResultsFoundTitle => 'No Results Found';

  @override
  String get noResultsFoundSubtitle => 'Try adjusting your search or filter to find what you\'re looking for.';

  @override
  String get clearFiltersButton => 'Clear Filters';
}
