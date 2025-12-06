import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed correct theme path
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/empty_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Data Model Mockup (To align with Backend Response) ---

class InseminationData {
  final int id;
  final String damTagNumber; // from dam.tag_number
  final String damName; // from dam.name
  final String breedingMethod; // breeding_method
  final String inseminationDate; // insemination_date
  final String expectedDeliveryDate; // expected_delivery_date
  final String status; // status

  InseminationData({
    required this.id,
    required this.damTagNumber,
    required this.damName,
    required this.breedingMethod,
    required this.inseminationDate,
    required this.expectedDeliveryDate,
    required this.status,
  });

  factory InseminationData.fromJson(Map<String, dynamic> json) {
    String formatDate(String dateString) {
      if (dateString.isEmpty) return 'N/A';
      try {
        final date = DateTime.parse(dateString);
        return DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        return dateString;
      }
    }

    return InseminationData(
      id: json['id'] as int,
      damTagNumber: json['dam']?['tag_number'] ?? 'N/A',
      damName: json['dam']?['name'] ?? 'N/A',
      breedingMethod: json['breeding_method'] as String,
      inseminationDate: formatDate(json['insemination_date'] as String),
      expectedDeliveryDate:
          formatDate(json['expected_delivery_date'] as String),
      status: json['status'] as String,
    );
  }

  // Helper to create a searchable string from the object
  String get searchableText => 
      '${damName} ${damTagNumber} ${breedingMethod} ${status}';
}

// --- Main Page Widget (Stateful) ---

class InseminationsPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/inseminations';

  const InseminationsPage({super.key});

  @override
  State<InseminationsPage> createState() => _InseminationsPageState();
}

class _InseminationsPageState extends State<InseminationsPage> {
  // Mock data definition to match backend structure
  final List<Map<String, dynamic>> _mockRawBackendData = [
    {
      'id': 1, 'insemination_date': '2025-12-02', 'expected_delivery_date': '2026-09-11',
      'breeding_method': 'AI', 'status': 'Pending',
      'dam': {'animal_id': 101, 'tag_number': '101', 'name': 'Cow', 'species_id': 1},
    },
    {
      'id': 2, 'insemination_date': '2025-11-25', 'expected_delivery_date': '2026-09-04',
      'breeding_method': 'Natural', 'status': 'Confirmed Pregnant',
      'dam': {'animal_id': 115, 'tag_number': '115', 'name': 'Cow', 'species_id': 1},
    },
    {
      'id': 3, 'insemination_date': '2025-11-15', 'expected_delivery_date': '2026-08-24',
      'breeding_method': 'AI', 'status': 'Failed',
      'dam': {'animal_id': 503, 'tag_number': '503', 'name': 'Heifer', 'species_id': 1},
    },
    {
      'id': 4, 'insemination_date': '2025-11-05', 'expected_delivery_date': '2026-04-01',
      'breeding_method': 'AI', 'status': 'Delivered',
      'dam': {'animal_id': 201, 'tag_number': '201', 'name': 'Goat', 'species_id': 2},
    },
  ];

  late List<InseminationData> _allInseminations;
  List<InseminationData> _filteredInseminations = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize the list once
    _allInseminations = _mockRawBackendData.map((json) => InseminationData.fromJson(json)).toList();
    _filteredInseminations = _allInseminations;
  }

  // --- Search Filtering Logic ---
  void _filterInseminations(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredInseminations = _allInseminations;
      } else {
        _filteredInseminations = _allInseminations.where((item) {
          // Check if any of the key fields contain the search query
          return item.searchableText.toLowerCase().contains(lowerCaseQuery);
        }).toList();
      }
    });
  }

  // Helper method updated to map all backend statuses to colors
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed Pregnant':
      case 'Delivered':
        return AppColors.success;
      case 'Failed':
      case 'Not Pregnant':
        return AppColors.error;
      case 'Pending':
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = BreedingColors.insemination;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.inseminations),
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
              onChanged: _filterInseminations,
              decoration: InputDecoration(
                // Assuming you have defined l10n.searchInseminations
                hintText: l10n.searchInseminations, 
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
            child: _filteredInseminations.isEmpty
                ? EmptyState(
                    icon: Icons.vaccines,
                    message: _searchQuery.isEmpty
                        ? "${l10n.noInseminationsYet}\n${l10n.recordFirstInsemination}"
                        // Assuming you have defined l10n.noResultsFound
                        : l10n.noResultsFound, 
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredInseminations.length,
                    itemBuilder: (context, i) {
                      final item = _filteredInseminations[i];
                      final status = item.status;
                      final statusColor = _getStatusColor(status);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.2),
                            child: Icon(Icons.vaccines, color: primaryColor),
                          ),
                          title: Text(
                            "${item.damName} #${item.damTagNumber}",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${l10n.method}: ${item.breedingMethod}",
                                  style: theme.textTheme.bodyMedium),
                              Text("${l10n.date}: ${item.inseminationDate}",
                                  style: theme.textTheme.bodyMedium),
                              Text("${l10n.dueDate}: ${item.expectedDeliveryDate}",
                                  style: theme.textTheme.bodyMedium),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              status,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: statusColor.computeLuminance() > 0.5
                                    ? Colors.black87
                                    : Colors.white,
                              ),
                            ),
                            backgroundColor: statusColor.withOpacity(0.2),
                            side: BorderSide(color: statusColor, width: 1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                          ),
                          // FIX: Accessing static routeName via the class name
                          onTap: () => context.push('${InseminationsPage.routeName}/${item.id}'),
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
        label: Text(l10n.recordInsemination),
        onPressed: () => context.push('${InseminationsPage.routeName}/add'),
      ),
    );
  }
}