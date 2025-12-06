import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed AppTheme includes AppColors
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Uncomment in production

// --- 1. HEALTH-SPECIFIC COLORS ---
class HealthColors {
  // Colors chosen based on common association with health (Blue, Green, Red, Orange)
  static const Color reports = Color(0xFF1E88E5); // Blue for reporting
  static const Color diagnosis = Color(0xFF00BFA5); // Teal for diagnosis
  static const Color treatment = Color(0xFFD81B60); // Pink for treatment
  static const Color vaccine = Color(0xFFFF9800); // Orange for prevention/vaccine
  static const Color appointment = Color(0xFF7E57C2); // Deep Purple for appointments
  static const Color chat = Color(0xFF43A047); // Green for communication
}

// --- 2. DATA STRUCTURES (Mock Data for Design Review) ---

// Mock Backend Data Structure
class _HealthDashboardData {
  // Reports
  final int totalReports = 45;
  final int activeCases = 12; // Status: Pending Diagnosis, Under Treatment, etc.
  final int highPriorityReports = 4;

  // Diagnosis
  final int confirmedDiagnoses = 33;
  final String mostCommonDisease = 'Foot and Mouth Disease';

  // Treatment
  final int totalTreatments = 85;
  final int overdueFollowUps = 7;
  final double avgTreatmentCost = 45000.0; // TZS

  // Vaccination
  final int totalSchedules = 120;
  final int upcomingVaccines = 8; // Next 7 days
  final int missedVaccines = 15;

  // Vet & Communication
  final int activeAppointments = 3;
  final int activeChats = 2;
  final int pendingExtensionRequests = 5;
}

final _mockData = _HealthDashboardData();

// Define a simple structure for modular navigation items
class ModuleItem {
  final String titleKey;
  final IconData icon;
  final Color color;
  final int count;
  final String route;

  const ModuleItem({
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.count,
    required this.route,
  });
}

final List<ModuleItem> _moduleItems = [
  ModuleItem(
      titleKey: 'healthReports',
      icon: Icons.report_problem,
      color: HealthColors.reports,
      count: _mockData.totalReports,
      route: '/farmer/health/reports'),
  ModuleItem(
      titleKey: 'diagnoses',
      icon: Icons.biotech,
      color: HealthColors.diagnosis,
      count: _mockData.confirmedDiagnoses,
      route: '/farmer/health/diagnoses'),
  ModuleItem(
      titleKey: 'treatments',
      icon: Icons.medical_services,
      color: HealthColors.treatment,
      count: _mockData.totalTreatments,
      route: '/farmer/health/treatments'),
  ModuleItem(
      titleKey: 'vaccinations',
      icon: Icons.vaccines,
      color: HealthColors.vaccine,
      count: _mockData.totalSchedules,
      route: '/farmer/health/vaccinations'),
  ModuleItem(
      titleKey: 'prescriptions',
      icon: Icons.receipt_long,
      color: HealthColors.treatment,
      count: 22, // Mock count
      route: '/farmer/health/prescriptions'),
  ModuleItem(
      titleKey: 'appointments',
      icon: Icons.calendar_month,
      color: HealthColors.appointment,
      count: _mockData.activeAppointments,
      route: '/farmer/health/appointments'),
  ModuleItem(
      titleKey: 'vetChat',
      icon: Icons.chat,
      color: HealthColors.chat,
      count: _mockData.activeChats,
      route: '/farmer/health/chat'),
];

// --- 3. HEALTH DASHBOARD WIDGET ---
class HealthDashboardPage extends StatelessWidget {
  static const String routeName = '/farmer/health';

  const HealthDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!; // Uncomment in production
    final l10n = _DesignL10n(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/farmer/dashboard'),
        ),
        title: Text(l10n.healthManagement),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STATS GRID (Key Performance Indicators)
            _HealthStatsSection(l10n: l10n, data: _mockData),

            // 2. ALERTS SECTION
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.alerts,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // High Priority Report Alert
                  _buildAlertCard(
                      context,
                      l10n.highPriorityReports,
                      _mockData.highPriorityReports,
                      AppColors.error,
                      Icons.priority_high,
                      '/farmer/health/reports/high'),
                  const SizedBox(height: 8),
                  // Overdue Follow-up Alert
                  _buildAlertCard(
                      context,
                      l10n.overdueFollowUps,
                      _mockData.overdueFollowUps,
                      AppColors.warning,
                      Icons.watch_later,
                      '/farmer/health/treatments/overdue'),
                  const SizedBox(height: 8),
                  // Missed Vaccines Alert
                  _buildAlertCard(
                      context,
                      l10n.missedVaccines,
                      _mockData.missedVaccines,
                      AppColors.secondary,
                      Icons.error_outline,
                      '/farmer/health/vaccinations/missed'),
                  const SizedBox(height: 8),
                  // Pending Extension Requests Alert
                  _buildAlertCard(
                      context,
                      l10n.pendingExtensionRequests,
                      _mockData.pendingExtensionRequests,
                      HealthColors.reports,
                      Icons.support_agent,
                      '/farmer/requests/pending'),
                ],
              ),
            ),

            const Divider(indent: 16, endIndent: 16),

            // 3. QUICK ACTIONS SECTION
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.quickActions,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.start,
                    children: [
                      _buildQuickActionButton(
                          context,
                          l10n.recordSymptoms,
                          Icons.sick,
                          HealthColors.reports,
                          '/farmer/health/reports/add'),
                      _buildQuickActionButton(
                          context,
                          l10n.bookAppointment,
                          Icons.calendar_month,
                          HealthColors.appointment,
                          '/farmer/health/appointments/add'),
                      _buildQuickActionButton(
                          context,
                          l10n.recordTreatment,
                          Icons.medical_services,
                          HealthColors.treatment,
                          '/farmer/health/treatments/add'),
                      _buildQuickActionButton(
                          context,
                          l10n.scheduleVaccine,
                          Icons.vaccines,
                          HealthColors.vaccine,
                          '/farmer/health/vaccinations/schedule'),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(indent: 16, endIndent: 16),

            // 4. MODULES SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(l10n.modules,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _moduleItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final item = _moduleItems[index];
                  return _buildModuleCard(context, item, l10n);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Alert Card using standard Card and ListTile
  Widget _buildAlertCard(BuildContext context, String title, int count,
      Color color, IconData icon, String route) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: theme.textTheme.titleLarge
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () => context.push(route),
      ),
    );
  }

  /// Quick Action Button using standard ElevatedButton for better accessibility
  Widget _buildQuickActionButton(BuildContext context, String label,
      IconData icon, Color color, String route) {
    // Calculated width to ensure two items per row, regardless of screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final widgetWidth = (screenWidth - 16 * 3) / 2;

    return SizedBox(
      width: widgetWidth,
      child: ElevatedButton.icon(
        onPressed: () => context.push(route),
        icon: Icon(icon, color: AppColors.onSecondary),
        label: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSecondary, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
    );
  }

  /// Module Navigation Card using standard Card and Column
  Widget _buildModuleCard(
      BuildContext context, ModuleItem item, _DesignL10n l10n) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(item.route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(item.icon, color: item.color, size: 30),
                  Text(
                    item.count.toString(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.getString(item.titleKey),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 4. NEW WIDGET FOR STATS SECTION ---
class _HealthStatsSection extends StatelessWidget {
  const _HealthStatsSection({required this.l10n, required this.data});

  final _DesignL10n l10n;
  final _HealthDashboardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define the list of stats to show
    final stats = [
      {
        'title': l10n.activeCases,
        'value': data.activeCases,
        'color': HealthColors.reports,
        'icon': Icons.healing,
      },
      {
        'title': l10n.confirmedDiagnoses,
        'value': data.confirmedDiagnoses,
        'color': HealthColors.diagnosis,
        'icon': Icons.verified,
      },
      {
        'title': l10n.upcomingVaccines,
        'value': data.upcomingVaccines,
        'color': HealthColors.vaccine,
        'icon': Icons.calendar_today,
      },
      {
        'title': l10n.avgTreatmentCost,
        'value':
            'TZS ${data.avgTreatmentCost.toStringAsFixed(0)}', // Assuming TZS currency
        'color': HealthColors.treatment,
        'icon': Icons.money,
      },
      {
        'title': l10n.mostCommonDisease,
        'value': data.mostCommonDisease,
        'color': AppColors.textPrimary,
        'icon': Icons.bug_report,
      },
      {
        'title': l10n.totalTreatments,
        'value': data.totalTreatments,
        'color': HealthColors.treatment,
        'icon': Icons.medication,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.healthOverview,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: stats.map((stat) {
              return _buildStatCard(
                context,
                stat['title'] as String,
                stat['value'],
                stat['color'] as Color,
                stat['icon'] as IconData,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Stat Card component for 2-column responsiveness
  Widget _buildStatCard(BuildContext context, String title, dynamic value,
      Color color, IconData icon) {
    final theme = Theme.of(context);
    // Calculated width to ensure two items per row, allowing for space and padding
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 16 * 2 - 12) / 2;

    return SizedBox(
      width: cardWidth,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              // Special handling for long string like disease name
              value is String && value.contains(' ')
                  ? Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      value.toString(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontSize: 10, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 5. MOCK LOCALIZATION CLASS (Necessary for code completion and review) ---
class _DesignL10n {
  final BuildContext context;
  _DesignL10n(this.context);

  String get healthManagement => 'Animal Health Management';
  String get healthOverview => 'Health Overview';
  String get alerts => 'Alerts';
  String get quickActions => 'Quick Actions';
  String get modules => 'Modules';

  // STATS
  String get activeCases => 'Active Health Cases';
  String get confirmedDiagnoses => 'Confirmed Diagnoses';
  String get upcomingVaccines => 'Upcoming Vaccines (7 Days)';
  String get avgTreatmentCost => 'Avg. Treatment Cost';
  String get mostCommonDisease => 'Most Common Disease';
  String get totalTreatments => 'Total Treatments';

  // ALERTS
  String get highPriorityReports => 'High Priority Reports';
  String get overdueFollowUps => 'Overdue Follow-ups';
  String get missedVaccines => 'Missed Vaccines';
  String get pendingExtensionRequests => 'Pending Extension Requests';

  // ACTIONS
  String get recordSymptoms => 'Record New Symptom';
  String get bookAppointment => 'Book Vet Appointment';
  String get recordTreatment => 'Record Treatment';
  String get scheduleVaccine => 'Schedule Vaccine';

  String getString(String key) {
    switch (key) {
      case 'healthReports':
        return 'Health Reports';
      case 'diagnoses':
        return 'Diagnoses';
      case 'treatments':
        return 'Treatments';
      case 'vaccinations':
        return 'Vaccinations';
      case 'prescriptions':
        return 'Prescriptions';
      case 'appointments':
        return 'Vet Appointments';
      case 'vetChat':
        return 'Vet Chat';
      default:
        return key;
    }
  }
}