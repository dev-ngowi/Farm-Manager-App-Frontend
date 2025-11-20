// lib/features/auth/presentation/pages/location/location_manager_page.dart

import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
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
        return BlocProvider<LocationBloc>.value(
          value: locationBloc,
          child: BlocListener<LocationBloc, LocationState>(
            listener: (listenerContext, state) {
              // Close dialog when ward is successfully created
              if (state.selectedWardId != null && !state.isCreatingWard) {
                Navigator.of(dialogContext).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${l10n.ward} '${state.wardSearchText}' ${l10n.addedSuccessfully ?? 'has been added'}! ${l10n.nowCaptureGps ?? 'Now capture GPS'}.",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }

              // Show error
              if (state is LocationError && !state.isCreatingWard) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? l10n.errorOccurred ?? "An error occurred"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<LocationBloc, LocationState>(
              builder: (builderContext, state) {
                final isCreating = state.isCreatingWard;

                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.add_location, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.addNewWard ?? "Add New Ward",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.enterNewWardName ?? "Enter new ward name:",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: wardController,
                        enabled: !isCreating,
                        decoration: InputDecoration(
                          labelText: l10n.ward ?? "Ward",
                          hintText: l10n.wardExample ?? "Example: Kilakala",
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: isCreating
                          ? null
                          : () {
                              Navigator.of(dialogContext).pop();
                            },
                      child: Text(
                        l10n.cancel ?? "Cancel",
                        style: TextStyle(
                          color: isCreating ? Colors.grey : AppColors.secondary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isCreating
                          ? null
                          : () {
                              final wardName = wardController.text.trim();
                              if (wardName.isEmpty) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.pleaseEnterWardName ?? "Please enter ward name"),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              locationBloc.add(CreateNewWardEvent(wardName));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.add ?? "Add",
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider<LocationBloc>(
      create: (context) {
        final repository = getIt<LocationRepository>();
        return LocationBloc(repository: repository, initialUserRole: 'Farmer')
          ..add(LoadRegionsEvent());
      },
      child: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.locationSavedSuccess ?? "Congratulations! Location saved successfully 🎉",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.primary,
              ),
            );
            final role = state.userRole.toLowerCase();
            final dashboard = switch (role) {
              'farmer' => '/farmer/dashboard',
              'vet' => '/vet/dashboard',
              'researcher' => '/researcher/dashboard',
              _ => '/farmer/dashboard',
            };
            // ⭐ NAVIGATION: Navigate immediately upon success
            context.go(dashboard);
          } else if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? l10n.unknownError ?? "An unknown error occurred.",
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // ⭐ FIX: Wrap the leading IconButton in a BlocBuilder
            leading: BlocBuilder<LocationBloc, LocationState>(
              buildWhen: (previous, current) => 
                  previous.isLoading != current.isLoading || 
                  previous.isCreatingWard != current.isCreatingWard || 
                  previous is LocationSuccess != current is LocationSuccess,
              builder: (context, state) {
                final bool isSavingOrSuccess = state.isLoading || state.isCreatingWard || state is LocationSuccess;

                return IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  // ⭐ NAVIGATION GUARD: Disable back/skip if saving is in progress
                  onPressed: isSavingOrSuccess
                      ? null
                      : () => context.go('/role-selection'),
                );
              },
            ),
          ),
          body: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              // Helper variable to check if the save button should be disabled
              final bool isSavingOrSuccess = state.isLoading || state.isCreatingWard || state is LocationSuccess;

              return Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Lottie Animation
                            Lottie.asset(
                              'assets/lottie/location.json',
                              height: 180,
                              repeat: true,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.location_on,
                                    size: 100,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                            Text(
                              l10n.setYourLocation ?? "Set Your Location",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.locationSubtitle ?? "This will help us provide better livestock services near you",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 32),

                            // --- Form Fields ---
                            if (state is LocationInitial && state.regions.isEmpty)
                              const Center(child: CircularProgressIndicator())
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Region Dropdown
                                  _DropdownField(
                                    label: l10n.region ?? "Region",
                                    items: state.regions,
                                    selectedId: state.selectedRegionId,
                                    onChanged: isSavingOrSuccess
                                        ? null
                                        : (id) => context
                                            .read<LocationBloc>()
                                            .add(SelectRegionEvent(id!)),
                                    enabled: state.regions.isNotEmpty &&
                                        !state.isCreatingWard && 
                                        !isSavingOrSuccess, // Disable while saving
                                    isLoading: state.isLoading && state.regions.isEmpty, // Only show initial load
                                    loadingText: '',
                                  ),
                                  const SizedBox(height: 20),

                                  // District Dropdown with Loading State
                                  _DropdownField(
                                    label: l10n.district ?? "District",
                                    items: state.districts,
                                    selectedId: state.selectedDistrictId,
                                    onChanged: isSavingOrSuccess
                                        ? null
                                        : (id) => context
                                            .read<LocationBloc>()
                                            .add(SelectDistrictEvent(id!)),
                                    enabled: state.selectedRegionId != null &&
                                        state.districts.isNotEmpty &&
                                        !state.isCreatingWard &&
                                        !state.isLoadingDistricts &&
                                        !isSavingOrSuccess, // Disable while saving
                                    isLoading: state.isLoadingDistricts,
                                    loadingText: l10n.loadingDistricts ?? "Loading districts...",
                                  ),
                                  const SizedBox(height: 20),

                                  // Ward Dropdown with Add Button and Loading State
                                  _WardDropdownWithAddButton(
                                    state: state,
                                    onAddWard: isSavingOrSuccess
                                        ? () {} // Null-safe stub
                                        : () => _showAddWardDialog(context),
                                    l10n: l10n,
                                  ),
                                  const SizedBox(height: 20),

                                  // GPS Button
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: state.selectedWardId == null ||
                                              isSavingOrSuccess
                                          ? null
                                          : () => context
                                              .read<LocationBloc>()
                                              .add(
                                                  RequestLocationPermissionEvent()),
                                      icon: isSavingOrSuccess
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.my_location),
                                      label: Text(
                                        state.hasGps
                                            ? "${l10n.gpsCaptured ?? 'GPS Captured'} (${state.latitude!.toStringAsFixed(4)}, ${state.longitude!.toStringAsFixed(4)})"
                                            : state.selectedWardId != null
                                                ? l10n.nowCaptureGps ?? "✓ Now capture GPS"
                                                : l10n.captureGps ??
                                                    "Capture My Location",
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            state.selectedWardId != null &&
                                                    !state.hasGps &&
                                                    !isSavingOrSuccess
                                                ? Colors.green
                                                : AppColors.secondary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 48),
                                ],
                              ),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (state.selectedWardId == null ||
                                        !state.hasGps ||
                                        isSavingOrSuccess) 
                                    ? null
                                    : () => context
                                        .read<LocationBloc>()
                                        .add(SaveUserLocationEvent()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: state.isLoading || state.isCreatingWard
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        l10n.saveLocation ?? "SAVE LOCATION",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            // REMOVED: Skip Button
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Global Loading Overlay ---
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

// --------------------------------------------------------------------------
// HELPER WIDGETS
// --------------------------------------------------------------------------
// ... (Helper widgets _DropdownField, _WardDropdownWithAddButton, GlobalLoadingOverlay remain unchanged)
// ...
// ...
// ...

class GlobalLoadingOverlay extends StatelessWidget {
  final AppLocalizations l10n;
  
  const GlobalLoadingOverlay({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                l10n.addingNewWard ?? "Adding new ward...",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Dropdown with Loading State
class _DropdownField extends StatelessWidget {
  final String label;
  final List<dynamic> items;
  final int? selectedId;
  final ValueChanged<int?>? onChanged; // Changed to nullable
  final bool enabled;
  final bool isLoading;
  final String loadingText;

  const _DropdownField({
    required this.label,
    required this.items,
    required this.selectedId,
    required this.onChanged,
    required this.enabled,
    this.isLoading = false,
    this.loadingText = '',
  });

  @override
  Widget build(BuildContext context) {
    // ⭐ Remove duplicate IDs to prevent assertion error
    final uniqueItems = <int, dynamic>{};
    for (var item in items) {
      final id = item is Map ? item['id'] as int : (item as dynamic).id as int;
      if (!uniqueItems.containsKey(id)) {
        uniqueItems[id] = item;
      }
    }

    // ⭐ Validate selectedId exists in unique items
    final validSelectedId =
        uniqueItems.containsKey(selectedId) ? selectedId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          value: validSelectedId,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          items: uniqueItems.entries.map<DropdownMenuItem<int>>((entry) {
            final item = entry.value;
            final id = entry.key;

            final name = item is Map
                ? (item['name'] ??
                    item['region_name'] ??
                    item['district_name'] ??
                    item['ward_name'] ??
                    'Unknown')
                : (item as dynamic).name ??
                    (item as dynamic).region_name ??
                    (item as dynamic).district_name ??
                    (item as dynamic).ward_name ??
                    'Unknown';

            return DropdownMenuItem<int>(
              value: id,
              child: Text(name.toString()),
            );
          }).toList(),
          // Use the provided onChanged, which is null-checked above.
          onChanged: enabled && !isLoading ? onChanged : null,
          validator: (v) => v == null ? 'Please select $label' : null,
        ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              loadingText,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

// Ward Dropdown with Add New Ward Button
class _WardDropdownWithAddButton extends StatelessWidget {
  final LocationState state;
  final VoidCallback onAddWard;
  final AppLocalizations l10n;

  const _WardDropdownWithAddButton({
    required this.state,
    required this.onAddWard,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // ⭐ Remove duplicate ward IDs
    final uniqueWards = <int, dynamic>{};
    for (var ward in state.wards) {
      final id = ward is Map ? ward['id'] as int : (ward as dynamic).id as int;
      if (!uniqueWards.containsKey(id)) {
        uniqueWards[id] = ward;
      }
    }

    // ⭐ Validate selectedWardId
    final validSelectedWardId =
        uniqueWards.containsKey(state.selectedWardId) ? state.selectedWardId : null;

    final isSavingOrSuccess = state.isLoading || state.isCreatingWard || state is LocationSuccess;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ward Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: validSelectedWardId,
              decoration: InputDecoration(
                labelText: l10n.ward ?? "Ward",
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.primary.withOpacity(0.3)),
                ),
                suffixIcon: state.isLoadingWards
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              items: uniqueWards.entries.map<DropdownMenuItem<int>>((entry) {
                final ward = entry.value;
                final id = entry.key;
                final name = ward is Map
                    ? ward['ward_name'] as String
                    : (ward as dynamic).ward_name as String;
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(name),
                );
              }).toList(),
              // ⭐ Disable if saving or successful
              onChanged: state.selectedDistrictId != null &&
                      !state.isCreatingWard &&
                      !state.isLoadingWards && 
                      !isSavingOrSuccess
                  ? (id) =>
                      context.read<LocationBloc>().add(SelectWardEvent(id!))
                  : null,
              validator: (v) => v == null ? 'Please select ward' : null,
            ),
            if (state.isLoadingWards)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  l10n.loadingWards ?? "Loading wards...",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Add New Ward Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            // ⭐ Disable if saving or successful
            onPressed: state.selectedDistrictId == null ||
                    state.isCreatingWard ||
                    state.isLoadingWards ||
                    isSavingOrSuccess
                ? null
                : onAddWard,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(l10n.addNewWard ?? "Add New Ward"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: state.selectedDistrictId == null ||
                        state.isLoadingWards ||
                        isSavingOrSuccess // Set border color gray if saving
                    ? Colors.grey
                    : AppColors.primary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}