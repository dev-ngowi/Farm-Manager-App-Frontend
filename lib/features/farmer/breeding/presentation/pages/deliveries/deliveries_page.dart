import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed correct theme path
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/empty_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Data Model reflecting Backend JSON (DeliveryController::index) ---

class DeliveryData {
  final int id;
  final String actualDeliveryDate;
  final String damTagNumber;
  final String damName;
  final String deliveryType;
  final int totalBorn;
  final int liveBorn;
  final int stillborn;
  final List<Map<String, dynamic>> offspring;

  DeliveryData({
    required this.id,
    required this.actualDeliveryDate,
    required this.damTagNumber,
    required this.damName,
    required this.deliveryType,
    required this.totalBorn,
    required this.liveBorn,
    required this.stillborn,
    required this.offspring,
  });

  factory DeliveryData.fromJson(Map<String, dynamic> json) {
    String formatDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return 'N/A';
      try {
        final date = DateTime.parse(dateString);
        return DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        return dateString;
      }
    }

    final insemination = json['insemination'] as Map<String, dynamic>?;
    final dam = insemination?['dam'] as Map<String, dynamic>?;

    return DeliveryData(
      id: json['id'] as int,
      actualDeliveryDate: formatDate(json['actual_delivery_date'] as String?),
      deliveryType: json['delivery_type'] as String,
      totalBorn: json['total_born'] as int,
      liveBorn: json['live_born'] as int,
      stillborn: json['stillborn'] as int,
      damTagNumber: dam?['tag_number'] ?? 'N/A',
      damName: dam?['name'] ?? 'N/A',
      offspring: List<Map<String, dynamic>>.from(json['offspring'] ?? []),
    );
  }

  // Helper method to generate a human-readable summary of offspring
  String get offspringSummary {
    if (liveBorn == 0 && stillborn == 0) return 'No Offspring Recorded';
    
    final Map<String, int> counts = {};
    for (var child in offspring) {
      final gender = child['gender'] ?? 'Unknown';
      counts[gender] = (counts[gender] ?? 0) + 1;
    }
    
    final parts = counts.entries.map((e) => '${e.value} ${e.key}').toList();
    
    // Add stillborn count if greater than 0
    if (stillborn > 0) {
      parts.add('$stillborn Stillborn');
    }
    
    return parts.join(', ');
  }

  // Getter for combining searchable fields
  String get searchableText =>
      '$damName $damTagNumber $deliveryType $actualDeliveryDate $offspringSummary';
}

// --- Main Page Widget (Stateful) ---

class DeliveriesPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/deliveries';

  const DeliveriesPage({super.key});

  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {
  
  // --- Mock Data reflecting Backend Structure ---
  final List<Map<String, dynamic>> _mockRawBackendData = [
    {
      'id': 1,
      'insemination_id': 101,
      'actual_delivery_date': '2025-09-10',
      'delivery_type': 'Normal',
      'calving_ease_score': 1,
      'total_born': 1,
      'live_born': 1,
      'stillborn': 0,
      'dam_condition_after': 'Good',
      'insemination': {
        'dam_id': 1,
        'dam': {'id': 1, 'tag_number': '105', 'name': 'Cow'},
      },
      'offspring': [
        {'gender': 'Female', 'birth_condition': 'Vigorous', 'birth_weight_kg': 32.5},
      ],
    },
    {
      'id': 2,
      'insemination_id': 102,
      'actual_delivery_date': '2025-09-08',
      'delivery_type': 'Assisted',
      'calving_ease_score': 3,
      'total_born': 2,
      'live_born': 2,
      'stillborn': 0,
      'dam_condition_after': 'Weak',
      'insemination': {
        'dam_id': 2,
        'dam': {'id': 2, 'tag_number': '108', 'name': 'Cow'},
      },
      'offspring': [
        {'gender': 'Male', 'birth_condition': 'Weak', 'birth_weight_kg': 35.0},
        {'gender': 'Female', 'birth_condition': 'Vigorous', 'birth_weight_kg': 33.0},
      ],
    },
    {
      'id': 3,
      'insemination_id': 103,
      'actual_delivery_date': '2025-08-15',
      'delivery_type': 'Normal',
      'calving_ease_score': 1,
      'total_born': 3,
      'live_born': 2,
      'stillborn': 1,
      'dam_condition_after': 'Excellent',
      'insemination': {
        'dam_id': 3,
        'dam': {'id': 3, 'tag_number': '203', 'name': 'Goat'},
      },
      'offspring': [
        {'gender': 'Male', 'birth_condition': 'Vigorous', 'birth_weight_kg': 3.5},
        {'gender': 'Female', 'birth_condition': 'Vigorous', 'birth_weight_kg': 3.2},
        {'gender': 'Male', 'birth_condition': 'Stillborn', 'birth_weight_kg': 3.1},
      ],
    },
  ];

  late List<DeliveryData> _allDeliveries;
  List<DeliveryData> _filteredDeliveries = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize the list once
    _allDeliveries = _mockRawBackendData.map((json) => DeliveryData.fromJson(json)).toList();
    _filteredDeliveries = _allDeliveries;
  }

  // --- Search Filtering Logic ---
  void _filterDeliveries(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredDeliveries = _allDeliveries;
      } else {
        _filteredDeliveries = _allDeliveries.where((item) {
          // Filter using the combined searchable text getter
          return item.searchableText.toLowerCase().contains(lowerCaseQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = BreedingColors.delivery;
    final deliveries = _filteredDeliveries;
    final routeName = DeliveriesPage.routeName;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.deliveries),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: <Widget>[
          // --- Search Bar Widget ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filterDeliveries,
              decoration: InputDecoration(
                // Assuming you have defined l10n.searchDeliveries
                hintText: l10n.searchDeliveries,
                prefixIcon: Icon(Icons.search, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          
          // --- Filtered List View ---
          Expanded(
            child: deliveries.isEmpty
                ? EmptyState(
                    icon: Icons.baby_changing_station,
                    message: _searchQuery.isEmpty
                        ? "${l10n.noDeliveriesYet}\n${l10n.recordFirstDelivery}"
                        : l10n.noResultsFound,
                        iconColor: AppColors.iconPrimary,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: deliveries.length,
                    itemBuilder: (context, i) {
                      final d = deliveries[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.2),
                            child: Icon(Icons.baby_changing_station, color: primaryColor),
                          ),
                          title: Text(
                            // Dam Name and Tag Number
                            "${d.damName} #${d.damTagNumber}", 
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date and Type
                              Text("${l10n.date}: ${d.actualDeliveryDate} • ${d.deliveryType}", style: theme.textTheme.bodyMedium),
                              // Offspring Counts
                              Text(
                                "${l10n.liveBorn}: ${d.liveBorn}/${d.totalBorn} • ${d.offspringSummary}", 
                                style: theme.textTheme.bodyMedium
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                          // Use the check ID for navigation to the detail page
                          onTap: () => context.push('$routeName/${d.id}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.recordDelivery),
        onPressed: () => context.push('$routeName/add'),
      ),
    );
  }
}