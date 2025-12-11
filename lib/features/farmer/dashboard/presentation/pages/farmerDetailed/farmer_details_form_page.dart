import 'dart:convert';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:farm_manager_app/utils/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class FarmerDetailsFormPage extends StatefulWidget {
  static const String routeName = '/farmer/details-form';
  const FarmerDetailsFormPage({super.key});

  @override
  State<FarmerDetailsFormPage> createState() => _FarmerDetailsFormPageState();
}

class _FarmerDetailsFormPageState extends State<FarmerDetailsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _landAcresController = TextEditingController();
  final _experienceController = TextEditingController();

  String _selectedFarmPurpose = 'Milk';
  final List<String> _farmPurposes = ['Milk', 'Meat', 'Mixed', 'Other'];

  String? _photoBase64;
  int? _selectedLocationId;
  List<LocationEntity> _availableLocations = [];
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    print('🔄 FarmerDetailsFormPage: Initializing page state.'); // <-- LOG ADDED
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromAuthState();
    });
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _landAcresController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _initializeFromAuthState() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      print('✅ FarmerDetailsFormPage: AuthSuccess state found.'); // <-- LOG ADDED
      final locations = authState.user.locations ?? [];
      
      print('📍 FarmerDetailsFormPage: Found ${locations.length} locations in AuthState.'); // <-- LOG ADDED

      setState(() {
        _availableLocations = locations;
        _isInitializing = false;

        if (locations.isNotEmpty) {
          final primaryLocation = locations.firstWhere(
            (loc) => loc.isPrimary,
            orElse: () => locations.first,
          );
          _selectedLocationId = primaryLocation.locationId;
          print('🔑 FarmerDetailsFormPage: Selected Primary Location ID: $_selectedLocationId'); // <-- LOG ADDED
        } else {
          print('⚠️ FarmerDetailsFormPage: No locations available. Selected ID is null.'); // <-- LOG ADDED
        }
      });
    } else {
      print('❌ FarmerDetailsFormPage: AuthState is NOT AuthSuccess. State type: ${authState.runtimeType}'); // <-- LOG ADDED
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final base64Image = await ImageHelper.pickAndConvertToBase64(source);
      if (base64Image != null && mounted) {
        setState(() => _photoBase64 = base64Image);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            if (_photoBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photoBase64 = null);
                },
              ),
          ],
        ),
      ),
    );
  }

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

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a farm location'),
          backgroundColor: Colors.orange[700],
          action: _availableLocations.isEmpty
              ? SnackBarAction(
                  label: 'Add Location',
                  textColor: Colors.white,
                  onPressed: () => context.go('/location-manager'),
                )
              : null,
        ),
      );
      return;
    }

    print('Submitting farmer details...');
    print('   Farm: ${_farmNameController.text.trim()}');
    print('   Location ID: $_selectedLocationId');

    context.read<AuthBloc>().add(
          SubmitFarmerDetails(
            farmName: _farmNameController.text.trim(),
            farmPurpose: _selectedFarmPurpose,
            totalLandAcres: double.tryParse(_landAcresController.text) ?? 0.0,
            yearsExperience: int.tryParse(_experienceController.text) ?? 0,
            locationId: _selectedLocationId!,
            token: authState.user.token,
            profilePhotoBase64: _photoBase64,
          ),
        );
  }

  Widget _buildLocationDropdown(bool isLoading) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableLocations.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No locations found. Please add a location first.',
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_location, color: AppColors.primary),
            onPressed: () => context.go('/location-manager'),
            tooltip: 'Add Location',
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: _selectedLocationId,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.farmLocation ?? 'Farm Location',
              prefixIcon: const Icon(Icons.location_on),
              helperText: '${_availableLocations.length} location(s) available',
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _availableLocations.map((loc) {
              return DropdownMenuItem<int>(
                value: loc.locationId,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        // FIX: Use the dedicated dropdownDisplay getter for better formatting
                        loc.dropdownDisplay, 
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // REMOVED custom Primary badge because loc.dropdownDisplay includes '★'
                  ],
                ),
              );
            }).toList(),
            onChanged: isLoading ? null : (int? newId) {
              setState(() => _selectedLocationId = newId);
            },
            validator: (v) => v == null ? 'Please select a farm location' : null,
            isExpanded: true,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_location, color: AppColors.primary),
          tooltip: 'Add New Location',
          onPressed: () => context.go('/location-manager'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.completeFarmerProfile ?? 'Complete Your Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && state.user.hasCompletedDetails == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Profile completed successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) context.go('/farmer/dashboard');
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.farmerDetailsPrompt ?? 'Tell us about your farm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide your farm details to complete your profile',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Farm Name
                    TextFormField(
                      controller: _farmNameController,
                      decoration: InputDecoration(
                        labelText: l10n.farmName ?? 'Farm Name',
                        prefixIcon: const Icon(Icons.agriculture),
                        hintText: 'e.g., Green Valley Farm',
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Farm name is required' : null,
                      enabled: !isLoading,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    // Location Dropdown
                    _buildLocationDropdown(isLoading),
                    const SizedBox(height: 20),

                    // Farm Purpose
                    DropdownButtonFormField<String>(
                      initialValue: _selectedFarmPurpose,
                      decoration: InputDecoration(
                        labelText: l10n.farmPurpose ?? 'Main Farm Purpose',
                        prefixIcon: const Icon(Icons.grass),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: _farmPurposes
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: isLoading ? null : (v) => setState(() => _selectedFarmPurpose = v!),
                    ),
                    const SizedBox(height: 20),

                    // Land Acres
                    TextFormField(
                      controller: _landAcresController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.totalLandAcres ?? 'Total Land (acres)',
                        prefixIcon: const Icon(Icons.landscape),
                        suffixText: 'acres',
                        hintText: 'e.g., 50.5',
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (v) {
                        if (v?.trim().isEmpty ?? true) return 'Required';
                        final val = double.tryParse(v!);
                        if (val == null || val < 0.1) return 'Enter valid acres (min 0.1)';
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 20),

                    // Years Experience
                    TextFormField(
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.yearsExperience ?? 'Years of Experience',
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixText: 'years',
                        hintText: 'e.g., 10',
                        filled: true,
                        fillColor: Colors.grey[50],
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
                    const SizedBox(height: 32),

                    // Photo Upload
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _photoBase64 != null ? AppColors.primary : Colors.grey[300]!,
                          width: _photoBase64 != null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _photoBase64 != null ? AppColors.primary.withOpacity(0.05) : Colors.grey[50],
                      ),
                      child: Column(
                        children: [
                          if (_photoBase64 == null)
                            const Icon(Icons.photo_camera_outlined, size: 48, color: Colors.grey)
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(_photoBase64!),
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            _photoBase64 == null ? 'Profile Photo (Optional)' : 'Photo Selected',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: _photoBase64 != null ? AppColors.primary : Colors.grey[700],
                                  fontWeight: _photoBase64 != null ? FontWeight.w600 : null,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _showPhotoSourceDialog,
                            icon: Icon(_photoBase64 == null ? Icons.upload : Icons.edit),
                            label: Text(_photoBase64 == null ? 'Select Photo' : 'Change Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                l10n.completeProfile ?? 'Complete Profile',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}