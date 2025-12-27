// lib/features/auth/presentation/pages/vet_details_form_page.dart

import 'dart:convert';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class VetDetailsFormPage extends StatefulWidget {
  static const String routeName = '/vet/details-form';
  const VetDetailsFormPage({super.key});

  @override
  State<VetDetailsFormPage> createState() => _VetDetailsFormPageState();
}

class _VetDetailsFormPageState extends State<VetDetailsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _clinicNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _experienceController = TextEditingController();

  String _selectedSpecialization = 'Mixed Practice';
  final List<String> _specializations = ['Cattle', 'Goat', 'Sheep', 'Mixed Practice', 'Other'];

  String? _certificateBase64;
  String? _licenseBase64;
  final List<String> _clinicPhotosBase64 = []; 

  int? _selectedLocationId;
  List<LocationEntity> _availableLocations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocations();
    });
  }

  @override
  void dispose() {
    _clinicNameController.dispose();
    _licenseNumberController.dispose();
    _consultationFeeController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  // ========================================
  // LOCATION INITIALIZATION / REFRESH 
  // ========================================

  void _initializeLocations() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthSuccess) {
      if (state.user.locations != null && state.user.locations!.isNotEmpty) {
        setState(() {
          _availableLocations = state.user.locations!;
          try {
            final primaryLocation = _availableLocations.firstWhere(
              (loc) => loc.isPrimary,
              orElse: () => _availableLocations.first,
            );
            _selectedLocationId = primaryLocation.locationId;
          } catch (e) {
            _selectedLocationId = null;
          }
        });
      }
    }
  }

  void _refreshLocations() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthSuccess && state.user.token != null) {
      context.read<AuthBloc>().add(FetchUserLocations(token: state.user.token!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refreshing locations...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // ========================================
  // HELPER: Get Location Display Name
  // ========================================
  String _getLocationDisplayName(LocationEntity location) {
    // Build a readable name from location properties
    final parts = <String>[];
    
    if (location.wardName != null && location.wardName!.isNotEmpty) {
      parts.add(location.wardName!);
    }
    if (location.districtId != null) {
      parts.add('District ${location.districtId}');
    }
    
    return parts.isEmpty ? 'Location ${location.locationId}' : parts.join(', ');
  }

  // ========================================
  // DOCUMENT/PHOTO HANDLING (FIXED LOGIC)
  // ========================================

  Future<void> _pickSingleDocument(Function(String?) onPicked) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        // Web platform - use bytes
        final bytes = result.files.single.bytes!;
        final base64String = base64Encode(bytes);
        
        if (mounted) {
          onPicked(base64String);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document selected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (result != null && result.files.single.path != null) {
        // Mobile platform - use path
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        
        if (mounted) {
          onPicked(base64String);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document selected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickMultiplePhotos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        final List<String> newPhotos = [];
        
        for (var file in result.files) {
          if (_clinicPhotosBase64.length + newPhotos.length >= 5) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maximum 5 photos allowed'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            break;
          }

          if (file.bytes != null) {
            // Web platform
            newPhotos.add(base64Encode(file.bytes!));
          } else if (file.path != null) {
            // Mobile platform
            final fileObj = File(file.path!);
            final bytes = await fileObj.readAsBytes();
            newPhotos.add(base64Encode(bytes));
          }
        }

        if (mounted && newPhotos.isNotEmpty) {
          setState(() {
            _clinicPhotosBase64.addAll(newPhotos);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newPhotos.length} photo(s) added!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ========================================
  // FORM SUBMISSION
  // ========================================

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your service location'),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }

    if (_certificateBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Qualification Certificate is required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_licenseBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('License Document is required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final state = context.read<AuthBloc>().state;
    if (state is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call the Bloc event
    context.read<AuthBloc>().add(
          SubmitVetDetails(
            clinicName: _clinicNameController.text.trim(),
            licenseNumber: _licenseNumberController.text.trim(),
            specialization: _selectedSpecialization,
            consultationFee: double.tryParse(_consultationFeeController.text) ?? 0.0,
            yearsExperience: int.tryParse(_experienceController.text) ?? 0,
            locationId: _selectedLocationId!,
            token: state.user.token,
            certificateBase64: _certificateBase64!,
            licenseBase64: _licenseBase64!,
            clinicPhotosBase64: _clinicPhotosBase64,
          ),
        );
  }

  // ========================================
  // WIDGET HELPERS
  // ========================================

  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePickerTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String? fileBase64,
    required bool isRequired,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final hasFile = fileBase64 != null;
    final color = hasFile ? AppColors.primary : (isRequired ? Colors.red.shade700 : AppColors.textSecondary);

    return ListTile(
      leading: Icon(hasFile ? Icons.check_circle : icon, color: color),
      title: isRequired 
          ? _buildRequiredLabel(title)
          : Text(title, style: TextStyle(color: color)),
      subtitle: Text(hasFile ? 'File ready for upload' : subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasFile)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: onClear,
              tooltip: 'Remove',
            ),
          IconButton(
            icon: Icon(hasFile ? Icons.edit : Icons.upload_file, color: AppColors.primary),
            onPressed: onTap,
            tooltip: hasFile ? 'Change File' : 'Select File',
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildClinicPhotosSection(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clinic Photos (Optional)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload up to 5 photos of your clinic/workspace.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Display Selected Photos
          if (_clinicPhotosBase64.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _clinicPhotosBase64.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(_clinicPhotosBase64[index]),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: InkWell(
                            onTap: isLoading ? null : () {
                              setState(() {
                                _clinicPhotosBase64.removeAt(index);
                              });
                            },
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 12),

          // Add Photo Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading || _clinicPhotosBase64.length >= 5 
                  ? null 
                  : _pickMultiplePhotos,
              icon: const Icon(Icons.add_a_photo),
              label: Text(
                _clinicPhotosBase64.isEmpty
                    ? 'Add Photos'
                    : 'Add More Photos (${_clinicPhotosBase64.length}/5)',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // BUILD UI
  // ========================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.completeVetProfile ?? 'Complete Vet Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && _availableLocations.isEmpty) {
            _initializeLocations();
          }

          if (state is AuthSuccess && state.user.hasCompletedDetails == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Profile submitted for approval.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.go('/vet/pending-approval'); 
              }
            });
          } 
          else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    l10n.vetDetailsPrompt ?? 'Tell us about your practice',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please provide your professional and clinic details for review and approval.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),
                  
                  // --- PROFESSIONAL DETAILS ---
                  Text(
                    'Professional Information',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(height: 16, thickness: 1),
                  
                  // License Number *
                  TextFormField(
                    controller: _licenseNumberController,
                    decoration: InputDecoration(
                      label: _buildRequiredLabel('License Number'),
                      prefixIcon: const Icon(Icons.badge),
                      hintText: 'e.g., VET-123456',
                    ),
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'License number is required' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Years Experience *
                  TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: _buildRequiredLabel('Years of Experience'),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixText: 'years',
                      hintText: 'e.g., 5',
                    ),
                    validator: (v) {
                      if (v?.trim().isEmpty ?? true) return 'Required';
                      final val = int.tryParse(v!);
                      if (val == null || val < 0 || val > 70) {
                        return 'Enter years between 0 and 70';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),
                  
                  // Specialization *
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialization,
                    decoration: InputDecoration(
                      label: _buildRequiredLabel('Primary Specialization'),
                      prefixIcon: const Icon(Icons.pets),
                    ),
                    items: _specializations
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: isLoading
                        ? null
                        : (v) => setState(() => _selectedSpecialization = v!),
                  ),
                  const SizedBox(height: 32),
                  
                  // --- CLINIC & FEE DETAILS ---
                  Text(
                    'Clinic and Fee Details',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(height: 16, thickness: 1),

                  // Clinic Name *
                  TextFormField(
                    controller: _clinicNameController,
                    decoration: InputDecoration(
                      label: _buildRequiredLabel('Clinic Name'),
                      prefixIcon: const Icon(Icons.local_hospital),
                      hintText: 'e.g., Trusty Vet Services',
                    ),
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Clinic name is required' : null,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),
                  
                  // Consultation Fee *
                  TextFormField(
                    controller: _consultationFeeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      label: _buildRequiredLabel('Consultation Fee (Tsh)'),
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: 'Tsh',
                      hintText: 'e.g., 20000.00',
                    ),
                    validator: (v) {
                      if (v?.trim().isEmpty ?? true) return 'Required';
                      final val = double.tryParse(v!);
                      if (val == null || val < 0) {
                        return 'Enter a valid fee (min 0)';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  // LOCATION DROPDOWN WITH REFRESH BUTTON *
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedLocationId,
                          decoration: InputDecoration(
                            label: _buildRequiredLabel('Primary Service Location'),
                            prefixIcon: const Icon(Icons.location_on),
                            helperText: _availableLocations.isEmpty
                                ? 'No locations available. Add one first.'
                                : '${_availableLocations.length} location(s) available',
                            helperStyle: TextStyle(
                              color: _availableLocations.isEmpty
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                          ),
                          hint: Text(
                            _availableLocations.isEmpty
                                ? 'No locations yet'
                                : 'Select your service location',
                          ),
                          items: _availableLocations.isEmpty
                              ? null
                              : _availableLocations.map((loc) {
                                  return DropdownMenuItem<int>(
                                    value: loc.locationId,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _getLocationDisplayName(loc), 
                                            overflow: TextOverflow.ellipsis
                                          )
                                        ),
                                        if (loc.isPrimary)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppColors.primary, width: 1),
                                            ),
                                            child: const Text(
                                              'Primary', 
                                              style: TextStyle(
                                                fontSize: 10, 
                                                color: AppColors.primary, 
                                                fontWeight: FontWeight.bold
                                              )
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          onChanged: isLoading || _availableLocations.isEmpty
                              ? null
                              : (int? newId) => setState(() => _selectedLocationId = newId),
                          validator: (v) =>
                              v == null ? 'Please select a service location' : null,
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh, color: AppColors.primary),
                            tooltip: 'Refresh Locations',
                            onPressed: isLoading ? null : _refreshLocations,
                          ),
                          if (_availableLocations.isEmpty && !isLoading)
                            IconButton(
                              icon: const Icon(Icons.add_location, color: AppColors.primary),
                              tooltip: 'Add Location',
                              onPressed: () => context.go('/location-manager'),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- DOCUMENT UPLOAD SECTION ---
                  Text(
                    'Verification Documents (Required)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(height: 16, thickness: 1),

                  // 1. Qualification Certificate *
                  _buildFilePickerTile(
                    title: 'Qualification Certificate (PDF/Image)',
                    subtitle: 'E.g., Degree, Diploma certificate.',
                    icon: Icons.school,
                    fileBase64: _certificateBase64,
                    isRequired: true,
                    onTap: isLoading 
                        ? () {} 
                        : () => _pickSingleDocument(
                            (base64) => setState(() => _certificateBase64 = base64)
                          ),
                    onClear: () => setState(() => _certificateBase64 = null),
                  ),

                  // 2. License Document *
                  _buildFilePickerTile(
                    title: 'Practice License Document (PDF/Image)',
                    subtitle: 'Current license to practice.',
                    icon: Icons.verified_user,
                    fileBase64: _licenseBase64,
                    isRequired: true,
                    onTap: isLoading 
                        ? () {} 
                        : () => _pickSingleDocument(
                            (base64) => setState(() => _licenseBase64 = base64)
                          ),
                    onClear: () => setState(() => _licenseBase64 = null),
                  ),
                  
                  const SizedBox(height: 32),

                  // --- OPTIONAL CLINIC PHOTOS ---
                  _buildClinicPhotosSection(isLoading),
                  
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.submitForApproval ?? 'Submit for Approval',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}