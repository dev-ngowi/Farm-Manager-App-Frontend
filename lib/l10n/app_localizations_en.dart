// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Farm Manager';

  @override
  String get welcomeTitle => 'Welcome to Farm Manager';

  @override
  String get welcomeSubtitle =>
      'Keep livestock records, request vet services, and manage your farm offline.';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get continueBtn => 'Continue';

  @override
  String get login => 'Login';

  @override
  String get loginSubtitle => 'Welcome back! Please enter your credentials.';

  @override
  String get username => 'Username / Email / Phone';

  @override
  String get enterUsername => 'Please enter your username, email or phone';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get register => 'Create Account';

  @override
  String get registerSubtitle => 'Fill in your details to get started.';

  @override
  String get firstname => 'First Name';

  @override
  String get firstnameRequired => 'First name is required';

  @override
  String get lastname => 'Last Name';

  @override
  String get lastnameRequired => 'Last name is required';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get validPhone => 'Enter valid TZ phone (07xxxxxxxx)';

  @override
  String get email => 'Email (Optional for Farmer)';

  @override
  String get validEmail => 'Please enter a valid email';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMatch => 'Passwords do not match';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent => 'Reset link sent!';

  @override
  String get forgotPasswordDesc =>
      'Enter your email and we\'ll send you a reset link.';

  @override
  String get selectRoleTitle => 'Who are you?';

  @override
  String get selectRoleSubtitle =>
      'Please choose the role that best describes your work.';

  @override
  String get select => 'Select';

  @override
  String get farmer => 'Farmer';

  @override
  String get farmerDesc => 'Manage your livestock and request vet services';

  @override
  String get roleFarmerDesc => 'Manages crops and livestock.';

  @override
  String get vet => 'Veterinarian';

  @override
  String get vetDesc => 'Provide services and manage appointments';

  @override
  String get roleVetDesc => 'Provides animal health services.';

  @override
  String get researcher => ' Researcher';

  @override
  String get researcherDesc => 'Access anonymized data for research';

  @override
  String get roleResearcherDesc => 'Studies agricultural practices.';

  @override
  String get welcome => 'Welcome!';

  @override
  String get roleSelected => 'Role saved successfully';

  @override
  String get continueToApp => 'Continue to App';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get livestock => 'Livestock';

  @override
  String get addLivestock => 'Add Livestock';

  @override
  String get healthReport => 'Health Report';

  @override
  String get breedingRecord => 'Breeding Record';

  @override
  String get syncData => 'Sync Data';

  @override
  String get offlineData => 'Offline Data';

  @override
  String get syncingRecords => 'Syncing records...';

  @override
  String get vetRequests => 'Vet Requests';

  @override
  String get serviceRequests => 'Service Requests';

  @override
  String get prescription => 'Prescription';

  @override
  String get vetDashboard => 'Vet Dashboard';

  @override
  String get analytics => 'Analytics';

  @override
  String get researcherDashboard => 'Researcher Dashboard';

  @override
  String get submitDataRequest => 'Submit Data Request';

  @override
  String get chart => 'Chart';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get updateLanguage => 'Update Language';

  @override
  String get logout => 'Logout';

  @override
  String get error => 'Error';

  @override
  String get networkError => 'No internet connection';

  @override
  String get serverError => 'Server error. Please try again.';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get success => 'Success';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get registrationComplete => 'Account created successfully!';

  @override
  String get chooseYourRole => 'Now choose your role to continue';

  @override
  String get dataSynced => 'Data synced successfully';

  @override
  String get requestSent => 'Request sent';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get november => 'November';

  @override
  String get dateFormat => '17 Nov 2025';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get version => 'Version 1.1';

  @override
  String get developer => 'Developed by Japango';

  @override
  String get contact => 'Contact Support';

  @override
  String get creatingAccount => 'Creating Account';

  @override
  String get emailAlreadyRegistered => 'Email is Already Registered';

  @override
  String get validationError => 'Validation Error';

  @override
  String get registrationSuccessMsg => 'Successfully Registered';

  @override
  String get roleAssigned => 'Role Set Successfully';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get appTagline => 'Keep your farm safe';

  @override
  String get processing => 'Processing';

  @override
  String get ward => 'Ward';

  @override
  String get saveLocation => 'Save Location';

  @override
  String get captureGps => 'Capture GPS';

  @override
  String get gpsCaptured => 'GPS Captured';

  @override
  String get district => 'District';

  @override
  String get region => 'Region';

  @override
  String get locationSubtitle =>
      'This will help us provide better veterinary services near you';

  @override
  String get setYourLocation => 'Set your location';

  @override
  String get yesAdd => 'Yes Add';

  @override
  String get no => 'No';

  @override
  String get addNewWard => 'Add new ward';

  @override
  String get notFoundPrompt => 'Not Found Prompt';

  @override
  String get enterWardName => 'Enter Ward Name';

  @override
  String get wardName => 'Ward name';

  @override
  String get wardNameRequired => 'Ward name is Required';

  @override
  String get districtId => 'District id';

  @override
  String get save => 'Save';

  @override
  String get nowCaptureGps => '✓ Now capture GPS';

  @override
  String get skipForNow => 'Skip for now →';

  @override
  String get enterNewWardName => 'Enter new ward name:';

  @override
  String get wardExample => 'Example: Kilakala';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get pleaseEnterWardName => 'Please enter ward name';

  @override
  String get addedSuccessfully => 'has been added';

  @override
  String get locationSavedSuccess =>
      'Congratulations! Location saved successfully 🎉';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get addingNewWard => 'Adding new ward...';

  @override
  String get loadingDistricts => 'Loading districts...';

  @override
  String get loadingWards => 'Loading wards...';

  @override
  String get registrationSuccess => 'Registration Success';

  @override
  String get completeFarmerProfile => 'Complete Farmer Profile';

  @override
  String get profileSaved => 'Profile saved successfully!';

  @override
  String get farmerDetailsPrompt =>
      'Tell us about your farm. This helps us tailor your experience.';

  @override
  String get farmName => 'Farm Name';

  @override
  String get requiredField => 'Required';

  @override
  String get farmPurpose => 'Main Farm Purpose';

  @override
  String get totalLandAcres => 'Total Land Acres';

  @override
  String get acresRangeError => 'Must be between 0.1 and 10,000';

  @override
  String get yearsExperience => 'Years of Farming Experience';

  @override
  String get yearsRangeError => 'Must be between 0 and 70';

  @override
  String get profilePhotoOptional => 'Profile Photo (Optional)';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get farmLocation => 'Select farm Location';

  @override
  String get addNewLivestock => 'Add New Livestock';

  @override
  String get animalDetails => 'Animal Details';

  @override
  String get invalidAnimalId => 'Invalid Animal ID.';

  @override
  String get errorLoadingDetails => 'Error loading details:';

  @override
  String get selectAnimalDetails => 'Select an animal to view details.';

  @override
  String get animalAddedSuccess => 'Animal registered successfully!';

  @override
  String get submissionFailed => 'Submission failed:';

  @override
  String get myLivestock => 'My Livestock';

  @override
  String get noLivestockRecords => 'No livestock records found.';

  @override
  String get pressToAdd => 'Press + to add livestock.';

  @override
  String get tagNumber => 'Tag Number:';

  @override
  String get name => 'Name:';

  @override
  String get species => 'Species:';

  @override
  String get breed => 'Breed:';

  @override
  String get sex => 'Sex:';

  @override
  String get dateOfBirth => 'Date of Birth:';

  @override
  String get essentialInfo => 'Essential Information (Required)';

  @override
  String get speciesRequired => 'Species is required.';

  @override
  String get breedRequired => 'Breed is required.';

  @override
  String get tagNumberRequired => 'Tag number';

  @override
  String get weightAtBirth => 'Weight at Birth (kg)';

  @override
  String get weightAtBirthRequired => 'Weight at birth';

  @override
  String get sexRequired => 'Sex';

  @override
  String get statusRequired => 'Status';

  @override
  String get optionalInfo => 'Optional Information';

  @override
  String get nameOptional => 'Name (Optional)';

  @override
  String get sireID => 'Sire ID (Optional)';

  @override
  String get damID => 'Dam ID (Optional)';

  @override
  String get purchaseDateOptional => 'Purchase Date (Optional)';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get purchaseCostOptional => 'Purchase Cost (Optional)';

  @override
  String get sourceVendor => 'Source/Vendor (Optional)';

  @override
  String get registerAnimal => 'Register Animal';

  @override
  String get failedLoadDropdown => 'Failed to load dropdown data:';

  @override
  String get livestockRegisteredSuccess => 'Livestock registered successfully!';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get unknown => 'Unknown';

  @override
  String get active => 'Active';

  @override
  String get sold => 'Sold';

  @override
  String get dead => 'Dead';

  @override
  String get stolen => 'Stolen';

  @override
  String get dam => 'Dam (Female)';

  @override
  String get sire => 'Sire (Male)';

  @override
  String get breedingType => 'Breeding Type';

  @override
  String get selectDamRequired => 'Please select the dam';

  @override
  String get selectBreedingTypeRequired => 'Please select the breeding type';

  @override
  String get semenCode => 'Semen Code';

  @override
  String get semenCodeRequired => 'Semen code is required';

  @override
  String get bullName => 'Bull Name';

  @override
  String get breedingDate => 'Breeding Date';

  @override
  String get dateRequired => 'Date is required';

  @override
  String get expectedDeliveryDate => 'Expected Delivery Date';

  @override
  String get status => 'Status';

  @override
  String get selectStatusRequired => 'Please select a status';

  @override
  String get notes => 'Notes';

  @override
  String get recordBreeding => 'Record Breeding';

  @override
  String get recordBirth => 'Record Birth';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get numberOfLiveBirths => 'Number of Live Births';

  @override
  String get validNumberRequired =>
      'Please enter a valid number (must be 1 or more)';

  @override
  String get birthNotes => 'Birth Notes';

  @override
  String get finalizeBirthRecord => 'Finalize Birth Record';

  @override
  String get recordPregnancyCheck => 'Record Pregnancy Check';

  @override
  String get checkDate => 'Check Date';

  @override
  String get checkResult => 'Check Result';

  @override
  String get checkResultPositive => 'Confirmed Pregnant';

  @override
  String get checkResultNegative => 'Failed (Open)';

  @override
  String get selectResultRequired => 'Please select a result';

  @override
  String get checkMethod => 'Check Method';

  @override
  String get ultrasound => 'Ultrasound';

  @override
  String get rectalPalpation => 'Rectal Palpation';

  @override
  String get bloodTest => 'Blood Test';

  @override
  String get selectMethodRequired => 'Please select a check method';

  @override
  String get recordNewBreeding => 'Add new breeding records';

  @override
  String get breedingRecordSuccess =>
      'Successfully to adding new breeding record';

  @override
  String get failedToLoadForm => 'Failed to load Form';

  @override
  String get tapToLoadDropdowns => 'Tap to load dropdown';

  @override
  String get noBreedingRecords => 'No breeding record';

  @override
  String get breedingRecords => 'Breeding Record';

  @override
  String get breedingRecordDetails => 'Breeding Record Details';

  @override
  String get errorLoading => 'Error loading data:';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get recordId => 'Record ID';

  @override
  String get damId => 'Dam ID';

  @override
  String get expectedDelivery => 'Expected Delivery';

  @override
  String get pregnancyCheck => 'Pregnancy Check';

  @override
  String get deliveryDetails => 'Delivery Details';

  @override
  String get deliveryDate => 'Delivery Date';

  @override
  String get offspringCount => 'Offspring Count';

  @override
  String get deliveryNotes => 'Delivery Notes';

  @override
  String get none => 'None';

  @override
  String get recordCheck => 'Record Check';

  @override
  String get noSiresAvailable => 'No sire available';

  @override
  String get noDamsAvailable => 'No Dams available';

  @override
  String get result => 'Result';

  @override
  String get method => 'Method';

  @override
  String get saveCheck => 'Save Check';

  @override
  String get completeVetProfile => 'Complete Vet Profile';

  @override
  String get vetDetailsPrompt => 'Tell us about your practice';

  @override
  String get submitForApproval => 'Submit for Approval';

  @override
  String get heatCycleEmptyStateMessage => '';

  @override
  String get heatCycles => 'Heat Cycles';

  @override
  String get deliveries => 'Deliveries';

  @override
  String get noDeliveriesYet => 'No delivery records found.';

  @override
  String get recordFirstDelivery =>
      'Tap + to begin recording the first delivery.';

  @override
  String get date => 'Date';

  @override
  String get totalWeight => 'Total Weight (kg)';

  @override
  String get recordDelivery => 'Record Delivery';

  @override
  String get inseminations => 'Inseminations';

  @override
  String get noInseminationsYet => 'No insemination records found.';

  @override
  String get recordFirstInsemination =>
      'Tap + to begin recording the first insemination.';

  @override
  String get recordInsemIination => 'Record Insemination';

  @override
  String get lactations => 'Lactations';

  @override
  String get noLactationsYet => 'No lactation records found.';

  @override
  String get recordFirstLactation =>
      'Tap + to begin recording the first lactation cycle.';

  @override
  String get recordLactation => 'Record Lactation';

  @override
  String get lactationNumber => 'Lactation';

  @override
  String get started => 'Started';

  @override
  String projectedDuration(Object projectedDays) {
    return '$projectedDays days projected';
  }

  @override
  String get offspring => 'Offspring';

  @override
  String get noOffspringYet => 'No offspring records found.';

  @override
  String get recordFirstOffspring => 'Tap + to record the first birth.';

  @override
  String get recordOffspring => 'Record Offspring';

  @override
  String get born => 'Born';

  @override
  String get readyToRegister => 'Ready to Register';

  @override
  String get pregnancyChecks => 'Pregnancy Checks';

  @override
  String get noChecksYet => 'No pregnancy check records found.';

  @override
  String get recordFirstCheck =>
      'Tap + to record the first pregnancy scan or test result.';

  @override
  String get dueDate => 'Due Date';

  @override
  String get recordInsemination => 'Record Insemination';

  @override
  String get semenInventory => 'Semen Inventory';

  @override
  String get noSemenRecordsYet => 'No semen inventory records found.';

  @override
  String get addFirstSemenRecord =>
      'Tap + to add the first semen inventory record.';

  @override
  String get addSemenRecord => 'Add Semen Record';

  @override
  String get semenSource => 'Semen Source';

  @override
  String get semenSourceRequired => 'Semen source is required';

  @override
  String get semenType => 'Semen Type';

  @override
  String get semenTypeRequired => 'Semen type is required';

  @override
  String get semenQuantity => 'Quantity (Straws)';

  @override
  String get validQuantityRequired =>
      'Please enter a valid quantity (must be 1 or more)';

  @override
  String get semenNotes => 'Notes';

  @override
  String get saveSemenRecord => 'Save Semen Record';

  @override
  String get semenRecordSuccess => 'Semen inventory record added successfully!';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get pressPlusToAdd => 'Press + to add records.';

  @override
  String get recordFirstSemenBatch =>
      'Record the first semen batch to get started.';

  @override
  String get availableUnits => 'Available Units';

  @override
  String get addSemen => 'Add Semen';

  @override
  String get recordHeatCycle => 'Record Heat Cycle';

  @override
  String get startDate => 'Start Date';

  @override
  String get heatCycleDetails => 'Heat Cycle Details';

  @override
  String get animalID => 'Animal ID';

  @override
  String get details => 'Details';

  @override
  String get completionDate => 'Completion Date';

  @override
  String get nextObservation => 'Next Observation';

  @override
  String get endHeatCycle => 'End Cycle';

  @override
  String get edit => 'Edit';

  @override
  String get selectAnimal => 'Select Animal';

  @override
  String get chooseAnimal => 'Choose Animal';

  @override
  String get animalRequired => 'Please select an animal.';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectStartDate => 'Select Start Date';

  @override
  String get notesPlaceholder =>
      'E.g., Signs observed (mucus, mounting, restlessness)';

  @override
  String get heatCycleRecorded => 'Heat cycle recorded successfully!';

  @override
  String get observedDate => 'Observed Date';

  @override
  String get selectObservedDate => 'Select Observed Date';

  @override
  String get heatIntensity => 'Heat Intensity';

  @override
  String get selectIntensity => 'Select Intensity';

  @override
  String get intensityRequired => 'Please select the heat intensity.';

  @override
  String get errorFetchingDetails => 'Could not load heat cycle details.';

  @override
  String get selectAHeatCycle => 'Select a heat cycle to view details.';

  @override
  String get inseminatedStatus => 'Inseminated / Completed';

  @override
  String get activeStatus => 'Active';

  @override
  String get completedStatus => 'Missed / Completed';

  @override
  String get noNotesProvided => 'No notes provided for this cycle.';

  @override
  String get nextExpected => 'Next Expected';

  @override
  String get intensity => 'Intensity';

  @override
  String get inseminationRecorded => 'Insemination Recorded';

  @override
  String get yes => 'Yes';

  @override
  String get retry => 'Retry';

  @override
  String get noFemaleAnimalsAvailable => 'No female animals available';

  @override
  String get saving => 'Saving...';

  @override
  String get collectionDate => 'Collection Date';

  @override
  String get dose => 'Dose (straws)';

  @override
  String get motility => 'Motility (%)';

  @override
  String get costPerStraw => 'Cost per Straw';

  @override
  String get sourceSupplier => 'Source / Supplier';

  @override
  String get sourceSupplierHint =>
      'Enter the name of the supplier or leave blank if collected on-farm';

  @override
  String get internalBullId => 'Internal Bull ID';

  @override
  String get bullTag => 'Bull Tag / Ear Tag';

  @override
  String get selectCollectionDate => 'Select Collection Date';

  @override
  String get selectBreed => 'Select Breed';

  @override
  String get selectOwnedBull => 'Select Owned Bull';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidNumber => 'Please enter a valid number';

  @override
  String get invalidPercentage => 'Please enter a valid percentage (0-100)';

  @override
  String get optionalDetails => 'Optional Details';

  @override
  String get semenAddInfo => 'Additional Semen Information';

  @override
  String get fillAllRequiredFields => 'Please fill in all required fields';

  @override
  String get savingSemen => 'Saving Semen...';

  @override
  String get strawCode => 'Straw Code / Batch';

  @override
  String get timesUsed => 'Times Used';

  @override
  String get conceptions => 'Confirmed Conceptions';

  @override
  String get successRate => 'Conception Rate';

  @override
  String get generalDetails => 'General Details';

  @override
  String get internalBullSource => 'Internal Bull / Own Collection';

  @override
  String get usageHistory => 'Usage History';

  @override
  String get notRecorded => 'Not recorded';

  @override
  String get noUsageRecords => 'No usage records yet';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String get confirmDelete => 'Confirm Deletion';

  @override
  String get deleteSemenWarning =>
      'Are you sure you want to permanently delete this semen record? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get editSemen => '';

  @override
  String get semenEditInfo => '';

  @override
  String get update => '';

  @override
  String get used => 'Used';

  @override
  String get available => 'Available';

  @override
  String get currency => 'TZS';

  @override
  String formatCurrency(double amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.currency(locale: localeName, symbol: 'TZS');
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString';
  }

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get editInsemination => 'Edit Insemination';

  @override
  String get selectDam => 'Select Dam';

  @override
  String get heatCycle => 'Heat Cycle';

  @override
  String get selectHeatCycle => 'Select Heat Cycle';

  @override
  String get breedingMethod => 'Breeding Method';

  @override
  String get natural => 'Natural';

  @override
  String get ai => 'AI';

  @override
  String get selectSire => 'Select Sire';

  @override
  String get semenStraw => 'Semen Straw';

  @override
  String get selectSemen => 'Select Semen';

  @override
  String get inseminationDate => 'Insemination Date';

  @override
  String get technician => 'Technician';

  @override
  String get breedingDetails => 'Breeding Details';

  @override
  String get breedingPartner => 'Breeding Partner';

  @override
  String get sireName => 'Sire Name';

  @override
  String get detailsUnavailable =>
      'Details unavailable for this breeding method.';

  @override
  String get noNotes => 'No notes recorded.';

  @override
  String get checkRecord => 'Check Record';

  @override
  String get noPregnancyChecksRecorded =>
      'No pregnancy checks have been recorded for this insemination.';

  @override
  String get deleteInsemination => 'Delete Insemination Record';

  @override
  String get deleteConfirmation =>
      'Are you sure you want to delete the record?';

  @override
  String get searchInseminations => 'Search by Tag, Name, or Status';

  @override
  String get noResultsFound => 'No results found for your search.';

  @override
  String get deleteCheck => 'delete check';

  @override
  String get deleteCheckConfirmation =>
      'Are you sure you want to delete the check record? This action cannot be undone.';

  @override
  String get fetusCount => '';

  @override
  String get checkDetails => '';

  @override
  String get relatedInsemination => '';

  @override
  String get viewInseminationDetails => '';

  @override
  String get addPregnancyCheck => 'Add Pregnancy Check';

  @override
  String get selectInsemination => 'Select Insemination';

  @override
  String get selectMethod => 'Select Method';

  @override
  String get selectResult => 'Select Result';

  @override
  String get pregnancyDetails => 'Pregnancy Details';

  @override
  String get selectTechnician => 'Select Technician';

  @override
  String get pregnantFieldsRequired =>
      'Please fill in all required fields for a positive pregnancy result';

  @override
  String get editPregnancyCheck => 'Edit Pregnancy Check';

  @override
  String get searchChecks => 'Search by Tag, Name, or Result';

  @override
  String get liveBorn => 'Live Born';

  @override
  String get totalBorn => 'Total Born';

  @override
  String get searchDeliveries => 'Search by Tag, Name, or Date';

  @override
  String get delivery => 'delivery';

  @override
  String get deleteDelivery => 'deleteDelivery';

  @override
  String get deleteDeliveryConfirmation =>
      'Are you sure you want to delete the delivery record? This action cannot be undone and will affect related records.';

  @override
  String get deliverySummary => 'deliverySummary';

  @override
  String get deliveryType => 'deliveryType';

  @override
  String get calvingEaseScore => 'calvingEaseScore';

  @override
  String get damConditionAfter => 'damConditionAfter';

  @override
  String get offspringRecords => 'offspringRecords';

  @override
  String get stillborn => 'stillborn';

  @override
  String get stillbornCalf => 'stillbornCalf';

  @override
  String get birthWeight => 'birthWeight';

  @override
  String get colostrumIntake => 'colostrumIntake';

  @override
  String get navelTreated => 'navelTreated';

  @override
  String get downloadPdf => 'downloadPdf';

  @override
  String get saveDelivery => 'Save Delivery';

  @override
  String get selectInseminationRequired =>
      'Please select an insemination record first.';

  @override
  String get atLeastOneOffspringRequired =>
      'At least one offspring record is required.';

  @override
  String get selectDeliveryType => 'Select Delivery Type';

  @override
  String get scoreEasy => 'Easy';

  @override
  String get scoreDifficult => 'Difficult';

  @override
  String get selectDamCondition => 'Select Dam Condition';

  @override
  String get addOffspring => 'Add Offspring';

  @override
  String get removeOffspring => 'Remove Offspring';

  @override
  String get temporaryTag => 'Temporary Tag';

  @override
  String get gender => 'Gender';

  @override
  String get birthCondition => 'Birth Condition';

  @override
  String get offspringNotes => 'Offspring Notes';

  @override
  String get editDelivery => 'Edit Delivery';

  @override
  String get newLabel => 'New';

  @override
  String get insemination => 'Insemination';

  @override
  String get unknownInsemination => 'Unknown Insemination';

  @override
  String get registered => 'Registered';

  @override
  String get noTemporaryTag => 'No temporary tag';

  @override
  String get condition => 'Stillborn';

  @override
  String get offspringNotFound => 'Offspring not found';

  @override
  String get loading => 'Loading...';

  @override
  String get offspringDetails => 'Offspring Details';

  @override
  String get birthEvent => 'Birth Event';

  @override
  String get lineage => 'Lineage';

  @override
  String get damTag => 'Dam Tag';

  @override
  String get sireTag => 'Sire Tag';

  @override
  String get registrationStatusRegistered => 'Registered';

  @override
  String get registrationStatusPending => 'Pending Registration';

  @override
  String get registeredAs => 'Registered as';

  @override
  String get livestockId => 'Livestock ID';

  @override
  String get registerOffspring => 'Register Offspring';

  @override
  String get registerOffspringMessage =>
      'This offspring is ready to be registered with an official tag/ID.';

  @override
  String get unknownTag => 'Unknown Tag';

  @override
  String get selectDeliveryContext => 'Delivery Context';

  @override
  String get identification => 'Identification';

  @override
  String get birthMetrics => 'Birth Metrics';

  @override
  String get birthWeightKg => 'Birth Weight (kg)';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get saveOffspring => 'Save Offspring';

  @override
  String get savingOffspring => 'Saving offspring record...';

  @override
  String get offspringRecordSuccess => 'Offspring record saved successfully';

  @override
  String get enterValidWeight => 'Please enter a valid weight';

  @override
  String get editOffspring => 'Edit Offspring';

  @override
  String get savingChanges => 'Saving changes...';

  @override
  String get deliveryContext => 'Delivery Context';

  @override
  String get registrationInstructions =>
      'Enter the official livestock tag/ID to complete registration.';

  @override
  String get newLivestockTag => 'Official Livestock Tag / ID';

  @override
  String get enterUniqueTag => 'Enter a unique tag or ID';

  @override
  String get registrationDate => 'Registration Date';

  @override
  String get confirmRegistration => 'Confirm Registration';

  @override
  String get submittingRegistration => 'Submitting registration...';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get totalYield => 'Total Yield (liters)';

  @override
  String get editLactation => 'Edit Lactation';

  @override
  String get lactationStarted => 'Lactation Started';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get completed => 'Completed';

  @override
  String get peakDate => 'Peak Date';

  @override
  String get dateAfterStartDateError =>
      'Date must be on or after the lactation start date.';

  @override
  String get invalidDateError => 'Invalid date format.';

  @override
  String get dryOffDate => 'Dry Off Date';

  @override
  String get totalMilkKg => 'Total Milk Yield (kg)';

  @override
  String get invalidNumberError => 'Please enter a valid number.';

  @override
  String get mustBePositiveError => 'Value must be positive.';

  @override
  String get daysInMilk => 'Days in Milk';

  @override
  String get invalidIntegerError => 'Please enter a valid integer.';

  @override
  String get savingLactation => 'Saving lactation record...';

  @override
  String get lactationRecordSuccess => 'Lactation record saved successfully!';

  @override
  String get animalInformation => 'Animal Information';

  @override
  String get keyDates => 'Key Dates';

  @override
  String get initialMetrics => 'Initial Metrics (Optional)';

  @override
  String get lactationDetails => 'Lactation Details';

  @override
  String get yieldSummary => 'Yield Summary';

  @override
  String get totalMilkProduced => 'Total Milk Produced';

  @override
  String get lactationNotFound => 'Lactation record not found.';

  @override
  String get wardAddedSuccess => 'Ward added successfully!';

  @override
  String get researcherProfile => 'Researcher Profile';

  @override
  String get welcomeResearcher => 'Welcome, Researcher!';

  @override
  String get researcherDetailsSubtitle =>
      'Complete your profile to access research tools and data.';

  @override
  String get affiliatedInstitution => 'Affiliated Institution';

  @override
  String get department => 'Department';

  @override
  String get researchFocusArea => 'Research Focus Area';

  @override
  String get academicTitle => 'Academic Title';

  @override
  String get orcidId => 'ORCID ID';

  @override
  String get researchPurpose => 'Purpose of Research';

  @override
  String get genericError =>
      'A network or server error occurred. Please try again later.';
}
