import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddLactationPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/lactations/add';

  const AddLactationPage({super.key});

  @override
  State<AddLactationPage> createState() => _AddLactationPageState();
}

class _AddLactationPageState extends State<AddLactationPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = BreedingColors.lactation;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Form Field State
  int? _selectedDamId;
  String? _startDate;
  String? _peakDate;
  String? _dryOffDate;
  double? _totalMilkKg;
  int? _daysInMilk;
  String _status = 'Ongoing'; // Default status for a new lactation

  // Controllers for date fields
  late TextEditingController _startDateController;
  late TextEditingController _peakDateController;
  late TextEditingController _dryOffDateController;

  // Mock Dam Options (In a real app, this would be fetched from /api/farmer/livestock)
  final List<Map<String, dynamic>> _mockDams = [
    {'id': 101, 'tag': 'COW-101', 'name': 'Daisy'},
    {'id': 102, 'tag': 'COW-102', 'name': 'Bess'},
    {'id': 205, 'tag': 'GOAT-205', 'name': 'Gretchen'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize date controllers, defaulting start date to today
    _startDate = _dateFormat.format(DateTime.now());
    _startDateController = TextEditingController(text: _startDate);
    _peakDateController = TextEditingController();
    _dryOffDateController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _peakDateController.dispose();
    _dryOffDateController.dispose();
    super.dispose();
  }

  // --- Form Handlers ---
  Future<void> _selectDate(BuildContext context, TextEditingController controller, {String? minDateString}) async {
    DateTime initialDate = controller.text.isNotEmpty 
        ? DateTime.parse(controller.text)
        : DateTime.now();

    DateTime firstDate = minDateString != null 
        ? DateTime.parse(minDateString)
        : DateTime(DateTime.now().year - 5); // Allow up to 5 years past

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)), 
    );

    if (picked != null) {
      setState(() {
        final formattedDate = _dateFormat.format(picked);
        controller.text = formattedDate;
        
        // Update the state variable if it's the start date
        if (controller == _startDateController) {
          _startDate = formattedDate;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Data to be sent to LactationController@store
      final payload = {
        'dam_id': _selectedDamId,
        'start_date': _startDate,
        'peak_date': _peakDate,
        'dry_off_date': _dryOffDate,
        // Only include if value is not null and valid
        if (_totalMilkKg != null && _totalMilkKg! >= 0) 'total_milk_kg': _totalMilkKg,
        if (_daysInMilk != null && _daysInMilk! >= 0) 'days_in_milk': _daysInMilk,
        'status': _status, 
      };

      // --- Mock API Call ---
      debugPrint('Submitting New Lactation Data: $payload');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savingLactation)),
      );
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

      // On Success: Pop page and optionally show success message on previous screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.lactationRecordSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  // --- Widget Builders ---
  Widget _buildDamDropdown(AppLocalizations l10n) {
    final List<int> damIds = _mockDams.map((e) => e['id'] as int).toList();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: l10n.dam,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.pets, color: primaryColor),
        ),
        value: _selectedDamId,
        hint: Text(l10n.selectDam),
        isExpanded: true,
        items: damIds.map((int id) {
          final dam = _mockDams.firstWhere((e) => e['id'] == id);
          final label = '${dam['tag']} (${dam['name']})';
          return DropdownMenuItem<int>(
            value: id,
            child: Text(label),
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _selectedDamId = newValue;
          });
        },
        validator: (val) => val == null ? l10n.fieldRequired : null,
      ),
    );
  }

  Widget _buildDateField(
    AppLocalizations l10n, 
    String label, 
    TextEditingController controller, 
    String? minDateString,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: l10n.selectDate,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, controller, minDateString: minDateString),
          ),
        ),
        validator: (value) {
          if (label == l10n.startDate && (value == null || value.isEmpty)) {
            return l10n.fieldRequired;
          }
          if (value != null && value.isNotEmpty) {
            try {
              DateTime selectedDate = DateTime.parse(value);
              if (minDateString != null) {
                DateTime minDate = DateTime.parse(minDateString);
                if (selectedDate.isBefore(minDate)) {
                    return l10n.dateAfterStartDateError;
                }
              }
            } catch (_) {
               return l10n.invalidDateError;
            }
          }
          return null;
        },
        onSaved: (value) {
          if (controller == _peakDateController) _peakDate = value;
          if (controller == _dryOffDateController) _dryOffDate = value;
        },
      ),
    );
  }

  Widget _buildNumericField({
    required String label,
    required String hintText,
    required Function(String?) onSaved,
    bool isInteger = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: isInteger 
            ? TextInputType.number 
            : const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(isInteger ? Icons.access_time : Icons.local_drink, color: primaryColor),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return null; // Optional
          
          if (isInteger) {
            if (int.tryParse(value) == null) return l10n.invalidIntegerError;
            if (int.parse(value) < 0) return l10n.mustBePositiveError;
          } else {
            if (double.tryParse(value) == null) return l10n.invalidNumberError;
            if (double.parse(value) < 0) return l10n.mustBePositiveError;
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Determine the minimum selectable date for peak/dry-off based on the current start date
    final minFollowUpDate = _startDate; 

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordLactation),
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
              // --- Section: Dam Selection ---
              Text(
                l10n.animalInformation,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
              ),
              const SizedBox(height: 12),
              _buildDamDropdown(l10n),
              
              // --- Section: Key Dates ---
              const SizedBox(height: 16),
              Text(
                l10n.keyDates,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
              ),
              const SizedBox(height: 12),
              
              _buildDateField(l10n, l10n.startDate, _startDateController, null), // Start Date has no min date restriction (except global 5 year rule)
              
              _buildDateField(l10n, l10n.peakDate, _peakDateController, minFollowUpDate),
              
              _buildDateField(l10n, l10n.dryOffDate, _dryOffDateController, minFollowUpDate),

              // --- Section: Initial Metrics (Optional on creation) ---
              const SizedBox(height: 16),
              Text(
                l10n.initialMetrics,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
              ),
              const SizedBox(height: 12),
              
              _buildNumericField(
                label: l10n.totalMilkKg,
                hintText: '0.0',
                onSaved: (val) {
                  if (val != null && double.tryParse(val) != null) {
                    _totalMilkKg = double.parse(val);
                  }
                },
                isInteger: false,
              ),

              _buildNumericField(
                label: l10n.daysInMilk,
                hintText: '0',
                onSaved: (val) {
                  if (val != null && int.tryParse(val) != null) {
                    _daysInMilk = int.parse(val);
                  }
                },
                isInteger: true,
              ),

              // Note: Status defaults to 'Ongoing' and is typically not changed here.
              // If you wanted to allow setting status, you'd add a dropdown here.
              
              // --- Save Button ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.save),
                    label: Text(l10n.recordLactation.toUpperCase()),
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