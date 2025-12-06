// lib/features/auth/presentation/bloc/location/location_state.dart

part of 'location_bloc.dart';


abstract class LocationState extends Equatable {
  final List<dynamic> regions;
  final List<dynamic> districts;
  final List<dynamic> wards;
  final List<LocationEntity> userLocations;

  final int? selectedRegionId;
  final int? selectedDistrictId;
  final int? selectedWardId;

  final double? latitude;
  final double? longitude;

  final bool isLoading;
  final bool hasGps;
  final String? errorMessage;

  final String userRole;
  final String wardSearchText;

  final bool isCreatingWard;
  final bool showNewWardPrompt;
  final bool isLoadingDistricts;
  final bool isLoadingWards;
  final bool isLoadingLocations;

  final bool locationSaved;
  final LocationEntity? savedLocation; // THIS WAS MISSING!

  const LocationState({
    this.regions = const [],
    this.districts = const [],
    this.wards = const [],
    this.userLocations = const [],
    this.selectedRegionId,
    this.selectedDistrictId,
    this.selectedWardId,
    this.latitude,
    this.longitude,
    this.isLoading = false,
    this.hasGps = false,
    this.errorMessage,
    this.userRole = 'Farmer',
    this.wardSearchText = '',
    this.isCreatingWard = false,
    this.showNewWardPrompt = false,
    this.isLoadingDistricts = false,
    this.isLoadingWards = false,
    this.isLoadingLocations = false,
    this.locationSaved = false,
    this.savedLocation,
  });

  @override
  List<Object?> get props => [
        regions,
        districts,
        wards,
        userLocations,
        selectedRegionId,
        selectedDistrictId,
        selectedWardId,
        latitude,
        longitude,
        isLoading,
        hasGps,
        errorMessage,
        userRole,
        wardSearchText,
        isCreatingWard,
        showNewWardPrompt,
        isLoadingDistricts,
        isLoadingWards,
        isLoadingLocations,
        locationSaved,
        savedLocation, // ADD THIS!
      ];

  LocationState copyWith({
    List<dynamic>? regions,
    List<dynamic>? districts,
    List<dynamic>? wards,
    List<LocationEntity>? userLocations,
    int? selectedRegionId,
    int? selectedDistrictId,
    int? selectedWardId,
    double? latitude,
    double? longitude,
    bool? isLoading,
    bool? hasGps,
    String? errorMessage,
    String? userRole,
    String? wardSearchText,
    bool? isCreatingWard,
    bool? showNewWardPrompt,
    bool? isLoadingDistricts,
    bool? isLoadingWards,
    bool? isLoadingLocations,
    bool? locationSaved,
    LocationEntity? savedLocation, // ADD THIS!
  }) {
    return LocationLoaded(
      regions: regions ?? this.regions,
      districts: districts ?? this.districts,
      wards: wards ?? this.wards,
      userLocations: userLocations ?? this.userLocations,
      selectedRegionId: selectedRegionId ?? this.selectedRegionId,
      selectedDistrictId: selectedDistrictId ?? this.selectedDistrictId,
      selectedWardId: selectedWardId ?? this.selectedWardId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      hasGps: hasGps ?? this.hasGps,
      errorMessage: errorMessage ?? this.errorMessage,
      userRole: userRole ?? this.userRole,
      wardSearchText: wardSearchText ?? this.wardSearchText,
      isCreatingWard: isCreatingWard ?? this.isCreatingWard,
      showNewWardPrompt: showNewWardPrompt ?? this.showNewWardPrompt,
      isLoadingDistricts: isLoadingDistricts ?? this.isLoadingDistricts,
      isLoadingWards: isLoadingWards ?? this.isLoadingWards,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      locationSaved: locationSaved ?? this.locationSaved,
      savedLocation: savedLocation ?? this.savedLocation, // ADD THIS!
    );
  }
}

class LocationInitial extends LocationState {
  const LocationInitial();

  @override
  List<Object?> get props => [...super.props];
}

class LocationLoading extends LocationState {
  const LocationLoading({
    List<dynamic> regions = const [],
    List<dynamic> districts = const [],
    List<dynamic> wards = const [],
    List<LocationEntity> userLocations = const [],
    int? selectedRegionId,
    int? selectedDistrictId,
    int? selectedWardId,
    double? latitude,
    double? longitude,
    bool hasGps = false,
    String userRole = 'Farmer',
    String wardSearchText = '',
    bool isCreatingWard = false,
    bool showNewWardPrompt = false,
    bool isLoadingDistricts = false,
    bool isLoadingWards = false,
    bool isLoadingLocations = false,
    bool locationSaved = false,
    LocationEntity? savedLocation,
  }) : super(
          regions: regions,
          districts: districts,
          wards: wards,
          userLocations: userLocations,
          selectedRegionId: selectedRegionId,
          selectedDistrictId: selectedDistrictId,
          selectedWardId: selectedWardId,
          latitude: latitude,
          longitude: longitude,
          hasGps: hasGps,
          userRole: userRole,
          wardSearchText: wardSearchText,
          isCreatingWard: isCreatingWard,
          showNewWardPrompt: showNewWardPrompt,
          isLoadingDistricts: isLoadingDistricts,
          isLoadingWards: isLoadingWards,
          isLoadingLocations: isLoadingLocations,
          locationSaved: locationSaved,
          savedLocation: savedLocation,
          isLoading: true,
          errorMessage: null,
        );

  @override
  List<Object?> get props => [...super.props];
}

class LocationLoaded extends LocationState {
  const LocationLoaded({
    super.regions = const [],
    super.districts = const [],
    super.wards = const [],
    super.userLocations = const [],
    super.selectedRegionId,
    super.selectedDistrictId,
    super.selectedWardId,
    super.latitude,
    super.longitude,
    super.hasGps = false,
    super.isLoading = false,
    super.errorMessage,
    super.userRole = 'Farmer',
    super.wardSearchText = '',
    super.isCreatingWard = false,
    super.showNewWardPrompt = false,
    super.isLoadingDistricts = false,
    super.isLoadingWards = false,
    super.isLoadingLocations = false,
    super.locationSaved = false,
    super.savedLocation, // ADD THIS!
  });

  @override
  List<Object?> get props => [...super.props];
}

class UserLocationsLoaded extends LocationState {
  const UserLocationsLoaded({
    required List<LocationEntity> locations,
    List<dynamic> regions = const [],
    List<dynamic> districts = const [],
    List<dynamic> wards = const [],
    int? selectedRegionId,
    int? selectedDistrictId,
    int? selectedWardId,
    double? latitude,
    double? longitude,
    bool hasGps = false,
    String userRole = 'Farmer',
    String wardSearchText = '',
    bool isCreatingWard = false,
    bool showNewWardPrompt = false,
    bool isLoadingDistricts = false,
    bool isLoadingWards = false,
    bool locationSaved = false,
    LocationEntity? savedLocation,
  }) : super(
          regions: regions,
          districts: districts,
          wards: wards,
          userLocations: locations,
          selectedRegionId: selectedRegionId,
          selectedDistrictId: selectedDistrictId,
          selectedWardId: selectedWardId,
          latitude: latitude,
          longitude: longitude,
          hasGps: hasGps,
          userRole: userRole,
          wardSearchText: wardSearchText,
          isCreatingWard: isCreatingWard,
          showNewWardPrompt: showNewWardPrompt,
          isLoadingDistricts: isLoadingDistricts,
          isLoadingWards: isLoadingWards,
          isLoadingLocations: false,
          locationSaved: locationSaved,
          savedLocation: savedLocation,
          isLoading: false,
          errorMessage: null,
        );

  @override
  List<Object?> get props => [...super.props];
}

class LocationError extends LocationState {
  const LocationError({
    required String message,
    List<dynamic> regions = const [],
    List<dynamic> districts = const [],
    List<dynamic> wards = const [],
    List<LocationEntity> userLocations = const [],
    int? selectedRegionId,
    int? selectedDistrictId,
    int? selectedWardId,
    double? latitude,
    double? longitude,
    bool hasGps = false,
    String userRole = 'Farmer',
    String wardSearchText = '',
    bool isCreatingWard = false,
    bool showNewWardPrompt = false,
    bool isLoadingDistricts = false,
    bool isLoadingWards = false,
    bool isLoadingLocations = false,
    bool locationSaved = false,
    LocationEntity? savedLocation,
  }) : super(
          regions: regions,
          districts: districts,
          wards: wards,
          userLocations: userLocations,
          selectedRegionId: selectedRegionId,
          selectedDistrictId: selectedDistrictId,
          selectedWardId: selectedWardId,
          latitude: latitude,
          longitude: longitude,
          hasGps: hasGps,
          errorMessage: message,
          userRole: userRole,
          wardSearchText: wardSearchText,
          isCreatingWard: isCreatingWard,
          showNewWardPrompt: showNewWardPrompt,
          isLoadingDistricts: isLoadingDistricts,
          isLoadingWards: isLoadingWards,
          isLoadingLocations: isLoadingLocations,
          locationSaved: locationSaved,
          savedLocation: savedLocation,
          isLoading: false,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}