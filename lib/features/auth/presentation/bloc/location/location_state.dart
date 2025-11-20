// lib/features/auth/presentation/bloc/location/location_state.dart

part of 'location_bloc.dart';

abstract class LocationState {
  final List<dynamic> regions;
  final List<dynamic> districts;
  final List<dynamic> wards;
  final List<dynamic> wardSearchResults;
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
  final bool isLoadingDistricts; // ⭐ NEW: Loading state for districts
  final bool isLoadingWards; // ⭐ NEW: Loading state for wards

  const LocationState({
    this.regions = const [],
    this.districts = const [],
    this.wards = const [],
    this.wardSearchResults = const [],
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
    this.isLoadingDistricts = false, // ⭐ NEW: Initialize to false
    this.isLoadingWards = false, // ⭐ NEW: Initialize to false
  });

  LocationState copyWith({
    List<dynamic>? regions,
    List<dynamic>? districts,
    List<dynamic>? wards,
    List<dynamic>? wardSearchResults,
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
    bool? isLoadingDistricts, // ⭐ NEW: Add to copyWith
    bool? isLoadingWards, // ⭐ NEW: Add to copyWith
  }) {
    return LocationLoaded(
      regions: regions ?? this.regions,
      districts: districts ?? this.districts,
      wards: wards ?? this.wards,
      wardSearchResults: wardSearchResults ?? this.wardSearchResults,
      selectedRegionId: selectedRegionId ?? this.selectedRegionId,
      selectedDistrictId: selectedDistrictId ?? this.selectedDistrictId,
      selectedWardId: selectedWardId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? false,
      hasGps: hasGps ?? this.hasGps,
      errorMessage: errorMessage,
      userRole: userRole ?? this.userRole,
      wardSearchText: wardSearchText ?? this.wardSearchText,
      isCreatingWard: isCreatingWard ?? this.isCreatingWard,
      showNewWardPrompt: showNewWardPrompt ?? this.showNewWardPrompt,
      isLoadingDistricts: isLoadingDistricts ?? this.isLoadingDistricts, // ⭐ NEW
      isLoadingWards: isLoadingWards ?? this.isLoadingWards, // ⭐ NEW
    );
  }
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {
  LocationLoading(LocationState current)
      : super(
          regions: current.regions,
          districts: current.districts,
          wards: current.wards,
          wardSearchResults: current.wardSearchResults,
          selectedRegionId: current.selectedRegionId,
          selectedDistrictId: current.selectedDistrictId,
          selectedWardId: current.selectedWardId,
          latitude: current.latitude,
          longitude: current.longitude,
          hasGps: current.hasGps,
          userRole: current.userRole,
          wardSearchText: current.wardSearchText,
          isCreatingWard: current.isCreatingWard,
          showNewWardPrompt: current.showNewWardPrompt,
          isLoadingDistricts: current.isLoadingDistricts, // ⭐ NEW
          isLoadingWards: current.isLoadingWards, // ⭐ NEW
          isLoading: true,
          errorMessage: null,
        );
}

class LocationLoaded extends LocationState {
  LocationLoaded({
    super.regions,
    super.districts,
    super.wards,
    super.wardSearchResults,
    super.selectedRegionId,
    super.selectedDistrictId,
    super.selectedWardId,
    super.latitude,
    super.longitude,
    super.hasGps,
    super.isLoading,
    super.errorMessage,
    super.userRole,
    super.wardSearchText,
    super.isCreatingWard,
    super.showNewWardPrompt,
    super.isLoadingDistricts, // ⭐ NEW
    super.isLoadingWards, // ⭐ NEW
  });

  @override
  LocationState copyWith({
    List<dynamic>? regions,
    List<dynamic>? districts,
    List<dynamic>? wards,
    List<dynamic>? wardSearchResults,
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
    bool? isLoadingDistricts, // ⭐ NEW
    bool? isLoadingWards, // ⭐ NEW
  }) {
    return LocationLoaded(
      regions: regions ?? this.regions,
      districts: districts ?? this.districts,
      wards: wards ?? this.wards,
      wardSearchResults: wardSearchResults ?? this.wardSearchResults,
      selectedRegionId: selectedRegionId ?? this.selectedRegionId,
      selectedDistrictId: selectedDistrictId ?? this.selectedDistrictId,
      selectedWardId: selectedWardId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? false,
      hasGps: hasGps ?? this.hasGps,
      errorMessage: errorMessage,
      userRole: userRole ?? this.userRole,
      wardSearchText: wardSearchText ?? this.wardSearchText,
      isCreatingWard: isCreatingWard ?? this.isCreatingWard,
      showNewWardPrompt: showNewWardPrompt ?? this.showNewWardPrompt,
      isLoadingDistricts: isLoadingDistricts ?? this.isLoadingDistricts, // ⭐ NEW
      isLoadingWards: isLoadingWards ?? this.isLoadingWards, // ⭐ NEW
    );
  }
}

class LocationGpsCaptured extends LocationState {
  LocationGpsCaptured(LocationState current, double lat, double lng)
      : super(
          regions: current.regions,
          districts: current.districts,
          wards: current.wards,
          wardSearchResults: current.wardSearchResults,
          selectedRegionId: current.selectedRegionId,
          selectedDistrictId: current.selectedDistrictId,
          selectedWardId: current.selectedWardId,
          userRole: current.userRole,
          wardSearchText: current.wardSearchText,
          isCreatingWard: current.isCreatingWard,
          showNewWardPrompt: current.showNewWardPrompt,
          isLoadingDistricts: current.isLoadingDistricts, // ⭐ NEW
          isLoadingWards: current.isLoadingWards, // ⭐ NEW
          latitude: lat,
          longitude: lng,
          hasGps: true,
          isLoading: false,
          errorMessage: null,
        );
}

class LocationError extends LocationState {
  LocationError(String message, LocationState current)
      : super(
          regions: current.regions,
          districts: current.districts,
          wards: current.wards,
          wardSearchResults: current.wardSearchResults,
          selectedRegionId: current.selectedRegionId,
          selectedDistrictId: current.selectedDistrictId,
          selectedWardId: current.selectedWardId,
          latitude: current.latitude,
          longitude: current.longitude,
          hasGps: current.hasGps,
          userRole: current.userRole,
          wardSearchText: current.wardSearchText,
          isCreatingWard: current.isCreatingWard,
          showNewWardPrompt: current.showNewWardPrompt,
          isLoadingDistricts: current.isLoadingDistricts, // ⭐ NEW
          isLoadingWards: current.isLoadingWards, // ⭐ NEW
          errorMessage: message,
          isLoading: false,
        );
}

class LocationSuccess extends LocationState {
  LocationSuccess({required LocationState current, required String userRole})
      : super(
          regions: current.regions,
          districts: current.districts,
          wards: current.wards,
          wardSearchResults: current.wardSearchResults,
          selectedRegionId: current.selectedRegionId,
          selectedDistrictId: current.selectedDistrictId,
          selectedWardId: current.selectedWardId,
          latitude: current.latitude,
          longitude: current.longitude,
          hasGps: current.hasGps,
          userRole: userRole,
          wardSearchText: current.wardSearchText,
          isCreatingWard: current.isCreatingWard,
          showNewWardPrompt: current.showNewWardPrompt,
          isLoadingDistricts: current.isLoadingDistricts,
          isLoadingWards: current.isLoadingWards, 
          isLoading: false,
          errorMessage: null,
        );
}