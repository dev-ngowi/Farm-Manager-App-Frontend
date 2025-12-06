import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed correct theme path
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/empty_state.dart';
// import 'package:farm_manager_app/l10n/app_localizations.dart'; // Using mock L10n
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Data Model Mockup (Aligned with treatmentsIndex) ---

class TreatmentData {
  final int id;
  final String animalTag; // healthReport.animal.tag_number
  final String animalName; // healthReport.animal.name
  final String drugName; // drug_name
  final String treatmentDate; // treatment_date
  final String outcome; // outcome
  final String vetName; // diagnosis.vet.name
  final String followUpCompletedDate; // follow_up_completed_date (Needed for overdue check)

  TreatmentData({
    required this.id,
    required this.animalTag,
    required this.animalName,
    required this.drugName,
    required this.treatmentDate,
    required this.outcome,
    required this.vetName,
    required this.followUpCompletedDate,
  });

  factory TreatmentData.fromJson(Map<String, dynamic> json) {
    String formatDate(String dateString) {
      if (dateString.isEmpty) return 'N/A';
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(dateString));
      } catch (e) {
        return dateString;
      }
    }

    return TreatmentData(
      id: json['treatment_id'] as int,
      animalTag: json['health_report']?['animal']?['tag_number'] ?? 'N/A',
      animalName: json['health_report']?['animal']?['name'] ?? 'N/A',
      drugName: json['drug_name'] as String,
      treatmentDate: formatDate(json['treatment_date'] as String),
      outcome: json['outcome'] as String,
      vetName: json['diagnosis']?['vet']?['name'] ?? 'N/A',
      followUpCompletedDate: json['follow_up_completed_date'] as String? ?? '',
    );
  }

  String get searchableText =>
      '${animalName} ${animalTag} ${drugName} ${outcome} ${vetName}';
}

// --- Main Page Widget (Stateful) ---

class TreatmentsListPage extends StatefulWidget {
  static const String routeName = '/farmer/health/treatments';

  final bool isOverdueFilter;

  const TreatmentsListPage({
    super.key,
    this.isOverdueFilter = false,
  });

  @override
  State<TreatmentsListPage> createState() => _TreatmentsListPageState();
}

class _TreatmentsListPageState extends State<TreatmentsListPage> {
  // Mock data structure simulating the combined output with nested relationships
  final List<Map<String, dynamic>> _mockRawBackendData = [
    {
        'treatment_id': 1, 'drug_name': 'Amoxicillin', 'treatment_date': '2025-12-01', 'outcome': 'In Progress',
        'follow_up_date': '2025-12-04', 'follow_up_completed_date': null, // OVERDUE
        'health_report': {'animal': {'name': 'Bessie', 'tag_number': 'A101', 'sex': 'F'}, 'farmer_id': 1},
        'diagnosis': {'vet': {'id': 50, 'name': 'Dr. Amina', 'phone': '0712345678'}}
    },
    {
        'treatment_id': 2, 'drug_name': 'Ivermectin', 'treatment_date': '2025-11-20', 'outcome': 'Completed',
        'follow_up_date': '2025-11-25', 'follow_up_completed_date': '2025-11-25T10:30:00Z', // COMPLETED
        'health_report': {'animal': {'name': 'Goat 2', 'tag_number': 'B202', 'sex': 'F'}, 'farmer_id': 1},
        'diagnosis': {'vet': {'id': 51, 'name': 'Dr. Musa', 'phone': '0722888999'}}
    },
    {
        'treatment_id': 3, 'drug_name': 'Fenbendazole', 'treatment_date': '2025-12-10', 'outcome': 'In Progress',
        'follow_up_date': '2025-12-15', 'follow_up_completed_date': null, // DUE LATER
        'health_report': {'animal': {'name': 'Bull 5', 'tag_number': 'C555', 'sex': 'M'}, 'farmer_id': 1},
        'diagnosis': {'vet': {'id': 50, 'name': 'Dr. Amina', 'phone': '0712345678'}}
    },
  ];

  late List<TreatmentData> _allTreatments;
  List<TreatmentData> _filteredTreatments = [];
  String _searchQuery = '';
  
  // Helper to simulate the overdueFollowUp scope logic
  bool _isItemOverdue(Map<String, dynamic> item) {
    final followUpDateString = item['follow_up_date'] as String?;
    final completedDateString = item['follow_up_completed_date'] as String?;
    
    // Condition: Has a follow-up date AND has NOT been completed
    if (followUpDateString == null || completedDateString != null) {
      return false; 
    }

    try {
      final followUpDate = DateTime.parse(followUpDateString);
      final today = DateTime.parse('2025-12-05'); // MOCK CURRENT DATE
      return followUpDate.isBefore(today);
    } catch (e) {
      return false;
    }
  }


  @override
  void initState() {
    super.initState();
    
    List<Map<String, dynamic>> initialRawData = _mockRawBackendData;

    if (widget.isOverdueFilter) {
      initialRawData = initialRawData.where(_isItemOverdue).toList();
    }
    
    _allTreatments = initialRawData.map((json) => TreatmentData.fromJson(json)).toList();
    _filteredTreatments = _allTreatments;
  }

  void _filterTreatments(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTreatments = _allTreatments;
      } else {
        _filteredTreatments = _allTreatments.where((item) {
          return item.searchableText.toLowerCase().contains(lowerCaseQuery);
        }).toList();
      }
    });
  }

  Color _getOutcomeColor(String outcome) {
    switch (outcome) {
      case 'Completed':
      case 'Resolved':
        return AppColors.success;
      case 'Failed':
        return AppColors.error;
      case 'In Progress':
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    const l10n = _MockL10n(); 
    final theme = Theme.of(context);
    final primaryColor = BreedingColors.insemination; 

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.isOverdueFilter 
          ? null 
          : AppBar(
              title: Text(l10n.treatments),
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
              onChanged: _filterTreatments,
              decoration: InputDecoration(
                hintText: l10n.searchTreatments, 
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
            child: _filteredTreatments.isEmpty
                ? EmptyState(
                    icon: Icons.healing,
                    message: _searchQuery.isEmpty
                        ? l10n.noTreatmentsFound
                        : l10n.noResultsFound, 
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredTreatments.length,
                    itemBuilder: (context, i) {
                      final item = _filteredTreatments[i];
                      final outcome = item.outcome;
                      final outcomeColor = _getOutcomeColor(outcome);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.2),
                            child: Icon(Icons.medication_liquid, color: primaryColor),
                          ),
                          title: Text(
                            item.drugName,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${l10n.animal}: ${item.animalName} #${item.animalTag}",
                                  style: theme.textTheme.bodyMedium),
                              Text("${l10n.date}: ${item.treatmentDate}",
                                  style: theme.textTheme.bodyMedium),
                              Text("${l10n.vet}: ${item.vetName}",
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              outcome,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: outcomeColor.computeLuminance() > 0.5
                                    ? Colors.black87
                                    : Colors.white,
                              ),
                            ),
                            backgroundColor: outcomeColor.withOpacity(0.2),
                            side: BorderSide(color: outcomeColor, width: 1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                          ),
                          onTap: () => context.push('${TreatmentsListPage.routeName}/${item.id}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // ACTION BUTTON REMOVED: Farmer should only review treatments made by vet
      floatingActionButton: null,
    );
  }
}

// --- MOCK LOCALIZATION CLASS ---
class _MockL10n {
  const _MockL10n();
  String get treatments => 'Treatments List';
  String get searchTreatments => 'Search treatments, animals...';
  String get noTreatmentsFound => 'No treatments have been recorded by the vet.';
  String get noResultsFound => 'No results found for your search.';
  String get animal => 'Animal';
  String get date => 'Date';
  String get vet => 'Vet';
}