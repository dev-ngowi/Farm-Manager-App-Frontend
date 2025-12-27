import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/dropdown_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditSemenPage extends StatefulWidget {
  final String semenId;
  static const String routeName = 'edit-semen';

  const EditSemenPage({super.key, required this.semenId});

  @override
  State<EditSemenPage> createState() => _EditSemenPageState();
}

class _EditSemenPageState extends State<EditSemenPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _strawCodeController = TextEditingController();
  final TextEditingController _bullNameController = TextEditingController();
  final TextEditingController _bullTagController = TextEditingController();
  final TextEditingController _doseMlController = TextEditingController();
  final TextEditingController _motilityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  // State Values
  DropdownEntity? _selectedBull;
  DropdownEntity? _selectedBreed;
  DateTime? _collectionDate;

  // Dropdown Data
  List<DropdownEntity> _bulls = [];
  List<DropdownEntity> _breeds = [];

  bool _isInitialized = false;
  bool _dropdownsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  void _loadDetails() {
    context.read<SemenInventoryBloc>().add(const SemenLoadDropdowns());
    context.read<SemenInventoryBloc>().add(SemenLoadDetails(widget.semenId));
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
      setState(() => _collectionDate = picked);
    }
  }

  void _updateSemen() {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_collectionDate == null || _selectedBreed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fillAllRequiredFields),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updatedSemen = SemenEntity(
      id: int.parse(widget.semenId),
      strawCode: _strawCodeController.text.trim(),
      bullId: _selectedBull != null ? int.tryParse(_selectedBull!.value) : null,
      bullName: _bullNameController.text.trim(),
      bullTag: _bullTagController.text.trim().isEmpty
          ? null
          : _bullTagController.text.trim(),
      breedId: int.tryParse(_selectedBreed!.value) ?? 0,
      collectionDate: _collectionDate!,
      used: false,
      costPerStraw: double.tryParse(_costController.text.trim()) ?? 0.0,
      doseMl: double.tryParse(_doseMlController.text.trim()) ?? 0.0,
      motilityPercentage: int.tryParse(_motilityController.text.trim()),
      sourceSupplier: _sourceController.text.trim().isEmpty
          ? null
          : _sourceController.text.trim(),
      bull: null,
      breed: null,
      inseminations: null,
      timesUsed: 0,
      successRate: '0%',
    );

    context.read<SemenInventoryBloc>().add(
      SemenUpdate(id: widget.semenId, semen: updatedSemen)
    );
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
          l10n.editSemen ?? 'Edit Semen',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<SemenInventoryBloc, SemenState>(
        listener: (context, state) {
          if (state is SemenActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/farmer/breeding/semen/${widget.semenId}');
          } else if (state is SemenError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is SemenLoadedDropdowns) {
            setState(() {
              _bulls = state.bulls;
              _breeds = state.breeds;
              _dropdownsLoaded = true;
            });
          } else if (state is SemenLoadedDetails && _dropdownsLoaded && !_isInitialized) {
            final semen = state.semen;
            setState(() {
              _strawCodeController.text = semen.strawCode;
              _bullNameController.text = semen.bullName;
              _bullTagController.text = semen.bullTag ?? '';
              _doseMlController.text = semen.doseMl.toString() ?? '';
              _motilityController.text = semen.motilityPercentage?.toString() ?? '';
              _costController.text = semen.costPerStraw.toString();
              _sourceController.text = semen.sourceSupplier ?? '';
              _collectionDate = semen.collectionDate;

              // Set breed
              if (_breeds.isNotEmpty) {
                _selectedBreed = _breeds.firstWhere(
                  (b) => int.tryParse(b.value) == semen.breedId,
                  orElse: () => _breeds.first,
                );
              }

              // Set bull if exists
              if (semen.bullId != null && _bulls.isNotEmpty) {
                try {
                  _selectedBull = _bulls.firstWhere(
                    (b) => int.tryParse(b.value) == semen.bullId,
                  );
                } catch (e) {
                  _selectedBull = null;
                }
              }

              _isInitialized = true;
            });
          }
        },
        builder: (context, state) {
          // Show loading while waiting for both dropdowns AND details
          if (!_dropdownsLoaded || !_isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading semen details...'),
                ],
              ),
            );
          }

          if (state is SemenError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Data',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadDetails,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BreedingColors.semen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final isSubmitting = state is SemenLoading;

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
                          'Edit Semen Straw',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Update semen straw information',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Required Information Section
                  _buildRequiredSection(l10n, formatter, isSubmitting),

                  const SizedBox(height: 16),

                  // Optional Information Section
                  _buildOptionalSection(l10n, isSubmitting),

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
    );
  }

  Widget _buildRequiredSection(
    AppLocalizations l10n,
    DateFormat formatter,
    bool isSubmitting,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _buildTextFieldCard(
            controller: _strawCodeController,
            label: l10n.strawCode,
            hint: 'e.g., HOL-001',
            icon: Icons.qr_code,
            color: BreedingColors.semen,
            isSubmitting: isSubmitting,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.fieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          _buildTextFieldCard(
            controller: _bullNameController,
            label: l10n.bullName,
            hint: 'e.g., Black Legend',
            icon: Icons.pets,
            color: BreedingColors.semen,
            isSubmitting: isSubmitting,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.fieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          _buildBreedDropdownField(l10n, isSubmitting),
          const SizedBox(height: 12),

          _buildDatePickerField(l10n, formatter, isSubmitting),
        ],
      ),
    );
  }

  Widget _buildOptionalSection(AppLocalizations l10n, bool isSubmitting) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optional Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _buildBullDropdownField(l10n, isSubmitting),
          const SizedBox(height: 12),

          _buildTextFieldCard(
            controller: _bullTagController,
            label: l10n.bullTag,
            hint: 'e.g., 9005',
            icon: Icons.tag,
            color: BreedingColors.semen,
            isSubmitting: isSubmitting,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTextFieldCard(
                  controller: _doseMlController,
                  label: '${l10n.dose} (ml)',
                  hint: 'e.g., 0.25',
                  icon: Icons.water_drop,
                  color: BreedingColors.semen,
                  keyboardType: TextInputType.number,
                  isSubmitting: isSubmitting,
                  validator: (value) {
                    if (value != null && 
                        value.isNotEmpty && 
                        double.tryParse(value) == null) {
                      return l10n.invalidNumber;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextFieldCard(
                  controller: _motilityController,
                  label: '${l10n.motility} (%)',
                  hint: 'e.g., 75',
                  icon: Icons.insights,
                  color: BreedingColors.semen,
                  keyboardType: TextInputType.number,
                  isSubmitting: isSubmitting,
                  validator: (value) {
                    final int? motility = int.tryParse(value ?? '');
                    if (value != null && 
                        value.isNotEmpty && 
                        (motility == null || 
                         motility < 0 || 
                         motility > 100)) {
                      return l10n.invalidPercentage;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildTextFieldCard(
            controller: _costController,
            label: l10n.costPerStraw,
            hint: 'e.g., 1500',
            icon: Icons.attach_money,
            color: BreedingColors.semen,
            keyboardType: TextInputType.number,
            isSubmitting: isSubmitting,
            validator: (value) {
              if (value != null && 
                  value.isNotEmpty && 
                  double.tryParse(value) == null) {
                return l10n.invalidNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          _buildTextFieldCard(
            controller: _sourceController,
            label: l10n.sourceSupplier,
            hint: l10n.sourceSupplierHint ?? 'Source/Supplier',
            icon: Icons.business,
            color: BreedingColors.semen,
            isSubmitting: isSubmitting,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    required bool isSubmitting,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: !isSubmitting,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
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
                validator: validator,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
    AppLocalizations l10n,
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
              Icon(Icons.calendar_today, color: BreedingColors.semen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.collectionDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _collectionDate == null
                          ? l10n.selectDate
                          : formatter.format(_collectionDate!),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _collectionDate == null
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

  Widget _buildBreedDropdownField(
    AppLocalizations l10n,
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
            Icon(Icons.catching_pokemon, color: BreedingColors.semen, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<DropdownEntity>(
                initialValue: _selectedBreed,
                decoration: InputDecoration(
                  labelText: l10n.breed,
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                hint: Text(l10n.selectBreed),
                isExpanded: true,
                items: _breeds.map((breed) {
                  return DropdownMenuItem(
                    value: breed,
                    child: Text(
                      breed.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullDropdownField(
    AppLocalizations l10n,
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
            Icon(Icons.male, color: BreedingColors.semen, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<DropdownEntity>(
                initialValue: _selectedBull,
                decoration: InputDecoration(
                  labelText: l10n.internalBullId,
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                hint: Text(l10n.selectOwnedBull),
                isExpanded: true,
                items: _bulls.map((bull) {
                  return DropdownMenuItem(
                    value: bull,
                    child: Text(
                      bull.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: isSubmitting ? null : (DropdownEntity? newValue) {
                  setState(() {
                    _selectedBull = newValue;
                  });
                },
              ),
            ),
          ],
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
          onPressed: isSubmitting ? null : _updateSemen,
          style: ElevatedButton.styleFrom(
            backgroundColor: BreedingColors.semen,
            disabledBackgroundColor: BreedingColors.semen.withOpacity(0.6),
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
              : const Text(
                  'SAVE CHANGES',
                  style: TextStyle(
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