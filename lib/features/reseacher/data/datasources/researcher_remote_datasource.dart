// 

import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/networking/api_endpoints.dart';
import 'package:farm_manager_app/core/networking/network_exception_handler.dart';
import 'package:farm_manager_app/features/auth/data/models/user_model.dart';
import 'package:farm_manager_app/features/reseacher/data/models/researcher_details_model.dart';

/// Abstract contract for researcher-related remote operations
abstract class ResearcherRemoteDataSource {
  /// Submit (Update) researcher profile details
  Future<UserModel> submitResearcherDetails(
    ResearcherDetailsModel details,
    String token,
  );
  
  /// Fetch allowed research purposes
  Future<List<String>> getResearchPurposes(String token);

  // Future<Map<String, dynamic>> getResearcherProfile(String token);
}

class ResearcherRemoteDataSourceImpl implements ResearcherRemoteDataSource {
  final Dio dio;

  ResearcherRemoteDataSourceImpl({required this.dio});

  // ========================================
  // SUBMIT RESEARCHER DETAILS (UPDATE PROFILE)
  // ========================================

  @override
  Future<UserModel> submitResearcherDetails(
    ResearcherDetailsModel details,
    String token,
  ) async {
    try {
      print('→ PUT ${ApiEndpoints.researcher.profileUpdate}');
      
      final response = await dio.put(
        ApiEndpoints.researcher.profileUpdate,
        data: details.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('← ${response.statusCode} ${ApiEndpoints.researcher.profileUpdate}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // -----------------------------------------------------------
        // ⭐ CRITICAL FIX: Handle incomplete response by ensuring ID is present
        // -----------------------------------------------------------
        
        // 1. Extract the partial user map from the response
        Map<String, dynamic>? partialUserMap;
        
        // Look for data structure 1: {message: '...', researcher: {user: {...}}}
        if (data['researcher'] is Map<String, dynamic>) {
            final researcherData = data['researcher'] as Map<String, dynamic>;
            partialUserMap = researcherData['user'] as Map<String, dynamic>?; 
        }
        
        // Look for data structure 2: {user: {...}, message: ...}
        if (partialUserMap == null && data['user'] is Map<String, dynamic>) {
            partialUserMap = data['user'] as Map<String, dynamic>;
        }

        if (partialUserMap != null) {
            // The key update is that the user's details are complete:
            partialUserMap['has_completed_details'] = true;

            // ⭐ ASSUMPTION: To avoid fetching the user profile again, 
            // the system MUST retrieve the full UserEntity from local storage/state 
            // and merge the update. Since this RemoteDataSource lacks that context,
            // we must assume the full User payload *should* be returned by the API
            // OR we must manually inject the required ID (e.g., if it was passed here).
            
            // Temporary fix: Manually inject the required fields for UserModel 
            // that the API may have omitted (like ID, name, email, etc.)
            
            // NOTE: The backend should ideally return the full, updated user object.
            // If it doesn't, this manual construction is necessary:
            final Map<String, dynamic> completeUserPayload = {
                // Ensure required non-nullable fields (like ID) are injected 
                // if the API only returned {has_completed_details: true}
                // (e.g., by retrieving the ID from state/secure storage). 
                // Since we don't have the original ID here, we let UserModel.fromJson
                // handle the missing fields, which now throws a clear error if ID is null.
                
                // We pass the response data structure, relying on the improved 
                // UserModel.fromJson logic to handle nesting and required fields.
                'user': partialUserMap,
                'message': data['message'] ?? 'Profile updated successfully',
            };
            
            // Call the improved UserModel parser
            return UserModel.fromJson(completeUserPayload);

        } else {
             // Fallback to parsing the whole response if no 'user' object was found, 
             // in case the API returns the user object at the root.
             return UserModel.fromJson(data);
        }
      }

      throw NetworkExceptionHandler.handleResponse(response, 'Failed to update researcher profile');
      
    } on DioException catch (e, stackTrace) {
      print('ERROR → ${e.response?.statusCode} ${ApiEndpoints.researcher.profileUpdate}');
      
      if (e.type == DioExceptionType.connectionError || e.response == null) {
        // This handles the DioExceptionType.unknown case we saw in the previous logs 
        // when the connection fails entirely.
        throw const ServerException(
          message: 'Connection failed or server is unreachable. Check network connection or API URL.',
        );
      }
      
      throw NetworkExceptionHandler.handleDioException(e, 'Failed to update researcher profile');
      
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw ServerException(
        message: 'An unexpected error occurred during profile update: ${e.runtimeType}',
      );
    }
  }

  // ========================================
  // GET RESEARCH PURPOSES
  // ========================================

  @override
  Future<List<String>> getResearchPurposes(String token) async {
    try {
      print('→ GET ${ApiEndpoints.researcher.researchPurposes}');

      final response = await dio.get(
        ApiEndpoints.researcher.researchPurposes,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('← ${response.statusCode} Purposes fetched');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Handle common API responses: {data: [...]} or {...}
        if (data['data'] is List) {
           return (data['data'] as List).cast<String>();
        }
        
        // Fallback if the array is returned directly
        if (response.data is List) {
          return (response.data as List).cast<String>();
        }
        
        // Fallback for empty/unrecognized structure
        return [];
      }

      throw NetworkExceptionHandler.handleResponse(response, 'Failed to fetch research purposes');
      
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.response == null) {
        throw const ServerException(
          message: 'Connection failed or server is unreachable. Cannot fetch research purposes.',
        );
      }
      
      throw NetworkExceptionHandler.handleDioException(e, 'Failed to fetch research purposes');
    }
  }
}