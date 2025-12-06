
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;

  LocationBloc({required this.repository}) : super(const LocationInitial()) {
    on<LoadRegionsEvent>(_onLoadRegions);
    on<SelectRegionEvent>(_onSelectRegion);
    on<SelectDistrictEvent>(_onSelectDistrict);
    on<CreateNewWardEvent>(_onCreateNewWard);
    on<SelectWardEvent>(_onSelectWard);
    on<DismissNewWardPromptEvent>(_onDismissNewWardPrompt);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<SaveUserLocationEvent>(_onSaveUserLocation);
    on<FetchUserLocationsEvent>(_onFetchUserLocations);
  }

  // Helper methods
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

  // Event handlers
  Future<void> _onLoadRegions(
      LoadRegionsEvent event, Emitter<LocationState> emit) async {
    emit(const LocationLoading());

    final result = await repository.getRegions();

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (regions) {
        final uniqueRegions = _removeDuplicates(regions);
        emit(LocationLoaded(regions: uniqueRegions));
      },
    );
  }

  Future<void> _onSelectRegion(
      SelectRegionEvent event, Emitter<LocationState> emit) async {
    emit(LocationLoading(
      regions: state.regions,
      userLocations: state.userLocations,
      isLoadingDistricts: true,
    ));

    final result = await repository.getDistricts(event.regionId);

    result.fold(
      (failure) => emit(LocationError(
        message: failure.message,
        regions: state.regions,
        userLocations: state.userLocations,
      )),
      (districts) {
        final uniqueDistricts = _removeDuplicates(districts);
        emit(LocationLoaded(
          regions: state.regions,
          districts: uniqueDistricts,
          selectedRegionId: event.regionId,
          userLocations: state.userLocations,
        ));
      },
    );
  }

  Future<void> _onSelectDistrict(
      SelectDistrictEvent event, Emitter<LocationState> emit) async {
    emit(LocationLoading(
      regions: state.regions,
      districts: state.districts,
      selectedRegionId: state.selectedRegionId,
      userLocations: state.userLocations,
      isLoadingWards: true,
    ));

    final result = await repository.getWards(event.districtId);

    result.fold(
      (failure) => emit(LocationError(
        message: failure.message,
        regions: state.regions,
        districts: state.districts,
        selectedRegionId: state.selectedRegionId,
        userLocations: state.userLocations,
      )),
      (wards) {
        final uniqueWards = _removeDuplicates(wards);
        emit(LocationLoaded(
          regions: state.regions,
          districts: state.districts,
          wards: uniqueWards,
          selectedRegionId: state.selectedRegionId,
          selectedDistrictId: event.districtId,
          userLocations: state.userLocations,
        ));
      },
    );
  }

  Future<void> _onCreateNewWard(
      CreateNewWardEvent event, Emitter<LocationState> emit) async {
    if (state.selectedDistrictId == null) {
      emit(LocationError(
        message: "Please select a district first.",
        regions: state.regions,
        districts: state.districts,
        selectedRegionId: state.selectedRegionId,
        userLocations: state.userLocations,
      ));
      return;
    }

    emit(LocationLoading(
      regions: state.regions,
      districts: state.districts,
      wards: state.wards,
      selectedRegionId: state.selectedRegionId,
      selectedDistrictId: state.selectedDistrictId,
      userLocations: state.userLocations,
      isCreatingWard: true,
    ));

    final result = await repository.createWard(event.wardName, state.selectedDistrictId!);

    result.fold(
      (failure) => emit(LocationError(
        message: failure.message,
        regions: state.regions,
        districts: state.districts,
        wards: state.wards,
        selectedRegionId: state.selectedRegionId,
        selectedDistrictId: state.selectedDistrictId,
        userLocations: state.userLocations,
      )),
      (newWard) {
        final wardData = _extractWardData(newWard);
        final newWardId = wardData['id'];
        final newWardName = wardData['ward_name'];

        if (newWardId == null || newWardName == null) {
          emit(LocationError(
            message: "Error: Could not get new ward ID.",
            regions: state.regions,
            districts: state.districts,
            wards: state.wards,
            selectedRegionId: state.selectedRegionId,
            selectedDistrictId: state.selectedDistrictId,
            userLocations: state.userLocations,
          ));
          return;
        }

        final updatedWards = List<dynamic>.from(state.wards)
          ..add({'id': newWardId, 'ward_name': newWardName});
        final uniqueWards = _removeDuplicates(updatedWards);

        emit(LocationLoaded(
          regions: state.regions,
          districts: state.districts,
          wards: uniqueWards,
          selectedRegionId: state.selectedRegionId,
          selectedDistrictId: state.selectedDistrictId,
          selectedWardId: newWardId,
          wardSearchText: newWardName,
          userLocations: state.userLocations,
        ));
      },
    );
  }

  void _onSelectWard(SelectWardEvent event, Emitter<LocationState> emit) {
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

    emit(LocationLoaded(
      regions: state.regions,
      districts: state.districts,
      wards: state.wards,
      selectedRegionId: state.selectedRegionId,
      selectedDistrictId: state.selectedDistrictId,
      selectedWardId: event.wardId,
      wardSearchText: wardName,
      userLocations: state.userLocations,
    ));
  }

  void _onDismissNewWardPrompt(
      DismissNewWardPromptEvent event, Emitter<LocationState> emit) {
    emit(LocationLoaded(
      regions: state.regions,
      districts: state.districts,
      wards: state.wards,
      selectedRegionId: state.selectedRegionId,
      selectedDistrictId: state.selectedDistrictId,
      selectedWardId: state.selectedWardId,
      userLocations: state.userLocations,
      showNewWardPrompt: false,
    ));
  }

  Future<void> _onRequestLocationPermission(
      RequestLocationPermissionEvent event, Emitter<LocationState> emit) async {
    emit(LocationLoading(
      regions: state.regions,
      districts: state.districts,
      wards: state.wards,
      selectedRegionId: state.selectedRegionId,
      selectedDistrictId: state.selectedDistrictId,
      selectedWardId: state.selectedWardId,
      wardSearchText: state.wardSearchText,
      userLocations: state.userLocations,
    ));

    var permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        emit(LocationLoaded(
          regions: state.regions,
          districts: state.districts,
          wards: state.wards,
          selectedRegionId: state.selectedRegionId,
          selectedDistrictId: state.selectedDistrictId,
          selectedWardId: state.selectedWardId,
          wardSearchText: state.wardSearchText,
          userLocations: state.userLocations,
          latitude: position.latitude,
          longitude: position.longitude,
          hasGps: true,
        ));
      } on LocationServiceDisabledException {
        emit(LocationError(
          message: "Please enable GPS/Location services on your device.",
          regions: state.regions,
          districts: state.districts,
          wards: state.wards,
          selectedRegionId: state.selectedRegionId,
          selectedDistrictId: state.selectedDistrictId,
          selectedWardId: state.selectedWardId,
          userLocations: state.userLocations,
        ));
      } catch (e) {
        emit(LocationError(
          message: "GPS Error: ${e.toString()}",
          regions: state.regions,
          districts: state.districts,
          wards: state.wards,
          selectedRegionId: state.selectedRegionId,
          selectedDistrictId: state.selectedDistrictId,
          selectedWardId: state.selectedWardId,
          userLocations: state.userLocations,
        ));
      }
    } else {
      emit(LocationError(
        message: "Location permission is required to capture GPS.",
        regions: state.regions,
        districts: state.districts,
        wards: state.wards,
        selectedRegionId: state.selectedRegionId,
        selectedDistrictId: state.selectedDistrictId,
        selectedWardId: state.selectedWardId,
        userLocations: state.userLocations,
      ));
    }
  }

  /// FULLY FIXED: Now returns the complete LocationEntity
  Future<void> _onSaveUserLocation(
    SaveUserLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    final int? regionId = state.selectedRegionId;
    final int? districtId = state.selectedDistrictId;
    final int? wardId = state.selectedWardId;
    final double? latitude = state.latitude;
    final double? longitude = state.longitude;
    final String userRole = state.userRole;

    if (regionId == null || districtId == null || wardId == null ||
        latitude == null || longitude == null) {
      final missingFields = <String>[];
      if (regionId == null) missingFields.add('region');
      if (districtId == null) missingFields.add('district');
      if (wardId == null) missingFields.add('ward');
      if (latitude == null || longitude == null) missingFields.add('GPS');

      emit(LocationError(
        message: "Please complete all steps: ${missingFields.join(', ')}",
        regions: state.regions,
        districts: state.districts,
        wards: state.wards,
        selectedRegionId: state.selectedRegionId,
        selectedDistrictId: state.selectedDistrictId,
        selectedWardId: state.selectedWardId,
        userLocations: state.userLocations,
      ));
      return;
    }

    emit(LocationLoading(
      regions: state.regions,
      districts: state.districts,
      wards: state.wards,
      selectedRegionId: state.selectedRegionId,
      selectedDistrictId: state.selectedDistrictId,
      selectedWardId: state.selectedWardId,
      wardSearchText: state.wardSearchText,
      userLocations: state.userLocations,
      latitude: state.latitude,
      longitude: state.longitude,
      hasGps: state.hasGps,
    ));

    final result = await repository.saveUserLocation(
      regionId: regionId,
      districtId: districtId,
      wardId: wardId,
      latitude: latitude,
      longitude: longitude,
    );

    result.fold(
      (failure) => emit(LocationError(
        message: failure.message,
        regions: state.regions,
        districts: state.districts,
        wards: state.wards,
        selectedRegionId: state.selectedRegionId,
        selectedDistrictId: state.selectedDistrictId,
        selectedWardId: state.selectedWardId,
        userLocations: state.userLocations,
      )),
      (savedLocationEntity) {
        print('Location saved successfully! ID: ${savedLocationEntity.locationId}');
        print('   → ${savedLocationEntity.displayName}');

        emit(LocationLoaded(
          regions: state.regions,
          districts: state.districts,
          wards: state.wards,
          selectedRegionId: state.selectedRegionId,
          selectedDistrictId: state.selectedDistrictId,
          selectedWardId: state.selectedWardId,
          wardSearchText: state.wardSearchText,
          userLocations: state.userLocations,
          latitude: state.latitude,
          longitude: state.longitude,
          hasGps: state.hasGps,
          userRole: userRole,
          locationSaved: true,
          savedLocation: savedLocationEntity, // THIS IS THE KEY!
        ));
      },
    );
  }

  Future<void> _onFetchUserLocations(
    FetchUserLocationsEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading(
      regions: state.regions,
      districts: state.districts,
      wards: state.wards,
      selectedRegionId: state.selectedRegionId,
      selectedDistrictId: state.selectedDistrictId,
      selectedWardId: state.selectedWardId,
      wardSearchText: state.wardSearchText,
      userLocations: state.userLocations,
      latitude: state.latitude,
      longitude: state.longitude,
      hasGps: state.hasGps,
      isLoadingLocations: true,
    ));

    try {
      final result = await repository.getUserLocations(event.token);

      result.fold(
        (failure) => emit(LocationError(
          message: failure.message,
          regions: state.regions,
          districts: state.districts,
          wards: state.wards,
          selectedRegionId: state.selectedRegionId,
          selectedDistrictId: state.selectedDistrictId,
          selectedWardId: state.selectedWardId,
          userLocations: state.userLocations,
          latitude: state.latitude,
          longitude: state.longitude,
          hasGps: state.hasGps,
        )),
        (locations) => emit(UserLocationsLoaded(
          regions: state.regions,
          districts: state.districts,
          wards: state.wards,
          selectedRegionId: state.selectedRegionId,
          selectedDistrictId: state.selectedDistrictId,
          selectedWardId: state.selectedWardId,
          wardSearchText: state.wardSearchText,
          locations: locations,
          latitude: state.latitude,
          longitude: state.longitude,
          hasGps: state.hasGps,
        )),
      );
    } catch (e) {
      emit(LocationError(
        message: 'Failed to fetch locations: $e',
        regions: state.regions,
        districts: state.districts,
        wards: state.wards,
        selectedRegionId: state.selectedRegionId,
        selectedDistrictId: state.selectedDistrictId,
        selectedWardId: state.selectedWardId,
        userLocations: state.userLocations,
        latitude: state.latitude,
        longitude: state.longitude,
        hasGps: state.hasGps,
      ));
    }
  }
}