// add_heat_cycle_page.dart

import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/data/models/heat_cycle_model.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_event.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddHeatCyclePage extends StatefulWidget {
  static const String routeName = 'add-heat-cycle';

  const AddHeatCyclePage({super.key});

  @override
  State<AddHeatCyclePage> createState() => _AddHeatCyclePageState();
}

class _AddHeatCyclePageState extends State<AddHeatCyclePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAnimalId;
  LivestockEntity? _selectedAnimal;
  DateTime? _observedDate;
  String? _selectedIntensity;
  final TextEditingController _notesController = TextEditingController();

  // Intensity options from the backend
  final List<String> _intensityOptions = [
    'Weak',
    'Moderate',
    'Strong',
    'Standing Heat'
  ];

  @override
  void initState() {
    super.initState();
    // Load livestock when page opens
    _loadLivestock();
  }

  void _loadLivestock() {
    // FIXED: Use LoadLivestockList event with empty filters
    context.read<LivestockBloc>().add(const LoadLivestockList(filters: {}));
  }

  String _getAuthToken() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return authState.user.token ?? '';
    }
    return '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, AppLocalizations l10n) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _observedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: l10n.selectObservedDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: BreedingColors.heat,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _observedDate) {
      setState(() {
        _observedDate = picked;
      });
    }
  }

  void _saveHeatCycle() {
    if (_formKey.currentState!.validate()) {
      if (_observedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // FIXED: Use existing localization key
            content: Text(AppLocalizations.of(context)!.selectDate),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedAnimal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.animalRequired),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final token = _getAuthToken();
      
      // FIXED: Create DamModel with correct type conversions
      final damModel = DamModel(
        animalId: _selectedAnimal!.animalId.toString(), // Convert int to String
        tagNumber: _selectedAnimal!.tagNumber,
        name: _selectedAnimal!.name ?? 'Unknown', // Handle nullable name
        species: _selectedAnimal!.species?.speciesName ?? 'Unknown', // Extract species name
      );

      // Create HeatCycleModel for API submission
      final newHeatCycle = HeatCycleModel(
        id: '', // Will be assigned by backend
        damId: _selectedAnimalId!,
        dam: damModel,
        observedDate: _observedDate!,
        intensity: _selectedIntensity!,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        inseminated: false,
      );

      print('📤 Submitting Heat Cycle:');
      print('   Dam ID: ${newHeatCycle.damId}');
      print('   Date: ${newHeatCycle.observedDate}');
      print('   Intensity: ${newHeatCycle.intensity}');
      print('   Notes: ${newHeatCycle.notes}');

      // Dispatch create event
      context.read<HeatCycleBloc>().add(
        CreateHeatCycleEvent(
          cycle: newHeatCycle,
          token: token,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordHeatCycle),
        backgroundColor: BreedingColors.heat,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen to HeatCycle creation success/error
          BlocListener<HeatCycleBloc, HeatCycleState>(
            listener: (context, state) {
              if (state is HeatCycleSuccess) {
                print('✅ Heat Cycle Created Successfully!');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate back to heat cycles list
                context.go('/farmer/breeding/heat-cycles');
              } else if (state is HeatCycleError) {
                print('❌ Error Creating Heat Cycle: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: () {},
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<HeatCycleBloc, HeatCycleState>(
          builder: (context, heatCycleState) {
            final isSubmitting = heatCycleState is HeatCycleLoading;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  // Info Card
                  Card(
                    color: BreedingColors.heat.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: BreedingColors.heat,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Record heat cycle observations for female animals',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Animal Selection Dropdown
                  _buildAnimalDropdownField(l10n, theme),
                  const SizedBox(height: 16),

                  // Observed Date Picker
                  _buildDatePickerField(l10n, theme, formatter),
                  const SizedBox(height: 16),

                  // Intensity Dropdown
                  _buildIntensityDropdownField(l10n, theme),
                  const SizedBox(height: 16),

                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: l10n.notes,
                      hintText: l10n.notesPlaceholder,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 4,
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton.icon(
                    onPressed: isSubmitting ? null : _saveHeatCycle,
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isSubmitting ? l10n.saving : l10n.save.toUpperCase(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BreedingColors.heat,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimalDropdownField(AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<LivestockBloc, LivestockState>(
      builder: (context, state) {
        // Filter for female animals only (dams)
        List<LivestockEntity> femaleAnimals = [];
        
        // FIXED: Use LivestockListLoaded instead of LivestockLoaded
        if (state is LivestockListLoaded) {
          // CHANGE: state.animals to state.livestock
          femaleAnimals = state.livestock 
              .where((animal) => 
                animal.sex.toLowerCase() == 'female') // Note: Using animal.sex from LivestockEntity
              .toList();
        }

        if (state is LivestockLoading) {
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: l10n.selectAnimal,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.pets, color: BreedingColors.heat),
            ),
            hint: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Loading animals...'),
              ],
            ),
            items: const [],
            onChanged: null,
          );
        }

        if (femaleAnimals.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.selectAnimal,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.pets, color: BreedingColors.heat),
                ),
                hint: Text(l10n.noFemaleAnimalsAvailable ?? 'No female animals'),
                items: const [],
                onChanged: null,
              ),
              const SizedBox(height: 8),
              Text(
                'Please add female animals to your livestock first.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
              ),
            ],
          );
        }

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.selectAnimal,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.pets, color: BreedingColors.heat),
          ),
          value: _selectedAnimalId,
          hint: Text(l10n.chooseAnimal),
          items: femaleAnimals.map((animal) {
            return DropdownMenuItem<String>(
              // FIXED: Convert animalId to String
              value: animal.animalId.toString(),
              child: Text("${animal.name ?? 'Unknown'} (${animal.tagNumber})"),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedAnimalId = newValue;
              _selectedAnimal = femaleAnimals.firstWhere(
                (animal) => animal.animalId.toString() == newValue,
              );
            });
          },
          validator: (value) {
            if (value == null) {
              return l10n.animalRequired;
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildIntensityDropdownField(AppLocalizations l10n, ThemeData theme) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.heatIntensity,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.flash_on, color: BreedingColors.heat),
      ),
      value: _selectedIntensity,
      hint: Text(l10n.selectIntensity),
      items: _intensityOptions.map((intensity) {
        IconData icon;
        Color color;
        
        switch (intensity) {
          case 'Weak':
            icon = Icons.flash_on_outlined;
            color = Colors.orange.shade300;
            break;
          case 'Moderate':
            icon = Icons.flash_on;
            color = Colors.orange.shade600;
            break;
          case 'Strong':
            icon = Icons.bolt;
            color = Colors.deepOrange;
            break;
          case 'Standing Heat':
            icon = Icons.whatshot;
            color = BreedingColors.heat;
            break;
          default:
            icon = Icons.flash_on;
            color = Colors.grey;
        }
        
        return DropdownMenuItem<String>(
          value: intensity,
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(intensity),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedIntensity = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return l10n.intensityRequired;
        }
        return null;
      },
    );
  }

  Widget _buildDatePickerField(
    AppLocalizations l10n,
    ThemeData theme,
    DateFormat formatter,
  ) {
    return InkWell(
      onTap: () => _selectDate(context, l10n),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.observedDate,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today, color: BreedingColors.heat),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          _observedDate == null
              ? l10n.selectDate
              : formatter.format(_observedDate!),
          style: theme.textTheme.titleMedium?.copyWith(
            color: _observedDate == null ? Colors.grey.shade600 : Colors.black,
          ),
        ),
      ),
    );
  }
}