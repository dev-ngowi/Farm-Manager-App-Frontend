// diagnoses_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'diagnosis_list_cubit.dart';
import 'diagnosis_list_state.dart';
// NOTE: Assuming DiagnosisDetailsPage exists and is linked via router
// import 'diagnosis_details_page.dart'; 

class DiagnosesListPage extends StatelessWidget {
  const DiagnosesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    const l10n = _MockL10n();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnosesListTitle),
        // Removed the actions list (including the Add Diagnosis button)
        // to reflect the Farmer-only role for this screen, where 
        // they view diagnoses but don't create them.
      ),
      body: BlocBuilder<DiagnosisListCubit, DiagnosisListState>(
        builder: (context, state) {
          if (state is DiagnosisListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiagnosisListError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 50, color: Colors.red.shade400),
                    const SizedBox(height: 10),
                    Text(state.error, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => context.read<DiagnosisListCubit>().fetchDiagnoses(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is DiagnosisListLoaded) {
            if (state.diagnoses.isEmpty) {
              return Center(
                child: Text(l10n.noDiagnosesFound, style: theme.textTheme.titleMedium),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.diagnoses.length,
              itemBuilder: (context, index) {
                final diagnosis = state.diagnoses[index];
                return _DiagnosisListTile(
                  diagnosis: diagnosis,
                  l10n: l10n,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DiagnosisListTile extends StatelessWidget {
  final Map<String, dynamic> diagnosis;
  final _MockL10n l10n;
  
  const _DiagnosisListTile({required this.diagnosis, required this.l10n});

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vetName = diagnosis['vet']?['name'] ?? l10n.unknownVet;
    final diagnosisDate = _formatDate(diagnosis['diagnosis_date']);
    final diagnosisId = diagnosis['diagnosis_id'];


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(Icons.bug_report, color: theme.primaryColor),
        ),
        title: Text(
          diagnosis['condition'] as String,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${l10n.reportedOn} $diagnosisDate'),
            Text('${l10n.vet}: $vetName'),
            Text('${l10n.treatments}: ${diagnosis['treatment_count']}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigates to the new Diagnosis Details Page
          context.goNamed('diagnosis-details', pathParameters: {'diagnosisId': diagnosisId});
        },
      ),
    );
  }
}


// --- MOCK LOCALIZATION CLASS ---
class _MockL10n {
  const _MockL10n();
  String get diagnosesListTitle => 'Veterinary Diagnoses';
  String get reportedOn => 'Diagnosed On:';
  String get vet => 'Vet';
  String get treatments => 'Treatments Count';
  String get unknownVet => 'Unknown Vet';
  String get addDiagnosis => 'Opening Add Diagnosis Page...';
  String get noDiagnosesFound => 'No diagnoses have been recorded yet.';
  String get viewingDiagnosis => 'Viewing Diagnosis Details for ID:';
  String get retry => 'Retry';
}