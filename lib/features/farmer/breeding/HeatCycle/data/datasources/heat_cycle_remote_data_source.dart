// heat_cycle_remote_data_source.dart (in /data/datasources)

import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/networking/api_endpoints.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/data/models/heat_cycle_model.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'dart:convert'; // Required for JSON encoding/decoding

// ------------------------------------------------------------------
// ABSTRACT CONTRACT
// ------------------------------------------------------------------

abstract class HeatCycleRemoteDataSource {
  Future<List<HeatCycleModel>> getHeatCycles(String token);
  Future<HeatCycleModel> getHeatCycleDetails(String id, String token);
  Future<HeatCycleModel> createHeatCycle(HeatCycleModel cycle, String token);
  Future<HeatCycleModel> updateHeatCycle(String id, HeatCycleModel cycle, String token);
  
  /// Deletes a heat cycle by ID. Returns nothing on success. ⬅️ NEW METHOD
  Future<void> deleteHeatCycle(String id, String token); 
}

// ------------------------------------------------------------------
// IMPLEMENTATION
// ------------------------------------------------------------------

class HeatCycleRemoteDataSourceImpl implements HeatCycleRemoteDataSource {
  final Dio dio;

  HeatCycleRemoteDataSourceImpl({required this.dio});

  // Helper method to get Dio Options with Authorization header
  Options _authOptions(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
  
  // Helper method to handle common Dio exceptions and return custom failures
  Exception _handleDioException(DioException e, String defaultMessage) {
    // Re-using the logic from your FarmerRemoteDataSourceImpl for consistency.
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Use placeholder message extraction (you would implement your own)
    final String errorMessage = (data is Map<String, dynamic> && data.containsKey('message')) 
        ? data['message'].toString() 
        : defaultMessage;

    switch (statusCode) {
      case 401:
      case 403:
        return AuthException(errorMessage);
      case 422:
        final errors = (data is Map<String, dynamic> && data.containsKey('errors')) 
            ? data['errors'] as Map<String, dynamic> 
            : null;
        return ValidationException(message: errorMessage, errors: errors);
      case 404:
        return ServerException(message: errorMessage, statusCode: 404);
      default:
        return ServerException(message: errorMessage, statusCode: statusCode);
    }
  }

  // ========================================
  // 1. GET HEAT CYCLES (INDEX)
  // ========================================

  @override
  Future<List<HeatCycleModel>> getHeatCycles(String token) async {
    final endpoint = ApiEndpoints.heatCycles;
    try {
      print('→ GET $endpoint');

      final response = await dio.get(
        endpoint,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        
        // Map the list of JSON objects to a list of HeatCycleModel
        return data.map((json) => HeatCycleModel.fromJson(json as Map<String, dynamic>)).toList();
      }

      throw ServerException(
        message: 'Failed to fetch heat cycles list',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch heat cycles');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  // ========================================
  // 2. GET HEAT CYCLE DETAILS
  // ========================================

  @override
  Future<HeatCycleModel> getHeatCycleDetails(String id, String token) async {
    final endpoint = '${ApiEndpoints.heatCycles}/$id';
    try {
      print('→ GET $endpoint');

      final response = await dio.get(
        endpoint,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        // The detail API might return { status: 'success', data: {...} }
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
             throw const ServerException(message: 'Invalid response format for details.');
        }

        return HeatCycleModel.fromJson(data);
      }

      throw ServerException(
        message: 'Failed to fetch heat cycle $id details',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch heat cycle details');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  // ========================================
  // 3. CREATE HEAT CYCLE (STORE)
  // ========================================

  @override
  Future<HeatCycleModel> createHeatCycle(HeatCycleModel cycle, String token) async {
    final endpoint = ApiEndpoints.heatCycles;
    try {
      print('→ POST $endpoint');
      
      // Use the model's toJson specifically built for the POST request
      final requestData = cycle.toJson();
      print('📦 Payload: ${jsonEncode(requestData)}');

      final response = await dio.post(
        endpoint,
        data: requestData,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 201) { // Created
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
             throw const ServerException(message: 'Invalid response format after creation.');
        }

        return HeatCycleModel.fromJson(data);
      }
      
      throw ServerException(
        message: 'Failed to create heat cycle',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to create heat cycle');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  // ========================================
  // 4. UPDATE HEAT CYCLE
  // ========================================

  @override
  Future<HeatCycleModel> updateHeatCycle(String id, HeatCycleModel cycle, String token) async {
    final endpoint = '${ApiEndpoints.heatCycles}/$id';
    try {
      print('→ PUT $endpoint');
      
      // Use the model's toJson for updates (it sends observed_date, intensity, notes)
      final requestData = cycle.toJson();
      print('📦 Payload: ${jsonEncode(requestData)}');

      // Use dio.put for full replacement/update (as per your backend controller)
      final response = await dio.put(
        endpoint,
        data: requestData,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) { // OK
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
             throw const ServerException(message: 'Invalid response format after update.');
        }

        return HeatCycleModel.fromJson(data);
      }
      
      throw ServerException(
        message: 'Failed to update heat cycle',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to update heat cycle');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  // ========================================
  // 5. DELETE HEAT CYCLE ⬅️ NEW METHOD
  // ========================================
  
  @override
  Future<void> deleteHeatCycle(String id, String token) async {
    final endpoint = '${ApiEndpoints.heatCycles}/$id';
    try {
      print('→ DELETE $endpoint');

      // Use dio.delete for deletion
      final response = await dio.delete(
        endpoint,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');
      
      // The status code for a successful deletion with no body is typically 204 No Content.
      // Sometimes 200 OK or 202 Accepted might be used, so we check for success codes.
      if (response.statusCode == 200 || 
          response.statusCode == 202 || 
          response.statusCode == 204) {
        return; // Success, operation complete.
      }
      
      throw ServerException(
        message: 'Failed to delete heat cycle',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to delete heat cycle');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }
}