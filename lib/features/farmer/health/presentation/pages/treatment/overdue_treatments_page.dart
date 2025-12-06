// overdue_treatments_page.dart

import 'package:farm_manager_app/features/farmer/health/presentation/pages/treatment/treatments_list_page.dart';
import 'package:flutter/material.dart';
// Removed flutter_bloc import

class OverdueTreatmentsPage extends StatelessWidget {
  const OverdueTreatmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const l10n = _MockL10n();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.overdueTreatmentsTitle),
      ),
      // Delegate to the modified TreatmentsListPage with the filter enabled
      body: const TreatmentsListPage(
        isOverdueFilter: true,
      ),
    );
  }
}

// --- MOCK LOCALIZATION CLASS ---
class _MockL10n {
  const _MockL10n();
  // Ensure the list page l10n keys are available if the ListPage uses them
  String get treatments => 'Treatments List';
  String get overdueTreatmentsTitle => 'Overdue Follow-ups';
  String get searchTreatments => 'Search treatments, animals...';
  String get noTreatmentsYet => 'No treatments have been recorded yet.';
  String get recordFirstTreatment => 'Tap "+" to record the first one.';
  String get noResultsFound => 'No results found for your search.';
  String get recordTreatment => 'Record Treatment';
  String get animal => 'Animal';
  String get date => 'Date';
}