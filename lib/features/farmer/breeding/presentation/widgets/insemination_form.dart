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
  String _status = 'Pending';

  // Selected relationships
  InseminationAnimalEntity? _selectedDam;
  InseminationAnimalEntity? _selectedSire;
  InseminationSemenEntity? _selectedSemen;
  int? _heatCycleId;

  late final bool _isEditing;

  // Available options
  List<InseminationAnimalEntity>? _availableAnimals;
  List<InseminationSemenEntity>? _availableSemen;
  bool _isLoadingAnimals = false;
  bool _isLoadingSemen = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.recordToEdit != null;

    if (_isEditing) {
      final rec = widget.recordToEdit!;
      _inseminationDate = rec.inseminationDate;
      _expectedDeliveryDate = rec.expectedDeliveryDate;
      _breedingMethod = rec.breedingMethod;
      _status = rec.status;
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

  // ⭐ NEW: Load available animals from repository
  Future<void> _loadAvailableAnimals() async {
    setState(() => _isLoadingAnimals = true);
    final result = await widget.inseminationRepository.getAvailableAnimals();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load animals: ${failure.message}')),
          );
        }
      },
      (animals) {
        if (mounted) {
          setState(() {
            _availableAnimals = animals;
            _isLoadingAnimals = false;
          });
        }
      },
    );
  }

  // ⭐ NEW: Load available semen from repository
  Future<void> _loadAvailableSemen() async {
    setState(() => _isLoadingSemen = true);
    final result = await widget.inseminationRepository.getAvailableSemen();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load semen: ${failure.message}')),
          );
        }
      },
      (semen) {
        if (mounted) {
          setState(() {
            _availableSemen = semen;
            _isLoadingSemen = false;
          });
        }
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isInsemination) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isInsemination ? _inseminationDate ?? DateTime.now() : _expectedDeliveryDate ?? DateTime.now(),
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
        SnackBar(content: Text(l10n.requiredFieldsMissing ?? 'Required fields missing')),
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
      'status': _status,
      'notes': _notesController.text.trim(),
    };

    // ⭐ FIX: Corrected ternary operator syntax
    if (_isEditing) {
      bloc.add(UpdateInsemination(widget.recordToEdit!.id, data));
    } else {
      bloc.add(AddInsemination(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = context.watch<InseminationBloc>().state is InseminationLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Dam Selector (required)
          _buildAnimalSelector(
            label: l10n.dam ?? 'Dam *',
            selected: _selectedDam,
            onSelect: (animal) => setState(() => _selectedDam = animal),
            required: true,
            animals: _availableAnimals,
            isLoading: _isLoadingAnimals,
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
            items: ['AI', 'Natural'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _breedingMethod = v!),
            validator: (v) => v == null ? (l10n.fieldRequired ?? 'Field required') : null,
          ),
          const SizedBox(height: 16),

          // Insemination Date
          InkWell(
            onTap: () => _selectDate(context, true),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.inseminationDate ?? 'Insemination Date *',
                prefixIcon: const Icon(Icons.calendar_today),
                border: const OutlineInputBorder(),
              ),
              child: Text(_inseminationDate == null ? '' : DateFormat('dd MMM yyyy').format(_inseminationDate!)),
            ),
          ),
          const SizedBox(height: 16),

          // Expected Delivery Date
          InkWell(
            onTap: () => _selectDate(context, false),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.expectedDeliveryDate ?? 'Expected Delivery Date',
                prefixIcon: const Icon(Icons.event_available),
                border: const OutlineInputBorder(),
              ),
              child: Text(_expectedDeliveryDate == null ? '' : DateFormat('dd MMM yyyy').format(_expectedDeliveryDate!)),
            ),
          ),
          const SizedBox(height: 16),

          // Optional Sire (Natural breeding)
          if (_breedingMethod == 'Natural')
            _buildAnimalSelector(
              label: l10n.sire ?? 'Sire',
              selected: _selectedSire,
              onSelect: (animal) => setState(() => _selectedSire = animal),
              animals: _availableAnimals,
              isLoading: _isLoadingAnimals,
            ),

          // Optional Semen (AI)
          if (_breedingMethod == 'AI')
            _buildSemenSelector(
              selected: _selectedSemen,
              onSelect: (semen) => setState(() => _selectedSemen = semen),
              semens: _availableSemen,
              isLoading: _isLoadingSemen,
            ),
          const SizedBox(height: 16),

          // Status
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: InputDecoration(
              labelText: l10n.status ?? 'Status',
              prefixIcon: const Icon(Icons.check_circle_outline),
              border: const OutlineInputBorder(),
            ),
            items: ['Pending', 'Confirmed Pregnant', 'Not Pregnant', 'Aborted']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          const SizedBox(height: 16),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notes ?? 'Notes',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.note_alt_outlined),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 32),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(isLoading
                  ? l10n.saving ?? 'Saving...'
                  : (_isEditing ? l10n.saveChanges ?? 'Save Changes' : l10n.addRecord ?? 'Add Record')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isLoading ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ UPDATED: Animal selector with direct data access
  Widget _buildAnimalSelector({
    required String label,
    required InseminationAnimalEntity? selected,
    required void Function(InseminationAnimalEntity) onSelect,
    bool required = false,
    List<InseminationAnimalEntity>? animals,
    bool isLoading = false,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (animals == null || animals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'No animals available. Please add animals first.',
          style: TextStyle(color: Colors.orange[700]),
        ),
      );
    }

    return DropdownButtonFormField<InseminationAnimalEntity>(
      initialValue: selected,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.pets),
        border: const OutlineInputBorder(),
      ),
      items: animals
          .map((a) => DropdownMenuItem(value: a, child: Text('${a.tagNumber} - ${a.name}')))
          .toList(),
      onChanged: (v) => v != null ? onSelect(v) : null,
      validator: required
          ? (v) => v == null ? (l10n.fieldRequired ?? 'Field required') : null
          : null,
    );
  }

  // ⭐ UPDATED: Semen selector with direct data access
  Widget _buildSemenSelector({
    required InseminationSemenEntity? selected,
    required void Function(InseminationSemenEntity) onSelect,
    List<InseminationSemenEntity>? semens,
    bool isLoading = false,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (semens == null || semens.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'No semen straws available. Please add semen first.',
          style: TextStyle(color: Colors.orange[700]),
        ),
      );
    }

    return DropdownButtonFormField<InseminationSemenEntity>(
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Semen Straw',
        prefixIcon: Icon(Icons.biotech),
        border: OutlineInputBorder(),
      ),
      items: semens
          .map((s) => DropdownMenuItem(value: s, child: Text('${s.strawCode} - ${s.bullName}')))
          .toList(),
      onChanged: (v) => v != null ? onSelect(v) : null,
    );
  }
}