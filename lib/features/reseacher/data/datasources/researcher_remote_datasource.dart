// lib/features/reseacher/data/datasources/researcher_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/networking/api_endpoints.dart';
import 'package:farm_manager_app/core/networking/network_exception_handler.dart';
import 'package:farm_manager_app/features/auth/data/models/user_model.dart';
import 'package:farm_manager_app/features/reseacher/data/models/researcher_details_model.dart';
import 'package:farm_manager_app/features/reseacher/data/models/approval_status_model.dart'; // NEW IMPORT

/// Abstract contract for researcher-related remote operations
abstract class ResearcherRemoteDataSource {
  /// Submit (Update) researcher profile details
  Future<UserModel> submitResearcherDetails(
    ResearcherDetailsModel details,
    String token,
  );
  
  /// Fetch allowed research purposes
  Future<List<String>> getResearchPurposes(String token);

  // === NEW METHOD: Get Approval Status ===
  Future<ApprovalStatusModel> getResearcherApprovalStatus(String token);
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
            partialUserMap['has_completed_details'] = true;

            final Map<String, dynamic> completeUserPayload = {
                'user': partialUserMap,
                'message': data['message'] ?? 'Profile updated successfully',
            };
            
            return UserModel.fromJson(completeUserPayload);

        } else {
             return UserModel.fromJson(data);
        }
      }

      throw NetworkExceptionHandler.handleResponse(response, 'Failed to update researcher profile');
      
    } on DioException catch (e) {
      print('ERROR → ${e.response?.statusCode} ${ApiEndpoints.researcher.profileUpdate}');
      
      if (e.type == DioExceptionType.connectionError || e.response == null) {
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
        
        if (data['data'] is List) {
           return (data['data'] as List).cast<String>();
        }
        
        if (response.data is List) {
          return (response.data as List).cast<String>();
        }
        
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

  // ===============================================
  // GET RESEARCHER APPROVAL STATUS (NEW IMPLEMENTATION)
  // ===============================================
  
  @override
  Future<ApprovalStatusModel> getResearcherApprovalStatus(String token) async {
    try {
      // NOTE: This assumes 'ApiEndpoints.researcher' has a new path, e.g., 'statusCheck'
      print('→ GET ${ApiEndpoints.researcher.statusCheck}'); 
      
      final response = await dio.get(
        ApiEndpoints.researcher.statusCheck,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('← ${response.statusCode} Approval Status fetched');

      if (response.statusCode == 200) {
        // Parse the JSON response into the ApprovalStatusModel
        return ApprovalStatusModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw NetworkExceptionHandler.handleResponse(response, 'Failed to fetch researcher approval status');
      
    } on DioException catch (e) {
      print('ERROR → ${e.response?.statusCode} Status Check');
      
      if (e.type == DioExceptionType.connectionError || e.response == null) {
        throw const ServerException(
          message: 'Connection failed or server is unreachable. Cannot check approval status.',
        );
      }
      
      throw NetworkExceptionHandler.handleDioException(e, 'Failed to fetch researcher approval status');
      
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw ServerException(
        message: 'An unexpected error occurred during status check: ${e.runtimeType}',
      );
    }
  }
}