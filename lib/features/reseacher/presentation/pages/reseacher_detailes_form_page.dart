// lib/features/reseacher/presentation/pages/reseacher_detailes_form_page.dart

import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_bloc.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_event.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
// Ensure this import exists
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// -----------------------------------------------------------------
//                  PLACEHOLDER AND UTILITY COMPONENTS
// -----------------------------------------------------------------

class AppColors { 
  static const Color primary = Colors.blue; 
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  static const Color surface = Colors.white; 
}

// Route Constants (consistent with AppRoutes in router)
class AppRoutes {
  static const String researcherDashboard = '/researcher/dashboard';
}

const List<String> _researchPurposes = [
  'Academic',
  'Commercial Research',
  'Field Research',
  'Government Policy',
  'NGO Project',
];

// -----------------------------------------------------------------
//                      RESEARCHER DETAILS FORM PAGE (UPDATED)
// -----------------------------------------------------------------

class ResearcherDetailsFormPage extends StatefulWidget {
  const ResearcherDetailsFormPage({super.key});

  @override
  State<ResearcherDetailsFormPage> createState() => _ResearcherDetailsFormPageState();
}

class _ResearcherDetailsFormPageState extends State<ResearcherDetailsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _researchFocusController = TextEditingController(); 
  final _academicTitleController = TextEditingController();
  final _orcidIdController = TextEditingController();
  String? _selectedResearchPurpose;

  bool _isNavigating = false; // Prevent multiple navigation calls

  @override
  void dispose() {
    _institutionController.dispose();
    _departmentController.dispose();
    _researchFocusController.dispose();
    _academicTitleController.dispose();
    _orcidIdController.dispose();
    super.dispose();
  }
  
  void _submit(BuildContext context) { 
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.requiredField),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_selectedResearchPurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.requiredField),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<ResearcherBloc>().add(
      SubmitResearcherDetailsEvent(
        affiliatedInstitution: _institutionController.text.trim(), 
        department: _departmentController.text.trim(),
        researchPurpose: _selectedResearchPurpose!,
        researchFocusArea: _researchFocusController.text.trim(),
        academicTitle: _academicTitleController.text.trim().isEmpty 
            ? null 
            : _academicTitleController.text.trim(),
        orcidId: _orcidIdController.text.trim().isEmpty 
            ? null 
            : _orcidIdController.text.trim(),
        hasCompletedDetails: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.researcherProfile ?? "Researcher Profile"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<ResearcherBloc, ResearcherState>(
        listener: (context, state) {
          // Success → Show message + redirect to dashboard
          if (state is ResearcherSuccess && state.hasCompletedDetails == true && !_isNavigating) {
            _isNavigating = true; // Prevent double navigation

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Profile completed successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );

            // Safe delayed navigation
            Future.delayed(const Duration(milliseconds: 1800), () {
              if (mounted) {
                context.go(AppRoutes.researcherDashboard);
              }
            });
          } 
          // Error → Show error message
          else if (state is ResearcherError) {
            final errorMessage = state.message.isNotEmpty 
                ? state.message 
                : l10n.genericError;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _buildFormContent(context, l10n),
        ),
      ),
    );
  }
  
  Widget _buildFormContent(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<ResearcherBloc, ResearcherState>(
      builder: (context, state) {
        final isLoading = state is ResearcherLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeResearcher ?? "Welcome, Researcher!",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.researcherDetailsSubtitle ?? "Complete your profile to access research tools and data.",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Fields
              _buildTextFormField(
                controller: _institutionController, 
                labelText: l10n.affiliatedInstitution ?? "Institution / University",
                icon: Icons.school, 
                isLoading: isLoading, 
                isMandatory: true, 
                l10n: l10n,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _departmentController, 
                labelText: l10n.department ?? "Department",
                icon: Icons.biotech, 
                isLoading: isLoading, 
                isMandatory: true, 
                l10n: l10n,
              ),
              const SizedBox(height: 20),
              _buildDropdownFormField(
                labelText: l10n.researchPurpose ?? "Research Purpose",
                icon: Icons.flag,
                isLoading: isLoading,
                l10n: l10n,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _researchFocusController, 
                labelText: l10n.researchFocusArea ?? "Research Focus Area",
                icon: Icons.search, 
                isLoading: isLoading, 
                isMandatory: true,
                l10n: l10n,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _academicTitleController, 
                labelText: l10n.academicTitle,
                icon: Icons.title, 
                isLoading: isLoading, 
                isMandatory: false, 
                l10n: l10n,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _orcidIdController, 
                labelText: l10n.orcidId,
                icon: Icons.badge, 
                isLoading: isLoading, 
                isMandatory: false, 
                l10n: l10n,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          l10n.completeProfile,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String? labelText,
    required IconData icon,
    required bool isLoading,
    required bool isMandatory,
    required AppLocalizations l10n,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !isLoading,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: isMandatory 
          ? (v) => (v == null || v.isEmpty) ? l10n.requiredField : null 
          : null,
      textCapitalization: TextCapitalization.words,
    );
  }
  
  Widget _buildDropdownFormField({
    required String labelText,
    required IconData icon,
    required bool isLoading,
    required AppLocalizations l10n,
  }) {
    return DropdownButtonFormField<String>(
      value: _selectedResearchPurpose,
      hint: Text(labelText),
      validator: (v) => v == null ? l10n.requiredField : null,
      onChanged: isLoading ? null : (String? newValue) {
        setState(() {
          _selectedResearchPurpose = newValue;
        });
      },
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _researchPurposes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}