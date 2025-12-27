// lib/features/farmer/breeding/presentation/widgets/delivery_form.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OffspringFormData {
  dynamic id; // Changed to dynamic for API consistency
  String gender;
  String birthCondition;
  double birthWeightKg;
  String colostrumIntake;
  bool navelTreated;
  String temporaryTag;
  String notes;

  OffspringFormData({
    this.id,
    this.gender = 'Male',
    this.birthCondition = 'Vigorous',
    this.birthWeightKg = 0.0,
    this.colostrumIntake = 'Adequate',
    this.navelTreated = false,
    this.temporaryTag = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'gender': gender,
        'birth_condition': birthCondition,
        'birth_weight_kg': birthWeightKg,
        'colostrum_intake': colostrumIntake,
        'navel_treated': navelTreated ? 1 : 0, // MySQL boolean compatibility
        'temporary_tag': temporaryTag.trim().isEmpty ? null : temporaryTag.trim(),
        'notes': notes.trim().isEmpty ? null : notes.trim(),
      };
}

class DeliveryForm extends StatefulWidget {
  final DeliveryEntity? deliveryToEdit;

  const DeliveryForm({super.key, this.deliveryToEdit});

  @override
  State<DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  
  DateTime? _deliveryDate;
  String _deliveryType = 'Normal';
  String _damCondition = 'Good';
  int _calvingEaseScore = 1;

  DeliveryInseminationEntity? _selectedInsemination;
  List<OffspringFormData> _offspringList = [];
  List<DeliveryInseminationEntity> _availableInseminations = [];

  bool get _isEditing => widget.deliveryToEdit != null;

  // Options
  final List<String> _deliveryTypes = ['Normal', 'Assisted', 'C-Section', 'Dystocia'];
  final List<String> _damConditions = ['Excellent', 'Good', 'Weak', 'Critical'];
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _birthConditions = ['Vigorous', 'Weak', 'Stillborn'];
  final List<String> _colostrumOptions = ['Adequate', 'Partial', 'Insufficient', 'None'];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.deliveryToEdit?.notes ?? '');
    
    if (_isEditing) {
      final d = widget.deliveryToEdit!;
      _deliveryDate = d.actualDeliveryDate;
      _deliveryType = d.deliveryType;
      _damCondition = d.damConditionAfter;
      _calvingEaseScore = d.calvingEaseScore;
      
      _offspringList = d.offspring.map((o) => OffspringFormData(
        id: o.id,
        gender: o.gender,
        birthCondition: o.birthCondition,
        birthWeightKg: o.birthWeightKg,
        colostrumIntake: o.colostrumIntake,
        navelTreated: o.navelTreated,
        temporaryTag: o.temporaryTag ?? '',
        notes: o.notes ?? '',
      )).toList();

      _selectedInsemination = DeliveryInseminationEntity(
        id: d.inseminationId,
        damName: d.damName,
        damTagNumber: d.damTagNumber,
      );
    } else {
      _deliveryDate = DateTime.now();
      _offspringList = [OffspringFormData()];
    }

    context.read<DeliveryBloc>().add(const LoadDeliveryDropdowns());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInsemination == null) return;

    final data = {
      'insemination_id': _selectedInsemination!.id,
      'actual_delivery_date': DateFormat('yyyy-MM-dd').format(_deliveryDate!),
      'delivery_type': _deliveryType,
      'calving_ease_score': _calvingEaseScore,
      'dam_condition_after': _damCondition,
      'notes': _notesController.text.trim(),
      'offspring': _offspringList.map((o) => o.toJson()).toList(),
    };

    if (_isEditing) {
      context.read<DeliveryBloc>().add(UpdateDelivery(widget.deliveryToEdit!.id, data));
    } else {
      context.read<DeliveryBloc>().add(AddDelivery(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<DeliveryBloc, DeliveryState>(
      listener: (context, state) {
        if (state is DeliveryDropdownsLoaded) {
          setState(() => _availableInseminations = state.inseminations);
        }
      },
      builder: (context, state) {
        final isLoading = state is DeliveryLoading;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInseminationDropdown(l10n),
              const SizedBox(height: 16),
              
              _buildDatePicker(l10n),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: l10n.deliveryType,
                value: _deliveryType,
                items: _deliveryTypes,
                onChanged: (v) => setState(() => _deliveryType = v!),
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: l10n.damConditionAfter,
                value: _damCondition,
                items: _damConditions,
                onChanged: (v) => setState(() => _damCondition = v!),
              ),
              const SizedBox(height: 16),

              _buildEaseSlider(l10n),
              const SizedBox(height: 24),

              _buildOffspringList(l10n),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.comment_outlined),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditing ? 'UPDATE RECORD' : 'SAVE RECORD', 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInseminationDropdown(AppLocalizations l10n) {
    final displayList = List<DeliveryInseminationEntity>.from(_availableInseminations);
    if (_selectedInsemination != null && !displayList.any((i) => i.id == _selectedInsemination!.id)) {
      displayList.insert(0, _selectedInsemination!);
    }

    return DropdownButtonFormField<DeliveryInseminationEntity>(
      value: _selectedInsemination,
      decoration: const InputDecoration(labelText: 'Pregnant Cow (Insemination) *', border: OutlineInputBorder()),
      items: displayList.map((i) => DropdownMenuItem(
        value: i,
        child: Text('${i.damTagNumber} - ${i.damName}'),
      )).toList(),
      onChanged: _isEditing ? null : (v) => setState(() => _selectedInsemination = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildDatePicker(AppLocalizations l10n) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _deliveryDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _deliveryDate = picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Delivery Date *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
        child: Text(DateFormat('dd MMM yyyy').format(_deliveryDate!)),
      ),
    );
  }

  Widget _buildDropdownField({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: '$label *', border: const OutlineInputBorder()),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEaseSlider(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calving Ease Score: $_calvingEaseScore (1=Easy, 5=Difficult)'),
        Slider(
          value: _calvingEaseScore.toDouble(),
          min: 1, max: 5, divisions: 4,
          onChanged: (v) => setState(() => _calvingEaseScore = v.round()),
        ),
      ],
    );
  }

  Widget _buildOffspringList(AppLocalizations l10n) {
    return Column(
      children: [
        ..._offspringList.asMap().entries.map((e) => _buildOffspringCard(e.key, e.value, l10n)),
        TextButton.icon(
          onPressed: () => setState(() => _offspringList.add(OffspringFormData())),
          icon: const Icon(Icons.add),
          label: const Text('Add Another Offspring (Twins/Triplets)'),
        ),
      ],
    );
  }

  Widget _buildOffspringCard(int index, OffspringFormData data, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Offspring #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_offspringList.length > 1)
                  IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() => _offspringList.removeAt(index))),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: data.temporaryTag,
              decoration: const InputDecoration(labelText: 'Temporary Tag (Optional)', border: OutlineInputBorder()),
              onChanged: (v) => data.temporaryTag = v,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildDropdownField(label: 'Gender', value: data.gender, items: _genders, onChanged: (v) => setState(() => data.gender = v!))),
                const SizedBox(width: 8),
                Expanded(child: _buildDropdownField(label: 'Condition', value: data.birthCondition, items: _birthConditions, onChanged: (v) => setState(() => data.birthCondition = v!))),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: data.birthWeightKg > 0 ? data.birthWeightKg.toString() : '',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Birth Weight (kg) *', border: OutlineInputBorder()),
              onChanged: (v) => data.birthWeightKg = double.tryParse(v) ?? 0.0,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }
}