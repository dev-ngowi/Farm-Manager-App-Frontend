import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
// import 'package:farm_manager_app/l10n/app_localizations.dart'; // Using mock L10n
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Detailed Data Model Mockup (Aligned with treatmentShow) ---

class DetailedTreatment {
  final int id;
  final String drugName;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String routeLabel;
  final String administeredBy;
  final int cost;
  final String notes;
  final String treatmentDate;
  final String followUpDate;
  final String? followUpCompletedDate;
  final String outcome;

  // Associated Data (from nested relationships)
  final String vetName;
  final String vetContact;
  final String animalName;
  final String animalTag;
  final int healthReportId; // healthReport.health_id (Used for linking)
  final String healthReportStatus; // healthReport.status

  DetailedTreatment({
    required this.id, required this.drugName, required this.dosage, required this.frequency, 
    required this.durationDays, required this.routeLabel, required this.administeredBy, 
    required this.cost, required this.notes, required this.treatmentDate, required this.followUpDate,
    this.followUpCompletedDate, required this.outcome, required this.vetName, required this.vetContact,
    required this.animalName, required this.animalTag, required this.healthReportId, required this.healthReportStatus,
  });

  factory DetailedTreatment.fromJson(Map<String, dynamic> json) {
    String formatDate(String dateString) {
      if (dateString.isEmpty) return 'N/A';
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(dateString));
      } catch (e) {
        return dateString;
      }
    }

    return DetailedTreatment(
      id: json['treatment_id'] as int,
      drugName: json['drug_name'] as String,
      dosage: json['dosage'] as String? ?? 'N/A', // Assuming dosage can be null
      frequency: json['frequency'] as String? ?? 'N/A',
      durationDays: json['duration_days'] as int? ?? 0,
      routeLabel: json['route_label'] as String? ?? 'N/A',
      administeredBy: json['administered_by'] as String? ?? 'N/A',
      cost: json['cost'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
      treatmentDate: formatDate(json['treatment_date'] as String),
      followUpDate: formatDate(json['follow_up_date'] as String? ?? ''),
      followUpCompletedDate: json['follow_up_completed_date'] as String?,
      outcome: json['outcome'] as String,
      
      // Associated Data
      vetName: json['diagnosis']?['vet']?['name'] ?? 'N/A',
      vetContact: json['diagnosis']?['vet']?['phone'] ?? 'N/A',
      animalName: json['health_report']?['animal']?['name'] ?? 'N/A',
      animalTag: json['health_report']?['animal']?['tag_number'] ?? 'N/A',
      healthReportId: json['health_report']?['health_id'] as int? ?? 0,
      healthReportStatus: json['health_report']?['status'] as String? ?? 'N/A',
    );
  }
}

class TreatmentDetailsPage extends StatelessWidget {
  final int treatmentId;
  
  const TreatmentDetailsPage({super.key, required this.treatmentId});

  // --- Mock Data Fetching (Aligned with treatmentShow) ---
  DetailedTreatment? _fetchMockData(int id) {
    final Map<int, Map<String, dynamic>> mockTreatment = {
        1: {
            'treatment_id': 1, 'drug_name': 'Amoxicillin', 'dosage': '500mg', 'frequency': 'Twice Daily', 'duration_days': 5,
            'route_label': 'Oral', 'administered_by': 'Farmer', 'cost': 15000,
            'notes': 'Acute infection, administer twice daily for 5 days. Needs re-evaluation on follow-up date.',
            'treatment_date': '2025-12-01', 'follow_up_date': '2025-12-08', 'follow_up_completed_date': null, 'outcome': 'In Progress',
            'diagnosis': {'vet': {'id': 50, 'name': 'Dr. Amina', 'phone': '0712345678'}},
            'health_report': {'health_id': 10, 'status': 'Under Treatment', 'animal': {'name': 'Bessie', 'tag_number': 'A101'}}
        },
        2: {
            'treatment_id': 2, 'drug_name': 'Ivermectin', 'dosage': '10ml', 'frequency': 'Once', 'duration_days': 1,
            'route_label': 'SC', 'administered_by': 'Veterinarian', 'cost': 5000,
            'notes': 'Parasite treatment. Animal showed immediate improvement.',
            'treatment_date': '2025-11-20', 'follow_up_date': '2025-11-25', 'follow_up_completed_date': '2025-11-25T10:30:00Z', 'outcome': 'Completed',
            'diagnosis': {'vet': {'id': 51, 'name': 'Dr. Musa', 'phone': '0722888999'}},
            'health_report': {'health_id': 5, 'status': 'Resolved', 'animal': {'name': 'Goat 2', 'tag_number': 'B202'}}
        },
    };

    final data = mockTreatment[id];
    return data != null ? DetailedTreatment.fromJson(data) : null;
  }
  
  String _formatDate(String? dateString, {bool withTime = false}) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return withTime ? DateFormat('dd MMM yyyy HH:mm').format(date) : DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
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

  // --- Widget Builders ---

  @override
  Widget build(BuildContext context) {
    const l10n = _MockL10n();
    final theme = Theme.of(context);
    final primaryColor = BreedingColors.insemination; 

    final data = _fetchMockData(treatmentId);

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.treatment)),
        body: Center(child: Text('${l10n.error}: Treatment $treatmentId not found.')),
      );
    }

    final isFollowUpDone = data.followUpCompletedDate != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.treatment} #${data.id}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        // EDIT/ACTION BUTTONS REMOVED
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Treatment Header Card (Drug, Dosage, Dates)
            _buildTreatmentHeader(theme, data, l10n),
            const SizedBox(height: 20),
            
            // 2. Follow-up Status (Farmer Review Only)
            _buildFollowUpStatusCard(theme, data, isFollowUpDone, l10n),
            const SizedBox(height: 20),
            
            // 3. Administration Details
            _buildSectionTitle(theme, l10n.administration, Icons.medication_liquid),
            const SizedBox(height: 8),
            _buildDetailRow(l10n.route, data.routeLabel, theme),
            _buildDetailRow(l10n.administeredBy, data.administeredBy, theme),
            _buildDetailRow(l10n.cost, 'TZS ${data.cost}', theme),
            const SizedBox(height: 15),

            // 4. Notes
            _buildSectionTitle(theme, l10n.vetNotes, Icons.description),
            const SizedBox(height: 8),
            _buildNoteBox(data.notes.isNotEmpty ? data.notes : l10n.noneProvided),
            const SizedBox(height: 20),

            // 5. Associated Report & Vet
            _buildReportSummaryCard(context, theme, data, l10n),
            const SizedBox(height: 20),

            _buildSectionTitle(theme, l10n.vetDetails, Icons.person_pin),
            const SizedBox(height: 8),
            _buildDetailRow(l10n.vetName, data.vetName, theme),
            _buildDetailRow(l10n.vetContact, data.vetContact, theme),
            const SizedBox(height: 20),

            // DELETE BUTTON REMOVED
          ],
        ),
      ),
      // BOTTOM NAVIGATION BAR REMOVED
    );
  }

  // --- Helper Widgets ---

  Widget _buildTreatmentHeader(ThemeData theme, DetailedTreatment data, _MockL10n l10n) {
    final outcomeColor = _getOutcomeColor(data.outcome);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.medication, style: theme.textTheme.labelLarge),
            Text(
              data.drugName,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const Divider(height: 20),
            
            _buildDetailRow(l10n.dosage, data.dosage, theme),
            _buildDetailRow(l10n.frequency, data.frequency, theme),
            _buildDetailRow(l10n.duration, '${data.durationDays} days', theme),
            
            const Divider(height: 20),
            _buildDetailRow(l10n.treatmentDate, _formatDate(data.treatmentDate), theme),
            _buildDetailRow(l10n.followUpDate, _formatDate(data.followUpDate), theme),
            
            const Divider(height: 20),
            Text('${l10n.outcome}: ${data.outcome}', 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: outcomeColor)),
          ],
        ),
      ),
    );
  }

  // Modified to just show status, not actionable buttons
  Widget _buildFollowUpStatusCard(ThemeData theme, DetailedTreatment data, bool isFollowUpDone, _MockL10n l10n) {
    final followUpColor = isFollowUpDone ? AppColors.success : AppColors.error;

    return Card(
      elevation: 2,
      color: followUpColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isFollowUpDone ? Icons.check_circle : Icons.warning, color: followUpColor),
                const SizedBox(width: 8),
                Text(l10n.followUpStatus, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isFollowUpDone
                ? '${l10n.followUpCompleted} ${_formatDate(data.followUpCompletedDate, withTime: true)}'
                : '${l10n.followUpPending}. ${l10n.contactVet}',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportSummaryCard(BuildContext context, ThemeData theme, DetailedTreatment data, _MockL10n l10n) {
    return Card(
      elevation: 2,
      color: theme.colorScheme.secondary.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.bug_report, color: Colors.blueGrey),
        title: Text(
          '${data.animalName} (${data.animalTag})',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${l10n.reportStatus}: ${data.healthReportStatus}'),
        trailing: TextButton(
          onPressed: () {
             // Use the integer healthReportId for navigation
             context.goNamed('health-report-details', pathParameters: {'healthId': data.healthReportId.toString()});
          },
          child: Text(l10n.viewReport, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

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
}

// --- MOCK LOCALIZATION CLASS ---
class _MockL10n {
  const _MockL10n();
  String get treatment => 'Treatment Details';
  String get error => 'Error Loading Treatment';
  String get medication => 'Medication';
  String get dosage => 'Dosage';
  String get frequency => 'Frequency';
  String get duration => 'Duration';
  String get treatmentDate => 'Start Date';
  String get followUpDate => 'Follow-up Date';
  String get outcome => 'Outcome';
  String get administration => 'Administration Details';
  String get route => 'Route';
  String get administeredBy => 'Administered By';
  String get cost => 'Est. Cost';
  String get vetNotes => 'Treatment Notes (Vet)';
  String get noneProvided => 'No detailed notes provided.';
  String get vetDetails => 'Prescribing Vet';
  String get vetName => 'Veterinarian';
  String get vetContact => 'Vet Contact';
  String get reportStatus => 'Report Status';
  String get viewReport => 'View Health Report';
  String get followUpStatus => 'Follow-up Status';
  String get followUpCompleted => 'Completed On:';
  String get followUpPending => 'Required follow-up pending';
  String get contactVet => 'Contact vet for next steps.';
}