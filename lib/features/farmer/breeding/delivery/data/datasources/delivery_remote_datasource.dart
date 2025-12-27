// lib/features/farmer/breeding/delivery/data/datasources/delivery_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/data/models/delivery_model.dart';

abstract class DeliveryRemoteDataSource {
  Future<List<DeliveryModel>> getDeliveries({Map<String, dynamic>? filters});
  Future<DeliveryModel> getDeliveryById(dynamic id);
  Future<DeliveryModel> addDelivery(Map<String, dynamic> data);
  Future<DeliveryModel> updateDelivery(dynamic id, Map<String, dynamic> data);
  Future<void> deleteDelivery(dynamic id);
  Future<List<DeliveryInseminationModel>> getAvailableInseminations();
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final Dio dio;

  DeliveryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<DeliveryModel>> getDeliveries({
    Map<String, dynamic>? filters,
  }) async {
    const endpoint = '/breeding/deliveries';
    
    print('🔵 [DELIVERY API] GET $endpoint');
    print('🔵 [DELIVERY API] Filters: $filters');
    print('🔵 [DELIVERY API] Base URL: ${dio.options.baseUrl}');
    
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: filters,
      );

      print('🟢 [DELIVERY API] Status: ${response.statusCode}');
      print('🟢 [DELIVERY API] Response Type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List items = [];
        
        // Handle different response structures
        if (responseData is List) {
          // Direct array: [...]
          print('📦 [DELIVERY API] Direct list (${responseData.length} items)');
          items = responseData;
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            final dataContent = responseData['data'];
            
            if (dataContent is List) {
              // Wrapped: { data: [...] }
              print('📦 [DELIVERY API] Wrapped list (${dataContent.length} items)');
              items = dataContent;
            } else if (dataContent is Map<String, dynamic> && dataContent.containsKey('data')) {
              // Paginated: { data: { data: [...], meta: {...} } }
              final paginatedItems = dataContent['data'] as List;
              print('📦 [DELIVERY API] Paginated (${paginatedItems.length} items)');
              items = paginatedItems;
            } else {
              print('❌ [DELIVERY API] Unknown data structure in data key');
              throw const ServerException(message: 'Invalid response structure');
            }
          } else {
            print('❌ [DELIVERY API] No data key in response');
            throw const ServerException(message: 'Missing data in response');
          }
        } else {
          print('❌ [DELIVERY API] Unexpected response type');
          throw const ServerException(message: 'Unexpected response format');
        }

        // Parse items to models
        try {
          final deliveries = items
              .map((json) {
                try {
                  return DeliveryModel.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ [DELIVERY API] Error parsing item: $e');
                  print('⚠️ [DELIVERY API] Item data: $json');
                  rethrow;
                }
              })
              .toList();
          
          print('✅ [DELIVERY API] Successfully parsed ${deliveries.length} deliveries');
          return deliveries;
        } catch (e) {
          print('❌ [DELIVERY API] Parsing error: $e');
          throw ServerException(message: 'Failed to parse deliveries: $e');
        }
      }

      throw ServerException(
        message: 'Failed to load deliveries (Status: ${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [DELIVERY API] DioException: ${e.type}');
      print('🔴 [DELIVERY API] Message: ${e.message}');
      print('🔴 [DELIVERY API] Status: ${e.response?.statusCode}');
      print('🔴 [DELIVERY API] Response: ${e.response?.data}');
      throw _handleDioException(e, 'Failed to load deliveries');
    } catch (e) {
      print('🔴 [DELIVERY API] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<DeliveryModel> getDeliveryById(dynamic id) async {
    final endpoint = '/breeding/deliveries/$id';
    
    print('🔵 [DELIVERY API] GET $endpoint');
    
    try {
      final response = await dio.get(endpoint);

      print('🟢 [DELIVERY API] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle both direct object and wrapped in 'data'
        final responseData = response.data;
        Map<String, dynamic> deliveryData;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            deliveryData = responseData['data'] as Map<String, dynamic>;
          } else {
            deliveryData = responseData;
          }
          
          print('✅ [DELIVERY API] Delivery detail fetched');
          return DeliveryModel.fromJson(deliveryData);
        }
        
        throw const ServerException(message: 'Invalid delivery detail format');
      }

      throw ServerException(
        message: 'Failed to load delivery details',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [DELIVERY API] DioException: ${e.message}');
      print('🔴 [DELIVERY API] Status: ${e.response?.statusCode}');
      throw _handleDioException(e, 'Failed to load delivery details');
    } catch (e) {
      print('🔴 [DELIVERY API] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<DeliveryModel> addDelivery(Map<String, dynamic> data) async {
    const endpoint = '/breeding/deliveries';
    
    print('🔵 [DELIVERY API] POST $endpoint');
    print('🔵 [DELIVERY API] Data: $data');
    
    try {
      final response = await dio.post(endpoint, data: data);

      print('🟢 [DELIVERY API] Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> deliveryData;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            deliveryData = responseData['data'] as Map<String, dynamic>;
          } else {
            deliveryData = responseData;
          }
          
          print('✅ [DELIVERY API] Delivery created');
          return DeliveryModel.fromJson(deliveryData);
        }
        
        throw const ServerException(message: 'No data returned');
      }

      throw ServerException(
        message: 'Failed to create delivery',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [DELIVERY API] DioException: ${e.message}');
      print('🔴 [DELIVERY API] Status: ${e.response?.statusCode}');
      print('🔴 [DELIVERY API] Response: ${e.response?.data}');
      throw _handleDioException(e, 'Failed to create delivery');
    }
  }

  @override
  Future<DeliveryModel> updateDelivery(dynamic id, Map<String, dynamic> data) async {
    final endpoint = '/breeding/deliveries/$id';
    
    print('🔵 [DELIVERY API] PATCH $endpoint');
    print('🔵 [DELIVERY API] Data: $data');
    
    try {
      final response = await dio.patch(endpoint, data: data);

      print('🟢 [DELIVERY API] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> deliveryData;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            deliveryData = responseData['data'] as Map<String, dynamic>;
          } else {
            deliveryData = responseData;
          }
          
          print('✅ [DELIVERY API] Delivery updated');
          return DeliveryModel.fromJson(deliveryData);
        }
        
        throw const ServerException(message: 'No data returned');
      }

      throw ServerException(
        message: 'Failed to update delivery',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [DELIVERY API] DioException: ${e.message}');
      print('🔴 [DELIVERY API] Status: ${e.response?.statusCode}');
      print('🔴 [DELIVERY API] Response: ${e.response?.data}');
      throw _handleDioException(e, 'Failed to update delivery');
    }
  }

  @override
  Future<void> deleteDelivery(dynamic id) async {
    final endpoint = '/breeding/deliveries/$id';
    
    print('🔵 [DELIVERY API] DELETE $endpoint');
    
    try {
      final response = await dio.delete(endpoint);

      print('🟢 [DELIVERY API] Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ [DELIVERY API] Delivery deleted');
        return;
      }

      throw ServerException(
        message: 'Failed to delete delivery',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      print('🔴 [DELIVERY API] DioException: ${e.message}');
      print('🔴 [DELIVERY API] Status: ${e.response?.statusCode}');
      throw _handleDioException(e, 'Failed to delete delivery');
    }
  }

  @override
  Future<List<DeliveryInseminationModel>> getAvailableInseminations() async {
    const endpoint = '/breeding/deliveries/dropdowns';
    
    print('🔵 [DELIVERY API] GET $endpoint');
    
    try {
      final response = await dio.get(endpoint);

      print('🟢 [DELIVERY API] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle different structures
        List? inseminationsList;
        
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            final dataContent = responseData['data'];
            
            if (dataContent is Map<String, dynamic> && dataContent.containsKey('inseminations')) {
              inseminationsList = dataContent['inseminations'] as List?;
            } else if (dataContent is List) {
              inseminationsList = dataContent;
            }
          } else if (responseData.containsKey('inseminations')) {
            inseminationsList = responseData['inseminations'] as List?;
          }
        } else if (responseData is List) {
          inseminationsList = responseData;
        }
        
        if (inseminationsList == null) {
          print('⚠️ [DELIVERY API] No inseminations found');
          return [];
        }

        final parsed = inseminationsList
            .map((json) => DeliveryInseminationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('✅ [DELIVERY API] Loaded ${parsed.length} inseminations');
        return parsed;
      }
      
      return [];
    } on DioException catch (e) {
      print('🔴 [DELIVERY API] DioException: ${e.message}');
      throw _handleDioException(e, 'Failed to load available inseminations');
    }
  }

  /// DIO Exception Handler with detailed logging
  Exception _handleDioException(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    print('🔴 [ERROR HANDLER] Type: ${e.type}');
    print('🔴 [ERROR HANDLER] Status: $statusCode');
    print('🔴 [ERROR HANDLER] Data: $data');

    // Extract error message
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
        // Handle connection errors
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
            message: 'Cannot connect to server. Please check if the server is running.',
            statusCode: null,
          );
        }
        
        return ServerException(message: errorMessage, statusCode: statusCode);
    }
  }
}