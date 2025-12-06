import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/networking/network_info.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/data_resources/semen_data_resource.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/models/semen_model.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/dropdown_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';

class SemenRepositoryImpl implements SemenRepository {
  final SemenRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SemenRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // Helper method for common exception handling
  Future<Either<Failure, T>> _handleException<T>(Future<T> Function() call) async {
    // Note: Add network check here if needed: if (!await networkInfo.isConnected) return Left(NetworkFailure());
    
    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      // Pass the map of errors for the Bloc to handle
      return Left(ValidationFailure(e.message, errors: e.errors)); 
    } on DioException catch (e) {
      // NOTE: DioException is caught for network failure (like timeout, dns issues)
      return Left(ServerFailure('Network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unknown error occurred: ${e.toString()}'));
    }
  }

  /**
   * Helper to convert SemenModel (Data Layer) to SemenEntity (Domain Layer).
   * This handles required type conversions (String date to DateTime) and 
   * null-coalescing for non-nullable Entity fields.
   */
  SemenEntity _toEntity(SemenModel model) {
    return SemenEntity(
      id: model.id,
      strawCode: model.strawCode,
      bullId: model.bullId,
      bullTag: model.bullTag,
      bullName: model.bullName,
      breedId: model.breedId,
      // ✅ FIX: Convert String date from Model to non-nullable DateTime for Entity
      collectionDate: DateTime.parse(model.collectionDate), 
      used: model.used,
      // ✅ FIX: Ensure non-nullable Entity fields have null-coalescing from the nullable Model fields
      costPerStraw: model.costPerStraw ?? 0.0,
      doseMl: model.doseMl ?? 0.0,
      motilityPercentage: model.motilityPercentage,
      sourceSupplier: model.sourceSupplier,
      bull: model.bull?.toEntity(),
      breed: model.breed?.toEntity(),
      inseminations: model.inseminations?.map((m) => m.toEntity()).toList(),
      
      // ✅ FIX: Mapping the newly added statistical fields (using 0 or '0%' default)
      timesUsed: model.timesUsed ?? 0,
      successRate: model.successRate ?? '0%',
    );
  }

  @override
  Future<Either<Failure, List<SemenEntity>>> getSemenInventory({
    bool? availableOnly,
    String? breedId,
  }) {
    return _handleException(() async {
      final semenModels = await remoteDataSource.getSemenInventory(
        'TODO_PASS_TOKEN',
        availableOnly: availableOnly,
        breedId: breedId,
      );
      // Maps the list of models to entities using the robust helper
      return semenModels.map((model) => _toEntity(model)).toList();
    });
  }

  @override
  Future<Either<Failure, List<DropdownEntity>>> getAvailableSemen() {
    return _handleException(() async {
      final rawData = await remoteDataSource.getAvailableSemen('TODO_PASS_TOKEN');
      return rawData.map((json) => DropdownEntity(
        value: json['value'].toString(),
        label: json['label'].toString(),
        type: json['type'].toString()
      )).toList();
    });
  }

  @override
  Future<Either<Failure, SemenEntity>> getSemenDetails(String id) {
    return _handleException(() async {
      // This call returns the full model, including nested relationships and stats.
      final semenModel = await remoteDataSource.getSemenDetails(id, 'TODO_PASS_TOKEN');
      // The _toEntity helper is correctly configured to map these stats and nested objects.
      return _toEntity(semenModel); 
    });
  }

  @override
  Future<Either<Failure, SemenEntity>> createSemen(SemenEntity semen) {
    return _handleException(() async {
      // Converts Entity to Model for the API request payload
      final semenModel = SemenModel.fromEntity(semen);
      final createdModel = await remoteDataSource.createSemen(semenModel, 'TODO_PASS_TOKEN');
      return _toEntity(createdModel);
    });
  }

  @override
  Future<Either<Failure, SemenEntity>> updateSemen(String id, SemenEntity semen) {
    return _handleException(() async {
      final semenModel = SemenModel.fromEntity(semen);
      final updatedModel = await remoteDataSource.updateSemen(id, semenModel, 'TODO_PASS_TOKEN');
      return _toEntity(updatedModel);
    });
  }

  @override
  Future<Either<Failure, void>> deleteSemen(String id) {
    return _handleException(() async {
      await remoteDataSource.deleteSemen(id, 'TODO_PASS_TOKEN');
      return Future.value();
    });
  }
}