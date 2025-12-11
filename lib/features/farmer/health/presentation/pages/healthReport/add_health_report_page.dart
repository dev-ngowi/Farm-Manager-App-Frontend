import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// Import the Cubit and models from the previous section
import 'add_health_report_cubit.dart'; 
// import 'package:farm_manager_app/core/config/app_theme.dart'; // For AppColors

class AddHealthReportPage extends StatefulWidget {
  const AddHealthReportPage({super.key});

  @override
  State<AddHealthReportPage> createState() => _AddHealthReportPageState();
}

class _AddHealthReportPageState extends State<AddHealthReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DropdownItem? _selectedAnimal;
  DropdownItem? _selectedSeverity;
  DropdownItem? _selectedPriority;
  DateTime? _selectedOnsetDate;
  // File handling is simplified for mock-up
  final List<String> _mediaFiles = []; // Mock list of file paths/names

  @override
  void initState() {
    super.initState();
    // Start fetching required data when the page loads
    context.read<AddHealthReportCubit>().fetchDropdowns();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Form Handlers ---

  Future<void> _selectOnsetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedOnsetDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedOnsetDate) {
      setState(() {
        _selectedOnsetDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = <String, dynamic>{
        'animal_id': _selectedAnimal?.value,
        'symptoms': _symptomsController.text,
        'symptom_onset_date': _selectedOnsetDate?.toIso8601String().split('T').first,
        'severity': _selectedSeverity?.value,
        'priority': _selectedPriority?.value,
        'notes': _notesController.text,
        // 'photos': _mediaFiles, // Files need special handling (e.g., Multipart)
      };

      context.read<AddHealthReportCubit>().submitReport(formData);
    }
  }

  // Placeholder for media picking logic
  void _pickMedia() {
    // Implement image/video picker here.
    // For now, we mock adding a file.
    setState(() {
      _mediaFiles.add('photo_${_mediaFiles.length + 1}.jpg');
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media picker opened (mock file added).')));
  }

  @override
  Widget build(BuildContext context) {
    const l10n = _MockL10n();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordNewReport),
      ),
      body: BlocListener<AddHealthReportCubit, AddHealthReportState>(
        listener: (context, state) {
          if (state is AddHealthReportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Navigate back to the Health Reports List
            context.pop();
          } else if (state is AddHealthReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<AddHealthReportCubit, AddHealthReportState>(
          builder: (context, state) {
            final isLoading = state is AddHealthReportLoading;
            final isLoaded = state is AddHealthReportDropdownsLoaded;
            
            // Show loading indicator if necessary
            if (isLoading && !isLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Get dropdown data if loaded, otherwise empty lists
            final loadedState = isLoaded ? state : null;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.requiredFields, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    
                    // 1. ANIMAL SELECTION (REQUIRED)
                    _buildAnimalDropdown(l10n, loadedState),
                    const SizedBox(height: 16),

                    // 2. SYMPTOMS (REQUIRED)
                    TextFormField(
                      controller: _symptomsController,
                      decoration: InputDecoration(
                        labelText: l10n.symptomsObserved,
                        hintText: l10n.symptomsHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. SYMPTOM ONSET DATE (REQUIRED)
                    GestureDetector(
                      onTap: isLoading ? null : _selectOnsetDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.symptomOnsetDate,
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.calendar_today),
                          errorText: _selectedOnsetDate == null && _formKey.currentState?.validate() == false 
                              ? l10n.fieldRequired 
                              : null,
                        ),
                        child: Text(
                          _selectedOnsetDate == null
                              ? l10n.selectDate
                              : DateFormat('dd MMM yyyy').format(_selectedOnsetDate!),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. SEVERITY & PRIORITY (REQUIRED)
                    Row(
                      children: [
                        Expanded(child: _buildSeverityDropdown(l10n, loadedState)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPriorityDropdown(l10n, loadedState)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 5. NOTES (OPTIONAL)
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: l10n.additionalNotes,
                        hintText: l10n.notesHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // 6. MEDIA UPLOAD (OPTIONAL)
                    _buildMediaSection(l10n, theme),
                    const SizedBox(height: 32),

                    // 7. SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submitForm,
                        icon: isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(isLoading ? l10n.submitting : l10n.submitReport, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
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

  Widget _buildAnimalDropdown(_MockL10n l10n, AddHealthReportDropdownsLoaded? loadedState) {
    return DropdownButtonFormField<DropdownItem>(
      initialValue: _selectedAnimal,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.selectAnimal,
        border: const OutlineInputBorder(),
      ),
      items: loadedState?.animals.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item.label, overflow: TextOverflow.ellipsis),
        );
      }).toList() ?? [],
      onChanged: loadedState == null ? null : (item) => setState(() => _selectedAnimal = item),
      validator: (item) {
        if (item == null) {
          return l10n.fieldRequired;
        }
        return null;
      },
    );
  }

  Widget _buildSeverityDropdown(_MockL10n l10n, AddHealthReportDropdownsLoaded? loadedState) {
    return DropdownButtonFormField<DropdownItem>(
      initialValue: _selectedSeverity,
      decoration: InputDecoration(
        labelText: l10n.severity,
        border: const OutlineInputBorder(),
      ),
      items: loadedState?.severities.map((item) {
        return DropdownMenuItem(value: item, child: Text(item.label));
      }).toList() ?? [],
      onChanged: loadedState == null ? null : (item) => setState(() => _selectedSeverity = item),
      validator: (item) {
        if (item == null) {
          return l10n.fieldRequired;
        }
        return null;
      },
    );
  }

  Widget _buildPriorityDropdown(_MockL10n l10n, AddHealthReportDropdownsLoaded? loadedState) {
    return DropdownButtonFormField<DropdownItem>(
      initialValue: _selectedPriority,
      decoration: InputDecoration(
        labelText: l10n.priority,
        border: const OutlineInputBorder(),
      ),
      items: loadedState?.priorities.map((item) {
        return DropdownMenuItem(value: item, child: Text(item.label));
      }).toList() ?? [],
      onChanged: loadedState == null ? null : (item) => setState(() => _selectedPriority = item),
      validator: (item) {
        if (item == null) {
          return l10n.fieldRequired;
        }
        return null;
      },
    );
  }

  // --- Media Section Builder ---

  Widget _buildMediaSection(_MockL10n l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.mediaUpload, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(l10n.mediaHint, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ..._mediaFiles.map((file) => Chip(
                  label: Text(file, overflow: TextOverflow.ellipsis),
                  onDeleted: () => setState(() => _mediaFiles.remove(file)),
                  deleteIcon: const Icon(Icons.close, size: 18),
                )).toList(),
            // Button to add media
            ActionChip(
              avatar: const Icon(Icons.camera_alt),
              label: Text(l10n.addPhoto),
              onPressed: _mediaFiles.length < 5 ? _pickMedia : null, // Limit to 5 files as per API
            ),
          ],
        ),
      ],
    );
  }
}

// --- MOCK LOCALIZATION CLASS ---
class _MockL10n {
  const _MockL10n();
  String get recordNewReport => 'Record New Health Report';
  String get requiredFields => 'Report Details (Required)';
  String get selectAnimal => 'Select Affected Animal *';
  String get symptomsObserved => 'Symptoms Observed *';
  String get symptomsHint => 'Describe the observed symptoms (e.g., coughing, fever, diarrhea, swelling).';
  String get symptomOnsetDate => 'Symptom Onset Date *';
  String get selectDate => 'Select Date';
  String get severity => 'Severity *';
  String get priority => 'Priority *';
  String get additionalNotes => 'Additional Notes (Optional)';
  String get notesHint => 'Add any other relevant information, like previous events or initial actions taken.';
  String get mediaUpload => 'Attach Photos/Videos';
  String get mediaHint => 'Upload up to 5 photos or videos (max 15MB each) to assist the veterinarian.';
  String get addPhoto => 'Add Photo/Video';
  String get submitReport => 'Submit Report';
  String get submitting => 'Submitting...';
  String get fieldRequired => 'This field is required.';
}