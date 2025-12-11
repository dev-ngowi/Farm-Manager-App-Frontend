// lib/features/farmer/breeding/Insemination/data/datasources/insemination_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/networking/api_endpoints.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/data/models/insemination_model.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'dart:convert';

abstract class InseminationRemoteDataSource {
  Future<List<InseminationModel>> fetchInseminationList({Map<String, dynamic>? filters});
  Future<InseminationModel> fetchInseminationDetail(int id);
  Future<InseminationModel> addInsemination(Map<String, dynamic> recordData);
  Future<InseminationModel> updateInsemination(int id, Map<String, dynamic> updatedData);
  Future<void> deleteInsemination(int id);

  Future<List<InseminationAnimalModel>> getAvailableAnimals();
  Future<List<InseminationSemenModel>> getAvailableSemen();
}

class InseminationRemoteDataSourceImpl implements InseminationRemoteDataSource {
  final Dio dio;

  InseminationRemoteDataSourceImpl({required this.dio});

  // Helper method to handle common Dio exceptions and return custom failures
  Exception _handleDioException(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Extract error message from response
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
  Future<List<InseminationModel>> fetchInseminationList({
    Map<String, dynamic>? filters,
  }) async {
    final endpoint = ApiEndpoints.inseminations;
    try {
      print('→ GET $endpoint');
      
      final response = await dio.get(
        endpoint,
        queryParameters: filters,
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final List data = response.data['data'] as List;
        return data
            .map((json) => InseminationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Failed to load insemination records',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to load insemination records');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<InseminationModel> fetchInseminationDetail(int id) async {
    final endpoint = ApiEndpoints.inseminationDetails(id);
    try {
      print('→ GET $endpoint');

      final response = await dio.get(endpoint);

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        
        if (data == null) {
          throw const ServerException(message: 'Invalid response format for details.');
        }

        return InseminationModel.fromJson(data);
      }

      throw ServerException(
        message: 'Failed to load record details',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to load record details');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<InseminationModel> addInsemination(Map<String, dynamic> recordData) async {
    final endpoint = ApiEndpoints.inseminations;
    try {
      print('→ POST $endpoint');
      print('📦 Payload: ${jsonEncode(recordData)}');

      final response = await dio.post(
        endpoint,
        data: recordData,
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        
        if (data == null) {
          throw const ServerException(message: 'Invalid response format after creation.');
        }

        return InseminationModel.fromJson(data);
      }

      throw ServerException(
        message: 'Failed to create insemination record',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to create insemination record');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<InseminationModel> updateInsemination(int id, Map<String, dynamic> updatedData) async {
    final endpoint = ApiEndpoints.updateInsemination(id);
    try {
      print('→ PATCH $endpoint');
      print('📦 Payload: ${jsonEncode(updatedData)}');

      final response = await dio.patch(
        endpoint,
        data: updatedData,
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        
        if (data == null) {
          throw const ServerException(message: 'Invalid response format after update.');
        }

        return InseminationModel.fromJson(data);
      }

      throw ServerException(
        message: 'Failed to update record',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to update record');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<void> deleteInsemination(int id) async {
    final endpoint = ApiEndpoints.deleteInsemination(id);
    try {
      print('→ DELETE $endpoint');

      final response = await dio.delete(endpoint);

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Failed to delete record',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to delete record');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<List<InseminationAnimalModel>> getAvailableAnimals() async {
    final endpoint = ApiEndpoints.availableAnimals;
    try {
      print('→ GET $endpoint');

      final response = await dio.get(endpoint);

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final List data = response.data['data'] as List;
        return data
            .map((json) => InseminationAnimalModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Failed to load available animals',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to load available animals');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<List<InseminationSemenModel>> getAvailableSemen() async {
    final endpoint = ApiEndpoints.availableSemen;
    try {
      print('→ GET $endpoint');

      final response = await dio.get(endpoint);

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final List data = response.data['data'] as List;
        return data
            .map((json) => InseminationSemenModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Failed to load semen straws',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to load semen straws');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }
}