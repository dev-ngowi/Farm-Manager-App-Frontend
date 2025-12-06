// lib/features/auth/presentation/pages/location/location_manager_page.dart

import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/location/location_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';

class LocationManagerPage extends StatelessWidget {
  static const String routeName = '/location-manager';

  const LocationManagerPage({super.key});

  void _showAddWardDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationBloc = context.read<LocationBloc>();
    final TextEditingController wardController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // --- START OF MODIFICATION ---
        return BlocListener<LocationBloc, LocationState>(
          bloc: locationBloc, // Use the existing bloc
          listenWhen: (previous, current) => previous.isCreatingWard && !current.isCreatingWard,
          listener: (listenerContext, state) {
            // Check for success (e.g., if isCreatingWard just turned false and no error message is present)
            if (!state.isCreatingWard && state.errorMessage == null) {
              // Close the dialog using the dialogContext
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.wardAddedSuccess ?? "Ward added successfully!"), backgroundColor: AppColors.primary),
              );
              // Clear the text field after successful submission
              wardController.clear();
            } else if (!state.isCreatingWard && state.errorMessage != null) {
              // Show error in the main context if creation failed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
              );
            }
          },
          child: AlertDialog(
        // --- END OF MODIFICATION ---
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.add_location, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.addNewWard ?? "Add New Ward",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            content: BlocBuilder<LocationBloc, LocationState>(
              bloc: locationBloc,
              builder: (builderContext, state) {
                final isCreating = state.isCreatingWard;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.enterNewWardName ?? "Enter new ward name:", style: Theme.of(builderContext).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    TextField(
                      controller: wardController,
                      enabled: !isCreating,
                      decoration: InputDecoration(
                        labelText: l10n.ward ?? "Ward",
                        hintText: l10n.wardExample ?? "Example: Kilakala",
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ],
                );
              },
            ),
            actions: [
              BlocBuilder<LocationBloc, LocationState>(
                bloc: locationBloc,
                builder: (builderContext, state) {
                  final isCreating = state.isCreatingWard;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isCreating ? null : () => Navigator.of(dialogContext).pop(),
                        child: Text(l10n.cancel ?? "Cancel", style: TextStyle(color: isCreating ? Colors.grey : AppColors.secondary)),
                      ),
                      ElevatedButton(
                        onPressed: isCreating
                            ? null
                            : () {
                                final wardName = wardController.text.trim();
                                if (wardName.isEmpty) {
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    SnackBar(content: Text(l10n.pleaseEnterWardName ?? "Please enter ward name"), backgroundColor: Colors.orange),
                                  );
                                  return;
                                }
                                locationBloc.add(CreateNewWardEvent(wardName));
                              },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: isCreating
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(l10n.add ?? "Add", style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
              ),
            ],
          // --- START OF MODIFICATION ---
          ),
        );
        // --- END OF MODIFICATION ---
      },
    );
  }

  @override
  Widget build(BuildContext context) {
// ... rest of the build method remains the same ...
// I will only include the rest of the file content for completeness.
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider<LocationBloc>(
      create: (context) => LocationBloc(repository: getIt<LocationRepository>())..add(LoadRegionsEvent()),
      child: MultiBlocListener(
        listeners: [
          // FIXED: Now uses savedLocation (full LocationEntity)
          BlocListener<LocationBloc, LocationState>(
            listener: (context, locationState) {
              if (locationState.locationSaved == true && locationState.savedLocation != null) {
                final savedLocation = locationState.savedLocation!;

                print('Location saved successfully!');
                print('   → ${savedLocation.displayName}');
                print('   → Location ID: ${savedLocation.locationId}');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.locationSavedSuccess ?? "Location saved successfully!"),
                    backgroundColor: AppColors.primary,
                  ),
                );

                // Get current user role
                final authState = context.read<AuthBloc>().state;
                String? userRole = 'Farmer';
                if (authState is AuthSuccess) {
                  userRole = authState.user.role ?? 'Farmer';
                }

                // CRITICAL: Dispatch FULL LocationEntity
                context.read<AuthBloc>().add(
                  UserLocationUpdated(
                    location: savedLocation,
                    role: userRole,
                  ),
                );

                print('UserLocationUpdated dispatched with full LocationEntity');
              }

              if (locationState.errorMessage != null && !locationState.isCreatingWard) {
                // Only show general errors here, ward creation errors are handled in the dialog's listener
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(locationState.errorMessage!), backgroundColor: Colors.red),
                );
              }
            },
          ),

          // Navigate when AuthBloc confirms location is saved
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, current) =>
                current is AuthSuccess && current.user.hasLocation == true && (prev is! AuthSuccess || prev.user.hasLocation != true),
            listener: (context, authState) {
              if (authState is AuthSuccess && authState.user.hasLocation == true) {
                final role = (authState.user.role ?? 'Farmer').toLowerCase();
                final route = switch (role) {
                  'vet' => '/vet/details-form',
                  'researcher' => '/researcher/details-form',
                  _ => '/farmer/details-form',
                };

                Future.microtask(() => context.go(route));
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: BlocBuilder<LocationBloc, LocationState>(
              builder: (context, state) {
                final isBusy = state.isLoading || state.isCreatingWard || state.locationSaved;
                return IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: isBusy ? null : () => context.go('/role-selection'),
                );
              },
            ),
          ),
          body: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              final isBusy = state.isLoading || state.isCreatingWard || state.locationSaved;

              return Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Lottie.asset('assets/lottie/location.json', height: 180, repeat: true),
                          Text(l10n.setYourLocation ?? "Set Your Location", style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(l10n.locationSubtitle ?? "This will help us provide better livestock services near you", style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 32),

                          if (state.regions.isEmpty && state.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            Column(
                              children: [
                                _DropdownField(
                                  label: l10n.region ?? "Region",
                                  items: state.regions,
                                  selectedId: state.selectedRegionId,
                                  onChanged: isBusy ? null : (id) => context.read<LocationBloc>().add(SelectRegionEvent(id!)),
                                  enabled: !isBusy && state.regions.isNotEmpty,
                                  isLoading: state.isLoadingDistricts,
                                  loadingText: l10n.loadingDistricts ?? "Loading districts...",
                                ),
                                const SizedBox(height: 20),

                                _DropdownField(
                                  label: l10n.district ?? "District",
                                  items: state.districts,
                                  selectedId: state.selectedDistrictId,
                                  onChanged: isBusy ? null : (id) => context.read<LocationBloc>().add(SelectDistrictEvent(id!)),
                                  enabled: !isBusy && state.selectedRegionId != null,
                                  isLoading: state.isLoadingDistricts,
                                  loadingText: l10n.loadingDistricts ?? "Loading districts...",
                                ),
                                const SizedBox(height: 20),

                                _WardDropdownWithAddButton(
                                  state: state,
                                  onAddWard: isBusy ? () {} : () => _showAddWardDialog(context),
                                  l10n: l10n,
                                  isBusy: isBusy,
                                ),
                                const SizedBox(height: 20),

                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: state.selectedWardId == null || isBusy ? null : () => context.read<LocationBloc>().add(RequestLocationPermissionEvent()),
                                    icon: isBusy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.my_location),
                                    label: Text(
                                      state.hasGps
                                          ? "${l10n.gpsCaptured ?? 'GPS Captured'} (${state.latitude!.toStringAsFixed(4)}, ${state.longitude!.toStringAsFixed(4)})"
                                          : state.selectedWardId != null
                                              ? l10n.nowCaptureGps ?? "Now capture GPS"
                                              : l10n.captureGps ?? "Capture My Location",
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: state.hasGps ? AppColors.secondary : Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 48),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: state.selectedWardId == null || !state.hasGps || isBusy ? null : () => context.read<LocationBloc>().add(SaveUserLocationEvent()),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                    child: isBusy
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Text(l10n.saveLocation ?? "SAVE LOCATION", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (state.isCreatingWard) GlobalLoadingOverlay(l10n: l10n),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Helper Widgets (unchanged, just cleaned up)
class GlobalLoadingOverlay extends StatelessWidget {
  final AppLocalizations l10n;
  const GlobalLoadingOverlay({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black54, child: Center(child: Card(
      child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: const [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 16),
        Text("Adding new ward...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ])),
    )));
  }
}

class _DropdownField extends StatelessWidget {
  final String label; final List<dynamic> items; final int? selectedId;
  final ValueChanged<int?>? onChanged; final bool enabled; final bool isLoading; final String loadingText;

  const _DropdownField({required this.label, required this.items, required this.selectedId, this.onChanged, required this.enabled, this.isLoading = false, this.loadingText = ''});

  @override
  Widget build(BuildContext context) {
    final unique = <int, String>{};
    for (var i in items) {
      final id = i is Map ? i['id'] as int : i.id as int;
      final name = (i is Map ? i['name'] ?? i['region_name'] ?? i['district_name'] ?? i['ward_name'] : i.name ?? i.region_name ?? i.district_name ?? i.ward_name) ?? 'Unknown';
      unique[id] = name.toString();
    }

    return DropdownButtonFormField<int>(
      value: unique.containsKey(selectedId) ? selectedId : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_city),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)), borderRadius: BorderRadius.circular(16)),
        suffixIcon: isLoading ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))) : null,
      ),
      items: unique.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
    );
  }
}

class _WardDropdownWithAddButton extends StatelessWidget {
  final LocationState state; final VoidCallback onAddWard; final AppLocalizations l10n; final bool isBusy;

  const _WardDropdownWithAddButton({required this.state, required this.onAddWard, required this.l10n, required this.isBusy});

  @override
  Widget build(BuildContext context) {
    final wards = <int, String>{};
    for (var w in state.wards) {
      final id = w is Map ? w['id'] as int : w.id as int;
      final name = (w is Map ? w['ward_name'] : w.ward_name) as String;
      wards[id] = name;
    }

    return Column(
      children: [
        _DropdownField(
          label: l10n.ward ?? "Ward",
          items: state.wards,
          selectedId: state.selectedWardId,
          onChanged: !isBusy && state.selectedDistrictId != null ? (id) => context.read<LocationBloc>().add(SelectWardEvent(id!)) : null,
          enabled: state.selectedDistrictId != null && !isBusy,
          isLoading: state.isLoadingWards,
          loadingText: l10n.loadingWards ?? "Loading wards...",
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: isBusy ? null : onAddWard,
          icon: const Icon(Icons.add_circle_outline),
          label: Text(l10n.addNewWard ?? "Add New Ward"),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: BorderSide(color: isBusy ? Colors.grey : AppColors.primary), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        ),
      ],
    );
  }
}