import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- 1. HEALTH-SPECIFIC COLORS ---
class HealthColors {
  static const Color reports = Color(0xFF1E88E5);
  static const Color diagnosis = Color(0xFF00BFA5);
  static const Color treatment = Color(0xFFD81B60);
  static const Color vaccine = Color(0xFFFF9800);
  static const Color appointment = Color(0xFF7E57C2);
  static const Color chat = Color(0xFF43A047);
}

// --- 2. DATA STRUCTURES ---

class _HealthDashboardData {
  final int totalReports = 45;
  final int activeCases = 12;
  final int highPriorityReports = 4;
  final int confirmedDiagnoses = 33;
  final String mostCommonDisease = 'Foot and Mouth Disease';
  final int totalTreatments = 85;
  final int overdueFollowUps = 7;
  final double avgTreatmentCost = 45000.0;
  final int totalSchedules = 120;
  final int upcomingVaccines = 8;
  final int missedVaccines = 15;
  final int activeAppointments = 3;
  final int activeChats = 2;
  final int pendingExtensionRequests = 5;
  final double healthScore = 88.5;
  final int healthyAnimals = 138;
}

final _mockData = _HealthDashboardData();

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
      count: 22,
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
    final l10n = _DesignL10n(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/farmer/dashboard'),
        ),
        title: const Text(
          'Health Management',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: AppColors.primary),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with overview
              _buildHeader(l10n),

              const SizedBox(height: 16),

              // Key metrics cards
              _buildKeyMetrics(l10n, _mockData),

              const SizedBox(height: 16),

              // Health score card
              _buildHealthScoreCard(l10n, _mockData),

              const SizedBox(height: 16),

              // Critical alerts
              _buildCriticalAlerts(l10n, _mockData),

              const SizedBox(height: 16),

           

              // Health modules
              _buildHealthModules(l10n),

              const SizedBox(height: 16),

              // Additional stats
              _buildAdditionalStats(l10n, _mockData),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_DesignL10n l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Overview',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor and maintain your herd\'s health status',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(_DesignL10n l10n, _HealthDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'Active Cases',
              value: data.activeCases.toString(),
              subtitle: 'Need attention',
              icon: Icons.healing,
              color: HealthColors.reports,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Healthy Animals',
              value: data.healthyAnimals.toString(),
              subtitle: 'In good health',
              icon: Icons.favorite,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Vaccinations',
              value: data.upcomingVaccines.toString(),
              subtitle: 'Due soon',
              icon: Icons.vaccines,
              color: HealthColors.vaccine,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(_DesignL10n l10n, _HealthDashboardData data) {
    double score = data.healthScore;
    bool isGood = score >= 80;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGood ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                  Text(
                    '${score.toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Herd Health',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGood
                          ? 'Your herd is in excellent health condition'
                          : 'Some animals need immediate attention',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGood ? AppColors.success : AppColors.warning,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalAlerts(_DesignL10n l10n, _HealthDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 18),
              const SizedBox(width: 6),
              Text(
                'Critical Alerts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAlertCard(
                  title: 'High Priority',
                  count: data.highPriorityReports,
                  icon: Icons.priority_high,
                  color: AppColors.error,
                  route: '/farmer/health/reports/high',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertCard(
                  title: 'Overdue Follow-ups',
                  count: data.overdueFollowUps,
                  icon: Icons.watch_later,
                  color: AppColors.warning,
                  route: '/farmer/health/treatments/overdue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAlertCard(
                  title: 'Missed Vaccines',
                  count: data.missedVaccines,
                  icon: Icons.error_outline,
                  color: AppColors.secondary,
                  route: '/farmer/health/vaccinations/missed',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertCard(
                  title: 'Pending Requests',
                  count: data.pendingExtensionRequests,
                  icon: Icons.support_agent,
                  color: HealthColors.reports,
                  route: '/farmer/requests/pending',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Builder(
      builder: (context) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Tap to view',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildHealthModules(_DesignL10n l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.apps, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                'Health Modules',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _moduleItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final item = _moduleItems[index];
              return _buildModuleButton(item, l10n);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleButton(ModuleItem item, _DesignL10n l10n) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 28,
                    ),
                  ),
                  if (item.count > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          item.count > 99 ? '99+' : item.count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.getString(item.titleKey),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStats(_DesignL10n l10n, _HealthDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Statistics',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Total Treatments',
                  value: data.totalTreatments.toString(),
                  icon: Icons.medication,
                  color: HealthColors.treatment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Avg. Cost',
                  value: 'TZS ${(data.avgTreatmentCost / 1000).toStringAsFixed(0)}K',
                  icon: Icons.money,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: HealthColors.diagnosis.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.bug_report,
                        size: 20, color: HealthColors.diagnosis),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Common Disease',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.mostCommonDisease,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MOCK LOCALIZATION ---
class _DesignL10n {
  final BuildContext context;
  _DesignL10n(this.context);

  String get healthManagement => 'Animal Health Management';
  String get healthOverview => 'Health Overview';
  String get alerts => 'Alerts';
  String get modules => 'Modules';

  String get activeCases => 'Active Health Cases';
  String get confirmedDiagnoses => 'Confirmed Diagnoses';
  String get upcomingVaccines => 'Upcoming Vaccines';
  String get avgTreatmentCost => 'Avg. Treatment Cost';
  String get mostCommonDisease => 'Most Common Disease';
  String get totalTreatments => 'Total Treatments';

  String get highPriorityReports => 'High Priority Reports';
  String get overdueFollowUps => 'Overdue Follow-ups';
  String get missedVaccines => 'Missed Vaccines';
  String get pendingExtensionRequests => 'Pending Extension Requests';

  String get recordSymptoms => 'Record New Symptom';
  String get bookAppointment => 'Book Vet Appointment';
  String get recordTreatment => 'Record Treatment';
  String get scheduleVaccine => 'Schedule Vaccine';

  String getString(String key) {
    switch (key) {
      case 'healthReports':
        return 'Health\nReports';
      case 'diagnoses':
        return 'Diagnoses';
      case 'treatments':
        return 'Treatments';
      case 'vaccinations':
        return 'Vaccinations';
      case 'prescriptions':
        return 'Prescriptions';
      case 'appointments':
        return 'Appointments';
      case 'vetChat':
        return 'Vet Chat';
      default:
        return key;
    }
  }
}