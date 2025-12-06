import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterOffspringPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/offspring/:id/register';
  final int offspringId;

  const RegisterOffspringPage({super.key, required this.offspringId});

  @override
  State<RegisterOffspringPage> createState() => _RegisterOffspringPageState();
}

class _RegisterOffspringPageState extends State<RegisterOffspringPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = BreedingColors.offspring;
  
  // Form Field State
  final TextEditingController _tagController = TextEditingController();
  DateTime _registrationDate = DateTime.now(); // Date of registration

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _registrationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _registrationDate) {
      setState(() {
        _registrationDate = picked;
      });
    }
  }

  Future<void> _submitRegistration() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      
      // Data to be sent to OffspringController@register
      final payload = {
        'tag_number': _tagController.text.trim(),
        'registration_date': _registrationDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      };

      // --- Mock API Call: POST /api/farmer/offspring/{offspring_id}/register ---
      print('Registering Offspring ID ${widget.offspringId} with data: $payload');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.submittingRegistration)),
      );
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate latency

      // On Success: Pop page
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.registrationSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerOffspring),
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
              Text(
                l10n.registrationInstructions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(height: 32),

              // --- New Livestock Tag Number ---
              TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: l10n.newLivestockTag,
                  hintText: l10n.enterUniqueTag,
                  prefixIcon: const Icon(Icons.tag),
                  border: const OutlineInputBorder(),
                  filled: true,
                  // REPLACED AppColors.cardBackground with Colors.white
                  fillColor: Colors.white, 
                ),
                keyboardType: TextInputType.text,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return l10n.fieldRequired;
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Registration Date Picker ---
              ListTile(
                title: Text(l10n.registrationDate),
                subtitle: Text(_registrationDate.toIso8601String().split('T')[0]),
                trailing: const Icon(Icons.calendar_today, color: AppColors.secondary),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                // REPLACED AppColors.cardBackground with Colors.white
                tileColor: Colors.white,
              ),
              
              const SizedBox(height: 40),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitRegistration,
                  icon: const Icon(Icons.badge),
                  label: Text(l10n.confirmRegistration),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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