import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- DATA STRUCTURES ---

class _BreedingDashboardData {
  // Top 3 Key Metrics
  final int pregnantNow = 25;
  final double successRate = 82.5;
  final int totalOffspringRecorded = 73;
  final int activeBreeding = 45;
  final double pregnancyRate = 78.0;

  // Alerts
  final int dueSoonAlerts = 5;
  final int heatExpectedAlerts = 12;
  final int dryOffRequiredAlerts = 3;
  final int pregnancyChecksNeeded = 8;
}

final _mockData = _BreedingDashboardData();

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
      titleKey: 'heatCycles',
      icon: Icons.whatshot,
      color: BreedingColors.heat,
      count: 28,
      route: '/farmer/breeding/heat-cycles'),
  ModuleItem(
      titleKey: 'semenInventory',
      icon: Icons.storage,
      color: BreedingColors.semen,
      count: 52,
      route: '/farmer/breeding/semen'),
  ModuleItem(
      titleKey: 'inseminations',
      icon: Icons.vaccines,
      color: BreedingColors.insemination,
      count: 89,
      route: '/farmer/breeding/inseminations'),
  ModuleItem(
      titleKey: 'pregnancyChecks',
      icon: Icons.monitor_heart,
      color: BreedingColors.pregnancy,
      count: 41,
      route: '/farmer/breeding/pregnancy-checks'),
  ModuleItem(
      titleKey: 'deliveries',
      icon: Icons.baby_changing_station,
      color: BreedingColors.delivery,
      count: 15,
      route: '/farmer/breeding/deliveries'),
  ModuleItem(
      titleKey: 'offspring',
      icon: Icons.child_friendly,
      color: BreedingColors.offspring,
      count: 73,
      route: '/farmer/breeding/offspring'),
  ModuleItem(
      titleKey: 'lactations',
      icon: Icons.local_drink,
      color: BreedingColors.lactation,
      count: 38,
      route: '/farmer/breeding/lactations'),
];

class BreedingDashboardPage extends StatelessWidget {
  static const String routeName = '/farmer/breeding';

  const BreedingDashboardPage({super.key});

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
          'Breeding Management',
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

              // Breeding performance card
              _buildPerformanceCard(l10n, _mockData),

              const SizedBox(height: 16),

              // Action items / Alerts
              _buildActionItems(l10n, _mockData),

              const SizedBox(height: 16),

              // Quick access modules
              _buildQuickAccessModules(l10n),

              const SizedBox(height: 16),

              // Additional metrics
              _buildAdditionalMetrics(l10n, _mockData),

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
            'Breeding Overview',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor and manage your herd\'s reproductive health',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(_DesignL10n l10n, _BreedingDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'Currently Pregnant',
              value: data.pregnantNow.toString(),
              subtitle: 'Active pregnancies',
              icon: Icons.pregnant_woman,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Success Rate',
              value: '${data.successRate.toStringAsFixed(1)}%',
              subtitle: 'Conception rate',
              icon: Icons.trending_up,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Total Offspring',
              value: data.totalOffspringRecorded.toString(),
              subtitle: 'All time',
              icon: Icons.child_friendly,
              color: BreedingColors.offspring,
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

  Widget _buildPerformanceCard(_DesignL10n l10n, _BreedingDashboardData data) {
    double rate = data.pregnancyRate;
    bool isGood = rate >= 70;

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
                      value: rate / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGood ? AppColors.success : AppColors.secondary,
                      ),
                    ),
                  ),
                  Text(
                    '${rate.toInt()}%',
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
                      'Breeding Program Health',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGood
                          ? 'Your breeding program is performing excellently'
                          : 'Some areas need attention',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: rate / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGood ? AppColors.success : AppColors.secondary,
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

  Widget _buildActionItems(_DesignL10n l10n, _BreedingDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active,
                  color: AppColors.secondary, size: 18),
              const SizedBox(width: 6),
              Text(
                'Action Items',
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
                child: _buildActionCard(
                  title: 'Due Soon',
                  count: data.dueSoonAlerts,
                  icon: Icons.calendar_today,
                  color: AppColors.secondary,
                  route: '/farmer/breeding/deliveries',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  title: 'Heat Expected',
                  count: data.heatExpectedAlerts,
                  icon: Icons.whatshot,
                  color: BreedingColors.heat,
                  route: '/farmer/breeding/heat-cycles',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Dry-off Required',
                  count: data.dryOffRequiredAlerts,
                  icon: Icons.opacity,
                  color: AppColors.warning,
                  route: '/farmer/breeding/lactations',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  title: 'Pregnancy Checks',
                  count: data.pregnancyChecksNeeded,
                  icon: Icons.monitor_heart,
                  color: BreedingColors.pregnancy,
                  route: '/farmer/breeding/pregnancy-checks',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
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

  Widget _buildQuickAccessModules(_DesignL10n l10n) {
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
                'Quick Access',
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

  Widget _buildAdditionalMetrics(
      _DesignL10n l10n, _BreedingDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breeding Statistics',
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
                  label: 'Active Breeding',
                  value: data.activeBreeding.toString(),
                  icon: Icons.insights,
                  color: BreedingColors.insemination,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  label: 'Semen Straws',
                  value: '52',
                  icon: Icons.storage,
                  color: BreedingColors.semen,
                ),
              ),
            ],
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

// ═══════════════════════════════════════════════════════════════════════════
// MOCK LOCALIZATION
// ═══════════════════════════════════════════════════════════════════════════
class _DesignL10n {
  final BuildContext context;
  _DesignL10n(this.context);

  String get breedingManagement => 'Breeding Management';
  String get alerts => 'Alerts';
  String get modules => 'Modules';

  // STATS
  String get pregnantNow => 'Pregnant';
  String get successRate => 'Success Rate';
  String get totalOffspring => 'Offspring';

  // ALERTS
  String get dueSoon => 'Deliveries Due Soon';
  String get heatExpected => 'Heat Expected';
  String get dryOffRequired => 'Dry-off Required';

  String getString(String key) {
    switch (key) {
      case 'heatCycles':
        return 'Heat Cycles';
      case 'semenInventory':
        return 'Semen';
      case 'inseminations':
        return 'Inseminations';
      case 'pregnancyChecks':
        return 'Pregnancy';
      case 'deliveries':
        return 'Deliveries';
      case 'offspring':
        return 'Offspring';
      case 'lactations':
        return 'Lactations';
      default:
        return key;
    }
  }
}