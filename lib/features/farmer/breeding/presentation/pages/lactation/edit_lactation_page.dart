import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Reusing Model for Lactation Details ---
class LactationDetailData {
  final int id;
  final String damTag;
  final String damName;
  final String startDate;
  final String? peakDate;
  final String? dryOffDate;
  final double totalMilkKg;
  final int daysInMilk;
  final String status;

  LactationDetailData({
    required this.id,
    required this.damTag,
    required this.damName,
    required this.startDate,
    this.peakDate,
    this.dryOffDate,
    required this.totalMilkKg,
    required this.daysInMilk,
    required this.status,
  });
}

class EditLactationPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/lactations/:id/edit';
  final int lactationId;

  const EditLactationPage({super.key, required this.lactationId});

  @override
  State<EditLactationPage> createState() => _EditLactationPageState();
}

class _EditLactationPageState extends State<EditLactationPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = BreedingColors.lactation;

  bool _isLoading = true;
  LactationDetailData? _initialData;

  // Form Field Controllers and State
  late TextEditingController _peakDateController;
  late TextEditingController _dryOffDateController;
  late TextEditingController _totalMilkController;
  late TextEditingController _daysInMilkController;
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // --- Data Loading (Mock API) ---
  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = _fetchMockData(widget.lactationId);
    
    _initialData = data;
    _status = data.status;

    _peakDateController = TextEditingController(text: data.peakDate);
    _dryOffDateController = TextEditingController(text: data.dryOffDate);
    _totalMilkController = TextEditingController(text: data.totalMilkKg.toStringAsFixed(1));
    _daysInMilkController = TextEditingController(text: data.daysInMilk.toString());
    
    setState(() {
      _isLoading = false;
    });
  }
  
  // Mock API Response
  LactationDetailData _fetchMockData(int id) {
    switch (id) {
      case 1:
        return LactationDetailData(
          id: 1,
          damTag: 'COW-101',
          damName: 'Daisy',
          startDate: '2025-09-10',
          peakDate: '2025-10-15',
          dryOffDate: null,
          totalMilkKg: 2450.5,
          daysInMilk: 95,
          status: 'Ongoing',
        );
      case 3:
        return LactationDetailData(
          id: 3,
          damTag: 'GOAT-205',
          damName: 'Gretchen',
          startDate: '2024-10-01',
          peakDate: '2024-11-20',
          dryOffDate: '2025-04-01',
          totalMilkKg: 180.2,
          daysInMilk: 183,
          status: 'Completed',
        );
      default:
        return LactationDetailData(
          id: id,
          damTag: 'ANIMAL-999',
          damName: 'Unknown',
          startDate: '2025-01-01',
          peakDate: '2025-02-01',
          dryOffDate: null,
          totalMilkKg: 1500.0,
          daysInMilk: 300,
          status: 'Ongoing',
        );
    }
  }

  // --- Form Handlers ---
  Future<void> _selectDate(BuildContext context, TextEditingController controller, {required String startDate}) async {
    DateTime initialDate = controller.text.isNotEmpty 
        ? DateTime.parse(controller.text)
        : DateTime.now();

    // Ensure the selected date is not before the lactation start date
    DateTime firstDate = DateTime.parse(startDate);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate, // Min date is the start date of the lactation
      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow up to a year in the future for projections
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _saveLactation() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Collect updated data
      final updatedData = {
        'peak_date': _peakDateController.text.isNotEmpty ? _peakDateController.text : null,
        'dry_off_date': _dryOffDateController.text.isNotEmpty ? _dryOffDateController.text : null,
        'total_milk_kg': double.tryParse(_totalMilkController.text),
        'days_in_milk': int.tryParse(_daysInMilkController.text),
        'status': _status,
      };

      // In a real app, send updatedData to the API via your service layer
      debugPrint('Lactation ID ${widget.lactationId} saved: $updatedData');

      // Navigate back to the detail page (or previous screen)
      context.pop(); 
    }
  }
  
  @override
  void dispose() {
    _peakDateController.dispose();
    _dryOffDateController.dispose();
    _totalMilkController.dispose();
    _daysInMilkController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editLactation),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final initialData = _initialData!;
    final damLabel = '${initialData.damTag} (${initialData.damName})';
    final startDate = initialData.startDate;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.editLactation} - $damLabel'),
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
              // --- Status & Start Date Info ---
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  '${l10n.lactationStarted}: ${DateFormat.yMMMd().format(DateTime.parse(startDate))}',
                  style: theme.textTheme.titleMedium,
                ),
              ),

              // --- Status Dropdown ---
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.status,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle, color: primaryColor),
                ),
                value: _status,
                items: ['Ongoing', 'Completed'].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status == 'Ongoing' ? l10n.ongoing : l10n.completed),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue;
                  });
                },
                validator: (value) => value == null ? l10n.statusRequired : null,
              ),
              const SizedBox(height: 20),

              // --- Peak Date Field ---
              TextFormField(
                controller: _peakDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.peakDate,
                  hintText: l10n.selectDate,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.trending_up),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _peakDateController, startDate: startDate),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Simple date validation (more complex logic is handled by date picker minimum)
                    try {
                      DateTime selectedDate = DateTime.parse(value);
                      if (selectedDate.isBefore(DateTime.parse(startDate))) {
                          return l10n.dateAfterStartDateError;
                      }
                    } catch (_) {
                       return l10n.invalidDateError;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Dry Off Date Field ---
              TextFormField(
                controller: _dryOffDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.dryOffDate,
                  hintText: l10n.selectDate,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.event_busy),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _dryOffDateController, startDate: startDate),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      DateTime selectedDate = DateTime.parse(value);
                      if (selectedDate.isBefore(DateTime.parse(startDate))) {
                          return l10n.dateAfterStartDateError;
                      }
                    } catch (_) {
                       return l10n.invalidDateError;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Total Milk Yield Field (kg) ---
              TextFormField(
                controller: _totalMilkController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.totalMilkKg,
                  hintText: '0.0',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.local_drink),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (double.tryParse(value) == null) {
                    return l10n.invalidNumberError;
                  }
                  if (double.parse(value) < 0) {
                    return l10n.mustBePositiveError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // --- Days In Milk Field ---
              TextFormField(
                controller: _daysInMilkController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.daysInMilk,
                  hintText: '0',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (int.tryParse(value) == null) {
                    return l10n.invalidIntegerError;
                  }
                  if (int.parse(value) < 0) {
                    return l10n.mustBePositiveError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // --- Save Button ---
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveLactation,
                    icon: const Icon(Icons.save),
                    label: Text(l10n.saveChanges.toUpperCase()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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