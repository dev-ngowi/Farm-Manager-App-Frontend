// lib/features/farmer/breeding/presentation/widgets/offspring_form.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/domain/entities/offspring_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OffspringForm extends StatefulWidget {
  final OffspringEntity? offspringToEdit;

  const OffspringForm({super.key, this.offspringToEdit});

  @override
  State<OffspringForm> createState() => _OffspringFormState();
}

class _OffspringFormState extends State<OffspringForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tagController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;

  dynamic _selectedDelivery;
  List<OffspringDeliveryEntity> _availableDeliveries = [];
  String _gender = 'Male';
  String _birthCondition = 'Vigorous';
  String _colostrumIntake = 'Adequate';
  bool _navelTreated = false;

  // Options
  final List<String> _genders = ['Male', 'Female', 'Unknown'];
  final List<String> _birthConditions = ['Vigorous', 'Weak', 'Stillborn'];
  final List<String> _colostrumOptions = ['Adequate', 'Partial', 'Insufficient', 'None'];

  bool get _isEditing => widget.offspringToEdit != null;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
    _weightController = TextEditingController();
    _notesController = TextEditingController();

    // TODO: Load data if editing
    if (_isEditing) {
      // Load existing offspring data
    }

    context.read<OffspringBloc>().add(const LoadOffspringDropdowns());
  }

  @override
  void dispose() {
    _tagController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDelivery == null && !_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final data = {
      if (!_isEditing) 'delivery_id': _selectedDelivery,
      'temporary_tag': _tagController.text.trim().isEmpty ? null : _tagController.text.trim(),
      'gender': _gender,
      'birth_weight_kg': double.parse(_weightController.text),
      'birth_condition': _birthCondition,
      'colostrum_intake': _colostrumIntake,
      'navel_treated': _navelTreated ? 1 : 0,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    };

    if (_isEditing) {
      context.read<OffspringBloc>().add(UpdateOffspring(widget.offspringToEdit?.id, data));
    } else {
      context.read<OffspringBloc>().add(AddOffspring(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<OffspringBloc, OffspringState>(
      listener: (context, state) {
        if (state is OffspringDropdownsLoaded) {
          setState(() => _availableDeliveries = state.deliveries);
        }
      },
      builder: (context, state) {
        final isLoading = state is OffspringLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Selection (only for new offspring)
              if (!_isEditing) ...[
                Text(
                  l10n.selectDeliveryContext ?? 'Link to Delivery',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BreedingColors.offspring,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDeliveryDropdown(l10n),
                const SizedBox(height: 24),
              ],

              // Identification Section
              Text(
                l10n.identification ?? 'Identification',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BreedingColors.offspring,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: l10n.temporaryTag ?? 'Temporary Tag (Optional)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 24),

              // Birth Metrics Section
              Text(
                l10n.birthMetrics ?? 'Birth Metrics',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BreedingColors.offspring,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildDropdownField(
                label: l10n.gender ?? 'Gender',
                value: _gender,
                items: _genders,
                icon: Icons.transgender,
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                decoration: InputDecoration(
                  labelText: '${l10n.birthWeight ?? "Birth Weight"} (kg) *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.fitness_center),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.fieldRequired ?? 'Required';
                  if (double.tryParse(v) == null) return l10n.invalidNumber ?? 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: l10n.birthCondition ?? 'Birth Condition',
                value: _birthCondition,
                items: _birthConditions,
                icon: Icons.monitor_heart,
                onChanged: (v) => setState(() => _birthCondition = v!),
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: l10n.colostrumIntake ?? 'Colostrum Intake',
                value: _colostrumIntake,
                items: _colostrumOptions,
                icon: Icons.local_drink,
                onChanged: (v) => setState(() => _colostrumIntake = v!),
              ),
              const SizedBox(height: 16),

              // Navel Treatment Switch
              SwitchListTile(
                title: Text(l10n.navelTreated ?? 'Navel Treated'),
                value: _navelTreated,
                onChanged: (v) => setState(() => _navelTreated = v),
                secondary: const Icon(Icons.medical_services, color: BreedingColors.offspring),
                activeThumbColor: BreedingColors.offspring,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Notes Section
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.notes ?? 'Notes',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.comment_outlined),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BreedingColors.offspring,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditing ? 'UPDATE RECORD' : 'SAVE RECORD',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryDropdown(AppLocalizations l10n) {
    final displayList = List<OffspringDeliveryEntity>.from(_availableDeliveries);
    
    return DropdownButtonFormField<dynamic>(
      value: _selectedDelivery,
      decoration: InputDecoration(
        labelText: '${l10n.delivery ?? "Delivery"} *',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.event),
      ),
      items: displayList.map((d) {
        return DropdownMenuItem(
          value: d.id,
          child: Text(d.label),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedDelivery = v),
      validator: (v) => v == null ? l10n.fieldRequired ?? 'Required' : null,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: '$label *',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
    );
  }
}