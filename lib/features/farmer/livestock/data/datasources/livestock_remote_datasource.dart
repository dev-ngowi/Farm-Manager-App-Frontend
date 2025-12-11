// lib/features/farmer/livestock/data/datasources/livestock_remote_datasource.dart

import 'package:farm_manager_app/core/networking/api_client.dart';
import 'package:farm_manager_app/core/networking/api_endpoints.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/models/dropdown_model.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/models/livestock_model.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/models/livestock_summary_model.dart';

abstract class LivestockRemoteDataSource {
  /// Fetches a paginated list of livestock
  Future<List<LivestockModel>> getAllLivestock({Map<String, dynamic>? filters});

  /// Fetches details for a single animal
  Future<LivestockModel> getLivestockById(int animalId);

  /// Submits data to register a new animal
  Future<LivestockModel> addLivestock(Map<String, dynamic> animalData);

  /// Updates an existing animal
  Future<LivestockModel> updateLivestock({
    required int animalId,
    required Map<String, dynamic> animalData,
  });

  /// Deletes an animal
  Future<void> deleteLivestock(int animalId);

  /// Fetches data for dashboard summary
  Future<LivestockSummaryModel> getLivestockSummary();

  /// Fetches dropdown lists (species, breeds, parents) for forms
  Future<DropdownModel> getLivestockDropdowns();
}

class LivestockRemoteDataSourceImpl implements LivestockRemoteDataSource {
  final FarmerEndpoints endpoints;

  LivestockRemoteDataSourceImpl({required this.endpoints});

  @override
  Future<List<LivestockModel>> getAllLivestock({Map<String, dynamic>? filters}) async {
    final result = await ApiClient.get(
      endpoints.livestock,
      query: filters,
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        // ⭐ FIX: Handle both list and paginated response formats
        dynamic rawData = data['data'];
        
        // Check if data is already a list
        if (rawData is List) {
          return rawData
              .map((e) => LivestockModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        
        // If data is a map (paginated response), extract the list
        if (rawData is Map<String, dynamic>) {
          // Common pagination structures:
          // 1. Laravel: { data: [...], meta: {...}, links: {...} }
          // 2. Custom: { items: [...], total: 10, ... }
          
          // Try to find the list in common keys
          final List<dynamic>? list = rawData['data'] as List<dynamic>? ?? 
                                      rawData['items'] as List<dynamic>? ??
                                      rawData['results'] as List<dynamic>?;
          
          if (list != null) {
            return list
                .map((e) => LivestockModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
        
        // If we can't find a list, throw a descriptive error
        throw Exception(
          'Unexpected API response format. Expected a list or paginated object with data/items/results key. '
          'Received: ${data.runtimeType}'
        );
      },
    );
  }
  
  @override
  Future<LivestockModel> getLivestockById(int animalId) async {
    final result = await ApiClient.get(
      endpoints.livestockDetails(animalId),
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        return LivestockModel.fromJson(data['data'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<LivestockModel> addLivestock(Map<String, dynamic> animalData) async {
    final result = await ApiClient.post(
      endpoints.livestock,
      data: animalData,
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        return LivestockModel.fromJson(data['data'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<LivestockSummaryModel> getLivestockSummary() async {
    final result = await ApiClient.get(
      endpoints.livestockSummary,
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        return LivestockSummaryModel.fromJson(data['data'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<DropdownModel> getLivestockDropdowns() async {
    final result = await ApiClient.get(
      endpoints.livestockDropdowns,
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        return DropdownModel.fromJson(data['data'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<LivestockModel> updateLivestock({
    required int animalId,
    required Map<String, dynamic> animalData,
  }) async {
    final result = await ApiClient.patch(
      endpoints.livestockDetails(animalId),
      data: animalData,
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        return LivestockModel.fromJson(data['data'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<void> deleteLivestock(int animalId) async {
    final result = await ApiClient.delete(
      endpoints.livestockDetails(animalId),
    );

    return result.fold(
      (failure) => throw failure,
      (_) => Future.value(),
    );
  }
}