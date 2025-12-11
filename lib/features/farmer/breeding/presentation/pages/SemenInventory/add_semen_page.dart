import 'package:farm_manager_app/core/config/app_theme.dart'; // For AppColors/Theme styling
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/dropdown_entity.dart'; // For DropdownEntity
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart'; // For SemenEntity
import 'package:farm_manager_app/l10n/app_localizations.dart'; // For localization (l10n)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // For BLoC
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddSemenPage extends StatefulWidget {
  static const String routeName = 'add-semen';

  const AddSemenPage({super.key});

  @override
  State<AddSemenPage> createState() => _AddSemenPageState();
}

class _AddSemenPageState extends State<AddSemenPage> {
  final _formKey = GlobalKey<FormState>();
  
  // --- Text Controllers (Matching Backend Fields) ---
  final TextEditingController _strawCodeController = TextEditingController(); // straw_code (required)
  final TextEditingController _bullNameController = TextEditingController(); // bull_name (required)
  final TextEditingController _bullTagController = TextEditingController(); // bull_tag (optional)
  final TextEditingController _doseMlController = TextEditingController(); // dose_ml (optional)
  final TextEditingController _motilityController = TextEditingController(); // motility_percentage (optional)
  final TextEditingController _costController = TextEditingController(); // cost_per_straw (optional)
  final TextEditingController _sourceController = TextEditingController(); // source_supplier (optional)

  // --- Dropdown/Date Values (Matching Backend Fields) ---
  DropdownEntity? _selectedBull; // Matches bull_id (optional, maps to Livestock.animal_id)
  DropdownEntity? _selectedBreed; // Matches breed_id (required, maps to breeds.id)
  DateTime? _collectionDate; // Matches collection_date (required)

  // --- Dropdown Data Storage ---
  List<DropdownEntity> _bulls = [];
  List<DropdownEntity> _breeds = [];

  @override
  void initState() {
    super.initState();
    // 💡 Dispatch event to load necessary dropdown data (Bulls and Breeds)
    context.read<SemenInventoryBloc>().add(const SemenLoadDropdowns());
  }

  @override
  void dispose() {
    _strawCodeController.dispose();
    _bullNameController.dispose();
    _bullTagController.dispose();
    _doseMlController.dispose();
    _motilityController.dispose();
    _costController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, AppLocalizations l10n) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _collectionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: l10n.selectCollectionDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: BreedingColors.semen,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _collectionDate) {
      setState(() {
        _collectionDate = picked;
      });
    }
  }

  // ⭐ CORE UPDATE: Form submission now dispatches the BLoC event
  void _submitForm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_collectionDate == null || _selectedBreed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllRequiredFields), backgroundColor: Colors.red),
      );
      return;
    }

    // 1. Build the SemenEntity from form data
    final newSemen = SemenEntity(
      id: 0, // ID is ignored for creation
      strawCode: _strawCodeController.text.trim(),
      bullId: _selectedBull != null ? int.tryParse(_selectedBull!.value) : null,
      bullName: _bullNameController.text.trim(),
      bullTag: _bullTagController.text.trim().isEmpty ? null : _bullTagController.text.trim(),
      breedId: int.tryParse(_selectedBreed!.value) ?? 0, // Ensure breedId is int
      collectionDate: _collectionDate!, // Non-nullable DateTime
      used: false, // Default for new straw
      costPerStraw: double.tryParse(_costController.text.trim()) ?? 0.0, // Non-nullable
      doseMl: double.tryParse(_doseMlController.text.trim()) ?? 0.0,     // Non-nullable
      motilityPercentage: int.tryParse(_motilityController.text.trim()),
      sourceSupplier: _sourceController.text.trim().isEmpty ? null : _sourceController.text.trim(),
      // Default values for list/stats fields
      bull: null,
      breed: null,
      inseminations: null,
      timesUsed: 0,
      successRate: '0%',
    );
    
    // 2. Dispatch the Create event
    context.read<SemenInventoryBloc>().add(SemenCreate(newSemen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final primaryColor = BreedingColors.semen;
    
    return BlocListener<SemenInventoryBloc, SemenState>(
      listener: (context, state) {
        // Handle submission success
        if (state is SemenActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          // Navigate back to the inventory list
          context.go('/farmer/breeding/semen'); 
        }
        // Handle submission error
        else if (state is SemenError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        // Handle dropdown loading errors (e.g., if SemenLoadDropdowns fails)
         else if (state is SemenLoadedDropdowns) {
            _bulls = state.bulls;
            _breeds = state.breeds;
          }
        
      },
      child: BlocBuilder<SemenInventoryBloc, SemenState>(
        builder: (context, state) {
          final isSubmitting = state is SemenLoading;
          
          if (state is SemenLoadedDropdowns) {
            _bulls = state.bulls;
            _breeds = state.breeds;
          }
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              title: Text(l10n.addSemen),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 1,
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  // Info Card (omitted for brevity, assume localization works)
                  // ...

                  // 1. Straw Code (required, unique)
                  TextFormField(
                    controller: _strawCodeController,
                    decoration: InputDecoration(
                      labelText: '${l10n.strawCode} *',
                      hintText: 'e.g., HOL-001',
                      prefixIcon: Icon(Icons.qr_code, color: primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.fieldRequired;
                      }
                      return null;
                    },
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // 2. Bull Name (required)
                  TextFormField(
                    controller: _bullNameController,
                    decoration: InputDecoration(
                      labelText: '${l10n.bullName} *',
                      hintText: 'e.g., Black Legend',
                      prefixIcon: Icon(Icons.pets, color: primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.fieldRequired;
                      }
                      return null;
                    },
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // 3. Breed Selection (required) - Uses loaded data
                  _buildBreedDropdownField(l10n, primaryColor, isSubmitting),
                  const SizedBox(height: 16),

                  // 4. Collection Date (required, date picker)
                  _buildDatePickerField(l10n, theme, formatter, primaryColor, isSubmitting),
                  const SizedBox(height: 16),
                  
                  Divider(height: 32, color: primaryColor.withOpacity(0.5)),
                  Text(l10n.optionalDetails, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),

                  // 5. Bull ID Selection (Optional) - Uses loaded data
                  _buildBullIdAndTagSection(l10n, primaryColor, isSubmitting),
                  const SizedBox(height: 16),

                  // 6. Dose and Motility (TextFields omitted for brevity, logic remains same)
                  // ... (Keep the Row for dose and motility from original code)
                  Row(
                    children: [
                      // Dose (dose_ml)
                      Expanded(
                        child: TextFormField(
                          controller: _doseMlController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '${l10n.dose} (ml)',
                            hintText: 'e.g., 0.25',
                            prefixIcon: Icon(Icons.water_drop, color: primaryColor),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                              return l10n.invalidNumber;
                            }
                            return null;
                          },
                          enabled: !isSubmitting,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Motility (motility_percentage)
                      Expanded(
                        child: TextFormField(
                          controller: _motilityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '${l10n.motility} (%)',
                            hintText: 'e.g., 75',
                            prefixIcon: Icon(Icons.insights, color: primaryColor),
                          ),
                          validator: (value) {
                            final int? motility = int.tryParse(value ?? '');
                            if (value != null && value.isNotEmpty && (motility == null || motility < 0 || motility > 100)) {
                              return l10n.invalidPercentage;
                            }
                            return null;
                          },
                          enabled: !isSubmitting,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7. Cost per Straw
                  TextFormField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.costPerStraw,
                      hintText: 'e.g., 1500',
                      prefixIcon: Icon(Icons.attach_money, color: primaryColor),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                        return l10n.invalidNumber;
                      }
                      return null;
                    },
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // 8. Source/Supplier
                  TextFormField(
                    controller: _sourceController,
                    decoration: InputDecoration(
                      labelText: l10n.sourceSupplier,
                      hintText: l10n.sourceSupplierHint ?? 'Source/Supplier (e.g., Kenya Genetics)',
                      prefixIcon: Icon(Icons.business, color: primaryColor),
                    ),
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton.icon(
                    onPressed: isSubmitting ? null : () => _submitForm(context),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isSubmitting ? l10n.saving : l10n.save.toUpperCase(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildDatePickerField(
    AppLocalizations l10n,
    ThemeData theme,
    DateFormat formatter,
    Color primaryColor,
    bool isSubmitting,
  ) {
    return InkWell(
      onTap: isSubmitting ? null : () => _selectDate(context, l10n),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '${l10n.collectionDate} *',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          _collectionDate == null
              ? l10n.selectDate 
              : formatter.format(_collectionDate!),
          style: theme.textTheme.titleMedium?.copyWith(
            color: _collectionDate == null ? Colors.grey.shade600 : Colors.black,
          ),
        ),
      ),
    );
  }

  // ⭐ UPDATED: Uses the loaded _breeds list
  Widget _buildBreedDropdownField(
    AppLocalizations l10n,
    Color primaryColor,
    bool isSubmitting,
  ) {
    return DropdownButtonFormField<DropdownEntity>(
      initialValue: _selectedBreed,
      decoration: InputDecoration(
        labelText: '${l10n.breed} *',
        prefixIcon: Icon(Icons.catching_pokemon, color: primaryColor),
      ),
      hint: Text(l10n.selectBreed),
      isExpanded: true,
      items: _breeds.map((breed) {
        return DropdownMenuItem(
          value: breed,
          child: Text(breed.label),
        );
      }).toList(),
      onChanged: isSubmitting ? null : (DropdownEntity? newValue) {
        setState(() {
          _selectedBreed = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return l10n.fieldRequired;
        }
        return null;
      },
    );
  }

  // ⭐ UPDATED: Uses the loaded _bulls list
  Widget _buildBullIdAndTagSection(
    AppLocalizations l10n,
    Color primaryColor,
    bool isSubmitting,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown for selecting owned bull (bull_id)
        DropdownButtonFormField<DropdownEntity>(
          initialValue: _selectedBull,
          decoration: InputDecoration(
            labelText: l10n.internalBullId,
            prefixIcon: Icon(Icons.male, color: primaryColor),
          ),
          hint: Text(l10n.selectOwnedBull),
          isExpanded: true,
          items: _bulls.map((bull) {
            return DropdownMenuItem(
              value: bull,
              child: Text(bull.label),
            );
          }).toList(),
          onChanged: isSubmitting ? null : (DropdownEntity? newValue) {
            setState(() {
              _selectedBull = newValue;
            });
          },
        ),
        
        const SizedBox(height: 16),

        // Bull Tag (bull_tag)
        TextFormField(
          controller: _bullTagController,
          decoration: InputDecoration(
            labelText: l10n.bullTag,
            hintText: 'e.g., 9005',
            prefixIcon: Icon(Icons.tag, color: primaryColor),
          ),
          enabled: !isSubmitting,
        ),
      ],
    );
  }
}