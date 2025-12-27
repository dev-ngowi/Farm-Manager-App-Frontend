import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/routes/app_router.dart';
import 'package:farm_manager_app/core/widgets/add_record_bottom_sheet.dart';
import 'package:farm_manager_app/core/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FarmerDashboardScreen extends StatefulWidget {
  static const String routeName = '/farmer/dashboard';
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _selectedIndex = 0;
  String _selectedPeriod = 'Month to date';

  final Map<String, dynamic> _dummyData = {
    'farmer_name': 'Jackson Ngowi',
    'total_livestock': '150',
    'livestock_breakdown': 'Active: 120 | Pregnant: 20 | Sick: 10',
    'health_issues': '15',
    'health_breakdown': 'Critical: 5 | Pending: 10',
    'overall_score': 85.0,
    'vaccinations_due': '5',
    'expected_births': '12',
    'pending_vet_requests': '3',
    'upcoming_events': '7',
    'recent_records': [
      {
        'type': 'Milk Yield',
        'date': '2025-11-24',
        'description': 'Recorded 20L from Cow #123'
      },
      {
        'type': 'Expense',
        'date': '2025-11-23',
        'description': 'Feed purchase TZS 50,000'
      },
      {
        'type': 'Health Check',
        'date': '2025-11-22',
        'description': 'Vaccinated 10 cows'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final data = _dummyData;
    final currentRoute = GoRouterState.of(context).uri.path;

    int getSelectedBottomIndex() {
      if (currentRoute == '/farmer/dashboard') return 0;
      if (currentRoute.startsWith('/farmer/livestock')) return 1;
      if (currentRoute.startsWith('/farmer/reports')) return 3;
      if (currentRoute.startsWith('/farmer/profile')) return 4;
      return 0;
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
          style:
              TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
        // The corrected version of your code snippet:

        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: AppColors.primary),
            onPressed: () => context.push('/notifications'),
          ),
          // Profile Icon (wrapped in GestureDetector for tap functionality)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context
                  .go(AppRoutes.farmerProfile), 
              child: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      drawer: AppSidebar(currentRoute: currentRoute),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting
              _buildHeader(data),

              // Period filter chips
              _buildPeriodFilter(),

              const SizedBox(height: 16),

              // Compact stats cards
              _buildCompactStats(data),

              const SizedBox(height: 16),

              // Performance score
              _buildPerformanceCard(data),

              const SizedBox(height: 16),

              // Quick actions grid
              _buildQuickActionsGrid(),

              const SizedBox(height: 16),

              // Summary cards
              _buildSummaryCards(data),

              const SizedBox(height: 16),

              // Recent records
              _buildRecentRecords(data),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[600],
        currentIndex: selectedBottomIndex,
        elevation: 4,
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 24),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.pets, size: 24),
            label: 'Livestock',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary,
                    AppColors.secondary.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 24),
            label: 'Reports',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['farmer_name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your farm overview',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Today', 'Last 7 days', 'Month to date']
              .map((label) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _selectedPeriod == label,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedPeriod = label);
                        }
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedPeriod == label
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCompactStats(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Livestock card
          Expanded(
            child: _buildCompactStatCard(
              title: 'Livestock',
              value: data['total_livestock'],
              subtitle: 'Total animals',
              icon: Icons.pets,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),

          // Health card
          Expanded(
            child: _buildCompactStatCard(
              title: 'Health Issues',
              value: data['health_issues'],
              subtitle: 'Require attention',
              icon: Icons.medical_services,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: 12),

          // Events card
          Expanded(
            child: _buildCompactStatCard(
              title: 'Events',
              value: data['upcoming_events'],
              subtitle: 'Upcoming',
              icon: Icons.event,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard({
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

  Widget _buildPerformanceCard(Map<String, dynamic> data) {
    double score = data['overall_score']?.toDouble() ?? 0.0;
    bool isGood = score >= 70;

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
                        isGood ? AppColors.success : AppColors.secondary,
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
                      'Farm Performance',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGood
                          ? 'Excellent! Your farm is performing well'
                          : 'Needs attention in some areas',
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

  Widget _buildQuickActionsGrid() {
    final List<Map<String, dynamic>> actions = [
      {'icon': Icons.pets, 'label': 'Livestock', 'color': AppColors.primary},
      {
        'icon': Icons.medical_services,
        'label': 'Health',
        'color': AppColors.error
      },
      {
        'icon': Icons.insights,
        'label': 'Breeding',
        'color': AppColors.secondary
      },
      {
        'icon': Icons.attach_money,
        'label': 'Finance',
        'color': AppColors.success
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final item = actions[index];
              return Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label'].toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Vaccinations card
          Expanded(
            child: _buildSummaryCardItem(
              title: 'Vaccinations',
              value: data['vaccinations_due'],
              subtitle: 'Due soon',
              icon: Icons.vaccines,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),

          // Births card
          Expanded(
            child: _buildSummaryCardItem(
              title: 'Expected Births',
              value: data['expected_births'],
              subtitle: 'Upcoming',
              icon: Icons.child_friendly,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),

          // Vet requests card
          Expanded(
            child: _buildSummaryCardItem(
              title: 'Vet Requests',
              value: data['pending_vet_requests'],
              subtitle: 'Pending',
              icon: Icons.medical_information,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardItem({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
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
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecords(Map<String, dynamic> data) {
    List<dynamic> records = data['recent_records'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Records',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (records.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.history, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No recent records',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add your first record to get started',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: records.map<Widget>((record) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.history,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      record['type'] ?? 'Record',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      record['description'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      record['date'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
