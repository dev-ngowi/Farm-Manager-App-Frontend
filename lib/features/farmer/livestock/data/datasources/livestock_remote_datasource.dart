// lib/features/farmer/livestock/data/datasources/livestock_remote_datasource.dart

import 'package:farm_manager_app/core/error/failure.dart';
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
    // result is Either<AppException, dynamic>
    final result = await ApiClient.get(
      endpoints.livestock,
      query: filters,
    );

    return result.fold(
      (failure) => throw failure, // Throws AppException (e.g., ServerException)
      (data) {
        final List<dynamic> livestockJson = data['data']['data'];
        return livestockJson
            .map((json) => LivestockModel.fromJson(json as Map<String, dynamic>))
            .toList();
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
    // result is Either<AppException, dynamic>
    final result = await ApiClient.post(
      endpoints.livestock,
      data: animalData,
    );

    return result.fold(
      (failure) => throw failure, // Throws ValidationException (for 422)
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
}