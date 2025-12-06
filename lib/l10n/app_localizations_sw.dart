// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get app_name => 'Meneja wa Shamba';

  @override
  String get welcomeTitle => 'Karibu kwenye Meneja wa Shamba';

  @override
  String get welcomeSubtitle =>
      'Weka rekodi za mifugo, omba huduma za mifugo, na dhibiti shamba lako nje ya mtandao.';

  @override
  String get selectLanguage => 'Chagua Lugha';

  @override
  String get continueBtn => 'Endelea';

  @override
  String get login => 'Ingia';

  @override
  String get loginSubtitle => 'Karibu tena! Tafadhali weka vitambulisho vyako.';

  @override
  String get username => 'Jina la Mtumiaji / Barua pepe / Simu';

  @override
  String get enterUsername =>
      'Tafadhali weka jina lako la mtumiaji, barua pepe au simu';

  @override
  String get password => 'Neno la Siri';

  @override
  String get enterPassword => 'Tafadhali weka neno lako la siri';

  @override
  String get forgotPassword => 'Umesahau Neno la Siri?';

  @override
  String get noAccount => 'Huna akaunti?';

  @override
  String get signUp => 'Jisajili';

  @override
  String get register => 'Fungua Akaunti';

  @override
  String get registerSubtitle => 'Jaza maelezo yako ili uanze.';

  @override
  String get firstname => 'Jina la Kwanza';

  @override
  String get firstnameRequired => 'Jina la kwanza linahitajika';

  @override
  String get lastname => 'Jina la Mwisho';

  @override
  String get lastnameRequired => 'Jina la mwisho linahitajika';

  @override
  String get phoneNumber => 'Nambari ya Simu';

  @override
  String get phoneRequired => 'Nambari ya simu inahitajika';

  @override
  String get validPhone => 'Weka simu halali ya TZ (07xxxxxxxx)';

  @override
  String get email => 'Barua pepe (Si Lazima kwa Mkulima)';

  @override
  String get validEmail => 'Tafadhali weka barua pepe halali';

  @override
  String get passwordLength =>
      'Neno la siri lazima liwe na herufi zisizopungua 6';

  @override
  String get confirmPassword => 'Thibitisha Neno la Siri';

  @override
  String get passwordMatch => 'Maneno ya siri hayafanani';

  @override
  String get haveAccount => 'Tayari una akaunti?';

  @override
  String get sendResetLink => 'Tuma Kiungo cha Kuweka Upya';

  @override
  String get resetLinkSent => 'Kiungo cha kuweka upya kimetumwa!';

  @override
  String get forgotPasswordDesc =>
      'Weka barua pepe yako na tutakutumia kiungo cha kuweka upya.';

  @override
  String get selectRoleTitle => 'Wewe ni nani?';

  @override
  String get selectRoleSubtitle =>
      'Tafadhali chagua nafasi inayoelezea kazi yako vizuri.';

  @override
  String get select => 'Chagua';

  @override
  String get farmer => 'Mkulima';

  @override
  String get farmerDesc => 'Dhibiti mifugo yako na uombe huduma za mifugo';

  @override
  String get roleFarmerDesc => 'Anasimamia mazao na mifugo.';

  @override
  String get vet => 'Daktari wa Mifugo';

  @override
  String get vetDesc => 'Toa huduma na dhibiti miadi';

  @override
  String get roleVetDesc => 'Anatoa huduma za afya ya wanyama.';

  @override
  String get researcher => 'Mtafiti';

  @override
  String get researcherDesc =>
      'Fikia data iliyofanywa kuwa siri kwa ajili ya utafiti';

  @override
  String get roleResearcherDesc => 'Anasoma mazoea ya kilimo.';

  @override
  String get welcome => 'Karibu!';

  @override
  String get roleSelected => 'Nafasi imehifadhiwa kwa mafanikio';

  @override
  String get continueToApp => 'Endelea Kwenye App';

  @override
  String get dashboard => 'Dashibodi';

  @override
  String get livestock => 'Mifugo';

  @override
  String get addLivestock => 'Ongeza Mifugo';

  @override
  String get healthReport => 'Ripoti ya Afya';

  @override
  String get breedingRecord => 'Rekodi ya Uzalishaji';

  @override
  String get syncData => 'Sawazisha Data';

  @override
  String get offlineData => 'Data Nje ya Mtandao';

  @override
  String get syncingRecords => 'Inasawazisha rekodi...';

  @override
  String get vetRequests => 'Maombi ya Daktari wa Mifugo';

  @override
  String get serviceRequests => 'Maombi ya Huduma';

  @override
  String get prescription => 'Maagizo ya Dawa';

  @override
  String get vetDashboard => 'Dashibodi ya Daktari wa Mifugo';

  @override
  String get analytics => 'Uchambuzi';

  @override
  String get researcherDashboard => 'Dashibodi ya Mtafiti';

  @override
  String get submitDataRequest => 'Wasilisha Ombi la Data';

  @override
  String get chart => 'Chati';

  @override
  String get profile => 'Profaili';

  @override
  String get notifications => 'Arifa';

  @override
  String get settings => 'Mipangilio';

  @override
  String get updateLanguage => 'Sasisha Lugha';

  @override
  String get logout => 'Toka';

  @override
  String get error => 'Hitilafu';

  @override
  String get networkError => 'Hakuna muunganisho wa mtandao';

  @override
  String get serverError => 'Hitilafu ya seva. Tafadhali jaribu tena.';

  @override
  String get invalidCredentials => 'Vitambulisho visivyo sahihi';

  @override
  String get success => 'Mafanikio';

  @override
  String get loginSuccess => 'Kuingia kumefanikiwa';

  @override
  String get registerSuccess => 'Usajili umefanikiwa';

  @override
  String get registrationComplete => 'Akaunti imefunguliwa kwa mafanikio!';

  @override
  String get chooseYourRole => 'Sasa chagua nafasi yako ili uendelee';

  @override
  String get dataSynced => 'Data imesawazishwa kwa mafanikio';

  @override
  String get requestSent => 'Ombi limetumwa';

  @override
  String get today => 'Leo';

  @override
  String get yesterday => 'Jana';

  @override
  String get november => 'Novemba';

  @override
  String get dateFormat => '17 Nov 2025';

  @override
  String get help => 'Msaada';

  @override
  String get about => 'Kuhusu';

  @override
  String get version => 'Toleo 1.1';

  @override
  String get developer => 'Imeandaliwa na Japango';

  @override
  String get contact => 'Wasiliana na Msaada';

  @override
  String get creatingAccount => 'Inafungua Akaunti';

  @override
  String get emailAlreadyRegistered => 'Barua pepe tayari imesajiliwa';

  @override
  String get validationError => 'Hitilafu ya Uthibitishaji';

  @override
  String get registrationSuccessMsg => 'Usajili Umefanikiwa';

  @override
  String get roleAssigned => 'Nafasi Imewekwa kwa Mafanikio';

  @override
  String get noInternet => 'Hakuna muunganisho wa mtandao';

  @override
  String get appTagline => 'Weka shamba lako salama';

  @override
  String get processing => 'Inashughulikiwa';

  @override
  String get ward => 'Kata';

  @override
  String get saveLocation => 'Hifadhi Mahali';

  @override
  String get captureGps => 'Piga GPS';

  @override
  String get gpsCaptured => 'GPS Imepigwa';

  @override
  String get district => 'Wilaya';

  @override
  String get region => 'Mkoa';

  @override
  String get locationSubtitle =>
      'Hii itatusaidia kutoa huduma bora za mifugo karibu nawe';

  @override
  String get setYourLocation => 'Weka mahali pako';

  @override
  String get yesAdd => 'Ndiyo Ongeza';

  @override
  String get no => 'Hapana';

  @override
  String get addNewWard => 'Ongeza kata mpya';

  @override
  String get notFoundPrompt => 'Onyo la Kutopatikana';

  @override
  String get enterWardName => 'Weka Jina la Kata';

  @override
  String get wardName => 'Jina la kata';

  @override
  String get wardNameRequired => 'Jina la kata linahitajika';

  @override
  String get districtId => 'Kitambulisho cha Wilaya';

  @override
  String get save => 'Hifadhi';

  @override
  String get nowCaptureGps => '✓ Sasa piga GPS';

  @override
  String get skipForNow => 'Ruka kwa sasa →';

  @override
  String get enterNewWardName => 'Weka jina jipya la kata:';

  @override
  String get wardExample => 'Mfano: Kilakala';

  @override
  String get cancel => 'Ghairi';

  @override
  String get add => 'Ongeza';

  @override
  String get pleaseEnterWardName => 'Tafadhali weka jina la kata';

  @override
  String get addedSuccessfully => 'imeongezwa';

  @override
  String get locationSavedSuccess =>
      'Hongera! Mahali pamehifadhiwa kwa mafanikio 🎉';

  @override
  String get unknownError => 'Hitilafu isiyojulikana imetokea';

  @override
  String get errorOccurred => 'Hitilafu imetokea';

  @override
  String get addingNewWard => 'Inaongeza kata mpya...';

  @override
  String get loadingDistricts => 'Inapakia wilaya...';

  @override
  String get loadingWards => 'Inapakia kata...';

  @override
  String get registrationSuccess => 'Usajili Umefanikiwa';

  @override
  String get completeFarmerProfile => 'Kamilisha Profaili ya Mkulima';

  @override
  String get profileSaved => 'Profaili imehifadhiwa kwa mafanikio!';

  @override
  String get farmerDetailsPrompt =>
      'Tuambie kuhusu shamba lako. Hii inatusaidia kuboresha uzoefu wako.';

  @override
  String get farmName => 'Jina la Shamba';

  @override
  String get requiredField => 'Inahitajika';

  @override
  String get farmPurpose => 'Kusudi Kuu la Shamba';

  @override
  String get totalLandAcres => 'Jumla ya Eka za Ardhi';

  @override
  String get acresRangeError => 'Lazima iwe kati ya 0.1 na 10,000';

  @override
  String get yearsExperience => 'Miaka ya Uzoefu wa Kilimo';

  @override
  String get yearsRangeError => 'Lazima iwe kati ya 0 na 70';

  @override
  String get profilePhotoOptional => 'Picha ya Profaili (Si Lazima)';

  @override
  String get completeProfile => 'Kamilisha Profaili';

  @override
  String get farmLocation => 'Chagua Mahali pa Shamba';

  @override
  String get addNewLivestock => 'Ongeza Mifugo Mpya';

  @override
  String get animalDetails => 'Maelezo ya Mnyama';

  @override
  String get invalidAnimalId => 'Kitambulisho cha Mnyama si sahihi.';

  @override
  String get errorLoadingDetails => 'Hitilafu wakati wa kupakia maelezo:';

  @override
  String get selectAnimalDetails => 'Chagua mnyama kuangalia maelezo.';

  @override
  String get animalAddedSuccess => 'Mnyama amesajiliwa kwa mafanikio!';

  @override
  String get submissionFailed => 'Kuwakilisha kumeshindwa:';

  @override
  String get myLivestock => 'Mifugo Yangu';

  @override
  String get noLivestockRecords => 'Hakuna rekodi za mifugo zilizopatikana.';

  @override
  String get pressToAdd => 'Bonyeza + kuongeza mifugo.';

  @override
  String get tagNumber => 'Nambari ya Lebo:';

  @override
  String get name => 'Jina:';

  @override
  String get species => 'Spishi:';

  @override
  String get breed => 'Aina (Breed):';

  @override
  String get sex => 'Jinsia:';

  @override
  String get dateOfBirth => 'Tarehe ya Kuzaliwa:';

  @override
  String get essentialInfo => 'Maelezo Muhimu (Yanahitajika)';

  @override
  String get speciesRequired => 'Spishi inahitajika.';

  @override
  String get breedRequired => 'Aina inahitajika.';

  @override
  String get tagNumberRequired => 'Nambari ya lebo';

  @override
  String get weightAtBirth => 'Uzito Wakati wa Kuzaliwa (kg)';

  @override
  String get weightAtBirthRequired => 'Uzito wakati wa kuzaliwa';

  @override
  String get sexRequired => 'Jinsia';

  @override
  String get statusRequired => 'Hali';

  @override
  String get optionalInfo => 'Maelezo ya Hiari';

  @override
  String get nameOptional => 'Jina (Si Lazima)';

  @override
  String get sireID => 'Kitambulisho cha Baba (Si Lazima)';

  @override
  String get damID => 'Kitambulisho cha Mama (Si Lazima)';

  @override
  String get purchaseDateOptional => 'Tarehe ya Ununuzi (Si Lazima)';

  @override
  String get notSpecified => 'Haijabainishwa';

  @override
  String get purchaseCostOptional => 'Gharama ya Ununuzi (Si Lazima)';

  @override
  String get sourceVendor => 'Chanzo/Muuzaji (Si Lazima)';

  @override
  String get registerAnimal => 'Sajili Mnyama';

  @override
  String get failedLoadDropdown => 'Imeshindwa kupakia data ya chaguo:';

  @override
  String get livestockRegisteredSuccess => 'Mifugo imesajiliwa kwa mafanikio!';

  @override
  String get male => 'Dume';

  @override
  String get female => 'Jike';

  @override
  String get unknown => 'Haijulikani';

  @override
  String get active => 'Inafanya kazi';

  @override
  String get sold => 'Imeuzwa';

  @override
  String get dead => 'Imekufa';

  @override
  String get stolen => 'Imeibwa';

  @override
  String get dam => 'Mama (Mnyama wa Kike)';

  @override
  String get sire => 'Baba (Mnyama wa Kiume)';

  @override
  String get breedingType => 'Aina ya Uzalishaji';

  @override
  String get selectDamRequired => 'Tafadhali chagua mama';

  @override
  String get selectBreedingTypeRequired =>
      'Tafadhali chagua aina ya uzalishaji';

  @override
  String get semenCode => 'Nambari ya Mbegu';

  @override
  String get semenCodeRequired => 'Nambari ya mbegu inahitajika';

  @override
  String get bullName => 'Jina la Ng\'ombe Dume';

  @override
  String get breedingDate => 'Tarehe ya Uzalishaji';

  @override
  String get dateRequired => 'Tarehe inahitajika';

  @override
  String get expectedDeliveryDate => 'Tarehe Inayotarajiwa ya Kuzaa';

  @override
  String get status => 'Hali';

  @override
  String get selectStatusRequired => 'Tafadhali chagua hali';

  @override
  String get notes => 'Maelezo';

  @override
  String get recordBreeding => 'Rekodi Uzalishaji';

  @override
  String get recordBirth => 'Rekodi Kuzaliwa';

  @override
  String get birthDate => 'Tarehe ya Kuzaliwa';

  @override
  String get numberOfLiveBirths => 'Idadi ya Watoto walio Hai';

  @override
  String get validNumberRequired =>
      'Tafadhali weka nambari halali (inapaswa kuwa 1 au zaidi)';

  @override
  String get birthNotes => 'Maelezo ya Kuzaliwa';

  @override
  String get finalizeBirthRecord => 'Kamilisha Rekodi ya Kuzaliwa';

  @override
  String get recordPregnancyCheck => 'Rekodi Ukaguzi wa Mimba';

  @override
  String get checkDate => 'Tarehe ya Ukaguzi';

  @override
  String get checkResult => 'Matokeo ya Ukaguzi';

  @override
  String get checkResultPositive => 'Imethibitishwa Kuwa na Mimba';

  @override
  String get checkResultNegative => 'Imeshindwa (Haina Mimba)';

  @override
  String get selectResultRequired => 'Tafadhali chagua matokeo';

  @override
  String get checkMethod => 'Njia ya Ukaguzi';

  @override
  String get ultrasound => 'Ultrasound';

  @override
  String get rectalPalpation => 'Ukaguzi wa Kawaida (Rectal Palpation)';

  @override
  String get bloodTest => 'Kipimo cha Damu';

  @override
  String get selectMethodRequired => 'Tafadhali chagua njia ya ukaguzi';

  @override
  String get recordNewBreeding => 'Rekodi mpya za uzalishaji';

  @override
  String get breedingRecordSuccess =>
      'Rekodi mpya ya uzalishaji imeongezwa kwa mafanikio';

  @override
  String get failedToLoadForm => 'Imeshindwa kupakia Fomu';

  @override
  String get tapToLoadDropdowns => 'Gusa ili kupakia orodha kunjuzi';

  @override
  String get noBreedingRecords => 'Hakuna rekodi za uzalishaji';

  @override
  String get breedingRecords => 'Rekodi ya uzalishaji';

  @override
  String get breedingRecordDetails => 'Maelezo ya Rekodi ya Uzalishaji';

  @override
  String get errorLoading => 'Hitilafu wakati wa kupakia';

  @override
  String get loadingData => 'Inapakia Data';

  @override
  String get recordId => 'Kitambulisho cha Rekodi';

  @override
  String get damId => 'Kitambulisho cha Mama';

  @override
  String get expectedDelivery => 'Ujauzito Unaotarajiwa';

  @override
  String get pregnancyCheck => 'Ukaguzi wa Mimba';

  @override
  String get deliveryDetails => 'Maelezo ya Kujifungua';

  @override
  String get deliveryDate => 'Tarehe ya Kujifungua';

  @override
  String get offspringCount => 'Idadi ya Watoto';

  @override
  String get deliveryNotes => 'Vidokezo vya Kujifungua';

  @override
  String get none => 'Hakuna';

  @override
  String get recordCheck => 'Hifadhi Ukaguzi';

  @override
  String get noSiresAvailable => 'Hakuna baba wa mnyama';

  @override
  String get noDamsAvailable => 'Hakuna mama wa mnyama';

  @override
  String get result => 'Matokeo';

  @override
  String get method => 'Mbinu';

  @override
  String get saveCheck => 'Tunza tizama';

  @override
  String get completeVetProfile => 'Kamilisha Wasifu wa Dactari';

  @override
  String get vetDetailsPrompt => 'Tuambie kuhusu uzoefu wako';

  @override
  String get submitForApproval => 'Wasilisha Ombi';

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
