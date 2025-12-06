import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
// Replace these mocks with your actual models and BLoC imports
// import 'package:farm_manager_app/features/farmer/breeding/data/models/semen_model.dart'; 
// import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/Semen/semen_bloc.dart';
// import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/Semen/semen_event.dart';
// import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/Semen/semen_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Keep BLoC import for future use
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --------------------------------------------------------------------------
// --- Placeholder/Mock Data Definitions (Replace with actual Domain/Data Models) ---
// --------------------------------------------------------------------------

class MockAnimal {
  final int id;
  final String tagNumber;
  final String name;
  const MockAnimal(this.id, this.tagNumber, this.name);
}

class MockBreed {
  final int id;
  final String name;
  const MockBreed(this.id, this.name);
}

class SemenDetail {
  final int id;
  final String strawCode;
  final String bullName;
  final String bullTag;
  final int breedId;
  final DateTime collectionDate;
  final double? doseMl;
  final int? motilityPercentage;
  final double costPerStraw;
  final String? sourceSupplier;
  final int? bullId;

  const SemenDetail({
    required this.id,
    required this.strawCode,
    required this.bullName,
    required this.bullTag,
    required this.breedId,
    required this.collectionDate,
    this.doseMl,
    this.motilityPercentage,
    required this.costPerStraw,
    this.sourceSupplier,
    this.bullId,
  });
}

// Mock SemenModel for update payload (simplistic representation)
class SemenModel {
    final int id;
    final String strawCode;
    final int? bullId;
    final String? bullTag;
    final String bullName;
    final int breedId;
    final DateTime collectionDate;
    final double? doseMl;
    final int? motilityPercentage;
    final double? costPerStraw;
    final String? sourceSupplier;
    
    const SemenModel({
        required this.id,
        required this.strawCode,
        this.bullId,
        this.bullTag,
        required this.bullName,
        required this.breedId,
        required this.collectionDate,
        this.doseMl,
        this.motilityPercentage,
        this.costPerStraw,
        this.sourceSupplier,
    });
}

// --------------------------------------------------------------------------
// --- Edit Semen Page Implementation ---
// --------------------------------------------------------------------------

class EditSemenPage extends StatefulWidget {
  final String semenId;

  const EditSemenPage({super.key, required this.semenId});

  @override
  State<EditSemenPage> createState() => _EditSemenPageState();
}

class _EditSemenPageState extends State<EditSemenPage> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final TextEditingController _strawCodeController = TextEditingController();
  final TextEditingController _bullNameController = TextEditingController();
  final TextEditingController _bullTagController = TextEditingController();
  final TextEditingController _doseMlController = TextEditingController();
  final TextEditingController _motilityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  // --- State Values ---
  int? _existingSemenId; // The ID of the record being updated
  MockAnimal? _selectedBull;
  MockBreed? _selectedBreed;
  DateTime? _collectionDate;

  // --- Mock Data Lists ---
  final List<MockBreed> _mockBreeds = [
    const MockBreed(1, 'Holstein'),
    const MockBreed(2, 'Angus'),
    const MockBreed(3, 'Jersey'),
  ];
  final List<MockAnimal> _mockBulls = [
    const MockAnimal(101, 'BULL-001', 'King'),
    const MockAnimal(102, 'BULL-002', 'Titan'),
    const MockAnimal(103, 'BULL-003', 'Rambo'),
  ];

  @override
  void initState() {
    super.initState();
    // In a real application, you would dispatch a LoadSemenDetailEvent here:
    // context.read<SemenBloc>().add(LoadSemenDetailEvent(semenId: widget.semenId));

    // For presentation design, we use mock data to populate fields immediately
    _loadInitialData();
  }

  void _loadInitialData() {
    // Mock Fetch
    final existingData = _getMockSemenDetail(widget.semenId);

    _existingSemenId = existingData.id;

    _strawCodeController.text = existingData.strawCode;
    _bullNameController.text = existingData.bullName;
    _bullTagController.text = existingData.bullTag;

    if (existingData.doseMl != null) {
      _doseMlController.text = existingData.doseMl.toString();
    }
    if (existingData.motilityPercentage != null) {
      _motilityController.text = existingData.motilityPercentage.toString();
    }
    _costController.text = existingData.costPerStraw.toString();
    _sourceController.text = existingData.sourceSupplier ?? '';

    _collectionDate = existingData.collectionDate;

    // Set dropdowns based on IDs
    _selectedBreed = _mockBreeds.firstWhere(
      (b) => b.id == existingData.breedId,
      orElse: () => _mockBreeds.first,
    );
    if (existingData.bullId != null) {
      _selectedBull = _mockBulls.firstWhere(
        (b) => b.id == existingData.bullId,
        orElse: () => _mockBulls.first,
      );
    }
  }

  // Placeholder for fetching initial data
  SemenDetail _getMockSemenDetail(String id) {
    return SemenDetail(
      id: int.parse(id),
      strawCode: 'HOL-007-OLD',
      bullName: 'Mock Bull Alpha',
      bullTag: '9005',
      breedId: 1, // Holstein
      collectionDate: DateTime(2023, 10, 20),
      doseMl: 0.5,
      motilityPercentage: 80,
      costPerStraw: 1200.00,
      sourceSupplier: 'FarmGenetics',
      bullId: 101, // King
    );
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

  void _updateSemen() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_collectionDate == null || _selectedBreed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.fillAllRequiredFields),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Construct Semen Model for submission
    final updatedSemen = SemenModel(
      id: _existingSemenId!, // Required for update
      strawCode: _strawCodeController.text.trim(),
      bullId: _selectedBull?.id,
      bullTag: _bullTagController.text.trim().isEmpty
          ? null
          : _bullTagController.text.trim(),
      bullName: _bullNameController.text.trim(),
      breedId: _selectedBreed!.id,
      collectionDate: _collectionDate!,
      doseMl: double.tryParse(_doseMlController.text.trim() == '' ? '0' : _doseMlController.text.trim()),
      motilityPercentage: int.tryParse(_motilityController.text.trim() == '' ? '0' : _motilityController.text.trim()),
      costPerStraw: double.tryParse(_costController.text.trim() == '' ? '0' : _costController.text.trim()),
      sourceSupplier: _sourceController.text.trim().isEmpty
          ? null
          : _sourceController.text.trim(),
    );

    // In a real application:
    // context.read<SemenBloc>().add(UpdateSemenEvent(semen: updatedSemen, token: _getToken()));

    // --- Presentation Simulation ---
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Updating record ID: ${_existingSemenId}'),
          backgroundColor: BreedingColors.semen),
    );
    // Simulate navigation back to detail page
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final DateFormat formatter =
        DateFormat.yMMMd(Localizations.localeOf(context).toString());

    final primaryColor = BreedingColors.semen;

    // Simulating Bloc State for loading/submitting
    const bool isLoading = false; // Replace with BlocBuilder check

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(l10n.editSemen), // New L10n key: editSemen
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        // Replace with BlocBuilder<SemenBloc, SemenState> later
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // Info Card
            Card(
              color: primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.semenEditInfo ??
                            'Modify the details below and save your changes.', // New L10n key: semenEditInfo
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

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
              enabled: !isLoading,
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
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),

            // 3. Breed Selection (required)
            _buildBreedDropdownField(l10n, primaryColor, isLoading),
            const SizedBox(height: 16),

            // 4. Collection Date (required, date picker)
            _buildDatePickerField(l10n, theme, formatter, primaryColor, isLoading),
            const SizedBox(height: 16),

            Divider(height: 32, color: primaryColor.withOpacity(0.5)),
            Text(l10n.optionalDetails, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            // 5. Bull ID Selection & Bull Tag
            _buildBullIdAndTagSection(l10n, primaryColor, isLoading),
            const SizedBox(height: 16),

            // 6. Dose and Motility
            Row(
              children: [
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
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return l10n.invalidNumber;
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                ),
                const SizedBox(width: 16),
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
                      if (value != null &&
                          value.isNotEmpty &&
                          (motility == null || motility < 0 || motility > 100)) {
                        return l10n.invalidPercentage;
                      }
                      return null;
                    },
                    enabled: !isLoading,
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
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null) {
                  return l10n.invalidNumber;
                }
                return null;
              },
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),

            // 8. Source/Supplier
            TextFormField(
              controller: _sourceController,
              decoration: InputDecoration(
                labelText: l10n.sourceSupplier,
                hintText: l10n.sourceSupplierHint ?? 'Source/Supplier',
                prefixIcon: Icon(Icons.business, color: primaryColor),
              ),
              enabled: !isLoading,
            ),
            const SizedBox(height: 32),

            // Save/Update Button
            ElevatedButton.icon(
              onPressed: isLoading ? null : _updateSemen,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(
                isLoading
                    ? l10n.saving
                    : l10n.update.toUpperCase(), // New L10n key: update
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
  }

  // --- Reusable Widget Builders (from AddSemenPage) ---

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

  Widget _buildBreedDropdownField(
    AppLocalizations l10n,
    Color primaryColor,
    bool isSubmitting,
  ) {
    return DropdownButtonFormField<MockBreed>(
      value: _selectedBreed,
      decoration: InputDecoration(
        labelText: '${l10n.breed} *',
        prefixIcon: Icon(Icons.catching_pokemon, color: primaryColor),
      ),
      hint: Text(l10n.selectBreed),
      isExpanded: true,
      items: _mockBreeds.map((breed) {
        return DropdownMenuItem(
          value: breed,
          child: Text(breed.name),
        );
      }).toList(),
      onChanged: isSubmitting
          ? null
          : (MockBreed? newValue) {
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

  Widget _buildBullIdAndTagSection(
    AppLocalizations l10n,
    Color primaryColor,
    bool isSubmitting,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<MockAnimal>(
          value: _selectedBull,
          decoration: InputDecoration(
            labelText: l10n.internalBullId,
            prefixIcon: Icon(Icons.male, color: primaryColor),
          ),
          hint: Text(l10n.selectOwnedBull),
          isExpanded: true,
          items: _mockBulls.map((bull) {
            return DropdownMenuItem(
              value: bull,
              child: Text('${bull.tagNumber} (${bull.name})'),
            );
          }).toList(),
          onChanged: isSubmitting
              ? null
              : (MockAnimal? newValue) {
                  setState(() {
                    _selectedBull = newValue;
                  });
                },
        ),
        const SizedBox(height: 16),
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