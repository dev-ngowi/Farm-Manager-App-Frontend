import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Assuming you have these models or view models for dropdown data
class Livestock {
  final int id;
  final String tagNumber;
  final String name;
  Livestock(this.id, this.tagNumber, this.name);
}

class Semen {
  final int id;
  final String strawCode;
  final String bullName;
  Semen(this.id, this.strawCode, this.bullName);
}

class HeatCycle {
  final int id;
  final String date;
  HeatCycle(this.id, this.date);
}

class AddInseminationPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/inseminations/add';

  const AddInseminationPage({super.key});

  @override
  State<AddInseminationPage> createState() => _AddInseminationPageState();
}

class _AddInseminationPageState extends State<AddInseminationPage> {
  final _formKey = GlobalKey<FormState>();
  
  // --- Form Data State ---
  String? _breedingMethod = 'AI'; // Default to AI
  Livestock? _selectedDam;
  Livestock? _selectedSire; // Used for Natural breeding
  Semen? _selectedSemen; // Used for AI breeding
  HeatCycle? _selectedHeatCycle;
  DateTime _inseminationDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  // --- Mock Dropdown Data ---
  final List<Livestock> _mockDams = [
    Livestock(101, '101', 'Cow'),
    Livestock(115, '115', 'Cow'),
    Livestock(503, '503', 'Heifer'),
  ];
  final List<Livestock> _mockSires = [
    Livestock(10, '10', 'Bull'),
    Livestock(20, '20', 'Bull'),
  ];
  final List<Semen> _mockSemenInventory = [
    Semen(1, 'A901', 'Champion Bull'),
    Semen(2, 'B772', 'Elite Sire'),
    Semen(3, 'C453', 'Top Producer'),
  ];
  final List<HeatCycle> _mockHeatCycles = [
    HeatCycle(10, '2025-11-29'),
    HeatCycle(20, '2025-11-20'),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // --- Form Logic ---
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Data structure ready to be sent to the backend API:
      final formData = {
        'dam_id': _selectedDam!.id,
        'breeding_method': _breedingMethod,
        'heat_cycle_id': _selectedHeatCycle!.id,
        'insemination_date': DateFormat('yyyy-MM-dd').format(_inseminationDate),
        'technician_id': null, // Assuming you'll add technician selection later
        'notes': _notesController.text,
      };

      if (_breedingMethod == 'Natural') {
        formData['sire_id'] = _selectedSire!.id;
      } else {
        formData['semen_id'] = _selectedSemen!.id;
      }

      // TODO: Implement API call to your backend 'store' endpoint
      print('Form Data Submitted: $formData');
      
      // Navigate back or show success message
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _inseminationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Cannot be a future date
    );
    if (picked != null && picked != _inseminationDate) {
      setState(() {
        _inseminationDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = BreedingColors.insemination;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordInsemination),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // --- 1. DAM Selection (Required) ---
            _buildDropdownField<Livestock>(
              label: l10n.dam,
              value: _selectedDam,
              items: _mockDams,
              hint: l10n.selectDam,
              onChanged: (Livestock? newValue) {
                setState(() {
                  _selectedDam = newValue;
                });
              },
              validator: (value) => value == null ? l10n.requiredField : null,
              itemBuilder: (item) => '${item.name} #${item.tagNumber}',
            ),
            
            // --- 2. Heat Cycle Selection (Required) ---
            _buildDropdownField<HeatCycle>(
              label: l10n.heatCycle,
              value: _selectedHeatCycle,
              items: _mockHeatCycles.where((cycle) => _selectedDam != null).toList(), // Filter cycles based on selected dam in real implementation
              hint: l10n.selectHeatCycle,
              onChanged: (HeatCycle? newValue) {
                setState(() {
                  _selectedHeatCycle = newValue;
                });
              },
              validator: (value) => value == null ? l10n.requiredField : null,
              itemBuilder: (item) => 'Heat Date: ${item.date}',
            ),

            // --- 3. Breeding Method (Required) ---
            _buildMethodSelector(l10n, primaryColor),
            const SizedBox(height: 16),

            // --- 4. SIRE / SEMEN Selection (Conditional Required) ---
            if (_breedingMethod == 'Natural')
              _buildDropdownField<Livestock>(
                label: l10n.sire,
                value: _selectedSire,
                items: _mockSires,
                hint: l10n.selectSire,
                onChanged: (Livestock? newValue) {
                  setState(() {
                    _selectedSire = newValue;
                  });
                },
                validator: (value) => value == null ? l10n.requiredField : null,
                itemBuilder: (item) => '${item.name} #${item.tagNumber}',
              )
            else if (_breedingMethod == 'AI')
              _buildDropdownField<Semen>(
                label: l10n.semenStraw,
                value: _selectedSemen,
                items: _mockSemenInventory,
                hint: l10n.selectSemen,
                onChanged: (Semen? newValue) {
                  setState(() {
                    _selectedSemen = newValue;
                  });
                },
                validator: (value) => value == null ? l10n.requiredField : null,
                itemBuilder: (item) => '${item.bullName} (${item.strawCode})',
              ),
            
            // --- 5. Insemination Date (Required) ---
            _buildDatePickerField(l10n, theme, primaryColor),

            // --- 6. Technician (Optional) ---
            // TODO: Add technician selection field here
            
            // --- 7. Notes (Optional) ---
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notes,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 32),
            
            // --- Submit Button ---
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(l10n.recordInsemination.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildMethodSelector(AppLocalizations l10n, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(l10n.breedingMethod, style: Theme.of(context).textTheme.titleSmall),
        ),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Text(l10n.natural),
                selected: _breedingMethod == 'Natural',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _breedingMethod = 'Natural';
                      _selectedSemen = null; // Clear semen if switching to Natural
                    });
                  }
                },
                selectedColor: primaryColor.withOpacity(0.2),
                backgroundColor: Colors.grey.shade100,
                side: BorderSide(
                    color: _breedingMethod == 'Natural' ? primaryColor : Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: Text(l10n.ai),
                selected: _breedingMethod == 'AI',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _breedingMethod = 'AI';
                      _selectedSire = null; // Clear sire if switching to AI
                    });
                  }
                },
                selectedColor: primaryColor.withOpacity(0.2),
                backgroundColor: Colors.grey.shade100,
                side: BorderSide(
                    color: _breedingMethod == 'AI' ? primaryColor : Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
      AppLocalizations l10n, ThemeData theme, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: l10n.inseminationDate,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          child: Text(
            DateFormat('dd MMMM yyyy').format(_inseminationDate),
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
  
  // Generic Dropdown Field Helper
  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T?> onChanged,
    required String? Function(T?) validator,
    required String Function(T) itemBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.pets),
        ),
        value: value,
        isExpanded: true,
        items: items.map<DropdownMenuItem<T>>((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemBuilder(item)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}