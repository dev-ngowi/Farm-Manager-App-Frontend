// lib/features/farmer/insemination/presentation/widgets/insemination_form.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/repositories/insemination_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class InseminationForm extends StatefulWidget {
  final InseminationRepository inseminationRepository;
  final InseminationEntity? recordToEdit;

  const InseminationForm({
    super.key,
    required this.inseminationRepository,
    this.recordToEdit,
  });

  @override
  State<InseminationForm> createState() => _InseminationFormState();
}

class _InseminationFormState extends State<InseminationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers & Values
  late TextEditingController _notesController;
  DateTime? _inseminationDate;
  DateTime? _expectedDeliveryDate;
  String _breedingMethod = 'AI';

  // Selected relationships
  InseminationAnimalEntity? _selectedDam;
  InseminationAnimalEntity? _selectedSire;
  InseminationSemenEntity? _selectedSemen;
  int? _heatCycleId;

  late final bool _isEditing;

  // Available options
  List<InseminationAnimalEntity>? _availableAnimals;
  List<InseminationSemenEntity>? _availableSemen;
  bool _isLoadingAnimals = true;
  bool _isLoadingSemen = true;
  String? _animalLoadError;
  String? _semenLoadError;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.recordToEdit != null;

    if (_isEditing) {
      final rec = widget.recordToEdit!;
      _inseminationDate = rec.inseminationDate;
      _expectedDeliveryDate = rec.expectedDeliveryDate;
      _breedingMethod = rec.breedingMethod;
      _selectedDam = rec.dam;
      _selectedSire = rec.sire;
      _selectedSemen = rec.semen;
      _heatCycleId = rec.heatCycleId;
      _notesController = TextEditingController(text: rec.notes);
    } else {
      _notesController = TextEditingController();
      _inseminationDate = DateTime.now();
      _expectedDeliveryDate = DateTime.now().add(const Duration(days: 283));
    }

    // Load available options
    _loadAvailableAnimals();
    _loadAvailableSemen();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableAnimals() async {
    setState(() {
      _isLoadingAnimals = true;
      _animalLoadError = null;
    });

    final result = await widget.inseminationRepository.getAvailableAnimals();

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingAnimals = false;
          _animalLoadError = failure.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load animals: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (animals) {
        setState(() {
          _availableAnimals = animals;
          _isLoadingAnimals = false;
          _animalLoadError = null;
        });

        print('✅ Loaded ${animals.length} animals');
        print('  - Females: ${animals.where((a) => a.sex == 'Female').length}');
        print('  - Males: ${animals.where((a) => a.sex == 'Male').length}');
      },
    );
  }

  Future<void> _loadAvailableSemen() async {
    setState(() {
      _isLoadingSemen = true;
      _semenLoadError = null;
    });

    final result = await widget.inseminationRepository.getAvailableSemen();

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingSemen = false;
          _semenLoadError = failure.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load semen: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (semen) {
        setState(() {
          _availableSemen = semen;
          _isLoadingSemen = false;
          _semenLoadError = null;
        });

        print('✅ Loaded ${semen.length} semen straws');
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isInsemination) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isInsemination
          ? _inseminationDate ?? DateTime.now()
          : _expectedDeliveryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isInsemination) {
          _inseminationDate = picked;
          // Auto-calculate expected delivery (~283 days for cattle)
          _expectedDeliveryDate = picked.add(const Duration(days: 283));
        } else {
          _expectedDeliveryDate = picked;
        }
      });
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (_selectedDam == null || _inseminationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(l10n.requiredFieldsMissing ?? 'Required fields missing')),
      );
      return;
    }

    // Validate breeding method specific requirements
    if (_breedingMethod == 'Natural' && _selectedSire == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sire is required for Natural breeding')),
      );
      return;
    }

    if (_breedingMethod == 'AI' && _selectedSemen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semen is required for AI breeding')),
      );
      return;
    }

    final bloc = context.read<InseminationBloc>();

    final data = {
      'dam_id': _selectedDam!.id,
      'sire_id': _selectedSire?.id,
      'semen_id': _selectedSemen?.id,
      'heat_cycle_id': _heatCycleId ?? 0,
      'breeding_method': _breedingMethod,
      'insemination_date': _inseminationDate!.toIso8601String(),
      'expected_delivery_date': _expectedDeliveryDate!.toIso8601String(),
      'notes': _notesController.text.trim(),
    };

    if (_isEditing) {
      bloc.add(UpdateInsemination(widget.recordToEdit!.id, data));
    } else {
      bloc.add(AddInsemination(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<InseminationBloc, InseminationState>(
      listener: (context, state) {
        if (state is InseminationAdded || state is InseminationUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is InseminationAdded
                    ? 'Insemination recorded successfully'
                    : 'Insemination updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return success
        } else if (state is InseminationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // ✅ Check if currently submitting
        final isSubmitting = state is InseminationSubmitting;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Dam Selector (required) - Only Females
              _buildAnimalSelector(
                label: l10n.dam ?? 'Dam *',
                selected: _selectedDam,
                onSelect: (animal) => setState(() => _selectedDam = animal),
                required: true,
                animals: _availableAnimals?.where((a) => a.sex == 'Female').toList(),
                isLoading: _isLoadingAnimals,
                errorMessage: _animalLoadError,
                onRetry: _loadAvailableAnimals,
              ),
              const SizedBox(height: 16),

              // Breeding Method
              DropdownButtonFormField<String>(
                initialValue: _breedingMethod,
                decoration: InputDecoration(
                  labelText: l10n.breedingMethod ?? 'Breeding Method *',
                  prefixIcon: const Icon(Icons.category),
                  border: const OutlineInputBorder(),
                ),
                items: ['AI', 'Natural']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: isSubmitting ? null : (v) {
                  setState(() {
                    _breedingMethod = v!;
                    // Clear selections when switching methods
                    if (v == 'AI') {
                      _selectedSire = null;
                    } else {
                      _selectedSemen = null;
                    }
                  });
                },
                validator: (v) =>
                    v == null ? (l10n.fieldRequired ?? 'Field required') : null,
              ),
              const SizedBox(height: 16),

              // Insemination Date
              InkWell(
                onTap: isSubmitting ? null : () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.inseminationDate ?? 'Insemination Date *',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(_inseminationDate == null
                      ? ''
                      : DateFormat('dd MMM yyyy').format(_inseminationDate!)),
                ),
              ),
              const SizedBox(height: 16),

              // Expected Delivery Date
              InkWell(
                onTap: isSubmitting ? null : () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText:
                        l10n.expectedDeliveryDate ?? 'Expected Delivery Date',
                    prefixIcon: const Icon(Icons.event_available),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(_expectedDeliveryDate == null
                      ? ''
                      : DateFormat('dd MMM yyyy').format(_expectedDeliveryDate!)),
                ),
              ),
              const SizedBox(height: 16),

              // Optional Sire (Natural breeding) - Only Males
              if (_breedingMethod == 'Natural') ...[
                _buildAnimalSelector(
                  label: '${l10n.sire ?? 'Sire'} *',
                  selected: _selectedSire,
                  onSelect: (animal) => setState(() => _selectedSire = animal),
                  required: true,
                  animals: _availableAnimals?.where((a) => a.sex == 'Male').toList(),
                  isLoading: _isLoadingAnimals,
                  errorMessage: _animalLoadError,
                  onRetry: _loadAvailableAnimals,
                ),
                const SizedBox(height: 16),
              ],

              // Optional Semen (AI)
              if (_breedingMethod == 'AI') ...[
                _buildSemenSelector(
                  selected: _selectedSemen,
                  onSelect: (semen) => setState(() => _selectedSemen = semen),
                  semens: _availableSemen,
                  isLoading: _isLoadingSemen,
                  errorMessage: _semenLoadError,
                  onRetry: _loadAvailableSemen,
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              TextFormField(
                controller: _notesController,
                enabled: !isSubmitting,
                decoration: InputDecoration(
                  labelText: l10n.notes ?? 'Notes',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Submit Button with Loading State
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(isSubmitting
                      ? l10n.saving ?? 'Saving...'
                      : (_isEditing
                          ? l10n.saveChanges ?? 'Save Changes'
                          : l10n.addRecord ?? 'Add Record')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSubmitting ? null : _submit,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimalSelector({
    required String label,
    required InseminationAnimalEntity? selected,
    required void Function(InseminationAnimalEntity) onSelect,
    bool required = false,
    List<InseminationAnimalEntity>? animals,
    bool isLoading = false,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;

    // Loading state
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading animals...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Error state
    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
          color: Colors.red[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Failed to load animals',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      );
    }

    // Empty state
    if (animals == null || animals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange[50],
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No animals available',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please add animals first or check if they meet breeding requirements.',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Normal dropdown with animals
    // ✅ FIX: Only use selected value if it exists in the available list
    final selectedAnimal = selected != null && animals.any((a) => a.id == selected.id)
        ? selected
        : null;
    
    // Show warning if selected animal is not available
    final isSelectedUnavailable = selected != null && selectedAnimal == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Warning banner if selected animal is unavailable
        if (isSelectedUnavailable) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Previously selected animal (${selected.tagNumber} - ${selected.name}) is no longer available for breeding. Please select a new one.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        DropdownButtonFormField<InseminationAnimalEntity>(
          initialValue: selectedAnimal,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.pets),
            border: const OutlineInputBorder(),
          ),
          items: animals
              .map((a) => DropdownMenuItem(
                    value: a,
                    child: Text('${a.tagNumber} - ${a.name}'),
                  ))
              .toList(),
          onChanged: (v) => v != null ? onSelect(v) : null,
          validator: required
              ? (v) => v == null ? (l10n.fieldRequired ?? 'Field required') : null
              : null,
        ),
      ],
    );
  }

  Widget _buildSemenSelector({
    required InseminationSemenEntity? selected,
    required void Function(InseminationSemenEntity) onSelect,
    List<InseminationSemenEntity>? semens,
    bool isLoading = false,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    // Loading state
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading semen inventory...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Error state
    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
          color: Colors.red[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Failed to load semen',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      );
    }

    // Empty state
    if (semens == null || semens.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border.all(color: Colors.amber.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.amber[700]),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No semen straws found in inventory. Please add semen first.',
                style: TextStyle(color: Colors.brown),
              ),
            ),
          ],
        ),
      );
    }

    // Normal dropdown with semen
    final uniqueSemens = semens.toSet().toList();
    
    // ✅ FIX: Only use selected value if it exists in the available list
    final selectedId = selected != null && uniqueSemens.any((s) => s.id == selected.id)
        ? selected.id
        : null;
    
    // Show warning if selected semen is not available
    final isSelectedUnavailable = selected != null && selectedId == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Warning banner if selected semen is unavailable
        if (isSelectedUnavailable) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Previously used semen (${selected.strawCode} - ${selected.bullName}) is no longer available. Please select a new one.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        DropdownButtonFormField<int>(
          initialValue: selectedId,
          decoration: const InputDecoration(
            labelText: 'Select Semen Straw *',
            prefixIcon: Icon(Icons.biotech),
            border: OutlineInputBorder(),
            hintText: 'Choose a bull',
          ),
          items: uniqueSemens.map((s) {
            final String displayName = '${s.strawCode} - ${s.bullName}';
            return DropdownMenuItem<int>(
              value: s.id,
              child: Text(
                displayName,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (selectedId) {
            if (selectedId != null) {
              final semen = uniqueSemens.firstWhere((s) => s.id == selectedId);
              onSelect(semen);
            }
          },
          validator: (v) => v == null ? 'Please select a semen straw' : null,
        ),
      ],
    );
  }
}