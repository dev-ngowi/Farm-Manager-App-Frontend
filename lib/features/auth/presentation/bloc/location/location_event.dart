part of 'location_bloc.dart';


abstract class LocationEvent extends Equatable {
const LocationEvent();

@override
List<Object> get props => [];
}

class LoadRegionsEvent extends LocationEvent {}

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

class RequestLocationPermissionEvent extends LocationEvent {}

class SaveUserLocationEvent extends LocationEvent {}

// FIX: Add the missing event to dismiss the new ward prompt
class DismissNewWardPromptEvent extends LocationEvent {
const DismissNewWardPromptEvent();
@override
List<Object> get props => [];
}