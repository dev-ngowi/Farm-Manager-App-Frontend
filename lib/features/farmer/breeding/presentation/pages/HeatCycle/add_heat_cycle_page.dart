import 'package:farm_manager_app/core/config/app_theme.dart';
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

  final List<String> _intensityOptions = [
    'Weak',
    'Moderate',
    'Strong',
    'Standing Heat'
  ];

  @override
  void initState() {
    super.initState();
    _loadLivestock();
  }

  void _loadLivestock() {
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
      setState(() => _observedDate = picked);
    }
  }

  void _saveHeatCycle() {
    if (_formKey.currentState!.validate()) {
      if (_observedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectDate),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_selectedAnimal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.animalRequired),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final token = _getAuthToken();
      final damModel = DamModel(
        animalId: _selectedAnimal!.animalId.toString(),
        tagNumber: _selectedAnimal!.tagNumber,
        name: _selectedAnimal!.name ?? 'Unknown',
        species: _selectedAnimal!.species?.speciesName ?? 'Unknown',
      );

      final newHeatCycle = HeatCycleModel(
        id: '',
        damId: _selectedAnimalId!,
        dam: damModel,
        observedDate: _observedDate!,
        intensity: _selectedIntensity!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        inseminated: false,
      );

      context.read<HeatCycleBloc>().add(
            CreateHeatCycleEvent(cycle: newHeatCycle, token: token),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.recordHeatCycle,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<HeatCycleBloc, HeatCycleState>(
            listener: (context, state) {
              if (state is HeatCycleSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.go('/farmer/breeding/heat-cycles');
              } else if (state is HeatCycleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Record Heat Cycle',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track heat cycle observations for female animals',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Form Fields
                    _buildFormSection(l10n, theme, formatter, isSubmitting),

                    const SizedBox(height: 24),

                    // Save Button
                    _buildSaveButton(l10n, isSubmitting),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormSection(
    AppLocalizations l10n,
    ThemeData theme,
    DateFormat formatter,
    bool isSubmitting,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Heat Cycle Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Animal Selection
          _buildAnimalDropdownField(l10n, theme, isSubmitting),
          const SizedBox(height: 12),

          // Date Picker
          _buildDatePickerField(l10n, theme, formatter, isSubmitting),
          const SizedBox(height: 12),

          // Intensity
          _buildIntensityDropdownField(l10n, theme, isSubmitting),
          const SizedBox(height: 12),

          // Notes
          _buildNotesField(l10n, isSubmitting),
        ],
      ),
    );
  }

  Widget _buildAnimalDropdownField(
    AppLocalizations l10n,
    ThemeData theme,
    bool isSubmitting,
  ) {
    return BlocBuilder<LivestockBloc, LivestockState>(
      builder: (context, state) {
        List<LivestockEntity> femaleAnimals = [];

        if (state is LivestockListLoaded) {
          femaleAnimals = state.livestock
              .where((animal) => animal.sex.toLowerCase() == 'female')
              .toList();
        }

        if (state is LivestockLoading) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.female, color: BreedingColors.heat, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Loading animals...'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (femaleAnimals.isEmpty) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orange[300]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No female animals available. Please add female animals first.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.female, color: BreedingColors.heat, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l10n.selectAnimal,
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    initialValue: _selectedAnimalId,
                    hint: Text(l10n.chooseAnimal),
                    items: femaleAnimals.map((animal) {
                      return DropdownMenuItem<String>(
                        value: animal.animalId.toString(),
                        child: Text(
                          "${animal.name ?? 'Unknown'} (${animal.tagNumber})",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: isSubmitting
                        ? null
                        : (String? newValue) {
                            setState(() {
                              _selectedAnimalId = newValue;
                              _selectedAnimal = femaleAnimals.firstWhere(
                                (animal) =>
                                    animal.animalId.toString() == newValue,
                              );
                            });
                          },
                    validator: (value) {
                      if (value == null) return l10n.animalRequired;
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePickerField(
    AppLocalizations l10n,
    ThemeData theme,
    DateFormat formatter,
    bool isSubmitting,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isSubmitting ? null : () => _selectDate(context, l10n),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: BreedingColors.heat, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.observedDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _observedDate == null
                          ? l10n.selectDate
                          : formatter.format(_observedDate!),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _observedDate == null
                            ? Colors.grey[400]
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntensityDropdownField(
    AppLocalizations l10n,
    ThemeData theme,
    bool isSubmitting,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.bolt, color: BreedingColors.heat, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.heatIntensity,
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                initialValue: _selectedIntensity,
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
                        Icon(icon, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(
                          intensity,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: isSubmitting
                    ? null
                    : (String? newValue) {
                        setState(() => _selectedIntensity = newValue);
                      },
                validator: (value) {
                  if (value == null) return l10n.intensityRequired;
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField(AppLocalizations l10n, bool isSubmitting) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: _notesController,
          enabled: !isSubmitting,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.notes,
            hintText: l10n.notesPlaceholder,
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n, bool isSubmitting) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isSubmitting ? null : _saveHeatCycle,
          style: ElevatedButton.styleFrom(
            backgroundColor: BreedingColors.heat,
            disabledBackgroundColor: BreedingColors.heat.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  l10n.save.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}