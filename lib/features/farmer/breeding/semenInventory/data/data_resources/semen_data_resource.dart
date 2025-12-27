import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/networking/api_endpoints.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'dart:convert';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/models/semen_model.dart';

abstract class SemenRemoteDataSource {
  Future<List<SemenModel>> getSemenInventory(
    String token, {
    bool? availableOnly,
    String? breedId,
  });

  Future<List<Map<String, dynamic>>> getAvailableSemen(String token);
  Future<List<Map<String, dynamic>>> getSemenDropdownData(String token);
  Future<SemenModel> getSemenDetails(String id, String token);
  Future<SemenModel> createSemen(SemenModel semen, String token);
  Future<SemenModel> updateSemen(String id, SemenModel semen, String token);
  Future<void> deleteSemen(String id, String token);
}

class SemenRemoteDataSourceImpl implements SemenRemoteDataSource {
  final Dio dio;

  SemenRemoteDataSourceImpl({required this.dio});
  
  Options _authOptions(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
  
  Exception _handleDioException(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
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

  @override
  Future<List<SemenModel>> getSemenInventory(
    String token, {
    bool? availableOnly,
    String? breedId,
  }) async {
    final endpoint = ApiEndpoints.semenInventory;
    try {
      final Map<String, dynamic> queryParams = {};
      if (availableOnly == true) {
        queryParams['available_only'] = 'true'; 
      }
      if (breedId != null) {
        queryParams['breed_id'] = breedId;
      }
      
      print('→ GET $endpoint with params: $queryParams');

      final response = await dio.get(
        endpoint,
        queryParameters: queryParams,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');
      print('📦 Response data: ${jsonEncode(response.data)}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        
        print('✅ Parsing ${data.length} semen records...');
        
        final List<SemenModel> models = [];
        for (var i = 0; i < data.length; i++) {
          try {
            final json = data[i] as Map<String, dynamic>;
            print('  → Parsing record $i: ${json['straw_code']}');
            final model = SemenModel.fromJson(json);
            models.add(model);
            print('  ✅ Successfully parsed record $i');
          } catch (e, stackTrace) {
            print('  ❌ Error parsing record $i: $e');
            print('  Stack trace: $stackTrace');
            print('  Raw data: ${jsonEncode(data[i])}');
            rethrow;
          }
        }
        
        return models;
      }

      throw ServerException(
        message: 'Failed to fetch semen inventory list',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw _handleDioException(e, 'Failed to fetch semen inventory');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSemenDropdownData(String token) async {
    final endpoint = ApiEndpoints.semenDropdowns; 
    try {
      print('→ GET $endpoint');

      final response = await dio.get(
        endpoint,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>; 
        return data.cast<Map<String, dynamic>>(); 
      }

      throw ServerException(
        message: 'Failed to fetch semen creation dropdown data (Bulls and Breeds)',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch semen creation dropdown data');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableSemen(String token) async {
    final endpoint = ApiEndpoints.availableSemen;
    try {
      print('→ GET $endpoint');

      final response = await dio.get(
        endpoint,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.cast<Map<String, dynamic>>(); 
      }

      throw ServerException(
        message: 'Failed to fetch available semen list',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch available semen');
    }
  }

  @override
  Future<SemenModel> getSemenDetails(String id, String token) async {
    final endpoint = ApiEndpoints.semenDetail(id);
    try {
      print('→ GET $endpoint');

      final response = await dio.get(
        endpoint,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');
      print('📦 Response data: ${jsonEncode(response.data)}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
             throw const ServerException(message: 'Invalid response format for details.');
        }

        return SemenModel.fromJson(data);
      }

      throw ServerException(
        message: 'Failed to fetch semen details for $id',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch semen details');
    }
  }

  @override
  Future<SemenModel> createSemen(SemenModel semen, String token) async {
    final endpoint = ApiEndpoints.semenInventory;
    try {
      print('→ POST $endpoint');
      
      final requestData = semen.toJson();
      print('📦 Payload: ${jsonEncode(requestData)}');

      final response = await dio.post(
        endpoint,
        data: requestData,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
             throw const ServerException(message: 'Invalid response format after creation.');
        }

        return SemenModel.fromJson(data);
      }
      
      throw ServerException(
        message: 'Failed to create semen record',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to create semen record');
    }
  }

  @override
  Future<SemenModel> updateSemen(String id, SemenModel semen, String token) async {
    final endpoint = ApiEndpoints.semenDetail(id);
    try {
      print('→ PUT $endpoint');
      
      final requestData = semen.toJson();
      print('📦 Payload: ${jsonEncode(requestData)}');

      final response = await dio.put(
        endpoint,
        data: requestData,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
             throw const ServerException(message: 'Invalid response format after update.');
        }

        return SemenModel.fromJson(data);
      }
      
      throw ServerException(
        message: 'Failed to update semen record',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to update semen record');
    }
  }

  @override
  Future<void> deleteSemen(String id, String token) async {
    final endpoint = ApiEndpoints.semenDetail(id);
    try {
      print('→ DELETE $endpoint');
      
      final response = await dio.delete(
        endpoint,
        options: _authOptions(token),
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200 || response.statusCode == 204) { 
        return;
      }
      
      throw ServerException(
        message: 'Failed to delete semen record',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to delete semen record');
    }
  }
}