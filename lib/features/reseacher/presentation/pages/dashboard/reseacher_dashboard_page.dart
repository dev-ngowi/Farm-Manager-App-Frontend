
import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed AppTheme includes AppColors
import 'package:farm_manager_app/features/farmer/health/presentation/pages/health_records_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// -------------------------------------------------------------------
// --- 1. RESEARCHER-SPECIFIC COLORS and DATA (AS DEFINED ABOVE) ---
// -------------------------------------------------------------------

class ResearcherColors {
  static const Color request = Color(0xFF7E57C2); // Purple for new requests
  static const Color pending = Color(0xFFFFB300); // Amber for pending review
  static const Color approved = Color(0xFF43A047); // Green for approval/active access
  static const Color export = Color(0xFF1E88E5); // Blue for data export/download
  static const Color expired = Color(0xFFD81B60); // Pink/Red for expired access
}

class _ResearcherDashboardData {
  final int totalRequests = 15;
  final int pendingRequests = 3;
  final int underReviewRequests = 2;
  final int activeAccessGrants = 7;
  final int availableExports = 5;
  final int expiredExports = 2;
  final int totalDownloads = 48;
  final String lastExportDate = '2025-11-20';
  final String mostRequestedSpecies = 'Cattle (Shorthorn)'; 
}

final _mockResearcherData = _ResearcherDashboardData();

final List<ModuleItem> _researcherModuleItems = [
  ModuleItem(
      titleKey: 'dataRequests',
      icon: Icons.assignment,
      color: ResearcherColors.request,
      count: _mockResearcherData.totalRequests,
      route: '/researcher/requests'),
  ModuleItem(
      titleKey: 'myExports',
      icon: Icons.download,
      color: ResearcherColors.export,
      count: _mockResearcherData.availableExports,
      route: '/researcher/exports'),
  ModuleItem(
      titleKey: 'researchStats',
      icon: Icons.analytics,
      color: ResearcherColors.pending,
      count: _mockResearcherData.totalDownloads,
      route: '/researcher/stats'),
];

// -------------------------------------------------------------------
// --- 2. RESEARCHER DASHBOARD WIDGET ---
// -------------------------------------------------------------------

class ResearcherDashboardPage extends StatelessWidget {
  static const String routeName = '/researcher/dashboard';

  const ResearcherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a mock L10N class similar to the one provided
    final l10n = _ResearcherL10n(context); 
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'), // Assuming back to main entry point
        ),
        title: Text(l10n.researchDashboardTitle),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STATS GRID (Key Access and Request Status)
            _ResearcherStatsSection(l10n: l10n, data: _mockResearcherData),

            // 2. ALERTS SECTION (Critical actions required by Researcher)
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
                  // Pending Requests Alert (Pending Researcher action)
                  _buildAlertCard(
                      context,
                      l10n.pendingRequests,
                      _mockResearcherData.pendingRequests,
                      ResearcherColors.pending,
                      Icons.hourglass_empty,
                      '/researcher/requests?status=pending'),
                  const SizedBox(height: 8),
                  // Available Exports Alert (Ready to download)
                  _buildAlertCard(
                      context,
                      l10n.availableExports,
                      _mockResearcherData.availableExports,
                      ResearcherColors.approved, // Use green as it means data is READY
                      Icons.cloud_download,
                      '/researcher/exports?status=available'),
                  const SizedBox(height: 8),
                  // Expired Access Alert (Needs renewal)
                  _buildAlertCard(
                      context,
                      l10n.expiredAccess,
                      _mockResearcherData.expiredExports,
                      ResearcherColors.expired,
                      Icons.lock_clock,
                      '/researcher/access?status=expired'),
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
                          l10n.newRequest,
                          Icons.add_box,
                          ResearcherColors.request,
                          '/researcher/requests/add'),
                      _buildQuickActionButton(
                          context,
                          l10n.downloadData,
                          Icons.file_download,
                          ResearcherColors.export,
                          '/researcher/exports'),
                      _buildQuickActionButton(
                          context,
                          l10n.contactAdmin,
                          Icons.support_agent,
                          ResearcherColors.pending,
                          '/researcher/contact'),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(indent: 16, endIndent: 16),

            // 4. MODULES SECTION (Using the original ModuleItem and builder)
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
                itemCount: _researcherModuleItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final item = _researcherModuleItems[index];
                  // Reusing the original _buildModuleCard from the health dashboard code
                  return _buildModuleCard(context, item, l10n); 
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSED WIDGETS (Must be defined or imported) ---
  // To make this file standalone, I'm defining the necessary helper widgets below.

  /// Alert Card using standard Card and ListTile (REUSED)
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

  /// Quick Action Button (REUSED)
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

  /// Module Navigation Card (REUSED)
  Widget _buildModuleCard(
      BuildContext context, ModuleItem item, _ResearcherL10n l10n) {
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

// -------------------------------------------------------------------
// --- 3. NEW WIDGET FOR RESEARCHER STATS SECTION ---
// -------------------------------------------------------------------

class _ResearcherStatsSection extends StatelessWidget {
  const _ResearcherStatsSection({required this.l10n, required this.data});

  final _ResearcherL10n l10n;
  final _ResearcherDashboardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final stats = [
      {
        'title': l10n.activeAccessGrants,
        'value': data.activeAccessGrants,
        'color': ResearcherColors.approved,
        'icon': Icons.vpn_key,
      },
      {
        'title': l10n.availableExports,
        'value': data.availableExports,
        'color': ResearcherColors.export,
        'icon': Icons.file_present,
      },
      {
        'title': l10n.totalDownloads,
        'value': data.totalDownloads,
        'color': ResearcherColors.request,
        'icon': Icons.cloud_done,
      },
      {
        'title': l10n.mostRequestedSpecies,
        'value': data.mostRequestedSpecies,
        'color': AppColors.textPrimary,
        'icon': Icons.pets,
      },
      {
        'title': l10n.totalRequests,
        'value': data.totalRequests,
        'color': ResearcherColors.pending,
        'icon': Icons.list_alt,
      },
      {
        'title': l10n.lastExportDate,
        'value': data.lastExportDate,
        'color': ResearcherColors.export,
        'icon': Icons.calendar_month,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.researchOverview,
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

// -------------------------------------------------------------------
// --- 4. MOCK LOCALIZATION CLASS for Researcher ---
// -------------------------------------------------------------------

class _ResearcherL10n {
  final BuildContext context;
  _ResearcherL10n(this.context);

  String get researchDashboardTitle => 'Research Data Access';
  String get researchOverview => 'Data Access Overview';
  String get alerts => 'Critical Alerts';
  String get quickActions => 'Quick Actions';
  String get modules => 'Modules';

  // STATS
  String get activeAccessGrants => 'Active Data Access Grants';
  String get availableExports => 'Data Exports Available';
  String get totalDownloads => 'Total Downloads';
  String get mostRequestedSpecies => 'Top Species Requested';
  String get totalRequests => 'Total Requests Submitted';
  String get lastExportDate => 'Last Data Export Date';

  // ALERTS
  String get pendingRequests => 'Pending Requests (Action)';
  String get expiredAccess => 'Expired Data Access';

  // ACTIONS
  String get newRequest => 'Submit New Request';
  String get downloadData => 'View & Download Exports';
  String get contactAdmin => 'Contact Data Admin';

  String getString(String key) {
    switch (key) {
      case 'dataRequests':
        return 'Data Requests';
      case 'myExports':
        return 'My Exports';
      case 'researchStats':
        return 'Research Metrics';
      default:
        return key;
    }
  }
}