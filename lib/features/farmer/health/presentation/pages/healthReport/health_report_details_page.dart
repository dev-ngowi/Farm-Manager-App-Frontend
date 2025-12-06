// health_report_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// Note: Assumes 'health_report_details_cubit.dart' exists and is correctly structured
import 'health_report_details_cubit.dart'; 

class HealthReportDetailsPage extends StatelessWidget {
  final String healthId;
  
  const HealthReportDetailsPage({super.key, required this.healthId});

  // --- Helpers ---
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Emergency': return Colors.red.shade700;
      case 'High': return Colors.deepOrange;
      case 'Medium': return Colors.yellow.shade800;
      case 'Low': default: return Colors.green.shade600;
    }
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    const l10n = _MockL10n();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.report} #$healthId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // Call API: downloadPdf(healthId)
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.downloadingPDF)));
            },
          ),
          
          // The Edit Button needs to be inside the BlocBuilder to access the loaded state data
          // We wrap it in a Builder to ensure the context is available for navigation/read
          Builder(
            builder: (context) {
              final state = context.watch<HealthReportDetailsCubit>().state;
              
              // Only show the edit button if the report data is loaded
              if (state is HealthReportDetailsLoaded) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    // Navigate to the edit page, passing the current report data as 'extra'
                    final result = await context.pushNamed(
                      'edit-health-report',
                      pathParameters: {'healthId': healthId},
                      extra: state.report, 
                    );
                    
                    // If the edit page pops with 'true', refresh the details page data
                    if (result == true) {
                      context.read<HealthReportDetailsCubit>().fetchReport(healthId);
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<HealthReportDetailsCubit, HealthReportDetailsState>(
        builder: (context, state) {
          if (state is HealthReportDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HealthReportDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('${l10n.error}: ${state.error}', textAlign: TextAlign.center),
              ),
            );
          }
          if (state is HealthReportDetailsLoaded) {
            final report = state.report;
            final animal = report['animal'] ?? {};
            final diagnoses = report['diagnoses'] as List<dynamic>? ?? [];
            final treatments = report['treatments'] as List<dynamic>? ?? [];
            final media = report['media'] as List<dynamic>? ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER & STATUS CARD
                  _buildHeaderCard(theme, report, animal, l10n),
                  const SizedBox(height: 20),

                  // 2. DIAGNOSIS HISTORY
                  _buildSectionTitle(theme, l10n.diagnosisHistory, Icons.medical_information),
                  const SizedBox(height: 8),
                  diagnoses.isEmpty
                      ? _buildEmptyState(l10n.noDiagnosisYet)
                      : _buildDiagnosisList(theme, diagnoses, l10n),
                  const SizedBox(height: 20),

                  // 3. TREATMENT LOG
                  _buildSectionTitle(theme, l10n.treatmentLog, Icons.healing),
                  const SizedBox(height: 8),
                  treatments.isEmpty
                      ? _buildEmptyState(l10n.noTreatmentYet)
                      : _buildTreatmentList(theme, treatments, l10n),
                  const SizedBox(height: 20),

                  // 4. SYMPTOMS & NOTES
                  _buildSectionTitle(theme, l10n.reportDetails, Icons.subject),
                  const SizedBox(height: 8),
                  _buildDetailRow(l10n.symptoms, report['symptoms'], theme),
                  _buildDetailRow(l10n.onsetDate, _formatDate(report['symptom_onset_date']), theme),
                  // IMPORTANT: Pass the 'notes' key to the next page
                  _buildDetailRow(l10n.notes, report['notes'] ?? l10n.none, theme), 
                  const SizedBox(height: 20),

                  // 5. ATTACHED MEDIA
                  _buildSectionTitle(theme, l10n.attachedMedia, Icons.attachment),
                  const SizedBox(height: 8),
                  media.isEmpty
                      ? _buildEmptyState(l10n.noMedia)
                      : _buildMediaGrid(media, l10n),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
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

  Widget _buildHeaderCard(ThemeData theme, Map<String, dynamic> report, Map<String, dynamic> animal, _MockL10n l10n) {
    final priority = report['priority'] as String;
    final priorityColor = _getPriorityColor(priority);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Priority
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(report['status'] as String, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold)),
                  backgroundColor: priorityColor.withOpacity(0.1),
                  avatar: Icon(Icons.shield, color: priorityColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${l10n.priority}: $priority', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 20),
            // Animal Details
            Text(l10n.animal, style: theme.textTheme.labelLarge),
            Text('${animal['name'] ?? 'N/A'} (${animal['tag_number']})', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('${l10n.reportedOn}: ${_formatDate(report['report_date'])}'),
            Text('${l10n.severity}: ${report['severity']}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDiagnosisList(ThemeData theme, List<dynamic> diagnoses, _MockL10n l10n) {
    return Column(
      children: diagnoses.map((diagnosis) {
        final vet = diagnosis['vet'] ?? {};
        final treatments = diagnosis['treatments'] as List<dynamic>? ?? [];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          child: ExpansionTile(
            leading: const Icon(Icons.verified_user, color: Colors.blue),
            title: Text(diagnosis['condition'], style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('${l10n.diagnosedBy} ${vet['name'] ?? l10n.unknown} on ${_formatDate(diagnosis['diagnosis_date'])}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(l10n.vetNotes, diagnosis['vet_notes'] ?? l10n.none, theme),
                    const SizedBox(height: 10),
                    Text('${l10n.initialTreatment} (${treatments.length})', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ...treatments.map((t) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4),
                      child: Text('- ${t['drug_name'] ?? 'N/A'} (${t['dosage'] ?? 'N/A'})'),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTreatmentList(ThemeData theme, List<dynamic> treatments, _MockL10n l10n) {
    return Column(
      children: treatments.map((treatment) {
        final followUpDate = treatment['follow_up_date'];
        final isOverdue = followUpDate != null && DateTime.parse(followUpDate).isBefore(DateTime.now());
        
        return ListTile(
          leading: Icon(Icons.medical_services, color: isOverdue ? Colors.orange : theme.primaryColor),
          title: Text(treatment['drug_name'], style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text('${treatment['details'] ?? l10n.noDetails}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatDate(treatment['treatment_date']), style: theme.textTheme.bodySmall),
              if (followUpDate != null)
                Text(
                  '${l10n.followUp}: ${_formatDate(followUpDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: isOverdue ? Colors.red : Colors.green),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildMediaGrid(List<dynamic> media, _MockL10n l10n) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: media.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final item = media[index];
        final isVideo = item['type'] == 'video';
        
        return GestureDetector(
          onTap: () {
            // Placeholder for viewing media (e.g., full screen image or video player)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.viewing} ${item['type']} ${item['id']}')));
          },
          child: GridTile(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isVideo
                    ? const Icon(Icons.videocam, size: 40, color: Colors.black)
                    : const Icon(Icons.image, size: 40, color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- MOCK LOCALIZATION CLASS ---
class _MockL10n {
  const _MockL10n();
  String get report => 'Health Report';
  String get animal => 'Animal';
  String get priority => 'Priority';
  String get severity => 'Severity';
  String get reportedOn => 'Reported On';
  String get diagnosisHistory => 'Diagnosis History';
  String get treatmentLog => 'Treatment Log';
  String get reportDetails => 'Report Details';
  String get attachedMedia => 'Attached Media';
  String get symptoms => 'Symptoms';
  String get onsetDate => 'Symptom Onset Date';
  String get notes => 'Farmer Notes';
  String get none => 'None provided.';
  String get noDiagnosisYet => 'No formal diagnosis has been recorded yet.';
  String get noTreatmentYet => 'No treatments have been logged for this case.';
  String get noMedia => 'No media (photos/videos) attached to this report.';
  String get error => 'Error Loading Report';
  String get downloadingPDF => 'Preparing PDF for download...';
  String get editReport => 'Opening Edit Report page...';
  String get diagnosedBy => 'Diagnosed by';
  String get unknown => 'Unknown Vet';
  String get vetNotes => 'Vet Notes';
  String get initialTreatment => 'Initial Treatment Plan';
  String get followUp => 'Follow-up Due';
  String get noDetails => 'No details provided.';
  String get viewing => 'Viewing media file';
}