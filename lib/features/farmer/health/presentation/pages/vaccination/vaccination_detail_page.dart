// Vaccination Detail Page (show view) for the Farmer module.

import 'package:farm_manager_app/features/farmer/health/presentation/pages/vaccination/vaccination_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class VaccinationDetailPage extends StatefulWidget {
  final int scheduleId;

  const VaccinationDetailPage({required this.scheduleId, super.key, required String vaccinationId});

  @override
  State<VaccinationDetailPage> createState() => _VaccinationDetailPageState();
}

class _VaccinationDetailPageState extends State<VaccinationDetailPage> {
  final VaccinationService _service = VaccinationService();
  late Future<VaccinationSchedule> _scheduleFuture;
  final TextEditingController _batchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _service.fetchScheduleDetails(widget.scheduleId);
  }

  // Helper to show SnackBar (used in TreatmentDetailsPage and consistent with good UX)
  void _showSnackbar(String message, {bool isError = true}) {
    // Clear previous snackbar if any
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _markCompleted() async {
    const l10n = MockL10n();
    final batchNumber = _batchController.text.trim();
    
    if (batchNumber.isEmpty) {
      _showSnackbar(l10n.batchRequired);
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.completingVaccine)),
      );
      
      await _service.markCompleted(widget.scheduleId, batchNumber);
      
      // Clear previous snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackbar(l10n.completeSuccess, isError: false);
      
      // Navigate back and pass true to signal the list page to refresh
      Navigator.pop(context, true); 

    } catch (e) {
      // Handle the exception
      _showSnackbar('${l10n.completeError} ${e.toString().split(':').last.trim()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const l10n = MockL10n();
    final theme = Theme.of(context);
    final primaryColor = BreedingColors.insemination;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scheduleDetails),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<VaccinationSchedule>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Schedule not found.'));
          }

          final schedule = snapshot.data!;
          final isPendingOrMissed = schedule.status != 'Completed';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Card (Vaccine Name and Animal Tag)
                _buildHeaderCard(theme, schedule, l10n),
                const SizedBox(height: 20),
                
                // 2. Schedule Details
                _buildSectionTitle(theme, l10n.scheduleDetails, Icons.calendar_today),
                const SizedBox(height: 8),
                _buildDetailRow(l10n.vaccineName, schedule.vaccineName, theme),
                _buildDetailRow(l10n.prevents, schedule.diseasePrevented, theme),
                _buildDetailRow(l10n.scheduledDate, DateFormat('EEEE, dd MMM yyyy').format(schedule.scheduledDate), theme),
                _buildDetailRow(l10n.plannedBy, schedule.veterinarianName, theme),
                
                const SizedBox(height: 20),

                // 3. Completion Form / Details
                if (isPendingOrMissed) ...[
                  _buildCompletionForm(theme, schedule, l10n),
                ] else ...[
                  _buildCompletionDetails(theme, schedule, l10n),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widgets matching Treatment structure ---

  Widget _buildHeaderCard(ThemeData theme, VaccinationSchedule schedule, MockL10n l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.animal, style: theme.textTheme.labelLarge),
            Text(
              '${schedule.animalName} (${schedule.animalTag})',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.vaccineName, style: theme.textTheme.titleMedium),
                StatusBadge(text: schedule.statusSwahili, color: schedule.flutterStatusColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionDetails(ThemeData theme, VaccinationSchedule schedule, MockL10n l10n) {
    return Card(
      elevation: 2,
      color: AppColors.success.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(theme, l10n.completedDetails, Icons.check_circle_outline),
            const SizedBox(height: 10),
            _buildDetailRow(l10n.completedOn, DateFormat('dd MMM yyyy HH:mm').format(schedule.completedDate!), theme),
            _buildDetailRow(l10n.batchNumber, schedule.batchNumber ?? 'N/A', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionForm(ThemeData theme, VaccinationSchedule schedule, MockL10n l10n) {
    return Card(
      elevation: 2,
      color: Colors.yellow.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.confirmCompletion, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _batchController,
              decoration: InputDecoration(
                labelText: l10n.batchNumber,
                hintText: 'Mfano: ANX-12345',
                border: const OutlineInputBorder(),
                fillColor: theme.scaffoldBackgroundColor,
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _markCompleted,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l10n.completeVaccination),
              style: ElevatedButton.styleFrom(
                backgroundColor: BreedingColors.insemination,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 4,
              ),
            ),
          ],
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
}