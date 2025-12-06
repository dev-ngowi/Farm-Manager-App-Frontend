// lib/features/auth/data/datasources/location/location_datasource.dart

import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/networking/api_endpoints.dart';
import 'package:farm_manager_app/features/auth/data/models/location_model.dart';

/// Abstract contract for location-related remote operations
/// Defines what location operations are available
abstract class LocationDataSource {
  /// Fetch all locations for the authenticated user
  /// 
  /// Returns a list of LocationModel objects parsed from the API
  /// Throws [AuthException] if token is invalid/expired
  /// Throws [ServerException] if server returns an error
  /// Throws [NetworkException] if network is unavailable
  Future<List<LocationModel>> getUserLocations(String token);
  
  /// Optionally add other location operations:
  // Future<LocationModel> addLocation(Map<String, dynamic> locationData, String token);
  // Future<LocationModel> updateLocation(int locationId, Map<String, dynamic> updates, String token);
  // Future<void> deleteLocation(int userLocationId, String token);
  // Future<LocationModel> setPrimaryLocation(int userLocationId, String token);
}

/// Implementation of LocationDataSource using Dio for HTTP requests
class LocationDataSourceImpl implements LocationDataSource {
  final Dio dio;

  LocationDataSourceImpl({required this.dio});

  // ========================================
  // GET USER LOCATIONS
  // ========================================

  @override
  Future<List<LocationModel>> getUserLocations(String token) async {
    try {
      print('→ GET ${ApiEndpoints.userLocations}');
      print('   Token: ${token.substring(0, 20)}...');

      final response = await dio.get(
        ApiEndpoints.userLocations,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            // Accept 2xx and 404 (no locations yet)
            return status != null && status >= 200 && status < 500;
          },
        ),
      );

      print('← ${response.statusCode} ${ApiEndpoints.userLocations}');

      // ========================================
      // HANDLE RESPONSE
      // ========================================

      if (response.statusCode == 200) {
        return _parseLocationResponse(response.data);
      }

      if (response.statusCode == 404) {
        // User has no locations yet - this is not an error
        print('   ℹ️ User has no locations (404)');
        return [];
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        final message = _extractErrorMessage(response.data);
        print('   ❌ Auth error: $message');
        throw AuthException(message);
      }

      // Other error status codes
      final message = _extractErrorMessage(response.data);
      print('   ❌ Server error: $message');
      throw ServerException(
        message: message,
        statusCode: response.statusCode,
      );
      
    } on AuthException {
      // Re-throw auth exceptions
      rethrow;
      
    } on ServerException {
      // Re-throw server exceptions
      rethrow;
      
    } on DioException catch (e) {
      print('❌ DioException fetching locations');
      throw _handleDioException(e);
      
    } catch (e, stackTrace) {
      print('❌ Unexpected error fetching locations: $e');
      print('   Stack: $stackTrace');
      throw ServerException(
        message: 'Failed to load locations: $e',
      );
    }
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  /// Parse the location response from API
  /// 
  /// Your API returns:
  /// ```json
  /// {
  ///   "status": "success",
  ///   "data": [
  ///     {
  ///       "id": 11,
  ///       "location_id": 13,
  ///       "location": { ... }
  ///     }
  ///   ],
  ///   "meta": { ... }
  /// }
  /// ```
  List<LocationModel> _parseLocationResponse(dynamic data) {
    try {
      if (data is! Map<String, dynamic>) {
        print('⚠️ Response is not a map: ${data.runtimeType}');
        return [];
      }

      // Extract the data array
      final List<dynamic>? locationsList = data['data'] as List<dynamic>?;

      if (locationsList == null || locationsList.isEmpty) {
        print('   ℹ️ No locations in response');
        return [];
      }

      print('   📦 Parsing ${locationsList.length} location(s)');

      final locations = <LocationModel>[];

      for (var i = 0; i < locationsList.length; i++) {
        try {
          final json = locationsList[i] as Map<String, dynamic>;
          final location = LocationModel.fromJson(json);
          locations.add(location);
          
          print('      ✅ [$i] ${location.displayName} (ID: ${location.locationId})');
        } catch (e) {
          print('      ❌ [$i] Failed to parse location: $e');
          // Continue parsing other locations
        }
      }

      print('   ✅ Successfully parsed ${locations.length}/${locationsList.length} location(s)');

      return locations;
      
    } catch (e, stackTrace) {
      print('❌ Error parsing location response: $e');
      print('   Data: $data');
      print('   Stack: $stackTrace');
      return [];
    }
  }

  /// Extract error message from API response
  String _extractErrorMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return 'An error occurred';
    }

    // Try common error message fields
    if (data['message'] != null) {
      return data['message'].toString();
    }

    if (data['error'] != null) {
      return data['error'].toString();
    }

    // Try validation errors
    if (data['errors'] is Map) {
      final errors = data['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }

    return 'An error occurred';
  }

  /// Handle Dio exceptions and convert to appropriate custom exceptions
  Exception _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    print('   Status: $statusCode');
    print('   Type: ${e.type}');
    print('   Message: ${e.message}');

    // Handle network errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('Connection timeout. Please check your internet.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException('No internet connection. Please check your network.');
    }

    // Handle HTTP status code errors
    switch (statusCode) {
      case 401:
      case 403:
        return AuthException(_extractErrorMessage(data));

      case 404:
        // User has no locations - return empty list (handled in caller)
        return const ServerException(
          message: 'No locations found',
          statusCode: 404,
        );

      case 422:
        return ValidationException(
          message: _extractErrorMessage(data),
          errors: data is Map ? data['errors'] as Map<String, dynamic>? : null,
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
        );

      default:
        final message = _extractErrorMessage(data);
        return ServerException(
          message: message.isNotEmpty ? message : 'Failed to load locations',
          statusCode: statusCode,
        );
    }
  }
}

// ========================================
// OPTIONAL: ADD LOCATION OPERATIONS
// ========================================
// You can extend LocationDataSourceImpl with these methods later:

/*
/// Add a new location for the user
Future<LocationModel> addLocation(
  Map<String, dynamic> locationData,
  String token,
) async {
  final response = await dio.post(
    '/locations/add',
    data: locationData,
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );
  
  return LocationModel.fromJson(response.data['data']);
}

/// Update an existing location
Future<LocationModel> updateLocation(
  int locationId,
  Map<String, dynamic> updates,
  String token,
) async {
  final response = await dio.put(
    '/locations/$locationId',
    data: updates,
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );
  
  return LocationModel.fromJson(response.data['data']);
}

/// Delete a user location
Future<void> deleteLocation(int userLocationId, String token) async {
  await dio.delete(
    '/locations/user-locations/$userLocationId',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );
}

/// Set a location as primary
Future<LocationModel> setPrimaryLocation(
  int userLocationId,
  String token,
) async {
  final response = await dio.post(
    '/locations/user-locations/$userLocationId/set-primary',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );
  
  return LocationModel.fromJson(response.data['data']);
}
*/