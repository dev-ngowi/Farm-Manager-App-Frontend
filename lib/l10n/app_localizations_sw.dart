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
  String get submitForApproval => 'Wasilisha kwa Idhini';

  @override
  String get heatCycleEmptyStateMessage => '';

  @override
  String get heatCycles => 'Mizunguko ya Joto';

  @override
  String get deliveries => 'Uzalishaji / Kuzaa';

  @override
  String get noDeliveriesYet => 'Hakuna rekodi za uzalishaji zilizopatikana.';

  @override
  String get recordFirstDelivery =>
      'Gusa + kuanza kurekodi uzalishaji wa kwanza.';

  @override
  String get date => 'Tarehe';

  @override
  String get totalWeight => 'Jumla ya Uzito (kg)';

  @override
  String get recordDelivery => 'Rekodi Uzalishaji';

  @override
  String get inseminations => 'Mbegu Bandia / Kupandikiza';

  @override
  String get noInseminationsYet =>
      'Hakuna rekodi za mbegu bandia zilizopatikana.';

  @override
  String get recordFirstInsemination =>
      'Gusa + kuanza kurekodi mbegu bandia ya kwanza.';

  @override
  String get recordInsemIination => 'Rekodi Mbegu Bandia';

  @override
  String get lactations => 'Vipindi vya Kukamua';

  @override
  String get noLactationsYet => 'Hakuna rekodi za kukamua zilizopatikana.';

  @override
  String get recordFirstLactation =>
      'Gusa + kuanza kurekodi mzunguko wa kwanza wa kukamua.';

  @override
  String get recordLactation => 'Rekodi Kukamua';

  @override
  String get lactationNumber => 'Mkamuo';

  @override
  String get started => 'Ilianza';

  @override
  String projectedDuration(Object projectedDays) {
    return 'Siku $projectedDays zinatarajiwa';
  }

  @override
  String get offspring => 'Wazao / Ndama';

  @override
  String get noOffspringYet => 'Hakuna rekodi za wazao zilizopatikana.';

  @override
  String get recordFirstOffspring => 'Gusa + kurekodi kuzaliwa kwa kwanza.';

  @override
  String get recordOffspring => 'Rekodi Mzao';

  @override
  String get born => 'Amezaliwa';

  @override
  String get readyToRegister => 'Tayari Kusajiliwa';

  @override
  String get pregnancyChecks => 'Vipimo vya Mimba';

  @override
  String get noChecksYet => 'Hakuna rekodi za vipimo vya mimba zilizopatikana.';

  @override
  String get recordFirstCheck =>
      'Gusa + kurekodi skani au kipimo cha mimba cha kwanza.';

  @override
  String get dueDate => 'Tarehe Inayotarajiwa Kuzalia';

  @override
  String get recordInsemination => 'Rekodi Mbegu Bandia';

  @override
  String get semenInventory => 'Hifadhi ya Mbegu za Kiume';

  @override
  String get noSemenRecordsYet =>
      'Hakuna rekodi za mbegu za kiume zilizopatikana.';

  @override
  String get addFirstSemenRecord =>
      'Gusa + kuongeza rekodi ya kwanza ya mbegu za kiume.';

  @override
  String get addSemenRecord => 'Ongeza Rekodi ya Mbegu';

  @override
  String get semenSource => 'Chanzo cha Mbegu';

  @override
  String get semenSourceRequired => 'Chanzo cha mbegu kinahitajika';

  @override
  String get semenType => 'Aina ya Mbegu';

  @override
  String get semenTypeRequired => 'Aina ya mbegu inahitajika';

  @override
  String get semenQuantity => 'Idadi (Majani)';

  @override
  String get validQuantityRequired =>
      'Tafadhali ingiza idadi halali (lazima iwe 1 au zaidi)';

  @override
  String get semenNotes => 'Maelezo';

  @override
  String get saveSemenRecord => 'Hifadhi Rekodi ya Mbegu';

  @override
  String get semenRecordSuccess =>
      'Rekodi ya mbegu za kiume imeongezwa kwa ufanisi!';

  @override
  String get noDataAvailable => 'Hakuna data inayopatikana';

  @override
  String get pressPlusToAdd => 'Bonyeza + kuongeza rekodi.';

  @override
  String get recordFirstSemenBatch => 'Rekodi kundi la kwanza la mbegu kuanza.';

  @override
  String get availableUnits => 'Vitengo Vilivyobaki';

  @override
  String get addSemen => 'Ongeza Mbegu';

  @override
  String get recordHeatCycle => 'Rekodi Mzunguko wa Joto';

  @override
  String get startDate => 'Tarehe ya Kuanza';

  @override
  String get heatCycleDetails => 'Maelezo ya Mzunguko wa Joto';

  @override
  String get animalID => 'Kitambulisho cha Mnyama';

  @override
  String get details => 'Maelezo';

  @override
  String get completionDate => 'Tarehe ya Kumalizika';

  @override
  String get nextObservation => 'Uchunguzi Unaofuata';

  @override
  String get endHeatCycle => 'Maliza Mzunguko';

  @override
  String get edit => 'Hariri';

  @override
  String get selectAnimal => 'Chagua Mnyama';

  @override
  String get chooseAnimal => 'Chagua Mnyama';

  @override
  String get animalRequired => 'Tafadhali chagua mnyama.';

  @override
  String get selectDate => 'Chagua Tarehe';

  @override
  String get selectStartDate => 'Chagua Tarehe ya Kuanza';

  @override
  String get notesPlaceholder =>
      'Mfano: Dalili zilizochunguzwa (kamasi, kupanda, kutotulia)';

  @override
  String get heatCycleRecorded => 'Mzunguko wa joto umerekodiwa kwa ufanisi!';

  @override
  String get observedDate => 'Tarehe ya Kuchunguzwa';

  @override
  String get selectObservedDate => 'Chagua Tarehe ya Kuchunguzwa';

  @override
  String get heatIntensity => 'Ukali wa Joto';

  @override
  String get selectIntensity => 'Chagua Ukali';

  @override
  String get intensityRequired => 'Tafadhali chagua ukali wa joto.';

  @override
  String get errorFetchingDetails =>
      'Imeshindwa kupakia maelezo ya mzunguko wa joto.';

  @override
  String get selectAHeatCycle => 'Chagua mzunguko wa joto ili kuona maelezo.';

  @override
  String get inseminatedStatus => 'Amepandikizwa / Imekamilika';

  @override
  String get activeStatus => 'Inaendelea';

  @override
  String get completedStatus => 'Imekosa / Imekamilika';

  @override
  String get noNotesProvided => 'Hakuna maelezo yaliyotolewa kwa mzunguko huu.';

  @override
  String get nextExpected => 'Inayotarajiwa Ifuatayo';

  @override
  String get intensity => 'Ukali';

  @override
  String get inseminationRecorded => 'Mbegu Bandia Imerekodiwa';

  @override
  String get yes => 'Ndiyo';

  @override
  String get retry => 'Jaribu Tena';

  @override
  String get noFemaleAnimalsAvailable => 'Hakuna wanyama wa kike waliopo';

  @override
  String get saving => 'Inahifadhi...';

  @override
  String get collectionDate => 'Tarehe ya Kukusanya';

  @override
  String get dose => 'Kipimo (majani)';

  @override
  String get motility => 'Uwezo wa Kusonga (%)';

  @override
  String get costPerStraw => 'Gharama kwa Kijani';

  @override
  String get sourceSupplier => 'Chanzo / Muuzaji';

  @override
  String get sourceSupplierHint =>
      'Ingiza jina la muuzaji au acha wazi ikiwa imekusanywa shambani';

  @override
  String get internalBullId => 'Kitambulisho cha Fahali wa Ndani';

  @override
  String get bullTag => 'Namba ya Sikio la Fahali';

  @override
  String get selectCollectionDate => 'Chagua Tarehe ya Kukusanya';

  @override
  String get selectBreed => 'Chagua Aina';

  @override
  String get selectOwnedBull => 'Chagua Fahali wa Shamba';

  @override
  String get fieldRequired => 'Sehemu hii inahitajika';

  @override
  String get invalidNumber => 'Tafadhali ingiza namba halali';

  @override
  String get invalidPercentage => 'Tafadhali ingiza asilimia halali (0-100)';

  @override
  String get optionalDetails => 'Maelezo ya Ziada';

  @override
  String get semenAddInfo => 'Maelezo ya Ziada ya Mbegu';

  @override
  String get fillAllRequiredFields =>
      'Tafadhali jaza sehemu zote zinazohitajika';

  @override
  String get savingSemen => 'Inahifadhi mbegu...';

  @override
  String get strawCode => 'Namba ya Kijani / Kundi';

  @override
  String get timesUsed => 'Mara Zilizotumika';

  @override
  String get conceptions => 'Mimba Zilizothibitishwa';

  @override
  String get successRate => 'Kiwango cha Kushika Mimba';

  @override
  String get generalDetails => 'Maelezo ya Jumla';

  @override
  String get internalBullSource => 'Fahali wa Ndani / Kukusanya Shambani';

  @override
  String get usageHistory => 'Historia ya Matumizi';

  @override
  String get notRecorded => 'Haijarekodiwa';

  @override
  String get noUsageRecords => 'Hakuna rekodi za matumizi bado';

  @override
  String get deleteRecord => 'Futa Rekodi';

  @override
  String get confirmDelete => 'Thibitisha Kufuta';

  @override
  String get deleteSemenWarning =>
      'Una uhakika unataka kufuta rekodi hii ya mbegu kabisa? Hatua hii haiwezi kutenduliwa.';

  @override
  String get delete => 'Futa';

  @override
  String get editSemen => 'Hariri Mbegu';

  @override
  String get semenEditInfo => 'Maelezo ya kuhariri mbegu';

  @override
  String get update => 'Sasisha';

  @override
  String get used => 'Zimetumika';

  @override
  String get available => 'Zilizobaki';

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
  String get saveChanges => 'Hifadhi Mabadiliko';

  @override
  String get editInsemination => 'Hariri Mbegu Bandia';

  @override
  String get selectDam => 'Chagua Mama';

  @override
  String get heatCycle => 'Mzunguko wa Joto';

  @override
  String get selectHeatCycle => 'Chagua Mzunguko wa Joto';

  @override
  String get breedingMethod => 'Njia ya Kuzalisha';

  @override
  String get natural => 'Asilia';

  @override
  String get ai => 'Mbegu Bandia';

  @override
  String get selectSire => 'Chagua Baba';

  @override
  String get semenStraw => 'Kijani cha Mbegu';

  @override
  String get selectSemen => 'Chagua Mbegu';

  @override
  String get inseminationDate => 'Tarehe ya Kupandikiza';

  @override
  String get technician => 'Fundi';

  @override
  String get breedingDetails => 'Maelezo ya Uzalishaji';

  @override
  String get breedingPartner => 'Mshirika wa Kuzalisha';

  @override
  String get sireName => 'Jina la Baba';

  @override
  String get detailsUnavailable =>
      'Maelezo hayapatikani kwa njia hii ya uzalishaji.';

  @override
  String get noNotes => 'Hakuna maelezo yaliyorekodiwa.';

  @override
  String get checkRecord => 'Angalia Rekodi';

  @override
  String get noPregnancyChecksRecorded =>
      'Hakuna vipimo vya mimba vilivyorekodiwa kwa mbegu hii.';

  @override
  String get deleteInsemination => 'Futa Rekodi ya Mbegu Bandia';

  @override
  String get deleteConfirmation => 'Una uhakika unataka kufuta rekodi hii?';

  @override
  String get searchInseminations => 'Tafuta kwa Namba, Jina, au Hali';

  @override
  String get noResultsFound =>
      'Hakuna matokeo yaliyopatikana kwa utafutaji wako.';

  @override
  String get deleteCheck => 'Futa Kipimo';

  @override
  String get deleteCheckConfirmation =>
      'Una uhakika unataka kufuta rekodi hii ya kipimo? Hatua hii haiwezi kutenduliwa.';

  @override
  String get fetusCount => 'Idadi ya Vijuso';

  @override
  String get checkDetails => 'Maelezo ya Kipimo';

  @override
  String get relatedInsemination => 'Mbegu Bandia Inayohusiana';

  @override
  String get viewInseminationDetails => 'Angalia Maelezo ya Mbegu Bandia';

  @override
  String get addPregnancyCheck => 'Ongeza Kipimo cha Mimba';

  @override
  String get selectInsemination => 'Chagua Mbegu Bandia';

  @override
  String get selectMethod => 'Chagua Njia';

  @override
  String get selectResult => 'Chagua Matokeo';

  @override
  String get pregnancyDetails => 'Maelezo ya Mimba';

  @override
  String get selectTechnician => 'Chagua Fundi';

  @override
  String get pregnantFieldsRequired =>
      'Tafadhali jaza sehemu zote zinazohitajika kwa matokeo chanya ya mimba';

  @override
  String get editPregnancyCheck => 'Hariri Kipimo cha Mimba';

  @override
  String get searchChecks => 'Tafuta kwa Namba, Jina, au Matokeo';

  @override
  String get liveBorn => 'Waliozaliwa Hai';

  @override
  String get totalBorn => 'Jumla ya Waliozaliwa';

  @override
  String get searchDeliveries => 'Tafuta kwa Namba, Jina, au Tarehe';

  @override
  String get delivery => 'Uzalishaji';

  @override
  String get deleteDelivery => 'Futa Uzalishaji';

  @override
  String get deleteDeliveryConfirmation =>
      'Una uhakika unataka kufuta rekodi hii ya uzalishaji? Hatua hii haiwezi kutenduliwa na itaathiri rekodi zinazohusiana.';

  @override
  String get deliverySummary => 'Muhtasari wa Uzalishaji';

  @override
  String get deliveryType => 'Aina ya Uzalishaji';

  @override
  String get calvingEaseScore => 'Alama ya Ugumu wa Kuzalia';

  @override
  String get damConditionAfter => 'Hali ya Mama Baada ya Kuzalia';

  @override
  String get offspringRecords => 'Rekodi za Wazao';

  @override
  String get stillborn => 'Waliozaliwa Wafu';

  @override
  String get stillbornCalf => 'Ndama Aliyezaliwa Amekufa';

  @override
  String get birthWeight => 'Uzito wa Kuzaliwa';

  @override
  String get colostrumIntake => 'Unyonyeshaji wa Kolostramu';

  @override
  String get navelTreated => 'Kitovu Kilichotibiwa';

  @override
  String get downloadPdf => 'Pakua PDF';

  @override
  String get saveDelivery => 'Hifadhi Uzalishaji';

  @override
  String get selectInseminationRequired =>
      'Tafadhali chagua rekodi ya mbegu bandia kwanza.';

  @override
  String get atLeastOneOffspringRequired => 'Angalau mzao mmoja anahitajika.';

  @override
  String get selectDeliveryType => 'Chagua Aina ya Uzalishaji';

  @override
  String get scoreEasy => 'Rahisi';

  @override
  String get scoreDifficult => 'Ngumu';

  @override
  String get selectDamCondition => 'Chagua Hali ya Mama';

  @override
  String get addOffspring => 'Ongeza Mzao';

  @override
  String get removeOffspring => 'Ondoa Mzao';

  @override
  String get temporaryTag => 'Namba ya Muda';

  @override
  String get gender => 'Jinsia';

  @override
  String get birthCondition => 'Hali ya Kuzaliwa';

  @override
  String get offspringNotes => 'Maelezo ya Mzao';

  @override
  String get editDelivery => 'Hariri Uzalishaji';

  @override
  String get newLabel => 'Mpya';

  @override
  String get insemination => 'Mbegu Bandia';

  @override
  String get unknownInsemination => 'Mbegu Bandia Isiyojulikana';

  @override
  String get registered => 'Amesajiliwa';

  @override
  String get noTemporaryTag => 'Hakuna namba ya muda';

  @override
  String get condition => 'Amekufa';

  @override
  String get offspringNotFound => 'Mzao hajapatikana';

  @override
  String get loading => 'Inapakia...';

  @override
  String get offspringDetails => 'Maelezo ya Mzao';

  @override
  String get birthEvent => 'Tukio la Kuzaliwa';

  @override
  String get lineage => 'Nasaba';

  @override
  String get damTag => 'Namba ya Mama';

  @override
  String get sireTag => 'Namba ya Baba';

  @override
  String get registrationStatusRegistered => 'Amesajiliwa';

  @override
  String get registrationStatusPending => 'Inasubiri Usajili';

  @override
  String get registeredAs => 'Amesajiliwa kama';

  @override
  String get livestockId => 'Kitambulisho cha Mifugo';

  @override
  String get registerOffspring => 'Sajili Mzao';

  @override
  String get registerOffspringMessage =>
      'Mzao huyu yuko tayari kusajiliwa na namba rasmi.';

  @override
  String get unknownTag => 'Namba Isiyojulikana';

  @override
  String get selectDeliveryContext => 'Muktadha wa Uzalishaji';

  @override
  String get identification => 'Utambulisho';

  @override
  String get birthMetrics => 'Vipimo vya Kuzaliwa';

  @override
  String get birthWeightKg => 'Uzito wa Kuzaliwa (kg)';

  @override
  String get additionalNotes => 'Maelezo ya Ziada';

  @override
  String get saveOffspring => 'Hifadhi Mzao';

  @override
  String get savingOffspring => 'Inahifadhi rekodi ya mzao...';

  @override
  String get offspringRecordSuccess =>
      'Rekodi ya mzao imehifadhiwa kwa ufanisi';

  @override
  String get enterValidWeight => 'Tafadhali ingiza uzito halali';

  @override
  String get editOffspring => 'Hariri Mzao';

  @override
  String get savingChanges => 'Inahifadhi mabadiliko...';

  @override
  String get deliveryContext => 'Muktadha wa Uzalishaji';

  @override
  String get registrationInstructions =>
      'Ingiza namba rasmi ya mifugo ili kumaliza usajili.';

  @override
  String get newLivestockTag => 'Namba Rasmi ya Mifugo';

  @override
  String get enterUniqueTag => 'Ingiza namba ya kipekee';

  @override
  String get registrationDate => 'Tarehe ya Usajili';

  @override
  String get confirmRegistration => 'Thibitisha Usajili';

  @override
  String get submittingRegistration => 'Inawasilisha usajili...';

  @override
  String get statusCompleted => 'Imekamilika';

  @override
  String get totalYield => 'Jumla ya Maziwa (lita)';

  @override
  String get editLactation => 'Hariri Mkamuo';

  @override
  String get lactationStarted => 'Mkamuo Ulianza';

  @override
  String get ongoing => 'Unaendelea';

  @override
  String get completed => 'Imekamilika';

  @override
  String get peakDate => 'Tarehe ya Kilele';

  @override
  String get dateAfterStartDateError =>
      'Tarehe lazima iwe baada au sawa na tarehe ya kuanza kamua.';

  @override
  String get invalidDateError => 'Tarehe si halali.';

  @override
  String get dryOffDate => 'Tarehe ya Kumaliza Kukamua';

  @override
  String get totalMilkKg => 'Jumla ya Maziwa (kg)';

  @override
  String get invalidNumberError => 'Tafadhali ingiza namba halali.';

  @override
  String get mustBePositiveError => 'Thamani lazima iwe chanya.';

  @override
  String get daysInMilk => 'Siku za Kukamua';

  @override
  String get invalidIntegerError => 'Tafadhali ingiza namba kamili halali.';

  @override
  String get savingLactation => 'Inahifadhi rekodi ya mkamuo...';

  @override
  String get lactationRecordSuccess =>
      'Rekodi ya mkamuo imehifadhiwa kwa ufanisi!';

  @override
  String get animalInformation => 'Maelezo ya Mnyama';

  @override
  String get keyDates => 'Tarehe Muhimu';

  @override
  String get initialMetrics => 'Vipimo vya Mwanzo (Hiari)';

  @override
  String get lactationDetails => 'Maelezo ya Mkamuo';

  @override
  String get yieldSummary => 'Muhtasari wa Mazao';

  @override
  String get totalMilkProduced => 'Jumla ya Maziwa Yaliyotolewa';

  @override
  String get lactationNotFound => 'Rekodi ya mkamuo haijapatikana.';

  @override
  String get wardAddedSuccess => 'Wadi imeongezwa kwa ufanisi!';

  @override
  String get researcherProfile => 'Wasilisha kwa Idhini';

  @override
  String get welcomeResearcher => 'Karibu, Mtafiti!';

  @override
  String get researcherDetailsSubtitle =>
      'Kamilisha wasifu wako ili uweze kufikia zana na data za utafiti.';

  @override
  String get affiliatedInstitution => 'Taasisi Inayohusiana';

  @override
  String get department => 'Idara';

  @override
  String get researchFocusArea => 'Eneo la Utafiti';

  @override
  String get academicTitle => 'Cheo cha Kielimu';

  @override
  String get orcidId => 'ORCID ID';

  @override
  String get researchPurpose => 'Madhumuni ya Utafiti';

  @override
  String get genericError =>
      'Hitilafu ya mtandao au seva imetokea. Tafadhali jaribu tena baadaye.';

  @override
  String get addNewWardHint => 'Ongeza Wadi Mpya';

  @override
  String get awaitingApproval => 'Inasubiri Idhini';

  @override
  String get approvalPendingMessage =>
      'Wasifu wako wa mtafiti umewasilishwa kwa ufanisi. Tafadhali subiri wakati msimamizi anakagua maombi yako.';

  @override
  String get profileSubmitted => 'Wasifu Umewasilishwa';

  @override
  String get waitingForReview => 'Inasubiri Kukaguliwa';

  @override
  String get youWillBeNotified => 'Utaarifiwa mara itakapoidhinishwa';

  @override
  String get checkingStatus => 'Inaangalia hali...';

  @override
  String get checkStatus => 'Angalia Hali';

  @override
  String get approvalGranted => 'Wasifu wako wa mtafiti umeidhinishwa!';

  @override
  String get applicationDeclined => 'Maombi Yametengwa';

  @override
  String get declineMessage =>
      'Tunajuta kukuarifu kuwa ombi lako la mtafiti limekataliwa.';

  @override
  String get reason => 'Sababu:';

  @override
  String get ok => 'Sawa';

  @override
  String get editAnimal => 'Hariri Mnyama';

  @override
  String get animalUpdatedSuccess => 'Mnyama amesasishwa kwa ufanisi';

  @override
  String get deleteConfirmationTitle => 'Futa Mnyama';

  @override
  String deleteConfirmationMessage(Object tag) {
    return 'Una uhakika unataka kufuta mnyama $tag?';
  }

  @override
  String get animalDeletedSuccess => 'Mnyama amefutwa kwa ufanisi';

  @override
  String get failedLoadDetails => 'Imeshindwa kupakia maelezo ya mnyama: ';

  @override
  String get notApplicable => 'Haitumiki';

  @override
  String get noName => 'Hana Jina';

  @override
  String get genealogy => 'Nasaba';

  @override
  String get purchaseDetails => 'Maelezo ya Ununuzi';

  @override
  String get purchaseDate => 'Tarehe ya Kununua';

  @override
  String get purchaseCost => 'Gharama ya Kununua';

  @override
  String get source => 'Chanzo / Muuzaji';

  @override
  String get deleteAnimal => 'Futa Mnyama';

  @override
  String get updateAnimal => 'Sasisha Mnyama';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get searchByTagOrName => 'Search by Tag or Name';

  @override
  String get registerNewAnimal => 'Register New Animal';

  @override
  String get fillAnimalDetails =>
      'Please fill out all required details to register a new livestock record.';

  @override
  String get editAnimalHeader => 'Edit Animal Details';

  @override
  String get editAnimalHeaderSubtitle => 'Update information for this animal';

  @override
  String get requiredFieldsNote =>
      'All fields marked with * are required. The more details you add, the better your farm reports will be.';

  @override
  String get requiredFieldsReviewNote =>
      'All fields marked with * are required. Make sure to review all changes before submitting.';

  @override
  String get noSpeciesAvailable => 'No Species data available. Cannot proceed.';

  @override
  String get weightAtBirthKg => 'Weight at Birth (kg)';

  @override
  String get weightRequired => 'Weight is required';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexUnknown => 'Unknown';

  @override
  String get statusActive => 'Active';

  @override
  String get statusSold => 'Sold';

  @override
  String get statusDeceased => 'Deceased';

  @override
  String get statusCulled => 'Culled';

  @override
  String get editInseminationRecord => 'Edit Insemination Record';

  @override
  String get invalidRecordId => 'Invalid Record ID';

  @override
  String get inseminationUpdatedSuccess => 'Insemination updated successfully!';

  @override
  String get editInseminationDetails => 'Edit Insemination Details';

  @override
  String get updateInseminationNote =>
      'Update information for this insemination record.';

  @override
  String get reviewChangesNote =>
      'All fields marked with * are required. Make sure to review all changes before submitting.';

  @override
  String get inseminationDetails => 'Insemination Details';

  @override
  String get editRecord => 'Edit Record';

  @override
  String get inseminationDeletedSuccess => 'Insemination deleted successfully!';

  @override
  String get pregnancyResult => 'Pregnancy & Result';

  @override
  String get pregnancyDiagnosis => 'Pregnancy Diagnosis';

  @override
  String get diagnosisResult => 'Diagnosis Result';

  @override
  String get outcome => 'Outcome';

  @override
  String get addInseminationRecord => 'Add Insemination Record';

  @override
  String get inseminationAddedSuccess => 'Insemination added successfully!';

  @override
  String get registerNewInsemination => 'Register New Insemination';

  @override
  String get fillInseminationDetails =>
      'Please fill out all required details to register a new insemination record.';

  @override
  String get inseminationRecords => 'Insemination Records';

  @override
  String get searchByAnimalTag => 'Search by Animal Tag or Date';

  @override
  String get noInseminationRecords => 'No insemination records yet';

  @override
  String get animal => 'Animal';

  @override
  String get inseminationType => 'Insemination Type';

  @override
  String get inseminatorName => 'Inseminator Name';

  @override
  String get goBack => 'Go Back';

  @override
  String get animalName => 'Animal Name';

  @override
  String get daysToDue => 'Days To Due';

  @override
  String get inseminationEvent => 'Insemination Event';

  @override
  String get sireInformation => 'Sire/Semen Information';

  @override
  String get semenId => 'Semen ID';

  @override
  String get sireId => 'Sire ID';

  @override
  String get noSireInfo => 'No sire information recorded.';

  @override
  String get sireInfoMissing => 'Sire/Semen details expected but not loaded.';

  @override
  String get pregnancyStatus => 'Pregnancy Status';

  @override
  String get isPregnant => 'Is Pregnant?';

  @override
  String get addRecord => 'Add Record';

  @override
  String fieldRequiredFor(String fieldName) {
    return 'The $fieldName field is required.';
  }

  @override
  String get requiredFieldsMissing => 'Required fields missing';

  @override
  String get semenInfoHint => 'Semen Info Hints';

  @override
  String get selectASemen => 'Select a semen straw';

  @override
  String get semenDetails => 'Semen Details';

  @override
  String get pregnancyCheckAddedSuccess =>
      'Pregnancy check added successfully.';

  @override
  String get registerNewCheck => 'Register New Pregnancy Check';

  @override
  String get fillCheckDetails =>
      'Fill out all required details to record a pregnancy check.';

  @override
  String get deleteWarning => 'This action cannot be undone';

  @override
  String get invalidCheckId => 'Invalid Check ID';

  @override
  String get pregnancyCheckDeletedSuccess =>
      'Pregnancy check deleted successfully';

  @override
  String get pregnancyCheckDetails => 'Pregnancy Check Details';

  @override
  String get pregnancyCheckUpdatedSuccess =>
      'Pregnancy check updated successfully';

  @override
  String get editCheckDetails => 'Edit Pregnancy Check Details';

  @override
  String get updateCheckNote => 'Update information for this pregnancy check.';

  @override
  String get pregnancyChecksOverview => 'Pregnancy Checks Overview';

  @override
  String get total => 'Total';

  @override
  String get pregnant => 'Pregnant';

  @override
  String get notPregnant => 'Not Pregnant';

  @override
  String get all => 'All';

  @override
  String get errorLoadingData => 'Error Loading Data';

  @override
  String get damInformation => 'Dam Information';

  @override
  String get veterinarian => 'Veterinarian';

  @override
  String get deliveryUpdatedSuccess => 'Updated successfully';

  @override
  String get editDeliveryDetails => 'Edit Delivery Details';

  @override
  String get addDelivery => 'Add Delivery';

  @override
  String get deliveryAddedSuccess => 'Added successfully';

  @override
  String get registerNewDelivery => 'Register New Delivery';

  @override
  String get fillDeliveryDetails =>
      'Fill out all required details to record a delivery.';

  @override
  String get deliveryDeletedSuccess => 'Deleted successfully';

  @override
  String get deliveryError => 'Error loading deliveries';

  @override
  String get deliveriesOverview => 'Deliveries Overview';

  @override
  String get totalOffspring => 'Total Offspring';

  @override
  String get liveOffspring => 'Live Offspring';

  @override
  String get normalCount => 'Normal Count';

  @override
  String get normal => 'Normal';

  @override
  String get assisted => 'Assisted';

  @override
  String get selectADelivery => 'Select a delivery';

  @override
  String get tapToView => 'Tap to view details';

  @override
  String get noTag => 'No Tag';

  @override
  String get recordNewOffspring => 'Record New Offspring';

  @override
  String get fillOffspringDetails =>
      'Fill out all required details to record an offspring.';

  @override
  String get weight => 'Weight';

  @override
  String get birthDetails => 'Birth Details';

  @override
  String get registerAsLivestock => 'Register as Livestock';

  @override
  String get searchOffspring => 'Search Offspring';

  @override
  String get pending => 'Pending';

  @override
  String get critical => 'Critical';

  @override
  String get selectAnOffspring => 'Select an offspring';

  @override
  String get offspringDeletedSuccess => 'Offspring deleted successfully';

  @override
  String get deleteOffspringConfirmation =>
      'Are you sure you want to delete this offspring record? This action cannot be undone.';
}
