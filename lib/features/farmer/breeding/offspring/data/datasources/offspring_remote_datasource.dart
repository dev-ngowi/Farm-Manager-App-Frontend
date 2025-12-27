// lib/features/farmer/breeding/offspring/data/datasources/offspring_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/data/models/offspring_model.dart';

abstract class OffspringRemoteDataSource {
  Future<List<OffspringModel>> getOffspringList({Map<String, dynamic>? filters});
  Future<OffspringModel> getOffspringById(dynamic id);
  Future<OffspringModel> addOffspring(Map<String, dynamic> data);
  Future<OffspringModel> updateOffspring(dynamic id, Map<String, dynamic> data);
  Future<void> deleteOffspring(dynamic id);
  Future<dynamic> registerOffspring(dynamic id, Map<String, dynamic> data);
  Future<List<OffspringDeliveryModel>> getAvailableDeliveries();
}

class OffspringRemoteDataSourceImpl implements OffspringRemoteDataSource {
  final Dio dio;

  OffspringRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OffspringModel>> getOffspringList({
    Map<String, dynamic>? filters,
  }) async {
    const endpoint = '/breeding/offspring';
    
    print('🔵 [OFFSPRING API] GET $endpoint');
    print('🔵 [OFFSPRING API] Filters: $filters');
    
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: filters,
      );

      print('🟢 [OFFSPRING API] Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List items = [];
        
        // Handle different response structures
        if (responseData is List) {
          items = responseData;
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            final dataContent = responseData['data'];
            
            if (dataContent is List) {
              items = dataContent;
            } else if (dataContent is Map<String, dynamic> && dataContent.containsKey('data')) {
              final paginatedItems = dataContent['data'] as List;
              items = paginatedItems;
            }
          }
        }

        final offspring = items
            .map((json) => OffspringModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('✅ [OFFSPRING API] Successfully parsed ${offspring.length} offspring');
        return offspring;
      }

      throw ServerException(
        message: 'Failed to load offspring (Status: ${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [OFFSPRING API] DioException: ${e.type}');
      print('🔴 [OFFSPRING API] Message: ${e.message}');
      throw _handleDioException(e, 'Failed to load offspring');
    } catch (e) {
      print('🔴 [OFFSPRING API] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<OffspringModel> getOffspringById(dynamic id) async {
    final endpoint = '/breeding/offspring/$id';
    
    print('🔵 [OFFSPRING API] GET $endpoint');
    
    try {
      final response = await dio.get(endpoint);

      print('🟢 [OFFSPRING API] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> offspringData;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            offspringData = responseData['data'] as Map<String, dynamic>;
          } else {
            offspringData = responseData;
          }
          
          print('✅ [OFFSPRING API] Offspring detail fetched');
          return OffspringModel.fromJson(offspringData);
        }
        
        throw const ServerException(message: 'Invalid offspring detail format');
      }

      throw ServerException(
        message: 'Failed to load offspring details',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [OFFSPRING API] DioException: ${e.message}');
      throw _handleDioException(e, 'Failed to load offspring details');
    }
  }

  @override
  Future<OffspringModel> addOffspring(Map<String, dynamic> data) async {
    const endpoint = '/breeding/offspring';
    
    print('🔵 [OFFSPRING API] POST $endpoint');
    print('🔵 [OFFSPRING API] Data: $data');
    
    try {
      final response = await dio.post(endpoint, data: data);

      print('🟢 [OFFSPRING API] Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> offspringData;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            offspringData = responseData['data'] as Map<String, dynamic>;
          } else {
            offspringData = responseData;
          }
          
          print('✅ [OFFSPRING API] Offspring created');
          return OffspringModel.fromJson(offspringData);
        }
        
        throw const ServerException(message: 'No data returned');
      }

      throw ServerException(
        message: 'Failed to create offspring',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [OFFSPRING API] DioException: ${e.message}');
      print('🔴 [OFFSPRING API] Response: ${e.response?.data}');
      throw _handleDioException(e, 'Failed to create offspring');
    }
  }

  @override
  Future<OffspringModel> updateOffspring(dynamic id, Map<String, dynamic> data) async {
    final endpoint = '/breeding/offspring/$id';
    
    print('🔵 [OFFSPRING API] PATCH $endpoint');
    print('🔵 [OFFSPRING API] Data: $data');
    
    try {
      final response = await dio.patch(endpoint, data: data);

      print('🟢 [OFFSPRING API] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> offspringData;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            offspringData = responseData['data'] as Map<String, dynamic>;
          } else {
            offspringData = responseData;
          }
          
          print('✅ [OFFSPRING API] Offspring updated');
          return OffspringModel.fromJson(offspringData);
        }
        
        throw const ServerException(message: 'No data returned');
      }

      throw ServerException(
        message: 'Failed to update offspring',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [OFFSPRING API] DioException: ${e.message}');
      throw _handleDioException(e, 'Failed to update offspring');
    }
  }

  @override
  Future<void> deleteOffspring(dynamic id) async {
    final endpoint = '/breeding/offspring/$id';
    
    print('🔵 [OFFSPRING API] DELETE $endpoint');
    
    try {
      final response = await dio.delete(endpoint);

      print('🟢 [OFFSPRING API] Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ [OFFSPRING API] Offspring deleted');
        return;
      }

      throw ServerException(
        message: 'Failed to delete offspring',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [OFFSPRING API] DioException: ${e.message}');
      throw _handleDioException(e, 'Failed to delete offspring');
    }
  }

  @override
  Future<dynamic> registerOffspring(dynamic id, Map<String, dynamic> data) async {
    final endpoint = '/breeding/offspring/$id/register';
    
    print('🔵 [OFFSPRING API] POST $endpoint');
    print('🔵 [OFFSPRING API] Data: $data');
    
    try {
      final response = await dio.post(endpoint, data: data);

      print('🟢 [OFFSPRING API] Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          final livestockData = responseData.containsKey('data') 
              ? responseData['data'] 
              : responseData;
          
          print('✅ [OFFSPRING API] Offspring registered as livestock');
          return livestockData;
        }
        
        throw const ServerException(message: 'No data returned');
      }

      throw ServerException(
        message: 'Failed to register offspring',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [OFFSPRING API] DioException: ${e.message}');
      throw _handleDioException(e, 'Failed to register offspring');
    }
  }

  @override
  Future<List<OffspringDeliveryModel>> getAvailableDeliveries() async {
    const endpoint = '/breeding/offspring/deliveries/available';
    
    print('🔵 [OFFSPRING API] GET $endpoint');
    
    try {
      final response = await dio.get(endpoint);

      print('🟢 [OFFSPRING API] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        List? deliveriesList;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            final dataContent = responseData['data'];
            
            if (dataContent is Map<String, dynamic> && dataContent.containsKey('deliveries')) {
              deliveriesList = dataContent['deliveries'] as List?;
            } else if (dataContent is List) {
              deliveriesList = dataContent;
            }
          } else if (responseData.containsKey('deliveries')) {
            deliveriesList = responseData['deliveries'] as List?;
          }
        } else if (responseData is List) {
          deliveriesList = responseData;
        }
        
        if (deliveriesList == null) {
          print('⚠️ [OFFSPRING API] No deliveries found');
          return [];
        }

        final parsed = deliveriesList
            .map((json) => OffspringDeliveryModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('✅ [OFFSPRING API] Loaded ${parsed.length} deliveries');
        return parsed;
      }
      
      return [];
    } on DioException catch (e) {
      print('🔴 [OFFSPRING API] DioException: ${e.message}');
      throw _handleDioException(e, 'Failed to load available deliveries');
    }
  }

  Exception _handleDioException(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    String errorMessage = defaultMessage;
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      errorMessage = data['message'].toString();
    } else if (e.message != null) {
      errorMessage = '$defaultMessage: ${e.message}';
    }

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
        return ServerException(message: 'Resource not found', statusCode: 404);
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return ServerException(
            message: 'Connection timeout. Please check your internet connection.',
            statusCode: null,
          );
        }
        
        if (e.type == DioExceptionType.connectionError) {
          return ServerException(
            message: 'Cannot connect to server.',
            statusCode: null,
          );
        }
        
        return ServerException(message: errorMessage, statusCode: statusCode);
    }
  }
}