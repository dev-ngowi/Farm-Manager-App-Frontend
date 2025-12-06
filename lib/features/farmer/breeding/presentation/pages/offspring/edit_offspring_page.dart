import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

// --- Model for Initial Data (Simplified from Controller@show) ---
class OffspringEditData {
  final int id;
  final String temporaryTag;
  final String gender;
  final double birthWeightKg;
  final String birthCondition;
  final String colostrumIntake;
  final bool navelTreated;
  final String notes;
  
  // Context info (Read-only)
  final String damTag;
  final String deliveryDate;

  OffspringEditData({
    required this.id,
    required this.temporaryTag,
    required this.gender,
    required this.birthWeightKg,
    required this.birthCondition,
    required this.colostrumIntake,
    required this.navelTreated,
    required this.notes,
    required this.damTag,
    required this.deliveryDate,
  });
}

class EditOffspringPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/offspring/:id/edit';
  final int offspringId;

  const EditOffspringPage({super.key, required this.offspringId});

  @override
  State<EditOffspringPage> createState() => _EditOffspringPageState();
}

class _EditOffspringPageState extends State<EditOffspringPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = BreedingColors.offspring;
  bool _isLoading = true;

  // Form Controllers & State
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _gender;
  String? _birthCondition;
  String? _colostrumIntake;
  bool _navelTreated = false;
  
  // Context Data for Display
  String _damTagDisplay = '';
  String _deliveryDateDisplay = '';

  // Options
  final List<String> _genderOptions = ['Male', 'Female', 'Unknown'];
  final List<String> _conditionOptions = ['Vigorous', 'Weak', 'Stillborn'];
  final List<String> _colostrumOptions = ['Adequate', 'Partial', 'Insufficient', 'None'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tagController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Simulate API fetch delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Mock Data Fetching based on ID
    final data = _fetchMockData(widget.offspringId);
    
    setState(() {
      // Pre-fill Form State
      _tagController.text = data.temporaryTag;
      _gender = data.gender;
      _weightController.text = data.birthWeightKg.toString();
      _birthCondition = data.birthCondition;
      _colostrumIntake = data.colostrumIntake;
      _navelTreated = data.navelTreated;
      _notesController.text = data.notes;
      
      // Context Info
      _damTagDisplay = data.damTag;
      _deliveryDateDisplay = data.deliveryDate;
      
      _isLoading = false;
    });
  }

  // Mock API Response
  OffspringEditData _fetchMockData(int id) {
    return OffspringEditData(
      id: id,
      temporaryTag: 'CALF-001',
      gender: 'Female',
      birthWeightKg: 32.5,
      birthCondition: 'Vigorous',
      colostrumIntake: 'Adequate',
      navelTreated: true,
      notes: 'Healthy active calf.',
      damTag: 'COW-101',
      deliveryDate: '2025-09-10',
    );
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Payload matching OffspringController@update
      final payload = {
        'temporary_tag': _tagController.text.trim().isEmpty ? null : _tagController.text.trim(),
        'gender': _gender,
        'birth_weight_kg': double.parse(_weightController.text),
        'birth_condition': _birthCondition,
        'colostrum_intake': _colostrumIntake,
        'navel_treated': _navelTreated,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };

      print('Updating Offspring ID ${widget.offspringId}: $payload');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savingChanges)),
      );
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate latency

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editOffspring),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.editOffspring} #${widget.offspringId}'),
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
              // --- Read-Only Context Section ---
              _buildContextCard(l10n),
              const SizedBox(height: 24),

              // --- Identifiers ---
              Text(
                l10n.identification,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: l10n.temporaryTag,
                  prefixIcon: const Icon(Icons.tag),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white, // Replaced AppColors.cardBackground
                ),
              ),
              const SizedBox(height: 16),

              // --- Birth Metrics ---
              Text(
                l10n.birthMetrics,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildDropdown(
                label: l10n.gender,
                value: _gender,
                items: _genderOptions,
                icon: Icons.transgender,
                onChanged: (val) => _gender = val,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: '${l10n.birthWeight} (kg)',
                  prefixIcon: const Icon(Icons.fitness_center),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white, // Replaced AppColors.cardBackground
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (val) {
                  if (val == null || val.isEmpty) return l10n.fieldRequired;
                  if (double.tryParse(val) == null) return l10n.invalidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: l10n.birthCondition,
                value: _birthCondition,
                items: _conditionOptions,
                icon: Icons.monitor_heart,
                onChanged: (val) => _birthCondition = val,
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: l10n.colostrumIntake,
                value: _colostrumIntake,
                items: _colostrumOptions,
                icon: Icons.local_drink,
                onChanged: (val) => _colostrumIntake = val,
              ),
              const SizedBox(height: 16),

              // --- Toggle ---
              SwitchListTile(
                title: Text(l10n.navelTreated),
                value: _navelTreated,
                onChanged: (val) => setState(() => _navelTreated = val),
                secondary: Icon(Icons.medical_services, color: primaryColor),
                activeColor: primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              const SizedBox(height: 16),

              // --- Notes ---
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.notes),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white, // Replaced AppColors.cardBackground
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              
              const SizedBox(height: 32),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.saveChanges),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextCard(AppLocalizations l10n) {
    return Card(
      color: Colors.grey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: Colors.grey),
        title: Text(l10n.deliveryContext, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          '${l10n.dam}: $_damTagDisplay\n${l10n.date}: $_deliveryDateDisplay',
          style: const TextStyle(height: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white, // Replaced AppColors.cardBackground
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: (val) {
        setState(() {
          onChanged(val);
        });
      },
      validator: (val) => val == null ? l10n.fieldRequired : null,
    );
  }
}