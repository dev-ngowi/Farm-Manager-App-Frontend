import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Added for input formatting, though not strictly used in current TextFields

class AddOffspringPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/offspring/store';

  const AddOffspringPage({super.key});

  @override
  State<AddOffspringPage> createState() => _AddOffspringPageState();
}

class _AddOffspringPageState extends State<AddOffspringPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = BreedingColors.offspring;

  // Form Field State
  int? _selectedDeliveryId; // Corresponds to delivery_id
  String? _temporaryTag;
  String? _gender; // Required: Male, Female, Unknown
  double? _birthWeightKg; // Required, numeric
  String? _birthCondition; // Required: Vigorous, Weak, Stillborn
  String? _colostrumIntake; // Required: Adequate, Partial, Insufficient, None
  bool _navelTreated = false; // Required, boolean
  String? _notes;

  // Mock Delivery Options (In a real app, this would be fetched from /api/farmer/deliveries)
  final List<Map<String, dynamic>> _mockDeliveries = [
    {'id': 50, 'label': 'Delivery - COW-101 (2025-09-10)'},
    {'id': 51, 'label': 'Delivery - EWE-203 (2025-12-05)'},
    {'id': 52, 'label': 'Delivery - DOE-312 (2025-12-01)'},
  ];

  // Options for Dropdowns/Radio Buttons
  final List<String> _genderOptions = ['Male', 'Female', 'Unknown'];
  final List<String> _conditionOptions = ['Vigorous', 'Weak', 'Stillborn'];
  final List<String> _colostrumOptions = ['Adequate', 'Partial', 'Insufficient', 'None'];

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Data to be sent to OffspringController@store
      final payload = {
        'delivery_id': _selectedDeliveryId,
        'temporary_tag': _temporaryTag,
        'gender': _gender,
        'birth_weight_kg': _birthWeightKg,
        'birth_condition': _birthCondition,
        'colostrum_intake': _colostrumIntake,
        'navel_treated': _navelTreated,
        'notes': _notes,
      };

      // --- Mock API Call ---
      print('Submitting Offspring Data: $payload');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savingOffspring)),
      );
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

      // On Success: Pop page and optionally show success message on previous screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.offspringRecordSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  // Helper function to translate static options (if l10n supports it)
  String _translateOption(String key, AppLocalizations l10n) {
    // This is a placeholder for actual l10n implementation
    // For now, it just returns the key.
    return key; 
  }

  // --- Widget Builders ---

  Widget _buildDropdown<T>({
    required String label, 
    required T? value, 
    required List<T> options, 
    required String? Function(T?) validator, 
    required void Function(T?) onSaved,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white, // Replaced AppColors.cardBackground
        ),
        initialValue: value,
        hint: Text(l10n.select),
        isExpanded: true,
        items: options.map((T option) {
          final displayLabel = option is String 
              ? _translateOption(option, l10n) 
              : option.toString();
              
          // Handle the delivery ID case separately to show the label
          if (option is int && options == _mockDeliveries.map((e) => e['id'] as int).toList()) {
            final delivery = _mockDeliveries.firstWhere((e) => e['id'] == option);
            return DropdownMenuItem<T>(
              value: option,
              child: Text(delivery['label'] as String),
            );
          }

          return DropdownMenuItem<T>(
            value: option,
            child: Text(displayLabel),
          );
        }).toList(),
        onChanged: (T? newValue) {
          setState(() {
            onSaved(newValue); // Update the state immediately
          });
        },
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white, // Replaced AppColors.cardBackground
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordOffspring),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Section: Link to Delivery ---
              Text(
                l10n.selectDeliveryContext,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
              ),
              const SizedBox(height: 12),
              _buildDropdown<int>(
                label: l10n.delivery,
                value: _selectedDeliveryId,
                options: _mockDeliveries.map((e) => e['id'] as int).toList(),
                validator: (val) => val == null ? l10n.fieldRequired : null,
                onSaved: (val) => _selectedDeliveryId = val,
              ),

              // --- Section: Offspring Identification ---
              const SizedBox(height: 16),
              Text(
                l10n.identification,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
              ),
              const SizedBox(height: 12),
              
              _buildTextFormField(
                label: l10n.temporaryTag,
                onSaved: (val) => _temporaryTag = val,
                validator: (val) => null, // Optional field
                keyboardType: TextInputType.text,
              ),

              // --- Section: Birth Metrics ---
              const SizedBox(height: 16),
              Text(
                l10n.birthMetrics,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
              ),
              const SizedBox(height: 12),

              _buildDropdown<String>(
                label: l10n.gender,
                value: _gender,
                options: _genderOptions,
                validator: (val) => val == null ? l10n.fieldRequired : null,
                onSaved: (val) => _gender = val,
              ),

              _buildTextFormField(
                label: l10n.birthWeightKg,
                onSaved: (val) {
                  if (val != null && double.tryParse(val) != null) {
                    _birthWeightKg = double.parse(val);
                  }
                },
                validator: (val) {
                  if (val == null || val.isEmpty) return l10n.fieldRequired;
                  if (double.tryParse(val) == null || double.parse(val) <= 0) {
                    return l10n.enterValidWeight;
                  }
                  return null;
                },
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),

              _buildDropdown<String>(
                label: l10n.birthCondition,
                value: _birthCondition,
                options: _conditionOptions,
                validator: (val) => val == null ? l10n.fieldRequired : null,
                onSaved: (val) => _birthCondition = val,
              ),

              _buildDropdown<String>(
                label: l10n.colostrumIntake,
                value: _colostrumIntake,
                options: _colostrumOptions,
                validator: (val) => val == null ? l10n.fieldRequired : null,
                onSaved: (val) => _colostrumIntake = val,
              ),

              // --- Navel Treatment Switch ---
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: SwitchListTile(
                  title: Text(l10n.navelTreated),
                  value: _navelTreated,
                  onChanged: (bool value) {
                    setState(() {
                      _navelTreated = value;
                    });
                  },
                  activeThumbColor: primaryColor,
                  tileColor: Colors.grey.shade50, // Replaced AppColors.cardBackground
                ),
              ),

              // --- Section: Notes ---
              const SizedBox(height: 16),
              Text(
                l10n.additionalNotes,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
              ),
              const SizedBox(height: 12),
              
              _buildTextFormField(
                label: l10n.notes,
                onSaved: (val) => _notes = val,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),

              // --- Save Button ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.save),
                    label: Text(l10n.saveOffspring),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}