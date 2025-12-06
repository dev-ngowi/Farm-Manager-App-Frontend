import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Required for input formatters

// Assuming DetailedPregnancyCheck is accessible/defined in this file's scope
// For this example, we'll redefine the minimum required fields for clarity.
// In a real app, you would reuse the model from your detail page file.

class DetailedPregnancyCheck {
  final int id;
  final String checkDate;
  final String method;
  final String result;
  final int? fetusCount;
  final String? expectedDeliveryDate;
  final String notes;
  final int inseminationId;
  final String? vetId; // Store as string for dropdown value
  
  DetailedPregnancyCheck({
    required this.id,
    required this.checkDate,
    required this.method,
    required this.result,
    this.fetusCount,
    this.expectedDeliveryDate,
    this.notes = '',
    required this.inseminationId,
    this.vetId,
  });
}


class EditPregnancyCheckPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/pregnancy-checks/:id/edit';
  final int checkId;

  const EditPregnancyCheckPage({super.key, required this.checkId});

  @override
  State<EditPregnancyCheckPage> createState() => _EditPregnancyCheckPageState();
}

class _EditPregnancyCheckPageState extends State<EditPregnancyCheckPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _checkDateController = TextEditingController();
  final TextEditingController _fetusCountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // State variables for dropdowns
  late DetailedPregnancyCheck _initialData; // To hold fetched data
  String? _selectedInseminationId;
  String? _selectedMethod;
  String? _selectedResult;
  String? _selectedVetId;

  // Mock data for dropdowns (replace with API calls in real app)
  final List<String> _methods = ['Ultrasound', 'Palpation', 'Blood'];
  final List<String> _results = ['Pregnant', 'Not Pregnant', 'Reabsorbed'];
  
  final List<Map<String, String>> _mockVets = [
    {'id': '5', 'name': 'Dr. Mfumo'},
    {'id': '6', 'name': 'Dr. Langa'},
  ];
  
  @override
  void initState() {
    super.initState();
    // Simulate fetching existing data for the checkId
    _initialData = _fetchExistingData(widget.checkId);
    _populateFields();
  }
  
  @override
  void dispose() {
    _checkDateController.dispose();
    _fetusCountController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Mock Data Fetching (Replace with actual API call) ---
  DetailedPregnancyCheck _fetchExistingData(int id) {
    // Simulate API call to PregnancyCheckController@show
    return DetailedPregnancyCheck(
      id: id,
      checkDate: '2025-12-05', // YYYY-MM-DD from API
      method: 'Ultrasound',
      result: 'Pregnant',
      fetusCount: 2,
      expectedDeliveryDate: '2026-09-11', // YYYY-MM-DD from API
      notes: 'Twins confirmed, healthy heartbeat.',
      inseminationId: 101,
      vetId: '5', // Mocking existing vet ID
    );
  }

  // --- Populate Fields from Fetched Data ---
  void _populateFields() {
    final DateTime checkDate = DateFormat('yyyy-MM-dd').parse(_initialData.checkDate);
    final String formattedCheckDate = DateFormat('dd MMM yyyy').format(checkDate);
    
    _checkDateController.text = formattedCheckDate;
    _notesController.text = _initialData.notes;
    
    // Set Dropdowns
    _selectedInseminationId = _initialData.inseminationId.toString();
    _selectedMethod = _initialData.method;
    _selectedResult = _initialData.result;
    _selectedVetId = _initialData.vetId;
    
    // Set Conditional Fields
    if (_initialData.result == 'Pregnant') {
      _fetusCountController.text = _initialData.fetusCount.toString();
      if (_initialData.expectedDeliveryDate != null) {
        final DateTime dueDate = DateFormat('yyyy-MM-dd').parse(_initialData.expectedDeliveryDate!);
        _dueDateController.text = DateFormat('dd MMM yyyy').format(dueDate);
      }
    }
  }

  // --- Date Picker Helper ---
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty ? DateFormat('dd MMM yyyy').parse(controller.text) : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  // --- Submission Logic (Update) ---
  void _submitForm(AppLocalizations l10n) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final isPregnant = _selectedResult == 'Pregnant';
      
      // Data validation for conditional fields
      if (isPregnant) {
        if (_fetusCountController.text.isEmpty || _dueDateController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pregnantFieldsRequired)),
          );
          return;
        }
      }
      
      // Prepare data for API call (match backend keys)
      final apiPayload = {
        // Insemination ID should not change, but included for completeness if needed
        'insemination_id': int.tryParse(_selectedInseminationId!), 
        'check_date': DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(_checkDateController.text)),
        'method': _selectedMethod,
        'result': _selectedResult,
        // Send null if not pregnant, or the count if pregnant
        'fetus_count': isPregnant ? int.tryParse(_fetusCountController.text) : null,
        'expected_delivery_date': isPregnant
            ? DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(_dueDateController.text))
            : null,
        'vet_id': _selectedVetId != null ? int.tryParse(_selectedVetId!) : null,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };
      
      print('Updating Check ID: ${widget.checkId} with Data: $apiPayload');
      
      // TODO: Implement actual API call (e.g., PUT or PATCH to /pregnancy-checks/{id})
      
      // Simulate success and navigate back
      context.pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = BreedingColors.pregnancy;

    final isPregnant = _selectedResult == 'Pregnant';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.editPregnancyCheck} #${widget.checkId}'), // Assuming this key exists
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
              // --- 1. Check Date (Required) ---
              _buildSectionHeader(l10n.checkDate, Icons.calendar_today, primaryColor),
              _buildDateField(l10n.checkDate, _checkDateController, primaryColor),
              const SizedBox(height: 20),

              // --- 2. Check Method (Required) ---
              _buildSectionHeader(l10n.method, Icons.straighten, primaryColor),
              _buildMethodDropdown(l10n, primaryColor),
              const SizedBox(height: 20),

              // --- 3. Check Result (Required) ---
              _buildSectionHeader(l10n.result, Icons.favorite_border, primaryColor),
              _buildResultDropdown(l10n, primaryColor),
              const SizedBox(height: 20),

              // --- 4. Conditional Fields (Fetus Count & Due Date) ---
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (isPregnant && (value == null || value.isEmpty)) {
                      return l10n.fieldRequired;
                    }
                    if (value != null && int.tryParse(value) == null && isPregnant) {
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
              
              // --- 5. Technician (Optional) ---
              _buildSectionHeader(l10n.technician, Icons.person_pin, primaryColor),
              _buildVetDropdown(l10n, primaryColor),
              const SizedBox(height: 20),

              // --- 6. Notes (Optional) ---
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

              // --- 7. Save Button ---
              ElevatedButton.icon(
                onPressed: () => _submitForm(l10n),
                icon: const Icon(Icons.save),
                label: Text(l10n.saveChanges), // Assuming this key exists
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
  
  // --- Reusable Widget Builders (Copied from Add Page) ---

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

  Widget _buildMethodDropdown(AppLocalizations l10n, Color color) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.method,
        prefixIcon: Icon(Icons.straighten, color: color),
        border: const OutlineInputBorder(),
      ),
      value: _selectedMethod,
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
      value: _selectedResult,
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
          // Clear conditional fields if the result changes away from 'Pregnant'
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
      value: _selectedVetId,
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
    );
  }
}

// --- L10N Update Reminder ---
/* Remember to add these keys to your l10n.json file:
* "editPregnancyCheck"
* "saveChanges"
*/