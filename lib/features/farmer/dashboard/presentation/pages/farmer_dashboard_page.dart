import 'package:farm_manager_app/core/config/app_theme.dart'; // Defines AppColors: primary Color(0xFF196944), secondary Color(0xFFD88C3E), etc.
import 'package:farm_manager_app/core/widgets/add_record_bottom_sheet.dart';
import 'package:farm_manager_app/core/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// For multilingual support: import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Use AppLocalizations.of(context)!.someString for English/Swahili strings from languages/en.json and sw.json
// For design preview, using hard-coded English; replace with localization calls.

class FarmerDashboardScreen extends StatefulWidget {
  static const String routeName = '/farmer/dashboard';
  const FarmerDashboardScreen({super.key});
  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _selectedIndex = 0;
  String _selectedPeriod = 'Month to date'; // Localize: e.g., AppLocalizations.of(context)!.monthToDate

  // Static dummy data for design preview (no API calls)
  final Map<String, dynamic> _dummyData = {
    'farmer_name': 'Jackson Ngowi',
    'total_livestock': '150 Animals',
    'livestock_breakdown': 'Active: 120 | Pregnant: 20 | Sick: 10',
    'health_issues': '15 Issues',
    'health_breakdown': 'Critical: 5 | Pending: 10',
    'overall_score': 85.0,
    'vaccinations_due': '5 Overdue',
    'expected_births': '12 Upcoming',
    'pending_vet_requests': '3',
    'upcoming_events': '7',
    'recent_records': [
      {'type': 'Milk Yield', 'date': '2025-11-24', 'description': 'Recorded 20L from Cow #123'},
      {'type': 'Expense', 'date': '2025-11-23', 'description': 'Feed purchase TZS 50,000'},
      // Add more dummy entries as needed for design
    ],
  };

  // --- WIDGETS FOR DESIGN (USING DUMMY DATA) ---
  /// Stat Card
  Widget _buildStatCard({
    required String title,
    required Color accentColor,
    required Map<String, dynamic> data,
    required String valueKey,
    required String subValueKey,
  }) {
    String value = data[valueKey]?.toString() ?? '0';
    String subValue = data[subValueKey] ?? 'Active: 0 | Pregnant: 0 | Sick: 0';
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, // Localize
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subValue,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
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

  /// Summary Card
  Widget _buildSummaryCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vaccination & Breeding Summary', // Localize
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary),
                ),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.add, color: AppColors.onPrimary),
                    onPressed: () {}, // Design only
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Status as ($_selectedPeriod)', // Localize
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: 20),
            _buildSummaryRow(label: 'Vaccinations Due', value: data['vaccinations_due'] ?? '0 Overdue', color: AppColors.secondary),
            const Divider(height: 20),
            _buildSummaryRow(label: 'Expected Births', value: data['expected_births'] ?? '0 Upcoming', color: AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({required String label, required String value, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, // Localize
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  /// Quick Actions Grid
  Widget _buildQuickActionsGrid() {
    final List<Map<String, dynamic>> actions = [
      {'icon': Icons.pets, 'label': 'Livestock'},
      {'icon': Icons.medical_services, 'label': 'Health Records'},
      {'icon': Icons.trending_up, 'label': 'Breeding Records'},
      {'icon': Icons.attach_money, 'label': 'Finances'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final item = actions[index];
          return Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {}, // Design only
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      item['icon'] as IconData,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['label'].toString(), // Localize
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Performance Card
  Widget _buildPerformanceCard(Map<String, dynamic> data) {
    double score = data['overall_score']?.toDouble() ?? 0.0;
    bool isPositive = score >= 70;
    Color cardColor = isPositive ? AppColors.success.withOpacity(0.1) : AppColors.secondary.withOpacity(0.1);
    IconData icon = isPositive ? Icons.sentiment_satisfied_alt : Icons.sentiment_dissatisfied;
    String message = isPositive
        ? 'Great! Your farm is performing well with'
        : 'Attention: Your farm has issues with';
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isPositive ? AppColors.success : AppColors.secondary, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 48, color: isPositive ? AppColors.success : AppColors.secondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message, // Localize
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Overall Score: $score%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.star, color: AppColors.secondary, size: 30),
          ],
        ),
      ),
    );
  }

  /// Status Row
  Widget _buildStatusRow(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          _buildStatusCard(
            label: 'Pending Vet Requests ($_selectedPeriod)',
            value: data['pending_vet_requests'] ?? '0',
            isPending: true,
          ),
          const SizedBox(width: 16),
          _buildStatusCard(
            label: 'Upcoming Events ($_selectedPeriod)',
            value: data['upcoming_events'] ?? '0',
            isPending: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String label,
    required String value,
    required bool isPending,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            label, // Localize
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: isPending ? AppColors.secondary : AppColors.primary),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          onTap: () {}, // Design only
        ),
      ),
    );
  }

  /// Recent Records Section
  Widget _buildRecentRecords(Map<String, dynamic> data) {
    List<dynamic> records = data['recent_records'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Farm Records', // Localize
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {}, // Design only
                child: Text(
                  'View More', // Localize
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        if (records.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'No Recent Records', // Localize
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Add a record to see the list', // Localize
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length > 5 ? 5 : records.length,
            itemBuilder: (context, index) {
              final record = records[index] as Map<String, dynamic>;
              return ListTile(
                leading: Icon(Icons.history, color: AppColors.primary),
                title: Text(record['type'] ?? 'Unknown'), // Localize type
                subtitle: Text('${record['date']} - ${record['description']}'),
                onTap: () {}, // Design only
              );
            },
          ),
      ],
    );
  }

  /// Module Grid
  Widget _buildModuleGrid() {
    final List<Map<String, dynamic>> modules = [
      {'icon': Icons.local_shipping, 'label': 'Feed Suppliers'},
      {'icon': Icons.shopping_cart, 'label': 'Livestock Buyers'},
      {'icon': Icons.medical_services, 'label': 'Vet Services'},
      {'icon': Icons.bar_chart, 'label': 'Farm Reports'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: modules.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),
        itemBuilder: (context, index) {
          final item = modules[index];
          return ElevatedButton.icon(
            onPressed: () {}, // Design only
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface, // White base
              foregroundColor: AppColors.textPrimary,
              shadowColor: AppColors.textSecondary.withOpacity(0.1),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            icon: Icon(item['icon'] as IconData, color: AppColors.primary),
            label: Text(
              item['label'].toString(), // Localize
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
    );
  }

  // --- MAIN BUILD METHOD (DESIGN PREVIEW WITH DUMMY DATA) ---
  @override
  Widget build(BuildContext context) {
    final data = _dummyData;
    final currentRoute = GoRouterState.of(context).uri.path;

    // Define which route belongs to which bottom tab
    int getSelectedBottomIndex() {
      if (currentRoute == '/farmer/dashboard') return 0;
      if (currentRoute.startsWith('/farmer/livestock')) return 1;
      if (currentRoute.startsWith('/farmer/reports')) return 3;
      if (currentRoute.startsWith('/farmer/profile')) return 4;
      return 0; // Default to Home
    }

    int selectedBottomIndex = getSelectedBottomIndex();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: AppColors.primary),
            onPressed: () => context.push('/notifications'), // Optional
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ],
      ),

      // Sidebar (Drawer) - Full menu
      drawer: AppSidebar(currentRoute: currentRoute),

      // Main Content
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80), // Extra space for bottom nav
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GREETING
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
                child: Text(
                  'Good day, ${data['farmer_name']}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 16),
                child: Text(
                  'Here is your farm status',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              // PERIOD FILTER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Day', 'Last 7 days', 'Month to date']
                        .map((label) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: _selectedPeriod == label,
                                onSelected: (selected) {
                                  if (selected) setState(() => _selectedPeriod = label);
                                },
                                selectedColor: AppColors.secondary,
                                labelStyle: TextStyle(
                                  color: _selectedPeriod == label ? AppColors.onSecondary : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: _selectedPeriod == label
                                        ? AppColors.secondary
                                        : AppColors.textSecondary.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // STAT CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildStatCard(
                      title: 'Total Livestock',
                      accentColor: AppColors.success,
                      data: data,
                      valueKey: 'total_livestock',
                      subValueKey: 'livestock_breakdown',
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      title: 'Health Alerts',
                      accentColor: AppColors.error,
                      data: data,
                      valueKey: 'health_issues',
                      subValueKey: 'health_breakdown',
                    ),
                  ],
                ),
              ),

              _buildPerformanceCard(data),
              _buildSummaryCard(data),
              _buildQuickActionsGrid(),
              _buildRecentRecords(data),
              _buildStatusRow(data),
              _buildModuleGrid(),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar - Fast access to core sections
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: selectedBottomIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/farmer/dashboard');
              break;
            case 1:
              context.go('/farmer/livestock');
              break;
            case 2:
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AddRecordBottomSheet(),
            );
            break;
            case 3:
              context.go('/farmer/reports');
              break;
            case 4:
              context.go('/farmer/profile');
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Livestock'),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
  /// Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home', // Localize
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.pets_outlined),
          label: 'Livestock', // Localize
        ),
        BottomNavigationBarItem(
          icon: Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary,
            ),
            child: const Icon(Icons.add, color: AppColors.onSecondary),
          ),
          label: 'Add Record', // Localize
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.assessment_outlined),
          label: 'Reports', // Localize
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile', // Localize
        ),
      ],
    );
  }
}