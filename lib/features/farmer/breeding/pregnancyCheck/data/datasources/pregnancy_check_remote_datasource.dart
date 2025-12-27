// lib/features/farmer/breeding/pregnancyCheck/data/datasources/pregnancy_check_remote_datasource_impl.dart

import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/data/models/pregnancy_check_model.dart';
import 'dart:convert';

class PregnancyCheckRemoteDataSourceImpl implements PregnancyCheckRemoteDataSource {
  final Dio dio;

  PregnancyCheckRemoteDataSourceImpl({required this.dio});

  /// Handles DioException and converts to appropriate exceptions
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
  Future<List<PregnancyCheckModel>> getPregnancyChecks({
    Map<String, dynamic>? filters,
  }) async {
    const endpoint = '/breeding/pregnancy-checks';
    try {
      print('↑ GET $endpoint');
      
      final response = await dio.get(
        endpoint,
        queryParameters: filters,
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final List data = response.data['data'] as List;
        return data
            .map((json) => PregnancyCheckModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Failed to load pregnancy checks',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to load pregnancy checks');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<PregnancyCheckModel> getPregnancyCheckById(int id) async {
    final endpoint = '/breeding/pregnancy-checks/$id';
    try {
      print('↑ GET $endpoint');

      final response = await dio.get(endpoint);

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        
        if (data == null) {
          throw const ServerException(message: 'Invalid response format for details.');
        }

        return PregnancyCheckModel.fromJson(data);
      }

      throw ServerException(
        message: 'Failed to load pregnancy check details',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to load pregnancy check details');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<PregnancyCheckModel> addPregnancyCheck(Map<String, dynamic> data) async {
    const endpoint = '/breeding/pregnancy-checks';
    try {
      print('↑ POST $endpoint');
      print('📦 Payload: ${jsonEncode(data)}');

      final response = await dio.post(
        endpoint,
        data: data,
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>?;
        
        if (responseData == null) {
          throw const ServerException(message: 'Invalid response format after creation.');
        }

        return PregnancyCheckModel.fromJson(responseData);
      }

      throw ServerException(
        message: 'Failed to create pregnancy check',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to create pregnancy check');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<PregnancyCheckModel> updatePregnancyCheck(int id, Map<String, dynamic> data) async {
    final endpoint = '/breeding/pregnancy-checks/$id';
    try {
      print('↑ PATCH $endpoint');
      print('📦 Payload: ${jsonEncode(data)}');

      final response = await dio.patch(
        endpoint,
        data: data,
      );

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>?;
        
        if (responseData == null) {
          throw const ServerException(message: 'Invalid response format after update.');
        }

        return PregnancyCheckModel.fromJson(responseData);
      }

      throw ServerException(
        message: 'Failed to update pregnancy check',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to update pregnancy check');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<void> deletePregnancyCheck(int id) async {
    final endpoint = '/breeding/pregnancy-checks/$id';
    try {
      print('↑ DELETE $endpoint');

      final response = await dio.delete(endpoint);

      print('← ${response.statusCode} $endpoint');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Failed to delete pregnancy check',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      throw _handleDioException(e, 'Failed to delete pregnancy check');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e\n$stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<List<PregnancyCheckInseminationModel>> getAvailableInseminations() async {
    const endpoint = '/breeding/pregnancy-checks/dropdowns';
    try {
      print('↑ GET $endpoint');

      final response = await dio.get(endpoint);

      print('← ${response.statusCode} $endpoint');
      print('📦 Response data: ${jsonEncode(response.data)}');

      if (response.statusCode == 200) {
        // Assuming backend returns: { data: { inseminations: [...], vets: [...] } }
        final data = response.data['data'] as Map<String, dynamic>?;
        
        if (data == null || !data.containsKey('inseminations')) {
          throw const ServerException(message: 'Invalid dropdowns response format.');
        }

        final List inseminationsList = data['inseminations'] as List;
        
        print('✅ Parsing ${inseminationsList.length} insemination records...');
        
        final List<PregnancyCheckInseminationModel> inseminations = [];
        for (var i = 0; i < inseminationsList.length; i++) {
          try {
            final json = inseminationsList[i] as Map<String, dynamic>;
            print('  ↑ Parsing insemination $i: ${json['id']}');
            final insemination = PregnancyCheckInseminationModel.fromJson(json);
            inseminations.add(insemination);
            print('  ✅ Successfully parsed insemination $i');
          } catch (e, stackTrace) {
            print('  ❌ Error parsing insemination $i: $e');
            print('  Stack trace: $stackTrace');
            print('  Raw data: ${jsonEncode(inseminationsList[i])}');
          }
        }
        
        return inseminations;
      }

      throw ServerException(
        message: 'Failed to load available inseminations',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      print('❌ Response data: ${e.response?.data}');
      throw _handleDioException(e, 'Failed to load available inseminations');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e');
      print('Stack trace: $stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }

  @override
  Future<List<PregnancyCheckVetModel>> getAvailableVets() async {
    const endpoint = '/breeding/pregnancy-checks/dropdowns';
    try {
      print('↑ GET $endpoint');

      final response = await dio.get(endpoint);

      print('← ${response.statusCode} $endpoint');
      print('📦 Response data: ${jsonEncode(response.data)}');

      if (response.statusCode == 200) {
        // Assuming backend returns: { data: { inseminations: [...], vets: [...] } }
        final data = response.data['data'] as Map<String, dynamic>?;
        
        if (data == null || !data.containsKey('vets')) {
          throw const ServerException(message: 'Invalid dropdowns response format.');
        }

        final List vetsList = data['vets'] as List;
        
        print('✅ Parsing ${vetsList.length} vet records...');
        
        final List<PregnancyCheckVetModel> vets = [];
        for (var i = 0; i < vetsList.length; i++) {
          try {
            final json = vetsList[i] as Map<String, dynamic>;
            print('  ↑ Parsing vet $i: ${json['name']}');
            final vet = PregnancyCheckVetModel.fromJson(json);
            vets.add(vet);
            print('  ✅ Successfully parsed vet $i');
          } catch (e, stackTrace) {
            print('  ❌ Error parsing vet $i: $e');
            print('  Stack trace: $stackTrace');
            print('  Raw data: ${jsonEncode(vetsList[i])}');
          }
        }
        
        return vets;
      }

      throw ServerException(
        message: 'Failed to load available vets',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.message}');
      print('❌ Response data: ${e.response?.data}');
      throw _handleDioException(e, 'Failed to load available vets');
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e');
      print('Stack trace: $stackTrace');
      throw const ServerException(message: 'An unexpected error occurred.');
    }
  }
}

abstract class PregnancyCheckRemoteDataSource {
  Future<List<PregnancyCheckModel>> getPregnancyChecks({Map<String, dynamic>? filters});
  Future<PregnancyCheckModel> getPregnancyCheckById(int id);
  Future<PregnancyCheckModel> addPregnancyCheck(Map<String, dynamic> data);
  Future<PregnancyCheckModel> updatePregnancyCheck(int id, Map<String, dynamic> data);
  Future<void> deletePregnancyCheck(int id);
  
  Future<List<PregnancyCheckInseminationModel>> getAvailableInseminations();
  Future<List<PregnancyCheckVetModel>> getAvailableVets();
}