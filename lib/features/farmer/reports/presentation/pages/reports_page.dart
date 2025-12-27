import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- Color Definitions ---

class FinanceColors {
  static const Color income = Color(0xFF43A047);
  static const Color expense = Color(0xFFD81B60);
  static const Color profit = Color(0xFF1E88E5);
}

class ProductionColors {
  static const Color milk = Color(0xFF00BFA5);
  static const Color feed = Color(0xFFFF9800);
  static const Color factors = Color(0xFF7E57C2);
}

class HealthColors {
  static const Color reports = Color(0xFF1E88E5);
  static const Color diagnosis = Color(0xFF00BFA5);
}

class BreedingColors {
  static const Color repro = Color(0xFFD81B60);
  static const Color heat = Color(0xFFE53935);
  static const Color delivery = Color(0xFF006610);
}

// --- Data Structures ---

enum ReportType { list, chart, pdf, excel }

class ReportItem {
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final Color color;
  final String route;
  final List<ReportType> availableFormats;
  final bool isFeatured;

  const ReportItem({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.color,
    required this.route,
    this.availableFormats = const [ReportType.list, ReportType.pdf],
    this.isFeatured = false,
  });
}

class _ReportCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<ReportItem> reports;

  const _ReportCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.reports,
  });
}

// --- Reports Data (Featured Reports list removed) ---

final List<_ReportCategory> _reportCategories = [
  _ReportCategory(
    title: 'Financial Reports',
    icon: Icons.account_balance_wallet,
    color: FinanceColors.profit,
    reports: [
      ReportItem(
        titleKey: 'profitLossReport',
        subtitleKey: 'Detailed monthly/quarterly P&L statement',
        icon: Icons.show_chart,
        color: FinanceColors.profit,
        route: '/farmer/reports/finance/pnl',
        availableFormats: [ReportType.chart, ReportType.pdf],
      ),
      ReportItem(
        titleKey: 'expenseSummary',
        subtitleKey: 'Breakdown of expenses by category and time',
        icon: Icons.money_off,
        color: FinanceColors.expense,
        route: '/farmer/reports/finance/expenses',
        availableFormats: [ReportType.list, ReportType.chart, ReportType.pdf],
      ),
      ReportItem(
        titleKey: 'incomeSummary',
        subtitleKey: 'Overview of income by source',
        icon: Icons.attach_money,
        color: FinanceColors.income,
        route: '/farmer/reports/finance/income',
        availableFormats: [ReportType.list, ReportType.chart, ReportType.pdf],
      ),
    ],
  ),
  _ReportCategory(
    title: 'Production Reports',
    icon: Icons.trending_up,
    color: ProductionColors.milk,
    reports: [
      ReportItem(
        titleKey: 'milkYieldAnalysis',
        subtitleKey: 'Daily/monthly milk production and trend analysis',
        icon: Icons.local_drink,
        color: ProductionColors.milk,
        route: '/farmer/reports/production/milk',
        availableFormats: [ReportType.list, ReportType.chart, ReportType.pdf],
      ),
      ReportItem(
        titleKey: 'lactationAnalysis',
        subtitleKey: 'Lactation curve and peak performance',
        icon: Icons.opacity,
        color: ProductionColors.milk,
        route: '/farmer/reports/production/lactation',
        availableFormats: [ReportType.list, ReportType.chart],
      ),
      ReportItem(
        titleKey: 'feedIntakeVsYield',
        subtitleKey: 'Feed efficiency and production correlation',
        icon: Icons.fastfood,
        color: ProductionColors.feed,
        route: '/farmer/reports/production/feed',
        availableFormats: [ReportType.list, ReportType.chart, ReportType.pdf],
      ),
      ReportItem(
        titleKey: 'productionFactor',
        subtitleKey: 'Animal efficiency and performance factors',
        icon: Icons.analytics,
        color: ProductionColors.factors,
        route: '/farmer/reports/production/factors',
        availableFormats: [ReportType.list, ReportType.pdf],
      ),
    ],
  ),
  _ReportCategory(
    title: 'Health Reports',
    icon: Icons.medical_services,
    color: HealthColors.reports,
    reports: [
      ReportItem(
        titleKey: 'healthCaseSummary',
        subtitleKey: 'Summary of health cases and treatments',
        icon: Icons.report_problem,
        color: HealthColors.reports,
        route: '/farmer/reports/health/cases',
        availableFormats: [ReportType.list, ReportType.pdf, ReportType.excel],
      ),
      ReportItem(
        titleKey: 'vaccinationReport',
        subtitleKey: 'Vaccination compliance and schedules',
        icon: Icons.vaccines,
        color: HealthColors.diagnosis,
        route: '/farmer/reports/health/vaccines',
        availableFormats: [ReportType.list],
      ),
    ],
  ),
  _ReportCategory(
    title: 'Breeding Reports',
    icon: Icons.child_care,
    color: BreedingColors.repro,
    reports: [
      ReportItem(
        titleKey: 'breedingStatus',
        subtitleKey: 'Pregnancy rate and calving forecasts',
        icon: Icons.favorite,
        color: BreedingColors.repro,
        route: '/farmer/reports/repro/breeding',
        availableFormats: [ReportType.list, ReportType.chart],
      ),
      ReportItem(
        titleKey: 'deliveryRecord',
        subtitleKey: 'Calving records and delivery outcomes',
        icon: Icons.pets,
        color: BreedingColors.delivery,
        route: '/farmer/reports/repro/delivery',
        availableFormats: [ReportType.list, ReportType.pdf],
      ),
      ReportItem(
        titleKey: 'heatCycleAnalysis',
        subtitleKey: 'Heat cycles and insemination windows',
        icon: Icons.local_fire_department,
        color: BreedingColors.heat,
        route: '/farmer/reports/repro/heat',
        availableFormats: [ReportType.list, ReportType.chart],
      ),
    ],
  ),
];

// --- Mock Data ---
class _ReportStats {
  final int totalReports = 12;
  final int generatedThisMonth = 8;
  final String lastGenerated = '2 hours ago';
}

final _stats = _ReportStats();

// --- Reports Hub Widget ---

class ReportsHubPage extends StatelessWidget {
  static const String routeName = '/farmer/reports';

  const ReportsHubPage({super.key});

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
          'Reports & Analytics',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
            onPressed: () {
              // Filter options
            },
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
              // Header
              _buildHeader(l10n),

              const SizedBox(height: 16),

              // Quick stats
              _buildQuickStats(l10n, _stats),

              // Spacing between Stats and Categories (replacing featured section)
              const SizedBox(height: 24), 

              // All Report Categories
              ..._reportCategories.map((category) {
                return _buildReportCategory(context, category, l10n);
              }),

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
          const Text(
            'Farm Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate detailed reports and insights about your farm operations',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(_DesignL10n l10n, _ReportStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Available Reports',
              value: stats.totalReports.toString(),
              icon: Icons.description,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'This Month',
              value: stats.generatedThisMonth.toString(),
              icon: Icons.calendar_today,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Last Generated',
              value: stats.lastGenerated,
              icon: Icons.access_time,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // _buildFeaturedReports and _buildFeaturedReportCard methods have been removed.

  Widget _buildReportCategory(
      BuildContext context, _ReportCategory category, _DesignL10n l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(category.icon, color: category.color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${category.reports.length} reports',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Report Cards
          ...category.reports.map((item) {
            return _buildReportCard(context, item, l10n);
          }),
        ],
      ),
    );
  }

  Widget _buildReportCard(
      BuildContext context, ReportItem item, _DesignL10n l10n) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(item.route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 24, color: item.color),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString(item.titleKey),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitleKey,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Format Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFormatIcon(item.availableFormats),
                      color: item.color,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatFormats(item.availableFormats),
                      style: TextStyle(
                        color: item.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFormatIcon(List<ReportType> formats) {
    if (formats.contains(ReportType.excel)) return Icons.table_chart;
    if (formats.contains(ReportType.chart)) return Icons.bar_chart;
    return Icons.description;
  }

  String _formatFormats(List<ReportType> formats) {
    if (formats.contains(ReportType.excel)) return 'EXCEL';
    if (formats.contains(ReportType.chart)) return 'CHART';
    return 'PDF';
  }
}

// --- Mock Localization ---
class _DesignL10n {
  final BuildContext context;
  _DesignL10n(this.context);

  String getString(String key) {
    switch (key) {
      // Finance Reports
      case 'profitLossReport':
        return 'P&L Report';
      case 'expenseSummary':
        return 'Expenses';
      case 'incomeSummary':
        return 'Income';
      // Production Reports
      case 'milkYieldAnalysis':
        return 'Milk Yield';
      case 'lactationAnalysis':
        return 'Lactation';
      case 'feedIntakeVsYield':
        return 'Feed Efficiency';
      case 'productionFactor':
        return 'Production Factors';
      // Health Reports
      case 'healthCaseSummary':
        return 'Health Cases';
      case 'vaccinationReport':
        return 'Vaccinations';
      // Breeding Reports
      case 'breedingStatus':
        return 'Breeding Status';
      case 'deliveryRecord':
        return 'Deliveries';
      case 'heatCycleAnalysis':
        return 'Heat Cycles';
      default:
        return key;
    }
  }
}