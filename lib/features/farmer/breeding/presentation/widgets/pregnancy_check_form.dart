import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/entities/pregnancy_check_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PregnancyCheckForm extends StatefulWidget {
  final PregnancyCheckEntity? checkToEdit;

  const PregnancyCheckForm({
    super.key,
    this.checkToEdit,
  });

  @override
  State<PregnancyCheckForm> createState() => _PregnancyCheckFormState();
}

class _PregnancyCheckFormState extends State<PregnancyCheckForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _notesController;
  late TextEditingController _fetusCountController;
  DateTime? _checkDate;
  DateTime? _expectedDeliveryDate;
  String _method = 'Ultrasound';
  String _result = 'Pregnant';

  // Selected relationships
  PregnancyCheckInseminationEntity? _selectedInsemination;
  PregnancyCheckVetEntity? _selectedVet;

  late final bool _isEditing;

  // Dropdown data (from BLoC)
  List<PregnancyCheckInseminationEntity> _availableInseminations = [];
  List<PregnancyCheckVetEntity> _availableVets = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.checkToEdit != null;

    if (_isEditing) {
      final check = widget.checkToEdit!;
      _checkDate = check.checkDate;
      _expectedDeliveryDate = check.expectedDeliveryDate;
      _method = check.method;
      _result = check.result;
      
      // Try to reconstruct insemination entity from check data
      if (check.insemination != null) {
        _selectedInsemination = check.insemination;
      } else if (check.inseminationId > 0) {
        // Create a temporary entity from the check's data
        _selectedInsemination = PregnancyCheckInseminationEntity(
          id: check.inseminationId,
          damName: check.damName,
          damTagNumber: check.damTagNumber,
        );
      }
      
      // Try to reconstruct vet entity from check data
      if (check.vet != null) {
        _selectedVet = check.vet;
      } else if (check.vetId != null && check.vetName != null) {
        _selectedVet = PregnancyCheckVetEntity(
          id: check.vetId!,
          name: check.vetName!,
        );
      }
      
      _notesController = TextEditingController(text: check.notes);
      _fetusCountController = TextEditingController(
        text: check.fetusCount?.toString() ?? '',
      );
    } else {
      _notesController = TextEditingController();
      _fetusCountController = TextEditingController();
      _checkDate = DateTime.now();
    }

    // Load dropdown data using BLoC
    context.read<PregnancyCheckBloc>().add(const LoadPregnancyCheckDropdowns());
  }

  @override
  void dispose() {
    _notesController.dispose();
    _fetusCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckDate
          ? _checkDate ?? DateTime.now()
          : _expectedDeliveryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isCheckDate) {
          _checkDate = picked;
        } else {
          _expectedDeliveryDate = picked;
        }
      });
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (_selectedInsemination == null || _checkDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.requiredFieldsMissing ?? 'Required fields missing'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate pregnant-specific fields
    if (_result == 'Pregnant') {
      if (_fetusCountController.text.isEmpty || _expectedDeliveryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.pregnantFieldsRequired ?? 'Fetus count and due date are required for pregnant results',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final bloc = context.read<PregnancyCheckBloc>();

    final data = {
      'insemination_id': _selectedInsemination!.id,
      'check_date': _checkDate!.toIso8601String(),
      'method': _method,
      'result': _result,
      'fetus_count': _result == 'Pregnant' ? int.tryParse(_fetusCountController.text) : null,
      'expected_delivery_date': _result == 'Pregnant' && _expectedDeliveryDate != null
          ? _expectedDeliveryDate!.toIso8601String()
          : null,
      'vet_id': _selectedVet?.id,
      'notes': _notesController.text.trim(),
    };

    if (_isEditing) {
      bloc.add(UpdatePregnancyCheck(widget.checkToEdit!.id, data));
    } else {
      bloc.add(AddPregnancyCheck(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPregnant = _result == 'Pregnant';

    return BlocConsumer<PregnancyCheckBloc, PregnancyCheckState>(
      listener: (context, state) {
        // Handle dropdown data loaded
        if (state is PregnancyCheckDropdownsLoaded) {
          setState(() {
            _availableInseminations = state.inseminations;
            _availableVets = state.vets;
            
            // If editing, try to match the selected insemination with the loaded data
            if (_isEditing && _selectedInsemination != null) {
              try {
                final matchedInsemination = state.inseminations.firstWhere(
                  (i) => i.id == _selectedInsemination!.id,
                );
                _selectedInsemination = matchedInsemination;
              } catch (e) {
                // If not found in dropdown, keep the existing selection
                print('Insemination ${_selectedInsemination!.id} not found in dropdown list');
              }
            }
            
            // If editing, try to match the selected vet with the loaded data
            if (_isEditing && _selectedVet != null) {
              try {
                final matchedVet = state.vets.firstWhere(
                  (v) => v.id == _selectedVet!.id,
                );
                _selectedVet = matchedVet;
              } catch (e) {
                // If not found in dropdown, keep the existing selection
                print('Vet ${_selectedVet!.id} not found in dropdown list');
              }
            }
          });
        }
        
        // Handle errors
        if (state is PregnancyCheckError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PregnancyCheckLoading;
        final isDropdownsLoading = state is PregnancyCheckDropdownsLoading;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Show loading indicator for dropdowns
              if (isDropdownsLoading)
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading form data...',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!isDropdownsLoading) ...[
                // Insemination Selector (required)
                _buildInseminationSelector(
                  selected: _selectedInsemination,
                  onSelect: (insemination) => setState(() => _selectedInsemination = insemination),
                  inseminations: _availableInseminations,
                ),
                const SizedBox(height: 16),

                // Check Date
                InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '${l10n.checkDate ?? 'Check Date'} *',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    child: Text(
                      _checkDate == null ? '' : DateFormat('dd MMM yyyy').format(_checkDate!),
                      style: TextStyle(
                        color: _checkDate == null ? Colors.grey : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Method
                DropdownButtonFormField<String>(
                  value: _method,
                  decoration: InputDecoration(
                    labelText: '${l10n.method ?? 'Method'} *',
                    prefixIcon: const Icon(Icons.science),
                    border: const OutlineInputBorder(),
                  ),
                  items: ['Ultrasound', 'Palpation', 'Blood']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _method = v!),
                  validator: (v) => v == null ? (l10n.fieldRequired ?? 'Field required') : null,
                ),
                const SizedBox(height: 16),

                // Result
                DropdownButtonFormField<String>(
                  value: _result,
                  decoration: InputDecoration(
                    labelText: '${l10n.result ?? 'Result'} *',
                    prefixIcon: const Icon(Icons.favorite_border),
                    border: const OutlineInputBorder(),
                  ),
                  items: ['Pregnant', 'Not Pregnant', 'Reabsorbed']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _result = v!;
                      // Clear conditional fields if result changes away from 'Pregnant'
                      if (v != 'Pregnant') {
                        _fetusCountController.clear();
                        _expectedDeliveryDate = null;
                      }
                    });
                  },
                  validator: (v) => v == null ? (l10n.fieldRequired ?? 'Field required') : null,
                ),
                const SizedBox(height: 16),

                // Conditional Fields for Pregnant Result
                if (isPregnant) ...[
                  // Fetus Count
                  TextFormField(
                    controller: _fetusCountController,
                    decoration: InputDecoration(
                      labelText: '${l10n.fetusCount ?? 'Fetus Count'} *',
                      prefixIcon: const Icon(Icons.numbers),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (isPregnant && (value == null || value.isEmpty)) {
                        return l10n.fieldRequired ?? 'Field required';
                      }
                      if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                        return l10n.invalidNumber ?? 'Invalid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Expected Delivery Date
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '${l10n.dueDate ?? 'Due Date'} *',
                        prefixIcon: const Icon(Icons.event_available),
                        border: const OutlineInputBorder(),
                      ),
                      child: Text(
                        _expectedDeliveryDate == null
                            ? ''
                            : DateFormat('dd MMM yyyy').format(_expectedDeliveryDate!),
                        style: TextStyle(
                          color: _expectedDeliveryDate == null ? Colors.grey : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Vet Selector (optional)
                _buildVetSelector(
                  selected: _selectedVet,
                  onSelect: (vet) => setState(() => _selectedVet = vet),
                  vets: _availableVets,
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.notes ?? 'Notes',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isLoading
                          ? l10n.saving ?? 'Saving...'
                          : (_isEditing
                              ? l10n.saveChanges ?? 'Save Changes'
                              : l10n.addRecord ?? 'Add Record'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading || isDropdownsLoading ? null : _submit,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInseminationSelector({
    required PregnancyCheckInseminationEntity? selected,
    required void Function(PregnancyCheckInseminationEntity) onSelect,
    required List<PregnancyCheckInseminationEntity> inseminations,
  }) {
    final l10n = AppLocalizations.of(context)!;

    // Empty state
    if (inseminations.isEmpty) {
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
                    'No inseminations available',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please record inseminations first before adding pregnancy checks.',
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

    // Check if selected is in the list
    final isSelectedInList = selected != null && inseminations.any((i) => i.id == selected.id);
    final effectiveValue = isSelectedInList ? selected : null;

    // Build dropdown items
    final items = <DropdownMenuItem<PregnancyCheckInseminationEntity>>[];
    
    // Add the selected item if it's not in the list (for editing existing records)
    if (selected != null && !isSelectedInList) {
      items.add(
        DropdownMenuItem(
          value: selected,
          child: Text('ID #${selected.id} - ${selected.damName} (${selected.damTagNumber})'),
        ),
      );
    }
    
    // Add all available inseminations
    items.addAll(
      inseminations.map((i) => DropdownMenuItem(
        value: i,
        child: Text('ID #${i.id} - ${i.damName} (${i.damTagNumber})'),
      )),
    );

    // Normal dropdown
    return DropdownButtonFormField<PregnancyCheckInseminationEntity>(
      value: effectiveValue ?? selected,
      decoration: InputDecoration(
        labelText: '${l10n.relatedInsemination ?? 'Related Insemination'} *',
        prefixIcon: const Icon(Icons.vaccines),
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: (v) => v != null ? onSelect(v) : null,
      validator: (v) => v == null ? (l10n.fieldRequired ?? 'Field required') : null,
    );
  }

  Widget _buildVetSelector({
    required PregnancyCheckVetEntity? selected,
    required void Function(PregnancyCheckVetEntity?) onSelect,
    required List<PregnancyCheckVetEntity> vets,
  }) {
    final l10n = AppLocalizations.of(context)!;

    // Normal dropdown (with optional selection)
    return DropdownButtonFormField<PregnancyCheckVetEntity?>(
      value: selected,
      decoration: InputDecoration(
        labelText: l10n.technician ?? 'Technician (Optional)',
        prefixIcon: const Icon(Icons.person_pin),
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<PregnancyCheckVetEntity?>(
          value: null,
          child: Text(
            l10n.notRecorded ?? 'Not Recorded',
            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ),
        ...vets.map((v) => DropdownMenuItem(
              value: v,
              child: Text(v.name),
            )),
      ],
      onChanged: (v) => onSelect(v),
    );
  }
}