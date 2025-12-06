// diagnosis_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'diagnosis_details_cubit.dart';
import 'diagnosis_details_state.dart';

class DiagnosisDetailsPage extends StatelessWidget {
  final String diagnosisId;
  
  const DiagnosisDetailsPage({super.key, required this.diagnosisId});

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    const l10n = _MockL10n();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.diagnosis} #$diagnosisId'),
        // Removed the actions list (including the Edit Diagnosis button)
        // to enforce a read-only view for the farmer role.
      ),
      body: BlocBuilder<DiagnosisDetailsCubit, DiagnosisDetailsState>(
        builder: (context, state) {
          if (state is DiagnosisDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiagnosisDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('${l10n.error}: ${state.error}', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red)),
              ),
            );
          }
          if (state is DiagnosisDetailsLoaded) {
            final diagnosis = state.diagnosis;
            final vet = diagnosis['vet'] as Map<String, dynamic>? ?? {};
            final treatments = diagnosis['treatments'] as List<dynamic>? ?? [];
            final reportSummary = diagnosis['health_report_summary'] as Map<String, dynamic>? ?? {};

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Diagnosis Header Card
                  _buildDiagnosisHeader(theme, diagnosis, vet, l10n),
                  const SizedBox(height: 20),
                  
                  // 2. Report Summary Link
                  // CONTEXT PASSED HERE
                  _buildReportSummaryCard(context, theme, diagnosis, reportSummary, l10n),
                  const SizedBox(height: 20),

                  // 3. Vet Notes
                  _buildSectionTitle(theme, l10n.vetNotes, Icons.description),
                  const SizedBox(height: 8),
                  _buildNoteBox(diagnosis['vet_notes'] ?? l10n.noneProvided),
                  const SizedBox(height: 20),

                  // 4. Treatment Plan
                  _buildSectionTitle(theme, l10n.treatmentPlan, Icons.local_pharmacy),
                  const SizedBox(height: 8),
                  treatments.isEmpty
                      ? _buildEmptyState(l10n.noTreatmentsYet)
                      : _buildTreatmentList(theme, treatments, l10n),
                  const SizedBox(height: 20),
                  
                  // 5. Audit Details
                   _buildSectionTitle(theme, l10n.auditDetails, Icons.history),
                   const SizedBox(height: 8),
                   _buildDetailRow(l10n.diagnosisID, diagnosisId, theme),
                   _buildDetailRow(l10n.reportID, diagnosis['report_id'] as String? ?? 'N/A', theme),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text('$title:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteBox(String note) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(note, style: const TextStyle(fontStyle: FontStyle.italic)),
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      width: double.infinity,
      child: Text(message, style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildDiagnosisHeader(ThemeData theme, Map<String, dynamic> diagnosis, Map<String, dynamic> vet, _MockL10n l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.condition, style: theme.textTheme.labelLarge),
            Text(
              diagnosis['condition'] as String,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const Divider(height: 20),
            
            _buildDetailRow(l10n.diagnosedOn, _formatDate(diagnosis['diagnosis_date']), theme),
            _buildDetailRow(l10n.vetName, vet['name'] as String? ?? l10n.unknownVet, theme),
            _buildDetailRow(l10n.vetContact, vet['contact'] as String? ?? 'N/A', theme),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportSummaryCard(BuildContext context, ThemeData theme, Map<String, dynamic> diagnosis, Map<String, dynamic> reportSummary, _MockL10n l10n) {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.green),
        title: Text(
          '${reportSummary['animal_name'] ?? 'N/A'} (${reportSummary['tag_number'] ?? 'N/A'})',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${l10n.reportStatus}: ${reportSummary['status'] ?? 'N/A'}'),
        trailing: TextButton(
          onPressed: () {
            // Navigate to the full Health Report Details Page
             final reportId = diagnosis['report_id'] as String?;
             
             if (reportId != null) {
                // NOTE: The 'health-report-details' route must be defined in router_config.dart.
                // If it is not defined yet, uncomment the line below and comment out the context.goNamed line.
                
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report ID: $reportId. Route to Health Report Details is not yet implemented.')));
                context.goNamed('health-report-details', pathParameters: {'healthId': reportId});
             } else {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noReportID)));
             }
          },
          child: Text(l10n.viewReport, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
  
  Widget _buildTreatmentList(ThemeData theme, List<dynamic> treatments, _MockL10n l10n) {
    return Column(
      children: treatments.map((treatment) {
        final date = _formatDate(treatment['administered_date']);
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          elevation: 1,
          child: ListTile(
            leading: const Icon(Icons.medication_liquid, color: Colors.blueGrey),
            title: Text('${treatment['drug_name'] as String? ?? l10n.unknownDrug} - ${treatment['dosage'] as String? ?? 'N/A'}',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('${l10n.frequency}: ${treatment['frequency'] as String? ?? 'N/A'}'),
            trailing: Text(date, style: theme.textTheme.bodySmall),
          ),
        );
      }).toList(),
    );
  }
}

// --- MOCK LOCALIZATION CLASS ---
class _MockL10n {
  const _MockL10n();
  String get diagnosis => 'Diagnosis Details';
  String get condition => 'Condition';
  String get diagnosedOn => 'Diagnosed On';
  String get vetName => 'Veterinarian';
  String get vetContact => 'Vet Contact';
  String get unknownVet => 'Unknown';
  String get vetNotes => 'Clinical Notes';
  String get noneProvided => 'No detailed clinical notes provided by the veterinarian.';
  String get treatmentPlan => 'Treatment Plan';
  String get noTreatmentsYet => 'No treatment plan has been finalized for this diagnosis.';
  String get reportSummary => 'Associated Health Report';
  String get reportStatus => 'Report Status';
  String get viewReport => 'View Full Report';
  String get noReportID => 'Cannot navigate: Associated Report ID is missing.';
  String get auditDetails => 'Audit Details';
  String get diagnosisID => 'Diagnosis ID';
  String get reportID => 'Health Report ID';
  String get unknownDrug => 'Unknown Drug';
  String get frequency => 'Frequency';
  String get editDiagnosis => 'Opening Edit Diagnosis Page...';
  String get error => 'Error Loading Diagnosis';
}