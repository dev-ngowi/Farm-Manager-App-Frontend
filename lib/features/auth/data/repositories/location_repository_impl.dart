// lib/features/auth/data/repositories/location_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/networking/api_client.dart';
import 'package:farm_manager_app/core/networking/network_info.dart';
import 'package:farm_manager_app/features/auth/data/datasources/location/location_datasource.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/location_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
import 'package:farm_manager_app/features/auth/data/models/location_model.dart';
import '../../../../core/error/failure.dart';

class LocationRepositoryImpl implements LocationRepository {
  
  // 1. Define final fields for the dependencies
  final LocationDataSource _locationDataSource;
  final NetworkInfo _networkInfo;

  // 2. Assign the dependencies using the constructor
  LocationRepositoryImpl(this._locationDataSource, this._networkInfo);
  // NOTE: Your locator should now use positional arguments:
  // LocationRepositoryImpl(getIt<LocationDataSource>(), getIt<NetworkInfo>())

  // ----------------------------------------------------------------------
  // GET METHODS
  // ----------------------------------------------------------------------

  @override
  Future<Either<Failure, List<dynamic>>> getRegions() async {
    // Current implementation uses ApiClient directly (needs refactoring to use _locationDataSource)
    final result = await ApiClient.get('/locations/regions'); 
    
    return result.fold(
      (exception) => Left(FailureConverter.fromException(exception)),
      (data) => Right(data['data'] as List<dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<dynamic>>> getDistricts(int regionId) async {
    final result = await ApiClient.get('/locations/districts', query: {'region_id': regionId});
    
    return result.fold(
      (exception) => Left(FailureConverter.fromException(exception)),
      (data) => Right(data['data'] as List<dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<dynamic>>> getWards(int districtId) async {
    final result = await ApiClient.get('/locations/wards', query: {'district_id': districtId});
    
    return result.fold(
      (exception) => Left(FailureConverter.fromException(exception)),
      (data) => Right(data['data'] as List<dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<dynamic>>> searchWards(String query, int districtId) async {
    final result = await ApiClient.get('/locations/wards', query: {
      'district_id': districtId,
      'search': query,
    });
    
    return result.fold(
      (exception) => Left(FailureConverter.fromException(exception)),
      (data) => Right(data['data'] as List<dynamic>),
    );
  }

  // ----------------------------------------------------------------
  // GET USER LOCATIONS
  // ----------------------------------------------------------------

  @override
  Future<Either<Failure, List<LocationEntity>>> getUserLocations(String token) async {
    try {
      print('📍 Repository: Fetching user locations...');
      
      final result = await ApiClient.get(
        '/locations/user-locations',
        headers: {'Authorization': 'Bearer $token'},
      );
      
      return result.fold(
        (exception) {
          print('❌ Repository: Failed to fetch user locations: ${exception.message}');
          return Left(FailureConverter.fromException(exception));
        },
        (data) {
          try {
            final locationsData = data['data'] as List<dynamic>? ?? [];
            
            print('✅ Repository: Fetched ${locationsData.length} user locations');
            
            final locations = <LocationEntity>[];
            
            for (var locationData in locationsData) {
              try {
                if (locationData is Map<String, dynamic>) {
                  // Try to parse using LocationModel
                  final locationModel = LocationModel.fromJson(locationData);
                  locations.add(locationModel);
                } else {
                  print('⚠️ Repository: Skipping invalid location data format');
                }
              } catch (e) {
                print('⚠️ Repository: Error parsing location: $e');
                // Create a fallback location entity
                locations.add(LocationEntity(
                  locationId: 0,
                  regionId: 0,
                  districtId: 0,
                  wardId: 0,
                  isPrimary: false,
                  regionName: 'Unknown Region',
                  districtName: 'Unknown District',
                  wardName: 'Unknown Ward',
                ));
              }
            }
            
            return Right(locations);
          } catch (e) {
            print('❌ Repository: Error processing locations data: $e');
            return Left(ServerFailure('Failed to process locations data: $e'));
          }
        },
      );
    } catch (e) {
      print('❌ Repository: Unexpected error fetching locations: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  // ----------------------------------------------------------------
  // CREATE METHODS
  // ----------------------------------------------------------------

  @override
  Future<Either<Failure, dynamic>> createWard(String wardName, int districtId) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String uniqueWardCode = timestamp.substring(timestamp.length - 10);
    
    print('📍 Repository: Creating ward "$wardName" in district $districtId');
    
    final result = await ApiClient.post('/locations/wards', data: {
      'district_id': districtId,
      'ward_name': wardName,
      'ward_code': uniqueWardCode,
    });
    
    return result.fold(
      (exception) {
        print('❌ Repository: Failed to create ward: ${exception.message}');
        return Left(FailureConverter.fromException(exception));
      },
      (data) {
        print('✅ Repository: Ward created successfully');
        return Right(data['data']);
      },
    );
  }

  @override
Future<Either<Failure, LocationEntity>> saveUserLocation({
    required int regionId,
    required int districtId,
    required int wardId,
    required double latitude,
    required double longitude,
    String? addressDetails,
  }) async {
    print('📍 Repository: Saving user location...');
    print('   → Region: $regionId, District: $districtId, Ward: $wardId');
    print('   → GPS: ($latitude, $longitude)');
    
    // Step 1: Create the Location entry
    final result = await ApiClient.post('/locations', data: {
      'region_id': regionId,
      'district_id': districtId,
      'ward_id': wardId,
      'latitude': latitude,
      'longitude': longitude,
      'address_details': addressDetails ?? '',
    });

    return result.fold(
      (exception) {
        print('❌ Repository: Failed to create location: ${exception.message}');
        return Left(FailureConverter.fromException(exception));
      },
      (locationData) async {
        final locationId = locationData['data']['id']; 
        print('   → Location created with ID: $locationId');
        
        // Step 2: Associate the Location ID with the User
        print('   → Associating location with user...');
        final postResult = await ApiClient.post('/locations/user-locations', data: {
          'location_id': locationId,
          'is_primary': true,
        });
        
        return postResult.fold(
          (exception) {
            print('❌ Repository: Failed to associate location with user: ${exception.message}');
            return Left(FailureConverter.fromException(exception));
          },
          (userLocationData) {
            print('✅ Repository: User location saved successfully');
            
            // 1. Combine the data from both calls
            final combinedData = {
              ...(locationData['data'] as Map<String, dynamic>), // Location details (id, ward_id, lat/long)
              ...userLocationData['data'], // User Location details (is_primary, user_location_id)
            };

            // 2. For now, let's use the minimal data returned by the API
            final locationId = combinedData['id'] ?? combinedData['location_id'] ?? 0;
            
            try {
              // We rely on LocationEntity.fromJson to construct the full object
              final savedLocationEntity = LocationEntity.fromJson(
                {
                  ...locationData['data'],
                  'is_primary': userLocationData['data']['is_primary'],
                  'id': locationId,
                }
              );

              return Right(savedLocationEntity);
            } catch (e) {
              print('❌ Repository: Failed to parse saved location entity: $e');
              return Left(ServerFailure('Failed to process saved location data.'));
            }
          },
        );
      },
    );
  }

  // ----------------------------------------------------------------
  // CHECK METHODS
  // ----------------------------------------------------------------

  @override
  Future<Either<Failure, bool>> userHasLocation() async {
    print('📍 Repository: Checking if user has location...');
    
    final result = await ApiClient.get('/locations/user-locations');
    
    return result.fold(
      (exception) {
        final failure = FailureConverter.fromException(exception);
        
        if (failure is ServerFailure && failure.statusCode == 404) {
          print('   → No location found (404)');
          return const Right(false);
        }
        if (failure is AuthFailure) {
          print('   → Auth error while checking location');
          return Left(failure);
        }
        
        print('❌ Repository: Error checking user location: ${failure.message}');
        return Left(failure);
      },
      (data) {
        final hasLocation = (data['data'] as List).isNotEmpty;
        print('   → User has location: $hasLocation');
        return Right(hasLocation);
      },
    );
  }

  // ----------------------------------------------------------------
  // OPTIONAL: Set Primary Location Method
  // ----------------------------------------------------------------

  Future<Either<Failure, void>> setPrimaryLocation(int locationId) async {
    print('📍 Repository: Setting location $locationId as primary...');
    
    final result = await ApiClient.put(
      '/locations/user-locations/$locationId/set-primary',
      data: {'is_primary': true},
    );
    
    return result.fold(
      (exception) {
        print('❌ Repository: Failed to set primary location: ${exception.message}');
        return Left(FailureConverter.fromException(exception));
      },
      (_) {
        print('✅ Repository: Primary location set successfully');
        return const Right(null);
      },
    );
  }
}