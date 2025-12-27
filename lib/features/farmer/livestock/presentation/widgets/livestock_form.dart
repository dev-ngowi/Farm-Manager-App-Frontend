// lib/features/farmer/livestock/presentation/widgets/livestock_form.dart

import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/routes/app_router.dart'; 
import 'package:farm_manager_app/core/utils/validators.dart';
// NOTE: Assuming this file exists and contains your route constants.
import 'package:farm_manager_app/features/farmer/livestock/data/models/livestock_model.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/breed.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/species.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart'; // Import for LivestockEntity
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart'; 
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_event.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // <-- IMPORT GO_ROUTER

class LivestockForm extends StatefulWidget {
  final LivestockRepository livestockRepository; 
  final LivestockEntity? animalToEdit;
  
  const LivestockForm({
    super.key,
    required this.livestockRepository,
    this.animalToEdit, // New parameter for edit mode
  }); 

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
  bool get isEditMode => widget.animalToEdit != null; 

  @override
  void initState() {
    super.initState();
    
    if (isEditMode) {
      final animal = widget.animalToEdit!;
      
      // 1. Populate _formData from the animal to edit
      _formData.addAll({
        'species_id': animal.speciesId,
        'breed_id': animal.breedId,
        'tag_number': animal.tagNumber,
        'name': animal.name,
        'sex': animal.sex, 
        'status': animal.status, 
        'date_of_birth': animal.dateOfBirth, 
        'weight_at_birth_kg': animal.weightAtBirthKg,
        'sire_id': animal.sire?.animalId, // Use animalId if ParentEntity is available
        'dam_id': animal.dam?.animalId,
        'purchase_date': animal.purchaseDate,
        'purchase_cost': animal.purchaseCost,
        'source': animal.source,
        'notes': animal.notes,
      });
      
      // 2. Populate controllers
      _nameController.text = animal.name ?? '';
      _tagNumberController.text = animal.tagNumber;
      // Handle potential null/conversion issues for numerical data
      _birthWeightController.text = animal.weightAtBirthKg.toString();
      _purchaseCostController.text = animal.purchaseCost?.toString() ?? '';
      _sourceController.text = animal.source ?? '';
      
    } else {
      // Existing initialization for add mode
      _tagNumberController.text = _formData['tag_number'] as String;
      _nameController.text = _formData['name'] as String? ?? '';
      _formData['weight_at_birth_kg'] = double.tryParse(_birthWeightController.text) ?? 0.0;
    }
    
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
    
    // Check if the current selected breed is valid for the new species, otherwise reset
    if (currentBreedId != null && !_filteredBreedList.any((b) => b.id == currentBreedId)) {
        setState(() {
          _formData['breed_id'] = _filteredBreedList.isNotEmpty 
              ? _filteredBreedList.first.id 
              : null;
        });
    } else if (currentBreedId == null && _filteredBreedList.isNotEmpty && !isEditMode) {
      // Set default breed only in Add mode if no breed is currently selected
      setState(() {
        _formData['breed_id'] = _filteredBreedList.first.id;
      });
    } else if (_filteredBreedList.isEmpty) {
      // No breeds for this species
      setState(() {
        _formData['breed_id'] = null;
      });
    }
  }

  Future<void> _fetchDropdownData() async {
    setState(() => _isLoadingDropdowns = true);
    
    _validationError = null;

    final result = await widget.livestockRepository.getLivestockDropdowns();

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!; 

    result.fold(
      (failure) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
          
          if (!isEditMode && _speciesList.isNotEmpty) {
            // Only set default species if not in edit mode
            _formData['species_id'] = _speciesList.first.id;
          }
          
          // Filter breeds based on the selected species ID (which may be pre-filled in edit mode)
          _filterBreeds(_formData['species_id'] as int?);
          
          // Ensure that in edit mode, the selected breed_id is preserved if valid
          // The _filterBreeds handles resetting the breed ID if it's invalid for the species.
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
    // Clear previous backend validation errors
    setState(() {
      _validationError = null;
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      _formData['weight_at_birth_kg'] = double.tryParse(_birthWeightController.text) ?? 0.0;
      // Handle optional purchase cost which can be null
      _formData['purchase_cost'] = _purchaseCostController.text.trim().isEmpty 
                                    ? null 
                                    : double.tryParse(_purchaseCostController.text);
      
      // Use LivestockModel.toUpdateJson (which calls toApiJson) to create the payload.
      final payload = LivestockModel.toUpdateJson( 
        speciesId: _formData['species_id'] as int,
        breedId: _formData['breed_id'] as int?, 
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

      if (isEditMode) {
        // Dispatch Update Event
        context.read<LivestockBloc>().add(
          UpdateLivestock(
            // Use the required ID from the widget for update
            animalId: widget.animalToEdit!.animalId, 
            animalData: payload,
          ),
        );
      } else {
        // Dispatch Add Event
        context.read<LivestockBloc>().add(AddNewLivestock(payload));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; 

    if (_isLoadingDropdowns) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocConsumer<LivestockBloc, LivestockState>(
      listener: (context, state) {
        // Listener for both Add and Edit modes
        if (state is LivestockUpdated) { 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.animalUpdatedSuccess), backgroundColor: Colors.green),
          );
          
          // ⭐ FIX: Safely navigate back after successful update
          // This uses go_router.pop() wrapped in a post-frame callback to prevent the !_debugLocked error.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            // Pop the edit screen, returning the updated animal to the detail page (if one exists).
            GoRouter.of(context).pop(state.animal); 
          });
          
        } else if (state is LivestockAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.livestockRegisteredSuccess), backgroundColor: Colors.green),
          );
          
          // ⭐ FIX: Safely navigate after successful add.
          // Problem: If the 'Add' screen was navigated to with `go()`, `pop()` will fail.
          // Solution 1 (Safest): Use `go()` to replace the current route with the list view.
          // Solution 2 (If pushed): Use `pop()` safely (only if you are sure it was pushed).

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            
            // OPTION 1 (Recommended for Add flow): Navigate back to the list screen (clears the 'Add' screen from history)
            // Assuming your livestock list route is available via a constant, e.g., AppRoutes.livestock
            GoRouter.of(context).go(AppRoutes.livestock); // Use the base list route: '/farmer/livestock'
            
            // OPTION 2 (If you used `push` to reach the 'add' page):
            // GoRouter.of(context).pop(); 
          });

        } else if (state is LivestockError) {
          final failure = state.failure;
          
          if (failure is ValidationFailure) {
            setState(() {
              _validationError = failure;
              _formKey.currentState?.validate();
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.submissionFailed} ${FailureConverter.toMessage(failure)}'), backgroundColor: Colors.red),
            );
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.error} ${FailureConverter.toMessage(failure)}'), backgroundColor: Colors.red),
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is LivestockLoading || _isLoadingDropdowns;

        return Form(
          key: _formKey,
          // Removed SingleChildScrollView here as the page wrapping it should handle it
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(l10n.essentialInfo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              // Species ID Dropdown
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: l10n.species),
                initialValue: _formData['species_id'] as int?,
                items: _speciesList.map((s) => DropdownMenuItem<int>(
                  value: s.id, 
                  child: Text(s.speciesName)
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _formData['species_id'] = value;
                    _formData['breed_id'] = null; // Reset breed when species changes
                    _filterBreeds(value);
                  });
                },
                onSaved: (value) => _formData['species_id'] = value,
                validator: (value) => value == null ? l10n.speciesRequired : null,
              ),
              const SizedBox(height: 12),

              // Breed ID Dropdown
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: l10n.breed),
                initialValue: _filteredBreedList.any((b) => b.id == _formData['breed_id'])
                    ? _formData['breed_id'] as int?
                    : null, // Ensure value is only set if it exists in the current list
                items: _filteredBreedList.map((b) => DropdownMenuItem<int>(
                  value: b.id, 
                  child: Text(b.breedName)
                )).toList(),
                onChanged: _filteredBreedList.isEmpty ? null : (value) => setState(() => _formData['breed_id'] = value),
                onSaved: (value) => _formData['breed_id'] = value,
                // Validation only if there are breeds for the selected species
                validator: (value) => _filteredBreedList.isNotEmpty && value == null ? l10n.breedRequired : null,
              ),
              const SizedBox(height: 12),

              // Tag Number
              TextFormField(
                controller: _tagNumberController,
                decoration: InputDecoration(labelText: l10n.tagNumber),
                keyboardType: TextInputType.text,
                onSaved: (value) => _formData['tag_number'] = value?.trim() ?? '',
                validator: (value) {
                  final localError = Validators.validateRequired(value, l10n.tagNumberRequired);
                  if (localError != null) return localError;

                  // Check for backend validation errors
                  return _validationError?.getFieldError('tag_number');
                },
              ),
              const SizedBox(height: 12),

              // Date of Birth
              ListTile(
                title: Text(l10n.dateOfBirth),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_formData['date_of_birth'])),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'date_of_birth', _formData['date_of_birth']),
              ),
              const SizedBox(height: 12),

              // Birth Weight (kg)
              TextFormField(
                controller: _birthWeightController,
                decoration: InputDecoration(labelText: l10n.weightAtBirth, suffixText: 'kg'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _formData['weight_at_birth_kg'] = double.tryParse(value ?? '0.0'),
                validator: (value) => Validators.validateDouble(value, l10n.weightAtBirthRequired),
              ),
              const SizedBox(height: 12),
              
              // Sex Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: l10n.sex),
                initialValue: _formData['sex'] as String?,
                items: _availableSexes.map((e) => DropdownMenuItem(
                  value: e, 
                  child: Text(_getLocalizedOption(context, e))
                )).toList(),
                onChanged: (value) => setState(() => _formData['sex'] = value),
                onSaved: (value) => _formData['sex'] = value,
                validator: (value) => Validators.validateRequired(value, l10n.sexRequired),
              ),
              const SizedBox(height: 12),
              
              // Status Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: l10n.status),
                initialValue: _formData['status'] as String?,
                items: _availableStatuses.map((e) => DropdownMenuItem(
                  value: e, 
                  child: Text(_getLocalizedOption(context, e))
                )).toList(),
                onChanged: (value) => setState(() => _formData['status'] = value),
                onSaved: (value) => _formData['status'] = value,
                validator: (value) => Validators.validateRequired(value, l10n.statusRequired),
              ),
              const SizedBox(height: 30),


              // Optional Fields Group
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(l10n.optionalInfo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              // Name (Optional)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.nameOptional),
                keyboardType: TextInputType.text,
                onSaved: (value) => _formData['name'] = value?.trim().isEmpty == true ? null : value?.trim(),
              ),
              const SizedBox(height: 12),

              // Sire ID (Optional)
              TextFormField(
                // Pre-fill Sire ID in edit mode
                initialValue: _formData['sire_id']?.toString(), 
                decoration: InputDecoration(labelText: l10n.sireID),
                keyboardType: TextInputType.number,
                onSaved: (value) => _formData['sire_id'] = int.tryParse(value ?? ''),
                validator: (value) => Validators.validateIntegerOptional(value, l10n.sireID),
              ),
              const SizedBox(height: 12),

              // Dam ID (Optional)
              TextFormField(
                // Pre-fill Dam ID in edit mode
                initialValue: _formData['dam_id']?.toString(),
                decoration: InputDecoration(labelText: l10n.damID),
                keyboardType: TextInputType.number,
                onSaved: (value) => _formData['dam_id'] = int.tryParse(value ?? ''),
                validator: (value) => Validators.validateIntegerOptional(value, l10n.damID),
              ),
              const SizedBox(height: 12),
              
              // Purchase Date
              ListTile(
                title: Text(l10n.purchaseDateOptional),
                subtitle: Text(_formData['purchase_date'] == null ? l10n.notSpecified : DateFormat('dd MMM yyyy').format(_formData['purchase_date'])),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'purchase_date', _formData['purchase_date']),
              ),
              const SizedBox(height: 12),

              // Purchase Cost
              TextFormField(
                controller: _purchaseCostController,
                decoration: InputDecoration(labelText: l10n.purchaseCostOptional, prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _formData['purchase_cost'] = double.tryParse(value ?? ''),
                validator: (value) => Validators.validateDoubleOptional(value, l10n.purchaseCostOptional),
              ),
              const SizedBox(height: 12),

              // Source
              TextFormField(
                controller: _sourceController,
                decoration: InputDecoration(labelText: l10n.sourceVendor),
                keyboardType: TextInputType.text,
                onSaved: (value) => _formData['source'] = value?.trim().isEmpty == true ? null : value?.trim(),
              ),
              const SizedBox(height: 30),

              // Submit Button (Update for Edit Mode, Register for Add Mode)
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
                      : Text(
                          isEditMode ? l10n.updateAnimal : l10n.registerAnimal, 
                          style: const TextStyle(fontSize: 18)
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }
}