import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- Reusing Mock Data Models from Add/Detail Pages ---
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

// Data model for pre-filling the form (subset of DetailedInsemination)
class InseminationFormModel {
  final int id;
  final int damId;
  final String breedingMethod;
  final int heatCycleId;
  final DateTime inseminationDate;
  final String notes;
  final int? sireId;
  final int? semenId;

  InseminationFormModel({
    required this.id,
    required this.damId,
    required this.breedingMethod,
    required this.heatCycleId,
    required this.inseminationDate,
    required this.notes,
    this.sireId,
    this.semenId,
  });
}
// -----------------------------------------------------------

class EditInseminationPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/inseminations/:id/edit';
  final int inseminationId;

  const EditInseminationPage({super.key, required this.inseminationId});

  @override
  State<EditInseminationPage> createState() => _EditInseminationPageState();
}

class _EditInseminationPageState extends State<EditInseminationPage> {
  final _formKey = GlobalKey<FormState>();

  // --- Mock Dropdown Data ---
  // In a real app, these would be fetched from separate API endpoints
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
  
  // --- Form State ---
  InseminationFormModel? _initialData;
  bool _isLoading = true;

  // Form Field State Variables
  String? _breedingMethod;
  Livestock? _selectedDam;
  Livestock? _selectedSire;
  Semen? _selectedSemen;
  HeatCycle? _selectedHeatCycle;
  DateTime _inseminationDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInseminationData();
  }

  // --- Mock Data Fetching (Simulates calling the backend 'show' method) ---
  void _fetchInseminationData() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock the data returned by the backend 'show' method for a single item (ID 1)
    final mockJson = {
      'id': widget.inseminationId,
      'dam_id': 101, // Example: Cow 101
      'insemination_date': '2025-12-02',
      'breeding_method': 'AI', // Current breeding method
      'heat_cycle_id': 10,
      'semen_id': 1, // Current semen straw
      'sire_id': null,
      'notes': 'First-time AI, monitored closely for success.',
    };

    final data = InseminationFormModel(
      id: mockJson['id'] as int,
      damId: mockJson['dam_id'] as int,
      breedingMethod: mockJson['breeding_method'] as String,
      heatCycleId: mockJson['heat_cycle_id'] as int,
      inseminationDate: DateTime.parse(mockJson['insemination_date'] as String),
      notes: mockJson['notes'] as String,
      sireId: mockJson['sire_id'] as int?,
      semenId: mockJson['semen_id'] as int?,
    );
    
    // Set initial state based on fetched data
    setState(() {
      _initialData = data;
      
      // 1. Set simple strings/dates
      _breedingMethod = data.breedingMethod;
      _inseminationDate = data.inseminationDate;
      _notesController.text = data.notes;
      
      // 2. Set dropdown values by matching IDs
      _selectedDam = _mockDams.firstWhere((d) => d.id == data.damId);
      _selectedHeatCycle = _mockHeatCycles.firstWhere((h) => h.id == data.heatCycleId);
      
      if (data.breedingMethod == 'Natural' && data.sireId != null) {
        _selectedSire = _mockSires.firstWhere((s) => s.id == data.sireId);
      } else if (data.breedingMethod == 'AI' && data.semenId != null) {
        _selectedSemen = _mockSemenInventory.firstWhere((s) => s.id == data.semenId);
      }
      
      _isLoading = false;
    });
  }

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
        // Only send fields that can be updated based on your backend 'update' method
        'sire_id': _breedingMethod == 'Natural' ? _selectedSire?.id : null,
        'semen_id': _breedingMethod == 'AI' ? _selectedSemen?.id : null,
        'insemination_date': DateFormat('yyyy-MM-dd').format(_inseminationDate),
        // Note: The backend update method does NOT allow changing dam_id or breeding_method
        // but it does allow changing status and expected_delivery_date (which aren't on this form yet)
        'notes': _notesController.text,
      };

      // TODO: Implement API call to your backend 'update' endpoint (PUT/PATCH)
      print('Update Data Sent to API for ID ${widget.inseminationId}: $formData');
      
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editInsemination), backgroundColor: primaryColor, foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.editInsemination} #${widget.inseminationId}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // --- 1. DAM Display (Cannot be changed based on your backend update method) ---
            _buildDisplayField(
              label: l10n.dam, 
              value: '${_selectedDam!.name} #${_selectedDam!.tagNumber}', 
              icon: Icons.pets
            ),

            // --- 2. Heat Cycle Display (Cannot be changed) ---
            _buildDisplayField(
              label: l10n.heatCycle, 
              value: 'Heat Date: ${_selectedHeatCycle!.date}', 
              icon: Icons.local_fire_department
            ),

            // --- 3. Breeding Method Display (Cannot be changed) ---
            _buildDisplayField(
              label: l10n.breedingMethod, 
              value: _breedingMethod!, 
              icon: Icons.merge_type
            ),

            const SizedBox(height: 16),
            
            // --- 4. SIRE / SEMEN Selection (Conditional Required) ---
            if (_breedingMethod == 'Natural')
              _buildDropdownField<Livestock>(
                label: l10n.sire,
                value: _selectedSire,
                items: _mockSires,
                hint: l10n.selectSire,
                onChanged: (Livestock? newValue) {
                  setState(() => _selectedSire = newValue);
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
                  setState(() => _selectedSemen = newValue);
                },
                validator: (value) => value == null ? l10n.requiredField : null,
                itemBuilder: (item) => '${item.bullName} (${item.strawCode})',
              ),
            
            // --- 5. Insemination Date (Editable) ---
            _buildDatePickerField(l10n, theme, primaryColor),
            
            // --- 6. Notes (Editable) ---
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
              child: Text(l10n.saveChanges.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDisplayField({required String label, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        child: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
        ),
      ),
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
          prefixIcon: const Icon(Icons.male),
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