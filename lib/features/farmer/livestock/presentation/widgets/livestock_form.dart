// lib/features/farmer/livestock/presentation/widgets/livestock_form.dart

import 'package:farm_manager_app/core/error/failure.dart'; 
import 'package:farm_manager_app/core/utils/validators.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/models/livestock_model.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/breed.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/species.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart'; 
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_event.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
// Note: Changed import for l10n package structure
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class LivestockForm extends StatefulWidget {
  final LivestockRepository livestockRepository; 
  const LivestockForm({super.key, required this.livestockRepository}); 

  @override
  State<LivestockForm> createState() => _LivestockFormState();
}

class _LivestockFormState extends State<LivestockForm> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoadingDropdowns = true;
  List<SpeciesEntity> _speciesList = [];
  List<BreedEntity> _allBreedList = [];
  List<BreedEntity> _filteredBreedList = [];

  ValidationFailure? _validationError;

  final _formData = <String, dynamic>{
    'species_id': null,
    'breed_id': null,
    'tag_number': '',
    'name': null,
    'sex': 'Male', 
    'status': 'Active', 
    'date_of_birth': DateTime.now().subtract(const Duration(days: 1)), 
    'weight_at_birth_kg': 0.0,
    'sire_id': null,
    'dam_id': null,
    'purchase_date': null,
    'purchase_cost': null,
    'source': null,
    'notes': null,
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagNumberController = TextEditingController();
  final TextEditingController _birthWeightController = TextEditingController(text: '0.0');
  final TextEditingController _purchaseCostController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  final List<String> _availableSexes = ['Male', 'Female', 'Unknown'];
  final List<String> _availableStatuses = ['Active', 'Sold', 'Dead', 'Stolen']; 

  @override
  void initState() {
    super.initState();
    _tagNumberController.text = _formData['tag_number'] as String;
    _nameController.text = _formData['name'] as String? ?? '';
    _formData['weight_at_birth_kg'] = double.tryParse(_birthWeightController.text) ?? 0.0;
    
    // We call async function here
    _fetchDropdownData();
  }

  // ⭐ L10N Helper: Get localized string for Sex/Status
  String _getLocalizedOption(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context)!;
    switch (value) {
      case 'Male': return l10n.male;
      case 'Female': return l10n.female;
      case 'Unknown': return l10n.unknown;
      case 'Active': return l10n.active;
      case 'Sold': return l10n.sold;
      case 'Dead': return l10n.dead;
      case 'Stolen': return l10n.stolen;
      default: return value;
    }
  }


  void _filterBreeds(int? speciesId) {
    if (speciesId == null) {
      _filteredBreedList = [];
    } else {
      _filteredBreedList = _allBreedList
          .where((breed) => breed.speciesId == speciesId)
          .toList();
    }
    
    final currentBreedId = _formData['breed_id'] as int?;
    if (currentBreedId != null && !_filteredBreedList.any((b) => b.id == currentBreedId)) {
        _formData['breed_id'] = _filteredBreedList.isNotEmpty 
            ? _filteredBreedList.first.id 
            : null;
    } else if (currentBreedId == null && _filteredBreedList.isNotEmpty) {
      _formData['breed_id'] = _filteredBreedList.first.id;
    } else if (_filteredBreedList.isEmpty) {
      _formData['breed_id'] = null;
    }
  }

  Future<void> _fetchDropdownData() async {
    // ⭐ CRITICAL FIX: Do not access context/l10n synchronously here.
    setState(() => _isLoadingDropdowns = true);
    
    _validationError = null;

    final result = await widget.livestockRepository.getLivestockDropdowns();

    // Check if widget is still mounted before accessing context or setting state
    if (!mounted) return;
    
    // Obtain l10n only when required (after async call)
    final l10n = AppLocalizations.of(context)!; 

    result.fold(
      (failure) {
        // We are already in an async context, but running UI update via postFrameCallback is safer.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // ⭐ L10N FIX: Use l10n key
              content: Text('${l10n.failedLoadDropdown} ${FailureConverter.toMessage(failure)}'), 
              backgroundColor: Colors.red,
            ),
          );
        });
      },
      (dropdownData) {
        setState(() {
          _speciesList = dropdownData.species;
          _allBreedList = dropdownData.breeds;
          
          if (_speciesList.isNotEmpty) {
            _formData['species_id'] = _speciesList.first.id;
          }
          
          _filterBreeds(_formData['species_id'] as int?);

          if (_filteredBreedList.isNotEmpty) {
            _formData['breed_id'] = _filteredBreedList.first.id;
          }
        });
      },
    );
    
    setState(() => _isLoadingDropdowns = false);
  }


  @override
  void dispose() {
    _nameController.dispose();
    _tagNumberController.dispose();
    _birthWeightController.dispose();
    _purchaseCostController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String fieldName, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted && picked != _formData[fieldName]) {
      setState(() {
        _formData[fieldName] = picked;
      });
    }
  }

  void _submitForm() {
    // ⭐ CRITICAL STEP 1: Clear previous backend validation errors before attempting submission
    setState(() {
      _validationError = null;
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      _formData['weight_at_birth_kg'] = double.tryParse(_birthWeightController.text) ?? 0.0;
      _formData['purchase_cost'] = double.tryParse(_purchaseCostController.text) ?? null;
      
      final payload = LivestockModel.toStoreJson(
        speciesId: _formData['species_id'] as int,
        breedId: _formData['breed_id'] as int,
        tagNumber: _formData['tag_number'] as String,
        name: _formData['name'] as String?,
        sex: _formData['sex'] as String,
        dateOfBirth: _formData['date_of_birth'] as DateTime,
        weightAtBirthKg: _formData['weight_at_birth_kg'] as double,
        status: _formData['status'] as String,
        notes: _formData['notes'] as String?, 
        sireId: _formData['sire_id'] as int?,
        damId: _formData['dam_id'] as int?,
        purchaseDate: _formData['purchase_date'] as DateTime?,
        purchaseCost: _formData['purchase_cost'] as double?,
        source: _formData['source'] as String?,
      );

      context.read<LivestockBloc>().add(AddNewLivestock(payload));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get l10n here in build method where context is guaranteed to be valid
    final l10n = AppLocalizations.of(context)!; 

    if (_isLoadingDropdowns) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocConsumer<LivestockBloc, LivestockState>(
      listener: (context, state) {
        if (state is LivestockAdded) { 
          ScaffoldMessenger.of(context).showSnackBar(
            // ⭐ L10N FIX: Use l10n key
            SnackBar(content: Text(l10n.livestockRegisteredSuccess), backgroundColor: Colors.green),
          );
        } else if (state is LivestockError) {
          final failure = state.failure;
          
          if (failure is ValidationFailure) {
            setState(() {
              _validationError = failure;
              _formKey.currentState?.validate();
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              // ⭐ L10N FIX: Use l10n key
              SnackBar(content: Text('${l10n.submissionFailed} ${FailureConverter.toMessage(failure)}'), backgroundColor: Colors.red),
            );
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              // ⭐ L10N FIX: Use l10n key
              SnackBar(content: Text('${l10n.error} ${FailureConverter.toMessage(failure)}'), backgroundColor: Colors.red),
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is LivestockLoading || _isLoadingDropdowns;

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  // ⭐ L10N FIX: Use l10n key
                  child: Text(l10n.essentialInfo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                
                // Species ID Dropdown
                DropdownButtonFormField<int>(
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.species),
                  value: _formData['species_id'] as int?,
                  items: _speciesList.map((s) => DropdownMenuItem<int>(
                    value: s.id, 
                    child: Text(s.speciesName)
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _formData['species_id'] = value;
                      _filterBreeds(value);
                      _formData['breed_id'] = _filteredBreedList.isNotEmpty ? _filteredBreedList.first.id : null;
                    });
                  },
                  onSaved: (value) => _formData['species_id'] = value,
                  // ⭐ L10N FIX: Use l10n key
                  validator: (value) => value == null ? l10n.speciesRequired : null,
                ),
                const SizedBox(height: 12),

                // Breed ID Dropdown
                DropdownButtonFormField<int>(
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.breed),
                  value: _filteredBreedList.any((b) => b.id == _formData['breed_id'])
                      ? _formData['breed_id'] as int?
                      : null, 
                  items: _filteredBreedList.map((b) => DropdownMenuItem<int>(
                    value: b.id, 
                    child: Text(b.breedName)
                  )).toList(),
                  onChanged: (value) => setState(() => _formData['breed_id'] = value),
                  onSaved: (value) => _formData['breed_id'] = value,
                  // ⭐ L10N FIX: Use l10n key
                  validator: (value) => value == null ? l10n.breedRequired : null,
                ),
                const SizedBox(height: 12),

                // Tag Number
                TextFormField(
                  controller: _tagNumberController,
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.tagNumber),
                  keyboardType: TextInputType.text,
                  onSaved: (value) => _formData['tag_number'] = value?.trim() ?? '',
                  validator: (value) {
                    // ⭐ L10N FIX: Use l10n key for local validation message
                    final localError = Validators.validateRequired(value, l10n.tagNumberRequired);
                    if (localError != null) return localError;

                    return _validationError?.getFieldError('tag_number');
                  },
                ),
                const SizedBox(height: 12),

                // Date of Birth
                ListTile(
                  // ⭐ L10N FIX: Use l10n key
                  title: Text(l10n.dateOfBirth),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(_formData['date_of_birth'])),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, 'date_of_birth', _formData['date_of_birth']),
                ),
                const SizedBox(height: 12),

                // Birth Weight (kg)
                TextFormField(
                  controller: _birthWeightController,
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.weightAtBirth, suffixText: 'kg'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => _formData['weight_at_birth_kg'] = double.tryParse(value ?? '0.0'),
                  // ⭐ L10N FIX: Use l10n key for local validation message
                  validator: (value) => Validators.validateDouble(value, l10n.weightAtBirthRequired),
                ),
                const SizedBox(height: 12),
                
                // Sex Dropdown
                DropdownButtonFormField<String>(
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.sex),
                  value: _formData['sex'] as String?,
                  items: _availableSexes.map((e) => DropdownMenuItem(
                    value: e, 
                    // ⭐ L10N FIX: Localize the dropdown display value
                    child: Text(_getLocalizedOption(context, e))
                  )).toList(),
                  onChanged: (value) => setState(() => _formData['sex'] = value),
                  onSaved: (value) => _formData['sex'] = value,
                  // ⭐ L10N FIX: Use l10n key for local validation message
                  validator: (value) => Validators.validateRequired(value, l10n.sexRequired),
                ),
                const SizedBox(height: 12),
                
                // Status Dropdown
                DropdownButtonFormField<String>(
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.status),
                  value: _formData['status'] as String?,
                  items: _availableStatuses.map((e) => DropdownMenuItem(
                    value: e, 
                    // ⭐ L10N FIX: Localize the dropdown display value
                    child: Text(_getLocalizedOption(context, e))
                  )).toList(),
                  onChanged: (value) => setState(() => _formData['status'] = value),
                  onSaved: (value) => _formData['status'] = value,
                  // ⭐ L10N FIX: Use l10n key for local validation message
                  validator: (value) => Validators.validateRequired(value, l10n.statusRequired),
                ),
                const SizedBox(height: 30),


                // Optional Fields Group
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  // ⭐ L10N FIX: Use l10n key
                  child: Text(l10n.optionalInfo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                // Name (Optional)
                TextFormField(
                  controller: _nameController,
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.nameOptional),
                  keyboardType: TextInputType.text,
                  onSaved: (value) => _formData['name'] = value?.trim().isEmpty == true ? null : value?.trim(),
                ),
                const SizedBox(height: 12),

                // Sire ID (Optional)
                TextFormField(
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.sireID),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _formData['sire_id'] = int.tryParse(value ?? ''),
                  // ⭐ L10N FIX: Use l10n key for local validation message
                  validator: (value) => Validators.validateIntegerOptional(value, l10n.sireID),
                ),
                const SizedBox(height: 12),

                // Dam ID (Optional)
                TextFormField(
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.damID),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _formData['dam_id'] = int.tryParse(value ?? ''),
                  // ⭐ L10N FIX: Use l10n key for local validation message
                  validator: (value) => Validators.validateIntegerOptional(value, l10n.damID),
                ),
                const SizedBox(height: 12),
                
                // Purchase Date
                ListTile(
                  // ⭐ L10N FIX: Use l10n key
                  title: Text(l10n.purchaseDateOptional),
                  // ⭐ L10N FIX: Use l10n key
                  subtitle: Text(_formData['purchase_date'] == null ? l10n.notSpecified : DateFormat('dd MMM yyyy').format(_formData['purchase_date'])),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, 'purchase_date', _formData['purchase_date']),
                ),
                const SizedBox(height: 12),

                // Purchase Cost
                TextFormField(
                  controller: _purchaseCostController,
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.purchaseCostOptional, prefixText: '\$'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => _formData['purchase_cost'] = double.tryParse(value ?? ''),
                  // ⭐ L10N FIX: Use l10n key for local validation message
                  validator: (value) => Validators.validateDoubleOptional(value, l10n.purchaseCostOptional),
                ),
                const SizedBox(height: 12),

                // Source
                TextFormField(
                  controller: _sourceController,
                  // ⭐ L10N FIX: Use l10n key
                  decoration: InputDecoration(labelText: l10n.sourceVendor),
                  keyboardType: TextInputType.text,
                  onSaved: (value) => _formData['source'] = value?.trim().isEmpty == true ? null : value?.trim(),
                ),
                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        // ⭐ L10N FIX: Use l10n key
                        : Text(l10n.registerAnimal, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}