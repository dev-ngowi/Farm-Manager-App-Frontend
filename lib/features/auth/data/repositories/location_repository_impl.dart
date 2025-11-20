// lib/features/auth/data/repositories/location_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/networking/api_client.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
import '../../../../core/error/failure.dart';

class LocationRepositoryImpl implements LocationRepository {
  
  LocationRepositoryImpl();

  // --- GET METHODS ---

  @override
  Future<Either<Failure, List<dynamic>>> getRegions() async {
    final result = await ApiClient.get('/locations/regions');
    // Assuming API Client returns a response structure where data is inside a 'data' key
    return result.map((data) => data['data'] as List<dynamic>);
  }

  @override
  Future<Either<Failure, List<dynamic>>> getDistricts(int regionId) async {
    final result = await ApiClient.get('/locations/districts', query: {'region_id': regionId});
    return result.map((data) => data['data'] as List<dynamic>);
  }

  @override
  Future<Either<Failure, List<dynamic>>> getWards(int districtId) async {
    final result = await ApiClient.get('/locations/wards', query: {'district_id': districtId});
    return result.map((data) => data['data'] as List<dynamic>);
  }

  @override
  Future<Either<Failure, List<dynamic>>> searchWards(String query, int districtId) async {
    final result = await ApiClient.get('/locations/wards', query: {
      'district_id': districtId,
      'search': query,
    });
    return result.map((data) => data['data'] as List<dynamic>);
  }

  // --- POST/CREATE METHODS ---

  @override
  Future<Either<Failure, dynamic>> createWard(String wardName, int districtId) async {
    // 💡 CRITICAL FIX: Generate a ward_code that is MAX 10 characters and unique.
    // The backend requires ward_code to be unique and max 10 chars.
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Ensure we take only the last 10 characters of the timestamp for max:10 constraint
    final String uniqueWardCode = timestamp.substring(timestamp.length - 10);
    
    final result = await ApiClient.post('/locations/wards', data: {
      'district_id': districtId,
      'ward_name': wardName,
      'ward_code': uniqueWardCode, // Now guaranteed to be 10 characters long
    });
    // Assuming successful POST response returns the new ward data inside the 'data' key
    return result.map((data) => data['data']);
  }

  @override
  Future<Either<Failure, void>> saveUserLocation({
    required int regionId,
    required int districtId,
    required int wardId,
    required double latitude,
    required double longitude,
    String? addressDetails,
  }) async {
    // Step 1: Create the Location entry (returns the location data including its ID)
    final result = await ApiClient.post('/locations', data: {
      'region_id': regionId,
      'district_id': districtId,
      'ward_id': wardId,
      'latitude': latitude,
      'longitude': longitude,
      'address_details': addressDetails ?? '',
    });

    // Handle the creation of the main location record
    return result.fold(
      (failure) => Left(failure),
      (locationData) async {
        // Assuming locationData contains a key 'data' which has the created record, including 'id'
        final locationId = locationData['data']['id']; 
        
        // Step 2: Associate the Location ID with the User (UserLocation entry)
        final postResult = await ApiClient.post('/locations/user-locations', data: {
          'location_id': locationId,
          'is_primary': true,
        });
        
        // Handle the UserLocation association result
        return postResult.fold(
          (f) => Left(f),
          (_) => const Right(null), // Void return on success
        );
      },
    );
  }

  // --- CHECK METHODS ---

  @override
  Future<Either<Failure, bool>> userHasLocation() async {
    final result = await ApiClient.get('/locations/user-locations');
    
    return result.fold(
      (failure) {
        
        if (failure is ServerFailure) {
      
           return const Right(false);
        }
        
        // For actual network issues, pass the failure up.
        return Left(failure);
      },
      (data) {
        // If successful (200 OK), check if the data list is not empty
        return Right((data['data'] as List).isNotEmpty);
      },
    );
  }
}