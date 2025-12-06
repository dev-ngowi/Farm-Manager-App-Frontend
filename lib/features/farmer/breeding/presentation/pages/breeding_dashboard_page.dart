import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed AppTheme includes AppColors
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
// Note: Assuming AppLocalizations is available. Using mock for self-contained example.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Uncomment in production

// --- DATA STRUCTURES (Mock Data for Design Review) ---

// 1. Mock Backend Data Structure
class _BreedingDashboardData {
  // Insemination
  final int totalInseminations = 150;
  final int pregnantNow = 25;
  final double successRate = 82.5;
  final int dueSoonCount = 5;
  final double avgCalvingInterval = 385.2;

  // Lactation
  final int activeLactations = 35;
  final double avgDaysInMilk = 120.5;

  // Inventory
  final int totalAvailableStraws = 280;

  // Offspring
  final int totalOffspringRecorded = 73;

  // Alerts
  final int dueSoonAlerts = 5;
  final int heatExpectedAlerts = 12;
  final int dryOffRequiredAlerts = 3;
}

final _mockData = _BreedingDashboardData();

// 2. Define a simple structure for modular navigation items
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
    // final l10n = AppLocalizations.of(context)!; // Uncomment in production
    // Placeholder l10n for design review:
    final l10n = _DesignL10n(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Use theme background color
      appBar: AppBar(
        // --- START: FIXED NAVIGATION ERROR ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/farmer/dashboard'),
        ),
        // --- END: FIXED NAVIGATION ERROR ---
        title: Text(l10n.breedingManagement),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STATS GRID (Small, responsive cards)
            _BreedingStatsSection(l10n: l10n, data: _mockData),

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
                  // Delivery Due Soon Alert
                  _buildAlertCard(
                      context,
                      l10n.dueSoon,
                      _mockData.dueSoonAlerts,
                      AppColors.secondary,
                      Icons.pregnant_woman,
                      '/farmer/breeding/deliveries'),
                  const SizedBox(height: 8),
                  // Heat Expected Alert
                  _buildAlertCard(
                      context,
                      l10n.heatExpected,
                      _mockData.heatExpectedAlerts,
                      BreedingColors.heat,
                      Icons.whatshot,
                      '/farmer/breeding/heat-cycles'),
                  const SizedBox(height: 8),
                  // Dry-off Required Alert
                  _buildAlertCard(
                      context,
                      l10n.dryOffRequired,
                      _mockData.dryOffRequiredAlerts,
                      AppColors.warning,
                      Icons.opacity,
                      '/farmer/breeding/lactations'),
                ],
              ),
            ),

            const Divider(indent: 16, endIndent: 16),

            // 3. QUICK ACTIONS SECTION (Small, compact buttons)
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
                    spacing: 16, // Consistent horizontal spacing
                    runSpacing: 16, // Consistent vertical spacing
                    alignment: WrapAlignment.start,
                    children: [
                      _buildQuickActionButton(
                          context,
                          l10n.recordHeat,
                          Icons.whatshot,
                          BreedingColors.heat,
                          '/farmer/breeding/heat-cycles/add'),
                      _buildQuickActionButton(
                          context,
                          l10n.recordBreeding,
                          Icons.vaccines,
                          BreedingColors.insemination,
                          '/farmer/breeding/inseminations/add'),
                      _buildQuickActionButton(
                          context,
                          l10n.addSemen,
                          Icons.storage,
                          BreedingColors.semen,
                          '/farmer/breeding/semen/add'),
                      _buildQuickActionButton(
                          context,
                          l10n.pregnancyCheck,
                          Icons.monitor_heart,
                          BreedingColors.pregnancy,
                          '/farmer/breeding/pregnancy-checks/add'),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(indent: 16, endIndent: 16),

            // 4. MODULES SECTION (Cards now smaller/denser)
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
                  // Aspect ratio for smaller cards
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
      margin: EdgeInsets.zero, // Remove global card margin
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
    final widgetWidth = (screenWidth - 16 * 3) /
        2; // (Screen - (Paddings * 2) - (Spacing * 1)) / 2

    return SizedBox(
      width: widgetWidth,
      child: ElevatedButton.icon(
        onPressed: () => context.push(route),
        icon: Icon(icon,
            color: AppColors.onSecondary), // Use AppColors.onSecondary (white)
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
      elevation: 2, // Locally override global CardTheme
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero, // Remove global card margin
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
                l10n.getString(item.titleKey), // Use localized title
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

// --- NEW WIDGET FOR STATS SECTION ---
class _BreedingStatsSection extends StatelessWidget {
  const _BreedingStatsSection({required this.l10n, required this.data});

  final _DesignL10n l10n;
  final _BreedingDashboardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define the list of stats to show (selected 6 key stats for density)
    final stats = [
      // INSEMINATION
      {
        'title': l10n.pregnantNow,
        'value': data.pregnantNow,
        'color': AppColors.primary,
        'icon': Icons.favorite,
      },
      {
        'title': l10n.successRate,
        'value': '${data.successRate.toStringAsFixed(1)}%',
        'color': BreedingColors.insemination,
        'icon': Icons.trending_up,
      },
      {
        'title': l10n.avgCalvingInterval,
        'value': '${data.avgCalvingInterval.toStringAsFixed(0)} ${l10n.days}',
        'color': BreedingColors.delivery,
        'icon': Icons.calendar_today,
      },
      // LACTATION & INVENTORY & Offspring (Added Offspring Stat here)
      {
        'title': l10n.totalOffspring,
        'value': data.totalOffspringRecorded,
        'color': BreedingColors.offspring,
        'icon': Icons.child_friendly,
      },
      {
        'title': l10n.activeLactations,
        'value': data.activeLactations,
        'color': BreedingColors.lactation,
        'icon': Icons.local_drink,
      },
      {
        'title': l10n.availableSemen,
        'value': data.totalAvailableStraws,
        'color': BreedingColors.semen,
        'icon': Icons.storage,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.performanceSummary,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12, // Horizontal spacing between cards
            runSpacing: 12, // Vertical spacing between cards
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

  /// Stat Card component redesigned for 2-column responsiveness
  Widget _buildStatCard(BuildContext context, String title, dynamic value,
      Color color, IconData icon) {
    final theme = Theme.of(context);
    // Calculated width to ensure two items per row, allowing for space and padding
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 16 * 2 - 12) /
        2; // (Screen - (Paddings * 2) - (Spacing * 1)) / 2

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

// --- MOCK LOCALIZATION CLASS (Necessary for code completion and review) ---
class _DesignL10n {
  final BuildContext context;
  _DesignL10n(this.context);

  String get breedingManagement => 'Breeding Management';
  String get performanceSummary => 'Performance Summary';
  String get alerts => 'Alerts';
  String get quickActions => 'Quick Actions';
  String get modules => 'Modules';

  // STATS
  String get pregnantNow => 'Pregnant Now';
  String get successRate => 'Success Rate';
  String get avgCalvingInterval => 'Avg. Calving Interval';
  String get activeLactations => 'Active Lactations';
  String get avgDaysInMilk => 'Avg. Days in Milk';
  String get availableSemen => 'Available Semen Straws';
  String get totalOffspring => 'Total Offspring';
  String get days => 'Days';

  // ALERTS
  String get dueSoon => 'Deliveries Due Soon';
  String get heatExpected => 'Heat Expected';
  String get dryOffRequired => 'Dry-off Required';

  // ACTIONS
  String get recordHeat => 'Record Heat';
  String get addSemen => 'Add Semen';
  String get recordBreeding => 'Record Breeding';
  String get pregnancyCheck => 'Pregnancy Check';

  String getString(String key) {
    switch (key) {
      case 'heatCycles':
        return 'Heat Cycles';
      case 'semenInventory':
        return 'Semen Inventory';
      case 'inseminations':
        return 'Inseminations';
      case 'pregnancyChecks':
        return 'Pregnancy Checks';
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
