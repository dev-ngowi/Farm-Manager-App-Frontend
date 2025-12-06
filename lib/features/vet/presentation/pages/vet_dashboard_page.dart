// lib/features/vet/presentation/pages/vet_dashboard_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed AppTheme includes AppColors
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// -------------------------------------------------------------------
// --- 1. VET-SPECIFIC COLORS and DATA (AS DEFINED ABOVE) ---
// -------------------------------------------------------------------

class VetColors {
  static const Color appointments = Color(0xFF7E57C2); 
  static const Color actionRequired = Color(0xFFD81B60); 
  static const Color treatment = Color(0xFF00BFA5); 
  static const Color chat = Color(0xFF43A047); 
  static const Color finances = Color(0xFFFF9800); 
}

class _VetDashboardData {
  final int todayAppointments = 5;
  final int upcomingAppointments = 12; 
  final int dueOrOverdueVaccines = 18; 
  final int newHealthReports = 4; 
  final int overdueFollowUps = 7; 
  final int prescriptionsExpiring = 10; 
  final int unreadChats = 8;
  final double expectedFeesToday = 350000.0; 
  final int activeServiceAreas = 3;
}

final _mockVetData = _VetDashboardData();

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

final List<ModuleItem> _vetModuleItems = [
  ModuleItem(
      titleKey: 'appointments',
      icon: Icons.calendar_month,
      color: VetColors.appointments,
      count: _mockVetData.todayAppointments,
      route: '/vet/appointments'),
  ModuleItem(
      titleKey: 'actions',
      icon: Icons.medical_services,
      color: VetColors.treatment,
      count: _mockVetData.newHealthReports,
      route: '/vet/actions'),
  ModuleItem(
      titleKey: 'schedules',
      icon: Icons.vaccines,
      color: VetColors.actionRequired,
      count: _mockVetData.dueOrOverdueVaccines,
      route: '/vet/schedules'),
  ModuleItem(
      titleKey: 'prescriptions',
      icon: Icons.receipt_long,
      color: VetColors.treatment,
      count: _mockVetData.prescriptionsExpiring,
      route: '/vet/prescriptions'),
  ModuleItem(
      titleKey: 'chat',
      icon: Icons.chat,
      color: VetColors.chat,
      count: _mockVetData.unreadChats,
      route: '/vet/chat'),
  ModuleItem(
      titleKey: 'serviceArea',
      icon: Icons.location_on,
      color: VetColors.finances,
      count: _mockVetData.activeServiceAreas,
      route: '/vet/areas'),
];


// -------------------------------------------------------------------
// --- 2. VETERINARIAN DASHBOARD WIDGET ---
// -------------------------------------------------------------------

class VetDashboardPage extends StatelessWidget {
  static const String routeName = '/vet/dashboard';

  const VetDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = _VetL10n(context); 
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'), 
        ),
        title: Text(l10n.vetDashboardTitle),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STATS GRID 
            _VetStatsSection(l10n: l10n, data: _mockVetData),

            // 2. ALERTS SECTION (Highest priority tasks for the Vet)
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
                  // New Health Reports requiring initial diagnosis/action
                  _buildAlertCard(
                      context,
                      l10n.newReports,
                      _mockVetData.newHealthReports,
                      VetColors.actionRequired,
                      Icons.warning,
                      '/vet/health/pending'),
                  const SizedBox(height: 8),
                  // Overdue Recovery/Follow-ups
                  _buildAlertCard(
                      context,
                      l10n.overdueFollowUps,
                      _mockVetData.overdueFollowUps,
                      VetColors.finances,
                      Icons.history,
                      '/vet/actions/followup'),
                  const SizedBox(height: 8),
                  // Due/Overdue Vaccination Schedules (Needs Vet or Farmer action)
                  _buildAlertCard(
                      context,
                      l10n.overdueVaccines,
                      _mockVetData.dueOrOverdueVaccines,
                      VetColors.actionRequired,
                      Icons.vaccines,
                      '/vet/schedules/due'),
                  const SizedBox(height: 8),
                  // Unread Chat Messages
                  _buildAlertCard(
                      context,
                      l10n.unreadChats,
                      _mockVetData.unreadChats,
                      VetColors.chat,
                      Icons.mark_email_unread,
                      '/vet/chat'),
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
                          l10n.logAction,
                          Icons.medical_services,
                          VetColors.treatment,
                          '/vet/actions/log'),
                      _buildQuickActionButton(
                          context,
                          l10n.logRecovery,
                          Icons.healing,
                          VetColors.treatment,
                          '/vet/recovery/log'),
                      _buildQuickActionButton(
                          context,
                          l10n.newSchedule,
                          Icons.date_range,
                          VetColors.appointments,
                          '/vet/schedules/add'),
                      _buildQuickActionButton(
                          context,
                          l10n.viewServiceArea,
                          Icons.map,
                          VetColors.finances,
                          '/vet/areas'),
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
                itemCount: _vetModuleItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final item = _vetModuleItems[index];
                  return _buildModuleCard(context, item, l10n);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSED HELPER WIDGETS ---

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

  Widget _buildQuickActionButton(BuildContext context, String label,
      IconData icon, Color color, String route) {
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

  Widget _buildModuleCard(
      BuildContext context, ModuleItem item, _VetL10n l10n) {
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
                    // Special handling for the finance module to show TZS
                    item.titleKey == 'finances' 
                      ? 'TZS ${item.count ~/ 1000}K'
                      : item.count.toString(),
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

// -------------------------------------------------------------------
// --- 3. WIDGET FOR VET STATS SECTION ---
// -------------------------------------------------------------------

class _VetStatsSection extends StatelessWidget {
  const _VetStatsSection({required this.l10n, required this.data});

  final _VetL10n l10n;
  final _VetDashboardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define the list of stats to show
    final stats = [
      {
        'title': l10n.todayAppointments,
        'value': data.todayAppointments,
        'color': VetColors.appointments,
        'icon': Icons.today,
      },
      {
        'title': l10n.expectedFeesToday,
        'value': 'TZS ${data.expectedFeesToday.toStringAsFixed(0)}', 
        'color': VetColors.finances,
        'icon': Icons.money,
      },
      {
        'title': l10n.upcomingAppointments,
        'value': data.upcomingAppointments,
        'color': VetColors.appointments,
        'icon': Icons.calendar_month,
      },
      {
        'title': l10n.activeServiceAreas,
        'value': data.activeServiceAreas,
        'color': VetColors.chat,
        'icon': Icons.map,
      },
      {
        'title': l10n.prescriptionsExpiring,
        'value': data.prescriptionsExpiring,
        'color': VetColors.treatment,
        'icon': Icons.warning_amber,
      },
      {
        'title': l10n.dueOrOverdueVaccines,
        'value': data.dueOrOverdueVaccines,
        'color': VetColors.actionRequired,
        'icon': Icons.report_problem,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.vetOverview,
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

  /// Stat Card component for 2-column responsiveness (REUSED)
  Widget _buildStatCard(BuildContext context, String title, dynamic value,
      Color color, IconData icon) {
    final theme = Theme.of(context);
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
              Text(
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

// -------------------------------------------------------------------
// --- 4. MOCK LOCALIZATION CLASS for Veterinarian ---
// -------------------------------------------------------------------

class _VetL10n {
  final BuildContext context;
  _VetL10n(this.context);

  String get vetDashboardTitle => 'Veterinarian Dashboard';
  String get vetOverview => 'Today\'s Workload Overview';
  String get alerts => 'Critical Alerts & Action Required';
  String get quickActions => 'Quick Actions';
  String get modules => 'Modules';

  // STATS
  String get todayAppointments => 'Appointments Today';
  String get upcomingAppointments => 'Upcoming Appointments (7 Days)';
  String get expectedFeesToday => 'Expected Fees Today';
  String get prescriptionsExpiring => 'Prescriptions Expiring Soon';
  String get dueOrOverdueVaccines => 'Vaccines Due or Missed';
  String get activeServiceAreas => 'Active Service Areas';

  // ALERTS
  String get newReports => 'New Health Reports for Action';
  String get overdueFollowUps => 'Overdue Recovery Follow-ups';
  String get overdueVaccines => 'Due/Missed Vaccination Schedules';
  String get unreadChats => 'Unread Chat Messages';

  // ACTIONS
  String get logAction => 'Log Vet Action/Treatment';
  String get logRecovery => 'Log Recovery/Follow-up';
  String get newSchedule => 'Create New Vaccine Schedule';
  String get viewServiceArea => 'Manage Service Area';

  String getString(String key) {
    switch (key) {
      case 'appointments':
        return 'Appointments';
      case 'actions':
        return 'Treatment Actions';
      case 'schedules':
        return 'Vaccine Schedules';
      case 'prescriptions':
        return 'Prescriptions';
      case 'chat':
        return 'Farmer Chat';
      case 'finances':
        return 'Finances';
      case 'serviceArea':
        return 'Service Areas';
      default:
        return key;
    }
  }
}