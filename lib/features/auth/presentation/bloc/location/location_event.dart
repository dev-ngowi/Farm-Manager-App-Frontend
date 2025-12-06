// lib/features/auth/presentation/bloc/location/location_event.dart
part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class LoadRegionsEvent extends LocationEvent {
  const LoadRegionsEvent();
}

class SelectRegionEvent extends LocationEvent {
  final int regionId;
  
  const SelectRegionEvent(this.regionId);
  
  @override
  List<Object> get props => [regionId];
}

class SelectDistrictEvent extends LocationEvent {
  final int districtId;
  
  const SelectDistrictEvent(this.districtId);
  
  @override
  List<Object> get props => [districtId];
}

class SearchWardEvent extends LocationEvent {
  final String query;
  
  const SearchWardEvent(this.query);
  
  @override
  List<Object> get props => [query];
}

class CreateNewWardEvent extends LocationEvent {
  final String wardName;
  
  const CreateNewWardEvent(this.wardName);
  
  @override
  List<Object> get props => [wardName];
}

class SelectWardEvent extends LocationEvent {
  final int wardId;
  
  const SelectWardEvent(this.wardId);
  
  @override
  List<Object> get props => [wardId];
}

class DismissNewWardPromptEvent extends LocationEvent {
  const DismissNewWardPromptEvent();
}

class RequestLocationPermissionEvent extends LocationEvent {
  const RequestLocationPermissionEvent();
}

class SaveUserLocationEvent extends LocationEvent {
  const SaveUserLocationEvent();
}

class FetchUserLocationsEvent extends LocationEvent {
  final String token;

  const FetchUserLocationsEvent({required this.token});

  @override
  List<Object> get props => [token];
}