import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Assume this page is reached via /pregnancy-checks/add. 
// If it were reached via /inseminations/123/check/add, we'd pass the inseminationId.
// For simplicity, this design assumes the user will select the Insemination ID.
// In a real app, this selection would likely be a dropdown/search field.

class AddPregnancyCheckPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/pregnancy-checks/add';

  const AddPregnancyCheckPage({super.key});

  @override
  State<AddPregnancyCheckPage> createState() => _AddPregnancyCheckPageState();
}

class _AddPregnancyCheckPageState extends State<AddPregnancyCheckPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _checkDateController = TextEditingController();
  final TextEditingController _fetusCountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // State variables for dropdowns
  String? _selectedInseminationId; // Insemination ID to link the check to
  String? _selectedMethod; // Ultrasound, Palpation, Blood
  String? _selectedResult; // Pregnant, Not Pregnant, Reabsorbed
  String? _selectedVetId; // Vet ID (Technician)

  // Mock data for dropdowns (replace with API calls in real app)
  final List<String> _methods = ['Ultrasound', 'Palpation', 'Blood'];
  final List<String> _results = ['Pregnant', 'Not Pregnant', 'Reabsorbed'];
  
  // Mock Inseminations (ID, Dam Tag)
  final List<Map<String, String>> _mockInseminations = [
    {'id': '101', 'tag': 'Cow #101'},
    {'id': '102', 'tag': 'Cow #115'},
    {'id': '103', 'tag': 'Heifer #503'},
  ];
  
  // Mock Vets (ID, Name)
  final List<Map<String, String>> _mockVets = [
    {'id': '5', 'name': 'Dr. Mfumo'},
    {'id': '6', 'name': 'Dr. Langa'},
  ];

  @override
  void initState() {
    super.initState();
    // Set default check date to today
    _checkDateController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _checkDateController.dispose();
    _fetusCountController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Date Picker Helper ---
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  // --- Submission Logic ---
  void _submitForm(AppLocalizations l10n) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Data validation for conditional fields
      if (_selectedResult == 'Pregnant') {
        if (_fetusCountController.text.isEmpty || _dueDateController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pregnantFieldsRequired)), // Assuming this key exists
          );
          return;
        }
      }
      
      // Prepare data for API call (match backend keys)
      final apiPayload = {
        'insemination_id': int.tryParse(_selectedInseminationId!),
        'check_date': DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(_checkDateController.text)),
        'method': _selectedMethod,
        'result': _selectedResult,
        'fetus_count': _selectedResult == 'Pregnant' ? int.tryParse(_fetusCountController.text) : null,
        'expected_delivery_date': _selectedResult == 'Pregnant' 
            ? DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(_dueDateController.text))
            : null,
        'vet_id': _selectedVetId != null ? int.tryParse(_selectedVetId!) : null,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };
      
      print('Submitting Check Data: $apiPayload');
      
      // TODO: Implement actual API call (e.g., using a repository/cubit)
      
      // Simulate success and navigate back
      context.pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = BreedingColors.pregnancy;

    // Check if the result is 'Pregnant' to show conditional fields
    final isPregnant = _selectedResult == 'Pregnant';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addPregnancyCheck), // Assuming this key exists
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- 1. Insemination ID Selector (Required) ---
              _buildSectionHeader(l10n.relatedInsemination, Icons.vaccines, primaryColor),
              _buildInseminationDropdown(l10n, primaryColor),
              const SizedBox(height: 20),

              // --- 2. Check Date (Required) ---
              _buildSectionHeader(l10n.checkDate, Icons.calendar_today, primaryColor),
              _buildDateField(l10n.checkDate, _checkDateController, primaryColor),
              const SizedBox(height: 20),

              // --- 3. Check Method (Required) ---
              _buildSectionHeader(l10n.method, Icons.straighten, primaryColor),
              _buildMethodDropdown(l10n, primaryColor),
              const SizedBox(height: 20),

              // --- 4. Check Result (Required) ---
              _buildSectionHeader(l10n.result, Icons.favorite_border, primaryColor),
              _buildResultDropdown(l10n, primaryColor),
              const SizedBox(height: 20),

              // --- 5. Conditional Fields (Fetus Count & Due Date) ---
              if (isPregnant) ...[
                _buildSectionHeader(l10n.pregnancyDetails, Icons.baby_changing_station, primaryColor),
                
                // Fetus Count
                TextFormField(
                  controller: _fetusCountController,
                  decoration: InputDecoration(
                    labelText: l10n.fetusCount,
                    prefixIcon: const Icon(Icons.numbers),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (isPregnant && (value == null || value.isEmpty)) {
                      return l10n.fieldRequired;
                    }
                    if (value != null && int.tryParse(value) == null) {
                       return l10n.invalidNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Expected Delivery Date (Due Date)
                _buildDateField(l10n.dueDate, _dueDateController, primaryColor, isRequired: isPregnant),
                const SizedBox(height: 20),
              ],
              
              // --- 6. Technician (Optional) ---
              _buildSectionHeader(l10n.technician, Icons.person_pin, primaryColor),
              _buildVetDropdown(l10n, primaryColor),
              const SizedBox(height: 20),

              // --- 7. Notes (Optional) ---
              _buildSectionHeader(l10n.notes, Icons.description, primaryColor),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 32),

              // --- 8. Submit Button ---
              ElevatedButton.icon(
                onPressed: () => _submitForm(l10n),
                icon: const Icon(Icons.save),
                label: Text(l10n.saveCheck), // Assuming this key exists
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // --- Reusable Widget Builders ---

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, Color color, {bool isRequired = true}) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.date_range, color: color),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: const OutlineInputBorder(),
      ),
      onTap: () => _selectDate(context, controller),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return l10n.fieldRequired;
        }
        return null;
      },
    );
  }

  Widget _buildInseminationDropdown(AppLocalizations l10n, Color color) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.inseminations,
        prefixIcon: Icon(Icons.pets, color: color),
        border: const OutlineInputBorder(),
      ),
      initialValue: _selectedInseminationId,
      hint: Text(l10n.selectInsemination),
      items: _mockInseminations.map((item) {
        return DropdownMenuItem(
          value: item['id'],
          child: Text('ID #${item['id']} (${item['tag']})'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedInseminationId = value;
        });
      },
      validator: (value) => value == null ? l10n.fieldRequired : null,
    );
  }

  Widget _buildMethodDropdown(AppLocalizations l10n, Color color) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.method,
        prefixIcon: Icon(Icons.straighten, color: color),
        border: const OutlineInputBorder(),
      ),
      initialValue: _selectedMethod,
      hint: Text(l10n.selectMethod),
      items: _methods.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Text(method),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMethod = value;
        });
      },
      validator: (value) => value == null ? l10n.fieldRequired : null,
    );
  }

  Widget _buildResultDropdown(AppLocalizations l10n, Color color) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.result,
        prefixIcon: Icon(Icons.favorite_border, color: color),
        border: const OutlineInputBorder(),
      ),
      initialValue: _selectedResult,
      hint: Text(l10n.selectResult),
      items: _results.map((result) {
        return DropdownMenuItem(
          value: result,
          child: Text(result),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedResult = value;
          // Reset conditional fields if the result changes away from 'Pregnant'
          if (value != 'Pregnant') {
            _fetusCountController.clear();
            _dueDateController.clear();
          }
        });
      },
      validator: (value) => value == null ? l10n.fieldRequired : null,
    );
  }

  Widget _buildVetDropdown(AppLocalizations l10n, Color color) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.technician,
        prefixIcon: Icon(Icons.person_pin, color: color),
        border: const OutlineInputBorder(),
      ),
      initialValue: _selectedVetId,
      hint: Text(l10n.selectTechnician),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.notRecorded, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
        ..._mockVets.map((vet) {
          return DropdownMenuItem(
            value: vet['id'],
            child: Text(vet['name']!),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() {
          _selectedVetId = value;
        });
      },
      // This field is nullable in the backend, so no required validator needed
    );
  }
}

