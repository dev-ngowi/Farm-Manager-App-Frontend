// edit_health_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'health_report_update_cubit.dart';

class EditHealthReportPage extends StatefulWidget {
  final String healthId;
  // We pass the current data to pre-fill the form instantly
  final Map<String, dynamic> initialReportData; 
  
  const EditHealthReportPage({
    super.key, 
    required this.healthId, 
    required this.initialReportData,
  });

  @override
  State<EditHealthReportPage> createState() => _EditHealthReportPageState();
}

class _EditHealthReportPageState extends State<EditHealthReportPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;

  String? _selectedStatus;
  String? _selectedPriority;
  
  // Mock Localization
  final _MockL10n l10n = const _MockL10n();

  @override
  void initState() {
    super.initState();
    // Initialize form controls with current data
    _notesController = TextEditingController(text: widget.initialReportData['notes']);
    _selectedStatus = widget.initialReportData['status'] as String?;
    _selectedPriority = widget.initialReportData['priority'] as String?;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = <String, dynamic>{
        'status': _selectedStatus,
        'priority': _selectedPriority,
        'notes': _notesController.text,
      };

      context.read<HealthReportUpdateCubit>().updateReport(
        widget.healthId,
        formData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalName = widget.initialReportData['animal']?['name'] ?? 'Animal';

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.editReport} - $animalName'),
      ),
      body: BlocListener<HealthReportUpdateCubit, HealthReportUpdateState>(
        listener: (context, state) {
          if (state is HealthReportUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Pop back to the details page, which should refresh its data
            context.pop(true); // Pass 'true' to indicate success/refresh needed
          } else if (state is HealthReportUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<HealthReportUpdateCubit, HealthReportUpdateState>(
          builder: (context, state) {
            final isLoading = state is HealthReportUpdateLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.updateInstructions, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade700)),
                    const SizedBox(height: 20),

                    // 1. STATUS FIELD (REQUIRED)
                    _buildStatusDropdown(theme, isLoading),
                    const SizedBox(height: 16),

                    // 2. PRIORITY FIELD (SOMETIMES)
                    _buildPriorityDropdown(theme, isLoading),
                    const SizedBox(height: 16),

                    // 3. NOTES FIELD (OPTIONAL)
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: l10n.updateNotes,
                        hintText: l10n.notesHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 32),

                    // 4. SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submitForm,
                        icon: isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.save),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(isLoading ? l10n.saving : l10n.saveChanges, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Dropdown Builders ---

  Widget _buildStatusDropdown(ThemeData theme, bool isLoading) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedStatus,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.status,
        border: const OutlineInputBorder(),
      ),
      items: HealthReportUpdateCubit.statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: isLoading ? null : (value) => setState(() => _selectedStatus = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.fieldRequired;
        }
        return null;
      },
    );
  }

  Widget _buildPriorityDropdown(ThemeData theme, bool isLoading) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedPriority,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.priority,
        border: const OutlineInputBorder(),
      ),
      items: HealthReportUpdateCubit.priorityOptions.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Text(priority),
        );
      }).toList(),
      onChanged: isLoading ? null : (value) => setState(() => _selectedPriority = value),
    );
  }
}

// --- MOCK LOCALIZATION CLASS ---
class _MockL10n {
  const _MockL10n();
  String get editReport => 'Edit Health Report';
  String get updateInstructions => 'Update the current status, priority, and notes for this report.';
  String get status => 'Current Status *';
  String get priority => 'Priority';
  String get updateNotes => 'Update Notes';
  String get notesHint => 'Add comments about status changes or follow-up observations.';
  String get saveChanges => 'Save Changes';
  String get saving => 'Saving...';
  String get fieldRequired => 'This field is required.';
}