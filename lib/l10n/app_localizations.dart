import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Farm Manager'**
  String get app_name;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Farm Manager'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep livestock records, request vet services, and manage your farm offline.'**
  String get welcomeSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Please enter your credentials.'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username / Email / Phone'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username, email or phone'**
  String get enterUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to get started.'**
  String get registerSubtitle;

  /// No description provided for @firstname.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstname;

  /// No description provided for @firstnameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstnameRequired;

  /// No description provided for @lastname.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastname;

  /// No description provided for @lastnameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastnameRequired;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @validPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter valid TZ phone (07xxxxxxxx)'**
  String get validPhone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional for Farmer)'**
  String get email;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmail;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMatch;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent!'**
  String get resetLinkSent;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link.'**
  String get forgotPasswordDesc;

  /// No description provided for @selectRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get selectRoleTitle;

  /// No description provided for @selectRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please choose the role that best describes your work.'**
  String get selectRoleSubtitle;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @farmerDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your livestock and request vet services'**
  String get farmerDesc;

  /// No description provided for @roleFarmerDesc.
  ///
  /// In en, this message translates to:
  /// **'Manages crops and livestock.'**
  String get roleFarmerDesc;

  /// No description provided for @vet.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get vet;

  /// No description provided for @vetDesc.
  ///
  /// In en, this message translates to:
  /// **'Provide services and manage appointments'**
  String get vetDesc;

  /// No description provided for @roleVetDesc.
  ///
  /// In en, this message translates to:
  /// **'Provides animal health services.'**
  String get roleVetDesc;

  /// No description provided for @researcher.
  ///
  /// In en, this message translates to:
  /// **' Researcher'**
  String get researcher;

  /// No description provided for @researcherDesc.
  ///
  /// In en, this message translates to:
  /// **'Access anonymized data for research'**
  String get researcherDesc;

  /// No description provided for @roleResearcherDesc.
  ///
  /// In en, this message translates to:
  /// **'Studies agricultural practices.'**
  String get roleResearcherDesc;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @roleSelected.
  ///
  /// In en, this message translates to:
  /// **'Role saved successfully'**
  String get roleSelected;

  /// No description provided for @continueToApp.
  ///
  /// In en, this message translates to:
  /// **'Continue to App'**
  String get continueToApp;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @livestock.
  ///
  /// In en, this message translates to:
  /// **'Livestock'**
  String get livestock;

  /// No description provided for @addLivestock.
  ///
  /// In en, this message translates to:
  /// **'Add Livestock'**
  String get addLivestock;

  /// No description provided for @healthReport.
  ///
  /// In en, this message translates to:
  /// **'Health Report'**
  String get healthReport;

  /// No description provided for @breedingRecord.
  ///
  /// In en, this message translates to:
  /// **'Breeding Record'**
  String get breedingRecord;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// No description provided for @offlineData.
  ///
  /// In en, this message translates to:
  /// **'Offline Data'**
  String get offlineData;

  /// No description provided for @syncingRecords.
  ///
  /// In en, this message translates to:
  /// **'Syncing records...'**
  String get syncingRecords;

  /// No description provided for @vetRequests.
  ///
  /// In en, this message translates to:
  /// **'Vet Requests'**
  String get vetRequests;

  /// No description provided for @serviceRequests.
  ///
  /// In en, this message translates to:
  /// **'Service Requests'**
  String get serviceRequests;

  /// No description provided for @prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescription;

  /// No description provided for @vetDashboard.
  ///
  /// In en, this message translates to:
  /// **'Vet Dashboard'**
  String get vetDashboard;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @researcherDashboard.
  ///
  /// In en, this message translates to:
  /// **'Researcher Dashboard'**
  String get researcherDashboard;

  /// No description provided for @submitDataRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Data Request'**
  String get submitDataRequest;

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @updateLanguage.
  ///
  /// In en, this message translates to:
  /// **'Update Language'**
  String get updateLanguage;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get serverError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registerSuccess;

  /// No description provided for @registrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get registrationComplete;

  /// No description provided for @chooseYourRole.
  ///
  /// In en, this message translates to:
  /// **'Now choose your role to continue'**
  String get chooseYourRole;

  /// No description provided for @dataSynced.
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully'**
  String get dataSynced;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'17 Nov 2025'**
  String get dateFormat;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.1'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developed by Japango'**
  String get developer;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contact;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating Account'**
  String get creatingAccount;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Email is Already Registered'**
  String get emailAlreadyRegistered;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validationError;

  /// No description provided for @registrationSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Successfully Registered'**
  String get registrationSuccessMsg;

  /// No description provided for @roleAssigned.
  ///
  /// In en, this message translates to:
  /// **'Role Set Successfully'**
  String get roleAssigned;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Keep your farm safe'**
  String get appTagline;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @ward.
  ///
  /// In en, this message translates to:
  /// **'Ward'**
  String get ward;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocation;

  /// No description provided for @captureGps.
  ///
  /// In en, this message translates to:
  /// **'Capture GPS'**
  String get captureGps;

  /// No description provided for @gpsCaptured.
  ///
  /// In en, this message translates to:
  /// **'GPS Captured'**
  String get gpsCaptured;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @locationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will help us provide better veterinary services near you'**
  String get locationSubtitle;

  /// No description provided for @setYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Set your location'**
  String get setYourLocation;

  /// No description provided for @yesAdd.
  ///
  /// In en, this message translates to:
  /// **'Yes Add'**
  String get yesAdd;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @addNewWard.
  ///
  /// In en, this message translates to:
  /// **'Add new ward'**
  String get addNewWard;

  /// No description provided for @notFoundPrompt.
  ///
  /// In en, this message translates to:
  /// **'Not Found Prompt'**
  String get notFoundPrompt;

  /// No description provided for @enterWardName.
  ///
  /// In en, this message translates to:
  /// **'Enter Ward Name'**
  String get enterWardName;

  /// No description provided for @wardName.
  ///
  /// In en, this message translates to:
  /// **'Ward name'**
  String get wardName;

  /// No description provided for @wardNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Ward name is Required'**
  String get wardNameRequired;

  /// No description provided for @districtId.
  ///
  /// In en, this message translates to:
  /// **'District id'**
  String get districtId;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @nowCaptureGps.
  ///
  /// In en, this message translates to:
  /// **'✓ Now capture GPS'**
  String get nowCaptureGps;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now →'**
  String get skipForNow;

  /// No description provided for @enterNewWardName.
  ///
  /// In en, this message translates to:
  /// **'Enter new ward name:'**
  String get enterNewWardName;

  /// No description provided for @wardExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Kilakala'**
  String get wardExample;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @pleaseEnterWardName.
  ///
  /// In en, this message translates to:
  /// **'Please enter ward name'**
  String get pleaseEnterWardName;

  /// No description provided for @addedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'has been added'**
  String get addedSuccessfully;

  /// No description provided for @locationSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Location saved successfully 🎉'**
  String get locationSavedSuccess;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @addingNewWard.
  ///
  /// In en, this message translates to:
  /// **'Adding new ward...'**
  String get addingNewWard;

  /// No description provided for @loadingDistricts.
  ///
  /// In en, this message translates to:
  /// **'Loading districts...'**
  String get loadingDistricts;

  /// No description provided for @loadingWards.
  ///
  /// In en, this message translates to:
  /// **'Loading wards...'**
  String get loadingWards;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Success'**
  String get registrationSuccess;

  /// No description provided for @completeFarmerProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Farmer Profile'**
  String get completeFarmerProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSaved;

  /// No description provided for @farmerDetailsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your farm. This helps us tailor your experience.'**
  String get farmerDetailsPrompt;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @farmPurpose.
  ///
  /// In en, this message translates to:
  /// **'Main Farm Purpose'**
  String get farmPurpose;

  /// No description provided for @totalLandAcres.
  ///
  /// In en, this message translates to:
  /// **'Total Land Acres'**
  String get totalLandAcres;

  /// No description provided for @acresRangeError.
  ///
  /// In en, this message translates to:
  /// **'Must be between 0.1 and 10,000'**
  String get acresRangeError;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Farming Experience'**
  String get yearsExperience;

  /// No description provided for @yearsRangeError.
  ///
  /// In en, this message translates to:
  /// **'Must be between 0 and 70'**
  String get yearsRangeError;

  /// No description provided for @profilePhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo (Optional)'**
  String get profilePhotoOptional;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @farmLocation.
  ///
  /// In en, this message translates to:
  /// **'Select farm Location'**
  String get farmLocation;

  /// No description provided for @addNewLivestock.
  ///
  /// In en, this message translates to:
  /// **'Add New Livestock'**
  String get addNewLivestock;

  /// No description provided for @animalDetails.
  ///
  /// In en, this message translates to:
  /// **'Animal Details'**
  String get animalDetails;

  /// No description provided for @invalidAnimalId.
  ///
  /// In en, this message translates to:
  /// **'Invalid Animal ID.'**
  String get invalidAnimalId;

  /// No description provided for @errorLoadingDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading details:'**
  String get errorLoadingDetails;

  /// No description provided for @selectAnimalDetails.
  ///
  /// In en, this message translates to:
  /// **'Select an animal to view details.'**
  String get selectAnimalDetails;

  /// No description provided for @animalAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Animal registered successfully!'**
  String get animalAddedSuccess;

  /// No description provided for @submissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed:'**
  String get submissionFailed;

  /// No description provided for @myLivestock.
  ///
  /// In en, this message translates to:
  /// **'My Livestock'**
  String get myLivestock;

  /// No description provided for @noLivestockRecords.
  ///
  /// In en, this message translates to:
  /// **'No livestock records found.'**
  String get noLivestockRecords;

  /// No description provided for @pressToAdd.
  ///
  /// In en, this message translates to:
  /// **'Press + to add livestock.'**
  String get pressToAdd;

  /// No description provided for @tagNumber.
  ///
  /// In en, this message translates to:
  /// **'Tag Number:'**
  String get tagNumber;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name:'**
  String get name;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species:'**
  String get species;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed:'**
  String get breed;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex:'**
  String get sex;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth:'**
  String get dateOfBirth;

  /// No description provided for @essentialInfo.
  ///
  /// In en, this message translates to:
  /// **'Essential Information (Required)'**
  String get essentialInfo;

  /// No description provided for @speciesRequired.
  ///
  /// In en, this message translates to:
  /// **'Species is required.'**
  String get speciesRequired;

  /// No description provided for @breedRequired.
  ///
  /// In en, this message translates to:
  /// **'Breed is required.'**
  String get breedRequired;

  /// No description provided for @tagNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Tag number'**
  String get tagNumberRequired;

  /// No description provided for @weightAtBirth.
  ///
  /// In en, this message translates to:
  /// **'Weight at Birth (kg)'**
  String get weightAtBirth;

  /// No description provided for @weightAtBirthRequired.
  ///
  /// In en, this message translates to:
  /// **'Weight at birth'**
  String get weightAtBirthRequired;

  /// No description provided for @sexRequired.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexRequired;

  /// No description provided for @statusRequired.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusRequired;

  /// No description provided for @optionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Optional Information'**
  String get optionalInfo;

  /// No description provided for @nameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (Optional)'**
  String get nameOptional;

  /// No description provided for @sireID.
  ///
  /// In en, this message translates to:
  /// **'Sire ID (Optional)'**
  String get sireID;

  /// No description provided for @damID.
  ///
  /// In en, this message translates to:
  /// **'Dam ID (Optional)'**
  String get damID;

  /// No description provided for @purchaseDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date (Optional)'**
  String get purchaseDateOptional;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @purchaseCostOptional.
  ///
  /// In en, this message translates to:
  /// **'Purchase Cost (Optional)'**
  String get purchaseCostOptional;

  /// No description provided for @sourceVendor.
  ///
  /// In en, this message translates to:
  /// **'Source/Vendor (Optional)'**
  String get sourceVendor;

  /// No description provided for @registerAnimal.
  ///
  /// In en, this message translates to:
  /// **'Register Animal'**
  String get registerAnimal;

  /// No description provided for @failedLoadDropdown.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dropdown data:'**
  String get failedLoadDropdown;

  /// No description provided for @livestockRegisteredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Livestock registered successfully!'**
  String get livestockRegisteredSuccess;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @dead.
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get dead;

  /// No description provided for @stolen.
  ///
  /// In en, this message translates to:
  /// **'Stolen'**
  String get stolen;

  /// No description provided for @dam.
  ///
  /// In en, this message translates to:
  /// **'Dam (Female)'**
  String get dam;

  /// No description provided for @sire.
  ///
  /// In en, this message translates to:
  /// **'Sire (Male)'**
  String get sire;

  /// No description provided for @breedingType.
  ///
  /// In en, this message translates to:
  /// **'Breeding Type'**
  String get breedingType;

  /// No description provided for @selectDamRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select the dam'**
  String get selectDamRequired;

  /// No description provided for @selectBreedingTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select the breeding type'**
  String get selectBreedingTypeRequired;

  /// No description provided for @semenCode.
  ///
  /// In en, this message translates to:
  /// **'Semen Code'**
  String get semenCode;

  /// No description provided for @semenCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Semen code is required'**
  String get semenCodeRequired;

  /// No description provided for @bullName.
  ///
  /// In en, this message translates to:
  /// **'Bull Name'**
  String get bullName;

  /// No description provided for @breedingDate.
  ///
  /// In en, this message translates to:
  /// **'Breeding Date'**
  String get breedingDate;

  /// No description provided for @dateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date is required'**
  String get dateRequired;

  /// No description provided for @expectedDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Expected Delivery Date'**
  String get expectedDeliveryDate;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @selectStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a status'**
  String get selectStatusRequired;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @recordBreeding.
  ///
  /// In en, this message translates to:
  /// **'Record Breeding'**
  String get recordBreeding;

  /// No description provided for @recordBirth.
  ///
  /// In en, this message translates to:
  /// **'Record Birth'**
  String get recordBirth;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @numberOfLiveBirths.
  ///
  /// In en, this message translates to:
  /// **'Number of Live Births'**
  String get numberOfLiveBirths;

  /// No description provided for @validNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number (must be 1 or more)'**
  String get validNumberRequired;

  /// No description provided for @birthNotes.
  ///
  /// In en, this message translates to:
  /// **'Birth Notes'**
  String get birthNotes;

  /// No description provided for @finalizeBirthRecord.
  ///
  /// In en, this message translates to:
  /// **'Finalize Birth Record'**
  String get finalizeBirthRecord;

  /// No description provided for @recordPregnancyCheck.
  ///
  /// In en, this message translates to:
  /// **'Record Pregnancy Check'**
  String get recordPregnancyCheck;

  /// No description provided for @checkDate.
  ///
  /// In en, this message translates to:
  /// **'Check Date'**
  String get checkDate;

  /// No description provided for @checkResult.
  ///
  /// In en, this message translates to:
  /// **'Check Result'**
  String get checkResult;

  /// No description provided for @checkResultPositive.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Pregnant'**
  String get checkResultPositive;

  /// No description provided for @checkResultNegative.
  ///
  /// In en, this message translates to:
  /// **'Failed (Open)'**
  String get checkResultNegative;

  /// No description provided for @selectResultRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a result'**
  String get selectResultRequired;

  /// No description provided for @checkMethod.
  ///
  /// In en, this message translates to:
  /// **'Check Method'**
  String get checkMethod;

  /// No description provided for @ultrasound.
  ///
  /// In en, this message translates to:
  /// **'Ultrasound'**
  String get ultrasound;

  /// No description provided for @rectalPalpation.
  ///
  /// In en, this message translates to:
  /// **'Rectal Palpation'**
  String get rectalPalpation;

  /// No description provided for @bloodTest.
  ///
  /// In en, this message translates to:
  /// **'Blood Test'**
  String get bloodTest;

  /// No description provided for @selectMethodRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a check method'**
  String get selectMethodRequired;

  /// No description provided for @recordNewBreeding.
  ///
  /// In en, this message translates to:
  /// **'Add new breeding records'**
  String get recordNewBreeding;

  /// No description provided for @breedingRecordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully to adding new breeding record'**
  String get breedingRecordSuccess;

  /// No description provided for @failedToLoadForm.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Form'**
  String get failedToLoadForm;

  /// No description provided for @tapToLoadDropdowns.
  ///
  /// In en, this message translates to:
  /// **'Tap to load dropdown'**
  String get tapToLoadDropdowns;

  /// No description provided for @noBreedingRecords.
  ///
  /// In en, this message translates to:
  /// **'No breeding record'**
  String get noBreedingRecords;

  /// No description provided for @breedingRecords.
  ///
  /// In en, this message translates to:
  /// **'Breeding Record'**
  String get breedingRecords;

  /// No description provided for @breedingRecordDetails.
  ///
  /// In en, this message translates to:
  /// **'Breeding Record Details'**
  String get breedingRecordDetails;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading data:'**
  String get errorLoading;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @recordId.
  ///
  /// In en, this message translates to:
  /// **'Record ID'**
  String get recordId;

  /// No description provided for @damId.
  ///
  /// In en, this message translates to:
  /// **'Dam ID'**
  String get damId;

  /// No description provided for @expectedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Expected Delivery'**
  String get expectedDelivery;

  /// No description provided for @pregnancyCheck.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Check'**
  String get pregnancyCheck;

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetails;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get deliveryDate;

  /// No description provided for @offspringCount.
  ///
  /// In en, this message translates to:
  /// **'Offspring Count'**
  String get offspringCount;

  /// No description provided for @deliveryNotes.
  ///
  /// In en, this message translates to:
  /// **'Delivery Notes'**
  String get deliveryNotes;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @recordCheck.
  ///
  /// In en, this message translates to:
  /// **'Record Check'**
  String get recordCheck;

  /// No description provided for @noSiresAvailable.
  ///
  /// In en, this message translates to:
  /// **'No sire available'**
  String get noSiresAvailable;

  /// No description provided for @noDamsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Dams available'**
  String get noDamsAvailable;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @saveCheck.
  ///
  /// In en, this message translates to:
  /// **'Save Check'**
  String get saveCheck;

  /// No description provided for @completeVetProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Vet Profile'**
  String get completeVetProfile;

  /// No description provided for @vetDetailsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your practice'**
  String get vetDetailsPrompt;

  /// No description provided for @submitForApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit for Approval'**
  String get submitForApproval;

  /// No description provided for @heatCycleEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **''**
  String get heatCycleEmptyStateMessage;

  /// No description provided for @heatCycles.
  ///
  /// In en, this message translates to:
  /// **'Heat Cycles'**
  String get heatCycles;

  /// No description provided for @deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveries;

  /// No description provided for @noDeliveriesYet.
  ///
  /// In en, this message translates to:
  /// **'No delivery records found.'**
  String get noDeliveriesYet;

  /// No description provided for @recordFirstDelivery.
  ///
  /// In en, this message translates to:
  /// **'Tap + to begin recording the first delivery.'**
  String get recordFirstDelivery;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @totalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Weight (kg)'**
  String get totalWeight;

  /// No description provided for @recordDelivery.
  ///
  /// In en, this message translates to:
  /// **'Record Delivery'**
  String get recordDelivery;

  /// No description provided for @inseminations.
  ///
  /// In en, this message translates to:
  /// **'Inseminations'**
  String get inseminations;

  /// No description provided for @noInseminationsYet.
  ///
  /// In en, this message translates to:
  /// **'No insemination records found.'**
  String get noInseminationsYet;

  /// No description provided for @recordFirstInsemination.
  ///
  /// In en, this message translates to:
  /// **'Tap + to begin recording the first insemination.'**
  String get recordFirstInsemination;

  /// No description provided for @recordInsemIination.
  ///
  /// In en, this message translates to:
  /// **'Record Insemination'**
  String get recordInsemIination;

  /// No description provided for @lactations.
  ///
  /// In en, this message translates to:
  /// **'Lactations'**
  String get lactations;

  /// No description provided for @noLactationsYet.
  ///
  /// In en, this message translates to:
  /// **'No lactation records found.'**
  String get noLactationsYet;

  /// No description provided for @recordFirstLactation.
  ///
  /// In en, this message translates to:
  /// **'Tap + to begin recording the first lactation cycle.'**
  String get recordFirstLactation;

  /// No description provided for @recordLactation.
  ///
  /// In en, this message translates to:
  /// **'Record Lactation'**
  String get recordLactation;

  /// No description provided for @lactationNumber.
  ///
  /// In en, this message translates to:
  /// **'Lactation'**
  String get lactationNumber;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @projectedDuration.
  ///
  /// In en, this message translates to:
  /// **'{projectedDays} days projected'**
  String projectedDuration(Object projectedDays);

  /// No description provided for @offspring.
  ///
  /// In en, this message translates to:
  /// **'Offspring'**
  String get offspring;

  /// No description provided for @noOffspringYet.
  ///
  /// In en, this message translates to:
  /// **'No offspring records found.'**
  String get noOffspringYet;

  /// No description provided for @recordFirstOffspring.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record the first birth.'**
  String get recordFirstOffspring;

  /// No description provided for @recordOffspring.
  ///
  /// In en, this message translates to:
  /// **'Record Offspring'**
  String get recordOffspring;

  /// No description provided for @born.
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get born;

  /// No description provided for @readyToRegister.
  ///
  /// In en, this message translates to:
  /// **'Ready to Register'**
  String get readyToRegister;

  /// No description provided for @pregnancyChecks.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Checks'**
  String get pregnancyChecks;

  /// No description provided for @noChecksYet.
  ///
  /// In en, this message translates to:
  /// **'No pregnancy check records found.'**
  String get noChecksYet;

  /// No description provided for @recordFirstCheck.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record the first pregnancy scan or test result.'**
  String get recordFirstCheck;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @recordInsemination.
  ///
  /// In en, this message translates to:
  /// **'Record Insemination'**
  String get recordInsemination;

  /// No description provided for @semenInventory.
  ///
  /// In en, this message translates to:
  /// **'Semen Inventory'**
  String get semenInventory;

  /// No description provided for @noSemenRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No semen inventory records found.'**
  String get noSemenRecordsYet;

  /// No description provided for @addFirstSemenRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first semen inventory record.'**
  String get addFirstSemenRecord;

  /// No description provided for @addSemenRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Semen Record'**
  String get addSemenRecord;

  /// No description provided for @semenSource.
  ///
  /// In en, this message translates to:
  /// **'Semen Source'**
  String get semenSource;

  /// No description provided for @semenSourceRequired.
  ///
  /// In en, this message translates to:
  /// **'Semen source is required'**
  String get semenSourceRequired;

  /// No description provided for @semenType.
  ///
  /// In en, this message translates to:
  /// **'Semen Type'**
  String get semenType;

  /// No description provided for @semenTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Semen type is required'**
  String get semenTypeRequired;

  /// No description provided for @semenQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity (Straws)'**
  String get semenQuantity;

  /// No description provided for @validQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity (must be 1 or more)'**
  String get validQuantityRequired;

  /// No description provided for @semenNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get semenNotes;

  /// No description provided for @saveSemenRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Semen Record'**
  String get saveSemenRecord;

  /// No description provided for @semenRecordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Semen inventory record added successfully!'**
  String get semenRecordSuccess;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @pressPlusToAdd.
  ///
  /// In en, this message translates to:
  /// **'Press + to add records.'**
  String get pressPlusToAdd;

  /// No description provided for @recordFirstSemenBatch.
  ///
  /// In en, this message translates to:
  /// **'Record the first semen batch to get started.'**
  String get recordFirstSemenBatch;

  /// No description provided for @availableUnits.
  ///
  /// In en, this message translates to:
  /// **'Available Units'**
  String get availableUnits;

  /// No description provided for @addSemen.
  ///
  /// In en, this message translates to:
  /// **'Add Semen'**
  String get addSemen;

  /// No description provided for @recordHeatCycle.
  ///
  /// In en, this message translates to:
  /// **'Record Heat Cycle'**
  String get recordHeatCycle;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @heatCycleDetails.
  ///
  /// In en, this message translates to:
  /// **'Heat Cycle Details'**
  String get heatCycleDetails;

  /// No description provided for @animalID.
  ///
  /// In en, this message translates to:
  /// **'Animal ID'**
  String get animalID;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @completionDate.
  ///
  /// In en, this message translates to:
  /// **'Completion Date'**
  String get completionDate;

  /// No description provided for @nextObservation.
  ///
  /// In en, this message translates to:
  /// **'Next Observation'**
  String get nextObservation;

  /// No description provided for @endHeatCycle.
  ///
  /// In en, this message translates to:
  /// **'End Cycle'**
  String get endHeatCycle;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @selectAnimal.
  ///
  /// In en, this message translates to:
  /// **'Select Animal'**
  String get selectAnimal;

  /// No description provided for @chooseAnimal.
  ///
  /// In en, this message translates to:
  /// **'Choose Animal'**
  String get chooseAnimal;

  /// No description provided for @animalRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select an animal.'**
  String get animalRequired;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get selectStartDate;

  /// No description provided for @notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'E.g., Signs observed (mucus, mounting, restlessness)'**
  String get notesPlaceholder;

  /// No description provided for @heatCycleRecorded.
  ///
  /// In en, this message translates to:
  /// **'Heat cycle recorded successfully!'**
  String get heatCycleRecorded;

  /// No description provided for @observedDate.
  ///
  /// In en, this message translates to:
  /// **'Observed Date'**
  String get observedDate;

  /// No description provided for @selectObservedDate.
  ///
  /// In en, this message translates to:
  /// **'Select Observed Date'**
  String get selectObservedDate;

  /// No description provided for @heatIntensity.
  ///
  /// In en, this message translates to:
  /// **'Heat Intensity'**
  String get heatIntensity;

  /// No description provided for @selectIntensity.
  ///
  /// In en, this message translates to:
  /// **'Select Intensity'**
  String get selectIntensity;

  /// No description provided for @intensityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select the heat intensity.'**
  String get intensityRequired;

  /// No description provided for @errorFetchingDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not load heat cycle details.'**
  String get errorFetchingDetails;

  /// No description provided for @selectAHeatCycle.
  ///
  /// In en, this message translates to:
  /// **'Select a heat cycle to view details.'**
  String get selectAHeatCycle;

  /// No description provided for @inseminatedStatus.
  ///
  /// In en, this message translates to:
  /// **'Inseminated / Completed'**
  String get inseminatedStatus;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Missed / Completed'**
  String get completedStatus;

  /// No description provided for @noNotesProvided.
  ///
  /// In en, this message translates to:
  /// **'No notes provided for this cycle.'**
  String get noNotesProvided;

  /// No description provided for @nextExpected.
  ///
  /// In en, this message translates to:
  /// **'Next Expected'**
  String get nextExpected;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// No description provided for @inseminationRecorded.
  ///
  /// In en, this message translates to:
  /// **'Insemination Recorded'**
  String get inseminationRecorded;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noFemaleAnimalsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No female animals available'**
  String get noFemaleAnimalsAvailable;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @collectionDate.
  ///
  /// In en, this message translates to:
  /// **'Collection Date'**
  String get collectionDate;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose (straws)'**
  String get dose;

  /// No description provided for @motility.
  ///
  /// In en, this message translates to:
  /// **'Motility (%)'**
  String get motility;

  /// No description provided for @costPerStraw.
  ///
  /// In en, this message translates to:
  /// **'Cost per Straw'**
  String get costPerStraw;

  /// No description provided for @sourceSupplier.
  ///
  /// In en, this message translates to:
  /// **'Source / Supplier'**
  String get sourceSupplier;

  /// No description provided for @sourceSupplierHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of the supplier or leave blank if collected on-farm'**
  String get sourceSupplierHint;

  /// No description provided for @internalBullId.
  ///
  /// In en, this message translates to:
  /// **'Internal Bull ID'**
  String get internalBullId;

  /// No description provided for @bullTag.
  ///
  /// In en, this message translates to:
  /// **'Bull Tag / Ear Tag'**
  String get bullTag;

  /// No description provided for @selectCollectionDate.
  ///
  /// In en, this message translates to:
  /// **'Select Collection Date'**
  String get selectCollectionDate;

  /// No description provided for @selectBreed.
  ///
  /// In en, this message translates to:
  /// **'Select Breed'**
  String get selectBreed;

  /// No description provided for @selectOwnedBull.
  ///
  /// In en, this message translates to:
  /// **'Select Owned Bull'**
  String get selectOwnedBull;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get invalidNumber;

  /// No description provided for @invalidPercentage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid percentage (0-100)'**
  String get invalidPercentage;

  /// No description provided for @optionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Optional Details'**
  String get optionalDetails;

  /// No description provided for @semenAddInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Semen Information'**
  String get semenAddInfo;

  /// No description provided for @fillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get fillAllRequiredFields;

  /// No description provided for @savingSemen.
  ///
  /// In en, this message translates to:
  /// **'Saving Semen...'**
  String get savingSemen;

  /// No description provided for @strawCode.
  ///
  /// In en, this message translates to:
  /// **'Straw Code / Batch'**
  String get strawCode;

  /// No description provided for @timesUsed.
  ///
  /// In en, this message translates to:
  /// **'Times Used'**
  String get timesUsed;

  /// No description provided for @conceptions.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Conceptions'**
  String get conceptions;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Conception Rate'**
  String get successRate;

  /// No description provided for @generalDetails.
  ///
  /// In en, this message translates to:
  /// **'General Details'**
  String get generalDetails;

  /// No description provided for @internalBullSource.
  ///
  /// In en, this message translates to:
  /// **'Internal Bull / Own Collection'**
  String get internalBullSource;

  /// No description provided for @usageHistory.
  ///
  /// In en, this message translates to:
  /// **'Usage History'**
  String get usageHistory;

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @noUsageRecords.
  ///
  /// In en, this message translates to:
  /// **'No usage records yet'**
  String get noUsageRecords;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecord;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDelete;

  /// No description provided for @deleteSemenWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this semen record? This action cannot be undone.'**
  String get deleteSemenWarning;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editSemen.
  ///
  /// In en, this message translates to:
  /// **''**
  String get editSemen;

  /// No description provided for @semenEditInfo.
  ///
  /// In en, this message translates to:
  /// **''**
  String get semenEditInfo;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **''**
  String get update;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'TZS'**
  String get currency;

  /// Formats a number as TZS currency.
  ///
  /// In en, this message translates to:
  /// **'{amount}'**
  String formatCurrency(double amount);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @editInsemination.
  ///
  /// In en, this message translates to:
  /// **'Edit Insemination'**
  String get editInsemination;

  /// No description provided for @selectDam.
  ///
  /// In en, this message translates to:
  /// **'Select Dam'**
  String get selectDam;

  /// No description provided for @heatCycle.
  ///
  /// In en, this message translates to:
  /// **'Heat Cycle'**
  String get heatCycle;

  /// No description provided for @selectHeatCycle.
  ///
  /// In en, this message translates to:
  /// **'Select Heat Cycle'**
  String get selectHeatCycle;

  /// No description provided for @breedingMethod.
  ///
  /// In en, this message translates to:
  /// **'Breeding Method'**
  String get breedingMethod;

  /// No description provided for @natural.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get natural;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @selectSire.
  ///
  /// In en, this message translates to:
  /// **'Select Sire'**
  String get selectSire;

  /// No description provided for @semenStraw.
  ///
  /// In en, this message translates to:
  /// **'Semen Straw'**
  String get semenStraw;

  /// No description provided for @selectSemen.
  ///
  /// In en, this message translates to:
  /// **'Select Semen'**
  String get selectSemen;

  /// No description provided for @inseminationDate.
  ///
  /// In en, this message translates to:
  /// **'Insemination Date'**
  String get inseminationDate;

  /// No description provided for @technician.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get technician;

  /// No description provided for @breedingDetails.
  ///
  /// In en, this message translates to:
  /// **'Breeding Details'**
  String get breedingDetails;

  /// No description provided for @breedingPartner.
  ///
  /// In en, this message translates to:
  /// **'Breeding Partner'**
  String get breedingPartner;

  /// No description provided for @sireName.
  ///
  /// In en, this message translates to:
  /// **'Sire Name'**
  String get sireName;

  /// No description provided for @detailsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Details unavailable for this breeding method.'**
  String get detailsUnavailable;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes recorded.'**
  String get noNotes;

  /// No description provided for @checkRecord.
  ///
  /// In en, this message translates to:
  /// **'Check Record'**
  String get checkRecord;

  /// No description provided for @noPregnancyChecksRecorded.
  ///
  /// In en, this message translates to:
  /// **'No pregnancy checks have been recorded for this insemination.'**
  String get noPregnancyChecksRecorded;

  /// No description provided for @deleteInsemination.
  ///
  /// In en, this message translates to:
  /// **'Delete Insemination Record'**
  String get deleteInsemination;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the record?'**
  String get deleteConfirmation;

  /// No description provided for @searchInseminations.
  ///
  /// In en, this message translates to:
  /// **'Search by Tag, Name, or Status'**
  String get searchInseminations;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found for your search.'**
  String get noResultsFound;

  /// No description provided for @deleteCheck.
  ///
  /// In en, this message translates to:
  /// **'delete check'**
  String get deleteCheck;

  /// No description provided for @deleteCheckConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the check record? This action cannot be undone.'**
  String get deleteCheckConfirmation;

  /// No description provided for @fetusCount.
  ///
  /// In en, this message translates to:
  /// **''**
  String get fetusCount;

  /// No description provided for @checkDetails.
  ///
  /// In en, this message translates to:
  /// **''**
  String get checkDetails;

  /// No description provided for @relatedInsemination.
  ///
  /// In en, this message translates to:
  /// **''**
  String get relatedInsemination;

  /// No description provided for @viewInseminationDetails.
  ///
  /// In en, this message translates to:
  /// **''**
  String get viewInseminationDetails;

  /// No description provided for @addPregnancyCheck.
  ///
  /// In en, this message translates to:
  /// **'Add Pregnancy Check'**
  String get addPregnancyCheck;

  /// No description provided for @selectInsemination.
  ///
  /// In en, this message translates to:
  /// **'Select Insemination'**
  String get selectInsemination;

  /// No description provided for @selectMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Method'**
  String get selectMethod;

  /// No description provided for @selectResult.
  ///
  /// In en, this message translates to:
  /// **'Select Result'**
  String get selectResult;

  /// No description provided for @pregnancyDetails.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Details'**
  String get pregnancyDetails;

  /// No description provided for @selectTechnician.
  ///
  /// In en, this message translates to:
  /// **'Select Technician'**
  String get selectTechnician;

  /// No description provided for @pregnantFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields for a positive pregnancy result'**
  String get pregnantFieldsRequired;

  /// No description provided for @editPregnancyCheck.
  ///
  /// In en, this message translates to:
  /// **'Edit Pregnancy Check'**
  String get editPregnancyCheck;

  /// No description provided for @searchChecks.
  ///
  /// In en, this message translates to:
  /// **'Search by Tag, Name, or Result'**
  String get searchChecks;

  /// No description provided for @liveBorn.
  ///
  /// In en, this message translates to:
  /// **'Live Born'**
  String get liveBorn;

  /// No description provided for @totalBorn.
  ///
  /// In en, this message translates to:
  /// **'Total Born'**
  String get totalBorn;

  /// No description provided for @searchDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Search by Tag, Name, or Date'**
  String get searchDeliveries;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'delivery'**
  String get delivery;

  /// No description provided for @deleteDelivery.
  ///
  /// In en, this message translates to:
  /// **'deleteDelivery'**
  String get deleteDelivery;

  /// No description provided for @deleteDeliveryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the delivery record? This action cannot be undone and will affect related records.'**
  String get deleteDeliveryConfirmation;

  /// No description provided for @deliverySummary.
  ///
  /// In en, this message translates to:
  /// **'deliverySummary'**
  String get deliverySummary;

  /// No description provided for @deliveryType.
  ///
  /// In en, this message translates to:
  /// **'deliveryType'**
  String get deliveryType;

  /// No description provided for @calvingEaseScore.
  ///
  /// In en, this message translates to:
  /// **'calvingEaseScore'**
  String get calvingEaseScore;

  /// No description provided for @damConditionAfter.
  ///
  /// In en, this message translates to:
  /// **'damConditionAfter'**
  String get damConditionAfter;

  /// No description provided for @offspringRecords.
  ///
  /// In en, this message translates to:
  /// **'offspringRecords'**
  String get offspringRecords;

  /// No description provided for @stillborn.
  ///
  /// In en, this message translates to:
  /// **'stillborn'**
  String get stillborn;

  /// No description provided for @stillbornCalf.
  ///
  /// In en, this message translates to:
  /// **'stillbornCalf'**
  String get stillbornCalf;

  /// No description provided for @birthWeight.
  ///
  /// In en, this message translates to:
  /// **'birthWeight'**
  String get birthWeight;

  /// No description provided for @colostrumIntake.
  ///
  /// In en, this message translates to:
  /// **'colostrumIntake'**
  String get colostrumIntake;

  /// No description provided for @navelTreated.
  ///
  /// In en, this message translates to:
  /// **'navelTreated'**
  String get navelTreated;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'downloadPdf'**
  String get downloadPdf;

  /// No description provided for @saveDelivery.
  ///
  /// In en, this message translates to:
  /// **'Save Delivery'**
  String get saveDelivery;

  /// No description provided for @selectInseminationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select an insemination record first.'**
  String get selectInseminationRequired;

  /// No description provided for @atLeastOneOffspringRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one offspring record is required.'**
  String get atLeastOneOffspringRequired;

  /// No description provided for @selectDeliveryType.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Type'**
  String get selectDeliveryType;

  /// No description provided for @scoreEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get scoreEasy;

  /// No description provided for @scoreDifficult.
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get scoreDifficult;

  /// No description provided for @selectDamCondition.
  ///
  /// In en, this message translates to:
  /// **'Select Dam Condition'**
  String get selectDamCondition;

  /// No description provided for @addOffspring.
  ///
  /// In en, this message translates to:
  /// **'Add Offspring'**
  String get addOffspring;

  /// No description provided for @removeOffspring.
  ///
  /// In en, this message translates to:
  /// **'Remove Offspring'**
  String get removeOffspring;

  /// No description provided for @temporaryTag.
  ///
  /// In en, this message translates to:
  /// **'Temporary Tag'**
  String get temporaryTag;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @birthCondition.
  ///
  /// In en, this message translates to:
  /// **'Birth Condition'**
  String get birthCondition;

  /// No description provided for @offspringNotes.
  ///
  /// In en, this message translates to:
  /// **'Offspring Notes'**
  String get offspringNotes;

  /// No description provided for @editDelivery.
  ///
  /// In en, this message translates to:
  /// **'Edit Delivery'**
  String get editDelivery;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @insemination.
  ///
  /// In en, this message translates to:
  /// **'Insemination'**
  String get insemination;

  /// No description provided for @unknownInsemination.
  ///
  /// In en, this message translates to:
  /// **'Unknown Insemination'**
  String get unknownInsemination;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @noTemporaryTag.
  ///
  /// In en, this message translates to:
  /// **'No temporary tag'**
  String get noTemporaryTag;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Stillborn'**
  String get condition;

  /// No description provided for @offspringNotFound.
  ///
  /// In en, this message translates to:
  /// **'Offspring not found'**
  String get offspringNotFound;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @offspringDetails.
  ///
  /// In en, this message translates to:
  /// **'Offspring Details'**
  String get offspringDetails;

  /// No description provided for @birthEvent.
  ///
  /// In en, this message translates to:
  /// **'Birth Event'**
  String get birthEvent;

  /// No description provided for @lineage.
  ///
  /// In en, this message translates to:
  /// **'Lineage'**
  String get lineage;

  /// No description provided for @damTag.
  ///
  /// In en, this message translates to:
  /// **'Dam Tag'**
  String get damTag;

  /// No description provided for @sireTag.
  ///
  /// In en, this message translates to:
  /// **'Sire Tag'**
  String get sireTag;

  /// No description provided for @registrationStatusRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registrationStatusRegistered;

  /// No description provided for @registrationStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Registration'**
  String get registrationStatusPending;

  /// No description provided for @registeredAs.
  ///
  /// In en, this message translates to:
  /// **'Registered as'**
  String get registeredAs;

  /// No description provided for @livestockId.
  ///
  /// In en, this message translates to:
  /// **'Livestock ID'**
  String get livestockId;

  /// No description provided for @registerOffspring.
  ///
  /// In en, this message translates to:
  /// **'Register Offspring'**
  String get registerOffspring;

  /// No description provided for @registerOffspringMessage.
  ///
  /// In en, this message translates to:
  /// **'This offspring is ready to be registered with an official tag/ID.'**
  String get registerOffspringMessage;

  /// No description provided for @unknownTag.
  ///
  /// In en, this message translates to:
  /// **'Unknown Tag'**
  String get unknownTag;

  /// No description provided for @selectDeliveryContext.
  ///
  /// In en, this message translates to:
  /// **'Delivery Context'**
  String get selectDeliveryContext;

  /// No description provided for @identification.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get identification;

  /// No description provided for @birthMetrics.
  ///
  /// In en, this message translates to:
  /// **'Birth Metrics'**
  String get birthMetrics;

  /// No description provided for @birthWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Birth Weight (kg)'**
  String get birthWeightKg;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @saveOffspring.
  ///
  /// In en, this message translates to:
  /// **'Save Offspring'**
  String get saveOffspring;

  /// No description provided for @savingOffspring.
  ///
  /// In en, this message translates to:
  /// **'Saving offspring record...'**
  String get savingOffspring;

  /// No description provided for @offspringRecordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Offspring record saved successfully'**
  String get offspringRecordSuccess;

  /// No description provided for @enterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight'**
  String get enterValidWeight;

  /// No description provided for @editOffspring.
  ///
  /// In en, this message translates to:
  /// **'Edit Offspring'**
  String get editOffspring;

  /// No description provided for @savingChanges.
  ///
  /// In en, this message translates to:
  /// **'Saving changes...'**
  String get savingChanges;

  /// No description provided for @deliveryContext.
  ///
  /// In en, this message translates to:
  /// **'Delivery Context'**
  String get deliveryContext;

  /// No description provided for @registrationInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the official livestock tag/ID to complete registration.'**
  String get registrationInstructions;

  /// No description provided for @newLivestockTag.
  ///
  /// In en, this message translates to:
  /// **'Official Livestock Tag / ID'**
  String get newLivestockTag;

  /// No description provided for @enterUniqueTag.
  ///
  /// In en, this message translates to:
  /// **'Enter a unique tag or ID'**
  String get enterUniqueTag;

  /// No description provided for @registrationDate.
  ///
  /// In en, this message translates to:
  /// **'Registration Date'**
  String get registrationDate;

  /// No description provided for @confirmRegistration.
  ///
  /// In en, this message translates to:
  /// **'Confirm Registration'**
  String get confirmRegistration;

  /// No description provided for @submittingRegistration.
  ///
  /// In en, this message translates to:
  /// **'Submitting registration...'**
  String get submittingRegistration;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @totalYield.
  ///
  /// In en, this message translates to:
  /// **'Total Yield (liters)'**
  String get totalYield;

  /// No description provided for @editLactation.
  ///
  /// In en, this message translates to:
  /// **'Edit Lactation'**
  String get editLactation;

  /// No description provided for @lactationStarted.
  ///
  /// In en, this message translates to:
  /// **'Lactation Started'**
  String get lactationStarted;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @peakDate.
  ///
  /// In en, this message translates to:
  /// **'Peak Date'**
  String get peakDate;

  /// No description provided for @dateAfterStartDateError.
  ///
  /// In en, this message translates to:
  /// **'Date must be on or after the lactation start date.'**
  String get dateAfterStartDateError;

  /// No description provided for @invalidDateError.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format.'**
  String get invalidDateError;

  /// No description provided for @dryOffDate.
  ///
  /// In en, this message translates to:
  /// **'Dry Off Date'**
  String get dryOffDate;

  /// No description provided for @totalMilkKg.
  ///
  /// In en, this message translates to:
  /// **'Total Milk Yield (kg)'**
  String get totalMilkKg;

  /// No description provided for @invalidNumberError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get invalidNumberError;

  /// No description provided for @mustBePositiveError.
  ///
  /// In en, this message translates to:
  /// **'Value must be positive.'**
  String get mustBePositiveError;

  /// No description provided for @daysInMilk.
  ///
  /// In en, this message translates to:
  /// **'Days in Milk'**
  String get daysInMilk;

  /// No description provided for @invalidIntegerError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid integer.'**
  String get invalidIntegerError;

  /// No description provided for @savingLactation.
  ///
  /// In en, this message translates to:
  /// **'Saving lactation record...'**
  String get savingLactation;

  /// No description provided for @lactationRecordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Lactation record saved successfully!'**
  String get lactationRecordSuccess;

  /// No description provided for @animalInformation.
  ///
  /// In en, this message translates to:
  /// **'Animal Information'**
  String get animalInformation;

  /// No description provided for @keyDates.
  ///
  /// In en, this message translates to:
  /// **'Key Dates'**
  String get keyDates;

  /// No description provided for @initialMetrics.
  ///
  /// In en, this message translates to:
  /// **'Initial Metrics (Optional)'**
  String get initialMetrics;

  /// No description provided for @lactationDetails.
  ///
  /// In en, this message translates to:
  /// **'Lactation Details'**
  String get lactationDetails;

  /// No description provided for @yieldSummary.
  ///
  /// In en, this message translates to:
  /// **'Yield Summary'**
  String get yieldSummary;

  /// No description provided for @totalMilkProduced.
  ///
  /// In en, this message translates to:
  /// **'Total Milk Produced'**
  String get totalMilkProduced;

  /// No description provided for @lactationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Lactation record not found.'**
  String get lactationNotFound;

  /// No description provided for @wardAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ward added successfully!'**
  String get wardAddedSuccess;

  /// No description provided for @researcherProfile.
  ///
  /// In en, this message translates to:
  /// **'Researcher Profile'**
  String get researcherProfile;

  /// No description provided for @welcomeResearcher.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Researcher!'**
  String get welcomeResearcher;

  /// No description provided for @researcherDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to access research tools and data.'**
  String get researcherDetailsSubtitle;

  /// No description provided for @affiliatedInstitution.
  ///
  /// In en, this message translates to:
  /// **'Affiliated Institution'**
  String get affiliatedInstitution;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @researchFocusArea.
  ///
  /// In en, this message translates to:
  /// **'Research Focus Area'**
  String get researchFocusArea;

  /// No description provided for @academicTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Title'**
  String get academicTitle;

  /// No description provided for @orcidId.
  ///
  /// In en, this message translates to:
  /// **'ORCID ID'**
  String get orcidId;

  /// No description provided for @researchPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose of Research'**
  String get researchPurpose;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'A network or server error occurred. Please try again later.'**
  String get genericError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
