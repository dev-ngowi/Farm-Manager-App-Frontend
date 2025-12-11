import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed correct theme path
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/empty_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Data Model reflecting Backend JSON (PregnancyCheckController::index) ---

class PregnancyCheckData {
  final int id;
  final String checkDate;
  final String method;
  final String result; // Pregnant, Not Pregnant, Reabsorbed
  final String? expectedDeliveryDate;
  final String damTagNumber; // Nested from insemination.dam
  final String damName; // Nested from insemination.dam
  final int inseminationId;

  PregnancyCheckData({
    required this.id,
    required this.checkDate,
    required this.method,
    required this.result,
    this.expectedDeliveryDate,
    required this.damTagNumber,
    required this.damName,
    required this.inseminationId,
  });

  factory PregnancyCheckData.fromJson(Map<String, dynamic> json) {
    // Helper to format dates for display
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

    return PregnancyCheckData(
      id: json['id'] as int,
      checkDate: formatDate(json['check_date'] as String?),
      method: json['method'] as String,
      result: json['result'] as String,
      
      // Expected Delivery Date is null unless result is 'Pregnant'
      expectedDeliveryDate: formatDate(json['expected_delivery_date'] as String?),
      
      // Nested dam details
      damTagNumber: dam?['tag_number'] ?? 'N/A',
      damName: dam?['name'] ?? 'N/A',
      inseminationId: insemination?['id'] as int? ?? 0,
    );
  }
  
  // Getter for combining searchable fields
  String get searchableText => 
    '$damName $damTagNumber $method $result $checkDate';
}

// --- Main Page Widget (Now Stateful) ---

class PregnancyChecksPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/pregnancy-checks';

  const PregnancyChecksPage({super.key});

  @override
  State<PregnancyChecksPage> createState() => _PregnancyChecksPageState();
}

class _PregnancyChecksPageState extends State<PregnancyChecksPage> {
  // --- Mock Data reflecting Backend Structure ---
  final List<Map<String, dynamic>> _mockRawBackendData = [
    {
      'id': 1,
      'insemination_id': 101,
      'check_date': '2025-12-05',
      'method': 'Ultrasound',
      'result': 'Pregnant',
      'fetus_count': 1,
      'expected_delivery_date': '2026-09-11',
      'insemination': {
        'id': 101,
        'dam_id': 1,
        'dam': {'id': 1, 'tag_number': '101', 'name': 'Cow'},
      },
    },
    {
      'id': 2,
      'insemination_id': 102,
      'check_date': '2025-11-20',
      'method': 'Palpation',
      'result': 'Not Pregnant',
      'fetus_count': null,
      'expected_delivery_date': null,
      'insemination': {
        'id': 102,
        'dam_id': 2,
        'dam': {'id': 2, 'tag_number': '115', 'name': 'Cow'},
      },
    },
    {
      'id': 3,
      'insemination_id': 103,
      'check_date': '2025-12-01',
      'method': 'Blood',
      'result': 'Pregnant',
      'fetus_count': 1,
      'expected_delivery_date': '2026-08-24',
      'insemination': {
        'id': 103,
        'dam_id': 3,
        'dam': {'id': 3, 'tag_number': '503', 'name': 'Heifer'},
      },
    },
  ];

  late List<PregnancyCheckData> _allChecks;
  List<PregnancyCheckData> _filteredChecks = [];
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    // Initialize the list once
    _allChecks = _mockRawBackendData.map((json) => PregnancyCheckData.fromJson(json)).toList();
    _filteredChecks = _allChecks;
  }

  // --- Search Filtering Logic ---
  void _filterChecks(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredChecks = _allChecks;
      } else {
        _filteredChecks = _allChecks.where((item) {
          // Filter using the combined searchable text getter
          return item.searchableText.toLowerCase().contains(lowerCaseQuery);
        }).toList();
      }
    });
  }
  
  Color _getResultColor(String result) {
    switch (result) {
      case 'Pregnant':
        return AppColors.success;
      case 'Not Pregnant':
      case 'Reabsorbed':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = BreedingColors.pregnancy;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.pregnancyChecks),
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
              onChanged: _filterChecks,
              decoration: InputDecoration(
                hintText: l10n.searchChecks, 
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
            child: _filteredChecks.isEmpty
                ? EmptyState(
                    icon: Icons.monitor_heart,
                    message: _searchQuery.isEmpty
                        ? "${l10n.noChecksYet}\n${l10n.recordFirstCheck}"
                        // Assuming you have defined l10n.noResultsFound
                        : l10n.noResultsFound, 
                        iconColor: AppColors.iconPrimary,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredChecks.length,
                    itemBuilder: (context, i) {
                      final item = _filteredChecks[i];
                      final routeName = PregnancyChecksPage.routeName;
                      final result = item.result;
                      final resultColor = _getResultColor(result);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.2),
                            child: Icon(Icons.monitor_heart, color: primaryColor),
                          ),
                          title: Text(
                            // Use dam name and tag number as the primary title, append method
                            "${item.damName} #${item.damTagNumber} • ${item.method}",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Use correct localized keys for check date
                              Text("${l10n.checkDate}: ${item.checkDate}", style: theme.textTheme.bodyMedium),
                              // Only display Due Date if it exists (i.e., result is 'Pregnant')
                              if (item.expectedDeliveryDate != 'N/A')
                                Text("${l10n.dueDate}: ${item.expectedDeliveryDate}", style: theme.textTheme.bodyMedium),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              result,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: resultColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                              ),
                            ),
                            backgroundColor: resultColor.withOpacity(0.2),
                            side: BorderSide(color: resultColor, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          ),
                          // Use the check ID for navigation to the detail page
                          onTap: () => context.push('$routeName/${item.id}'),
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
        label: Text(l10n.recordCheck),
        onPressed: () => context.push('${PregnancyChecksPage.routeName}/add'),
      ),
    );
  }
}