// lib/features/auth/presentation/bloc/location/location_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;

  LocationBloc({required this.repository, required String initialUserRole})
      : super(LocationInitial().copyWith(
          userRole: initialUserRole,
          showNewWardPrompt: false,
          isCreatingWard: false,
          isLoading: false, // Ensure base state includes isLoading
        )) {
    on<LoadRegionsEvent>(_onLoadRegions);
    on<SelectRegionEvent>(_onSelectRegion);
    on<SelectDistrictEvent>(_onSelectDistrict);
    on<CreateNewWardEvent>(_onCreateNewWard);
    on<SelectWardEvent>(_onSelectWard);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<SaveUserLocationEvent>(_onSaveUserLocation);
  }

  // Helper function to remove duplicates from a list by ID
  List<dynamic> _removeDuplicates(List<dynamic> items) {
    final uniqueItems = <int, dynamic>{};
    for (var item in items) {
      final id = item is Map ? item['id'] as int : (item as dynamic).id as int;
      if (!uniqueItems.containsKey(id)) {
        uniqueItems[id] = item;
      }
    }
    return uniqueItems.values.toList();
  }

  // Helper function to safely cast/extract ID and name from dynamic object
  Map<String, dynamic> _extractWardData(dynamic ward) {
    if (ward is Map) {
      return {
        'id': ward['id'] as int?,
        'ward_name': ward['ward_name'] as String?,
      };
    }
    return {
      'id': (ward as dynamic).id as int?,
      'ward_name': (ward as dynamic).ward_name as String?,
    };
  }

  Future<void> _onLoadRegions(
    LoadRegionsEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading(state.copyWith(
      showNewWardPrompt: false,
      isCreatingWard: false,
      isLoading: true, // Use isLoading for network calls
    )));

    final result = await repository.getRegions();

    result.fold(
      (failure) => emit(LocationError(
        failure.message,
        state.copyWith(
          showNewWardPrompt: false,
          isCreatingWard: false,
          isLoading: false,
        ),
      )),
      (regions) {
        // ⭐ Remove duplicate regions
        final uniqueRegions = _removeDuplicates(regions);

        emit(state.copyWith(
          regions: uniqueRegions,
          showNewWardPrompt: false,
          isCreatingWard: false,
          isLoading: false, // Done loading
        ));
      },
    );
  }

  Future<void> _onSelectRegion(
    SelectRegionEvent event,
    Emitter<LocationState> emit,
  ) async {
    // ⭐ Show loading state for districts
    emit(state.copyWith(
      selectedRegionId: event.regionId,
      selectedDistrictId: null,
      selectedWardId: null,
      districts: const [],
      wards: const [],
      wardSearchText: '',
      showNewWardPrompt: false,
      isLoadingDistricts: true,
      isLoading: true, // Set general loading flag
    ));

    final result = await repository.getDistricts(event.regionId);

    result.fold(
      (failure) => emit(LocationError(
        failure.message,
        state.copyWith(isLoadingDistricts: false, isLoading: false),
      )),
      (districts) {
        // ⭐ Remove duplicate districts
        final uniqueDistricts = _removeDuplicates(districts);

        emit(state.copyWith(
          districts: uniqueDistricts,
          selectedRegionId: event.regionId,
          selectedDistrictId: null,
          selectedWardId: null,
          showNewWardPrompt: false,
          isLoadingDistricts: false,
          isLoading: false, // Done loading
        ));
      },
    );
  }

  Future<void> _onSelectDistrict(
    SelectDistrictEvent event,
    Emitter<LocationState> emit,
  ) async {
    // ⭐ Show loading state for wards
    emit(state.copyWith(
      selectedDistrictId: event.districtId,
      selectedWardId: null,
      wards: const [],
      wardSearchText: '',
      showNewWardPrompt: false,
      isLoadingWards: true,
      isLoading: true, // Set general loading flag
    ));

    // Load all wards for the selected district
    final result = await repository.getWards(event.districtId);

    result.fold(
      (failure) => emit(LocationError(
        failure.message,
        state.copyWith(isLoadingWards: false, isLoading: false),
      )),
      (wards) {
        // ⭐ Remove duplicate wards
        final uniqueWards = _removeDuplicates(wards);

        emit(state.copyWith(
          wards: uniqueWards,
          selectedDistrictId: event.districtId,
          selectedWardId: null,
          showNewWardPrompt: false,
          isLoadingWards: false,
          isLoading: false, // Done loading
        ));
      },
    );
  }

  Future<void> _onCreateNewWard(
    CreateNewWardEvent event,
    Emitter<LocationState> emit,
  ) async {
    if (state.selectedDistrictId == null) {
      emit(LocationError(
        "Please select a district first.",
        state.copyWith(showNewWardPrompt: false),
      ));
      return;
    }

    // Show loading overlay
    emit(LocationLoading(state.copyWith(
      isCreatingWard: true,
      showNewWardPrompt: false,
    )));

    final result = await repository.createWard(
      event.wardName,
      state.selectedDistrictId!,
    );

    result.fold(
      (failure) => emit(LocationError(
        failure.message,
        state.copyWith(isCreatingWard: false, isLoading: false), // Stop loading on error
      )),
      (newWard) {
        final wardData = _extractWardData(newWard);
        final newWardId = wardData['id'];
        final newWardName = wardData['ward_name'];

        if (newWardId == null || newWardName == null) {
          emit(LocationError(
            "Error: Could not get new ward ID.",
            state.copyWith(isCreatingWard: false, isLoading: false),
          ));
          return;
        }

        // Add the new ward to the wards list and select it
        final updatedWards = List<dynamic>.from(state.wards)
          ..add({
            'id': newWardId,
            'ward_name': newWardName,
          });

        // ⭐ Remove any potential duplicates after adding
        final uniqueWards = _removeDuplicates(updatedWards);

        emit(state.copyWith(
          selectedWardId: newWardId,
          wards: uniqueWards,
          wardSearchText: newWardName,
          isCreatingWard: false, // Stop ward creating flag
          showNewWardPrompt: false,
          isLoading: false, // Stop general loading flag
        ));
      },
    );
  }

  void _onSelectWard(
    SelectWardEvent event,
    Emitter<LocationState> emit,
  ) {
    // Find the ward name from the wards list
    final selectedWard = state.wards.firstWhere(
      (ward) {
        final id = ward is Map ? ward['id'] as int : (ward as dynamic).id as int;
        return id == event.wardId;
      },
      orElse: () => null,
    );

    String wardName = '';
    if (selectedWard != null) {
      wardName = selectedWard is Map
          ? selectedWard['ward_name'] as String
          : (selectedWard as dynamic).ward_name as String;
    }

    emit(state.copyWith(
      selectedWardId: event.wardId,
      wardSearchText: wardName,
      showNewWardPrompt: false,
    ));
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<LocationState> emit,
  ) async {
    // ⭐ Use LocationLoading to ensure the save button is disabled immediately
    emit(LocationLoading(state.copyWith(
      isLoading: true,
      showNewWardPrompt: false,
    )));

    var permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // ⭐ Set isLoading to false when captured
        emit(LocationGpsCaptured(
          state,
          position.latitude,
          position.longitude,
        ).copyWith(isLoading: false)); 

      } on LocationServiceDisabledException {
        emit(LocationError(
          "Please enable GPS/Location services on your device.",
          state.copyWith(isLoading: false),
        ));
      } catch (e) {
        emit(LocationError(
          "GPS Error: ${e.toString()}",
          state.copyWith(isLoading: false),
        ));
      }
    } else {
      emit(LocationError(
        "Location permission is required to capture GPS.",
        state.copyWith(isLoading: false),
      ));
    }
  }

  Future<void> _onSaveUserLocation(
    SaveUserLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    // 1. Guard against subsequent calls while loading or successful
    if (state.isLoading || state is LocationSuccess) {
        // Log.warning('Attempted duplicate submission while loading or succeeded.');
        return;
    }
    
    // 2. Perform comprehensive null check and assign to local variables
    final int? regionId = state.selectedRegionId;
    final int? districtId = state.selectedDistrictId;
    final int? wardId = state.selectedWardId;
    final double? latitude = state.latitude;
    final double? longitude = state.longitude;

    if (regionId == null ||
        districtId == null ||
        wardId == null ||
        latitude == null ||
        longitude == null) { // Removed !state.hasGps as null checks cover it
      emit(LocationError(
        "Please select complete location and capture GPS first.",
        state.copyWith(showNewWardPrompt: false),
      ));
      return;
    }

    // 3. Set isLoading to true to disable the button immediately
    emit(LocationLoading(state.copyWith(isLoading: true)));

    final result = await repository.saveUserLocation(
      regionId: regionId, // Use safe local variable
      districtId: districtId, // Use safe local variable
      wardId: wardId, // Use safe local variable
      latitude: latitude, // Use safe local variable
      longitude: longitude, // Use safe local variable
    );

    result.fold(
      // 4. Set isLoading to false on failure so user can re-try
      (failure) => emit(LocationError(failure.message, state.copyWith(isLoading: false))),
      // 5. On success, emit LocationSuccess
      (_) => emit(LocationSuccess(current: state, userRole: state.userRole)),
    );
  }
}