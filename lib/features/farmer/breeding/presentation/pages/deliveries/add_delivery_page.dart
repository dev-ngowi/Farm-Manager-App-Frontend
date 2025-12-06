import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

// --- Offspring Data Model for Form Management ---
class OffspringFormModel {
  String gender;
  String birthCondition;
  double birthWeightKg;
  String colostrumIntake;
  bool navelTreated;
  String temporaryTag;
  String notes;

  OffspringFormModel({
    this.gender = 'Male',
    this.birthCondition = 'Vigorous',
    this.birthWeightKg = 0.0,
    this.colostrumIntake = 'Adequate',
    this.navelTreated = false,
    this.temporaryTag = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'birth_condition': birthCondition,
        'birth_weight_kg': birthWeightKg,
        'colostrum_intake': colostrumIntake,
        'navel_treated': navelTreated,
        'temporary_tag': temporaryTag.trim().isEmpty ? null : temporaryTag.trim(),
        'notes': notes.trim().isEmpty ? null : notes.trim(),
      };
}


class AddDeliveryPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/deliveries/add';

  const AddDeliveryPage({super.key});

  @override
  State<AddDeliveryPage> createState() => _AddDeliveryPageState();
}

class _AddDeliveryPageState extends State<AddDeliveryPage> {
  final _formKey = GlobalKey<FormState>();
  
  // --- Delivery Event Controllers & State ---
  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedInseminationId;
  String? _selectedDeliveryType;
  String? _selectedDamCondition;
  int _calvingEaseScore = 1; // Default to 1 (Easy)

  // --- Offspring List State ---
  List<OffspringFormModel> _offspringList = [OffspringFormModel()]; // Start with one calf

  // --- Dropdown Options (Matching Backend) ---
  final List<String> _deliveryTypes = ['Normal', 'Assisted', 'C-Section', 'Dystocia'];
  final List<String> _damConditions = ['Excellent', 'Good', 'Weak', 'Critical'];
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _birthConditions = ['Vigorous', 'Weak', 'Stillborn'];
  final List<String> _colostrumIntakeOptions = ['Adequate', 'Partial', 'Insufficient', 'None'];

  // Mock Inseminations (ID, Dam Tag) - Replace with API call
  final List<Map<String, String>> _mockInseminations = [
    {'id': '101', 'tag': 'Cow #101', 'expected_date': '15 Mar 2026'},
    {'id': '102', 'tag': 'Cow #115', 'expected_date': '05 Mar 2026'},
  ];

  @override
  void initState() {
    super.initState();
    // Set default delivery date to today
    _deliveryDateController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _deliveryDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Date Picker Helper ---
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Cannot be after today
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }
  
  // --- Offspring Management ---
  void _addOffspring() {
    setState(() {
      _offspringList.add(OffspringFormModel());
    });
  }

  void _removeOffspring(int index) {
    if (_offspringList.length > 1) {
      setState(() {
        _offspringList.removeAt(index);
      });
    }
  }

  // --- Submission Logic ---
  void _submitForm(AppLocalizations l10n) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Since we're using a dynamic list of widgets, we need to manually trigger 
    // saving all children.
    _formKey.currentState!.save(); 

    if (_selectedInseminationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectInseminationRequired)), // Assuming key exists
      );
      return;
    }

    if (_offspringList.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.atLeastOneOffspringRequired)), // Assuming key exists
      );
      return;
    }
    
    // Prepare data for API call (match backend keys)
    final apiPayload = {
      'insemination_id': int.tryParse(_selectedInseminationId!),
      'actual_delivery_date': DateFormat('yyyy-MM-dd').format(DateFormat('dd MMM yyyy').parse(_deliveryDateController.text)),
      'delivery_type': _selectedDeliveryType,
      'calving_ease_score': _calvingEaseScore,
      'dam_condition_after': _selectedDamCondition,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'offspring': _offspringList.map((o) => o.toJson()).toList(),
    };
    
    print('Submitting Delivery Data: $apiPayload');
    
    // TODO: Implement actual API call (e.g., using a repository/cubit)
    
    // Simulate success and navigate back
    context.pop(); 
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = BreedingColors.delivery;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordDelivery),
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
              // --- 1. Related Insemination (Required) ---
              _buildSectionHeader(l10n.relatedInsemination, Icons.vaccines, primaryColor),
              _buildInseminationDropdown(l10n, primaryColor),
              const SizedBox(height: 20),

              // --- 2. Delivery Date (Required) ---
              _buildSectionHeader(l10n.deliveryDate, Icons.calendar_today, primaryColor),
              _buildDateField(l10n.deliveryDate, _deliveryDateController, primaryColor),
              const SizedBox(height: 20),

              // --- 3. Delivery Details (Required) ---
              _buildSectionHeader(l10n.deliveryDetails, Icons.event, primaryColor),
              _buildDeliveryTypeDropdown(l10n, primaryColor),
              const SizedBox(height: 16),
              _buildDamConditionDropdown(l10n, primaryColor),
              const SizedBox(height: 16),
              _buildCalvingEaseScoreSlider(l10n, primaryColor),
              const SizedBox(height: 20),
              
              // --- 4. Offspring Records (Dynamic List) ---
              _buildOffspringSection(l10n, primaryColor),
              
              const SizedBox(height: 20),

              // --- 5. Notes (Optional) ---
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

              // --- 6. Submit Button ---
              ElevatedButton.icon(
                onPressed: () => _submitForm(l10n),
                icon: const Icon(Icons.save),
                label: Text(l10n.saveDelivery),
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

  Widget _buildSectionHeader(String title, IconData icon, Color color, {bool isSub = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0, top: isSub ? 0 : 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: isSub ? 20 : 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isSub ? 15 : 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, Color color) {
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
      validator: (value) => value == null || value.isEmpty ? l10n.fieldRequired : null,
    );
  }

  Widget _buildInseminationDropdown(AppLocalizations l10n, Color color) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.insemination,
        prefixIcon: Icon(Icons.pets, color: color),
        border: const OutlineInputBorder(),
      ),
      value: _selectedInseminationId,
      hint: Text(l10n.selectInsemination),
      items: _mockInseminations.map((item) {
        return DropdownMenuItem(
          value: item['id'],
          child: Text('ID #${item['id']} (${item['tag']}) - Due: ${item['expected_date']}'),
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

  Widget _buildDeliveryTypeDropdown(AppLocalizations l10n, Color color) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.deliveryType,
        prefixIcon: Icon(Icons.local_hospital, color: color),
        border: const OutlineInputBorder(),
      ),
      value: _selectedDeliveryType,
      hint: Text(l10n.selectDeliveryType),
      items: _deliveryTypes.map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDeliveryType = value;
        });
      },
      validator: (value) => value == null ? l10n.fieldRequired : null,
    );
  }

  Widget _buildDamConditionDropdown(AppLocalizations l10n, Color color) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.damConditionAfter,
        prefixIcon: Icon(Icons.favorite_border, color: color),
        border: const OutlineInputBorder(),
      ),
      value: _selectedDamCondition,
      hint: Text(l10n.selectDamCondition),
      items: _damConditions.map((condition) {
        return DropdownMenuItem(value: condition, child: Text(condition));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDamCondition = value;
        });
      },
      validator: (value) => value == null ? l10n.fieldRequired : null,
    );
  }

  Widget _buildCalvingEaseScoreSlider(AppLocalizations l10n, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            '${l10n.calvingEaseScore}: $_calvingEaseScore',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        ),
        Slider(
          value: _calvingEaseScore.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: color,
          label: _calvingEaseScore.toString(),
          onChanged: (double value) {
            setState(() {
              _calvingEaseScore = value.round();
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.scoreEasy, style: TextStyle(color: Colors.grey[600])), // 1
              Text(l10n.scoreDifficult, style: TextStyle(color: Colors.grey[600])), // 5
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOffspringSection(AppLocalizations l10n, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.offspringRecords, Icons.child_care, primaryColor),
        ..._offspringList.asMap().entries.map((entry) {
          int index = entry.key;
          OffspringFormModel offspring = entry.value;

          return _buildOffspringCard(l10n, primaryColor, index, offspring);
        }).toList(),
        
        const SizedBox(height: 16),
        
        // Add Offspring Button
        OutlinedButton.icon(
          onPressed: _addOffspring,
          icon: const Icon(Icons.add),
          label: Text(l10n.addOffspring),
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
          ),
        ),
      ],
    );
  }
  
  Widget _buildOffspringCard(AppLocalizations l10n, Color color, int index, OffspringFormModel offspring) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('${l10n.offspring} ${index + 1}', Icons.star, color, isSub: true),
                if (_offspringList.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: AppColors.error),
                    onPressed: () => _removeOffspring(index),
                    tooltip: l10n.removeOffspring,
                  ),
              ],
            ),
            const Divider(),

            // Temporary Tag
            TextFormField(
              initialValue: offspring.temporaryTag,
              decoration: InputDecoration(
                labelText: l10n.temporaryTag,
                prefixIcon: const Icon(Icons.tag),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) => offspring.temporaryTag = value,
            ),
            const SizedBox(height: 16),

            // Gender
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.gender,
                prefixIcon: const Icon(Icons.transgender),
                border: const OutlineInputBorder(),
              ),
              value: offspring.gender,
              items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (value) => setState(() { offspring.gender = value!; }),
              validator: (value) => value == null ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),

            // Birth Condition
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.birthCondition,
                prefixIcon: const Icon(Icons.sentiment_satisfied),
                border: const OutlineInputBorder(),
              ),
              value: offspring.birthCondition,
              items: _birthConditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (value) => setState(() { offspring.birthCondition = value!; }),
              validator: (value) => value == null ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),

            // Birth Weight
            TextFormField(
              initialValue: offspring.birthWeightKg == 0.0 ? '' : offspring.birthWeightKg.toStringAsFixed(1),
              decoration: InputDecoration(
                labelText: '${l10n.birthWeight} (kg)',
                prefixIcon: const Icon(Icons.fitness_center),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              onChanged: (value) => offspring.birthWeightKg = double.tryParse(value) ?? 0.0,
              validator: (value) {
                if (value == null || value.isEmpty) return l10n.fieldRequired;
                if (double.tryParse(value)! <= 0) return l10n.invalidNumber;
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Colostrum Intake
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.colostrumIntake,
                prefixIcon: const Icon(Icons.local_drink),
                border: const OutlineInputBorder(),
              ),
              value: offspring.colostrumIntake,
              items: _colostrumIntakeOptions.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (value) => setState(() { offspring.colostrumIntake = value!; }),
              validator: (value) => value == null ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),

            // Navel Treated Checkbox
            Row(
              children: [
                Checkbox(
                  value: offspring.navelTreated,
                  onChanged: (bool? value) => setState(() { offspring.navelTreated = value ?? false; }),
                  activeColor: color,
                ),
                Text(l10n.navelTreated),
              ],
            ),
            const SizedBox(height: 16),
            
            // Notes (Offspring)
            TextFormField(
              initialValue: offspring.notes,
              decoration: InputDecoration(
                labelText: l10n.offspringNotes, // Assuming key exists
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              onChanged: (value) => offspring.notes = value,
            ),
          ],
        ),
      ),
    );
  }
}

