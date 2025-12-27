class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/login';
  static const String register = '/register';
  static const String assignRole = '/assign-role';
  static const String me = '/me';
  static const String logout = '/logout';
  static const String refresh = '/refresh';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String userLocations = '/locations/user-locations';
  static const String addLocation = '/locations/add';
  static String updateLocation(int locationId) => '/locations/$locationId';
  static String deleteUserLocation(int userLocationId) =>
      '/locations/user-locations/$userLocationId';
  static String setPrimaryLocation(int userLocationId) =>
      '/locations/user-locations/$userLocationId/set-primary';
  static const String regions = '/locations/regions';
  static String districtsByRegion(int regionId) =>
      '/locations/regions/$regionId/districts';
  static String wardsByDistrict(int districtId) =>
      '/locations/districts/$districtId/wards';
  static String streetsByWard(int wardId) => '/locations/wards/$wardId/streets';

  static const String farmerRegister = '/farmer/register';
  static const String farmerProfile = '/farmer/profile';
  static const String farmerUpdateProfile = '/farmer/profile';
  static const String farmerDashboard = '/farmer/dashboard';

  static const FarmerEndpoints farmer = FarmerEndpoints();

  static const String vetRegister = '/vet/register';
  static const String vetProfile = '/vet/profile';
  static const String vetUpdateProfile = '/vet/profile';
  static const String vetDashboard = '/vet/dashboard';

  static const VetEndpoints vet = VetEndpoints();

  // ========================================
  // RESEARCHER ENDPOINTS 🔬
  // ========================================
  static const ResearcherEndpoints researcher = ResearcherEndpoints();

  static const String cattle = '/cattle';
  static const String addCattle = '/cattle';
  static String cattleDetails(int cattleId) => '/cattle/$cattleId';
  static String updateCattle(int cattleId) => '/cattle/$cattleId';
  static String deleteCattle(int cattleId) => '/cattle/$cattleId';

  static String cattleHealthRecords(int cattleId) =>
      '/cattle/$cattleId/health-records';
  static String addHealthRecord(int cattleId) =>
      '/cattle/$cattleId/health-records';

  static const String notifications = '/notifications';
  static String markNotificationRead(int notificationId) =>
      '/notifications/$notificationId/read';
  static const String markAllNotificationsRead = '/notifications/mark-all-read';

  // ========================================
  // HEAT CYCLE ENDPOINTS (under /breeding prefix) 🐄🔥
  // ========================================
  static const String heatCycles = '/breeding/heat-cycles';
  static String heatCycleDetails(dynamic id) => '/breeding/heat-cycles/$id';
  static String updateHeatCycle(dynamic id) => '/breeding/heat-cycles/$id';

  // ========================================
  // SEMEN INVENTORY ENDPOINTS (under /breeding prefix) 🧪❄️
  // ========================================
  static const String semenInventory = '/breeding/semen';
  static const String availableSemen = '/breeding/semen/available';
  static const String semenDropdowns = '/breeding/semen/dropdowns';
  static String semenDetail(dynamic id) => '/breeding/semen/$id';

  // ========================================
  // INSEMINATION ENDPOINTS (under /breeding prefix) 🧬
  // ========================================
  static const String inseminations =
      '/breeding/inseminations'; // GET list & POST create
  static String inseminationDetails(dynamic id) =>
      '/breeding/inseminations/$id'; // GET show
  static String updateInsemination(dynamic id) =>
      '/breeding/inseminations/$id'; // PUT update
  static String deleteInsemination(dynamic id) =>
      '/breeding/inseminations/$id'; // DELETE

// Available resources for dropdowns (used in Flutter insemination form)
  static const String availableAnimals =
      '/breeding/inseminations/animals/available';
  // static const String availableSemen = '/breeding/inseminations/semen/available';
  static const String availableDams = '/breeding/inseminations/dams/available';
  static const String availableSires =
      '/breeding/inseminations/sires/available';

  // ========================================
  // PREGNANCY CHECK ENDPOINTS (under /breeding prefix) 🤰
  // ========================================
  static const String pregnancyChecks = '/breeding/pregnancy-checks';
  static String pregnancyCheckDetails(dynamic id) =>
      '/breeding/pregnancy-checks/$id';
  static String updatePregnancyCheck(dynamic id) =>
      '/breeding/pregnancy-checks/$id';
  static String deletePregnancyCheck(dynamic id) =>
      '/breeding/pregnancy-checks/$id';
  static const String pregnancyCheckDropdowns =
      '/breeding/pregnancy-checks/dropdowns';

  // Optional: If you want to add PDF download support later
  static String pregnancyCheckPdf(dynamic id) =>
      '/breeding/pregnancy-checks/$id/pdf';

  // ========================================
  // DELIVERIES (Calving/Birth Events) 🐮🍼
  // ========================================
  static const String deliveries = '/breeding/deliveries';
  static const String deliveryDropdowns = '/breeding/deliveries/dropdowns';
  static String deliveryDetails(dynamic id) => '/breeding/deliveries/$id';
  static String updateDelivery(dynamic id) => '/breeding/deliveries/$id';
  static String deleteDelivery(dynamic id) => '/breeding/deliveries/$id';
  static String deliveryPdf(dynamic id) => '/breeding/deliveries/$id/pdf';

    // ========================================
  // OFFSPRING ENDPOINTS 🐄👶
  // ========================================
  static const String offspring = '/breeding/offspring';
  static const String offspringAvailableDeliveries = '/breeding/offspring/deliveries/available';
  static String offspringDetails(dynamic id) => '/breeding/offspring/$id';
  static String updateOffspring(dynamic id) => '/breeding/offspring/$id';
  static String deleteOffspring(dynamic id) => '/breeding/offspring/$id';
  static String registerOffspring(dynamic id) => '/breeding/offspring/$id/register';
  static String offspringPdf(dynamic id) => '/breeding/offspring/$id/pdf';
}

class FarmerEndpoints {
  const FarmerEndpoints();

  String get register => '/farmer/register';
  String get profile => '/farmer/profile';
  String get updateProfile => '/farmer/profile';
  String get dashboard => '/farmer/dashboard';

  String get livestock => '/livestock';
  String get livestockSummary => '/livestock/summary';
  String get livestockDropdowns => '/livestock/dropdowns';
  String livestockDetails(dynamic animalId) => '/livestock/$animalId';
}

class VetEndpoints {
  const VetEndpoints();

  String get register => '/vet/register';
  String get profile => '/vet/profile';
  String get updateProfile => '/vet/profile';
  String get dashboard => '/vet/dashboard';
}

// ----------------------------------------------------
// RESEARCHER ENDPOINTS (UPDATED)
// ----------------------------------------------------
class ResearcherEndpoints {
  const ResearcherEndpoints();
  String get profileShow => '/researcher/profile';
  String get profileUpdate => '/researcher/profile';
  String get researchPurposes => '/researcher/purposes';

  // === NEW ENDPOINT for ResearcherAwaitingApprovalPage ===
  String get statusCheck => '/researcher/status';
}
