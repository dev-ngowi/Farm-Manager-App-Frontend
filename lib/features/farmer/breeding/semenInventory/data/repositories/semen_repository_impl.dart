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
    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors)); 
    } on DioException {
      return Left(ServerFailure('Network error occurred.'));
    } catch (e) {
      return Left(ServerFailure('An unknown error occurred: ${e.toString()}'));
    }
  }

  SemenEntity _toEntity(SemenModel model) {
    return SemenEntity(
      id: model.id,
      strawCode: model.strawCode,
      bullId: model.bullId,
      bullTag: model.bullTag,
      bullName: model.bullName,
      breedId: model.breedId,
      collectionDate: DateTime.parse(model.collectionDate), 
      used: model.used,
      costPerStraw: model.costPerStraw ?? 0.0,
      doseMl: model.doseMl ?? 0.0,
      motilityPercentage: model.motilityPercentage,
      sourceSupplier: model.sourceSupplier,
      bull: model.bull?.toEntity(),
      breed: model.breed?.toEntity(),
      inseminations: model.inseminations?.map((m) => m.toEntity()).toList(),
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

  // ⭐ NEW: Implementation for getting dropdown data
  @override
  Future<Either<Failure, Map<String, List<DropdownEntity>>>> getSemenDropdownData() {
    return _handleException(() async {
      final rawData = await remoteDataSource.getSemenDropdownData('TODO_PASS_TOKEN');
      
      print('📊 Raw dropdown data received: ${rawData.length} items');
      
      // Separate bulls and breeds from the response
      final List<DropdownEntity> bulls = [];
      final List<DropdownEntity> breeds = [];
      
      for (final json in rawData) {
        final type = json['type']?.toString().toLowerCase() ?? '';
        final dropdown = DropdownEntity(
          value: json['value'].toString(),
          label: json['label'].toString(),
          type: json['type'].toString(),
        );
        
        print('📌 Processing dropdown: type=$type, label=${dropdown.label}');
        
        if (type == 'bull') {
          bulls.add(dropdown);
        } else if (type == 'breed') {
          breeds.add(dropdown);
        }
      }
      
      print('✅ Separated: ${bulls.length} bulls, ${breeds.length} breeds');
      
      return {
        'bulls': bulls,
        'breeds': breeds,
      };
    });
  }

  @override
  Future<Either<Failure, SemenEntity>> getSemenDetails(String id) {
    return _handleException(() async {
      final semenModel = await remoteDataSource.getSemenDetails(id, 'TODO_PASS_TOKEN');
      return _toEntity(semenModel); 
    });
  }

  @override
  Future<Either<Failure, SemenEntity>> createSemen(SemenEntity semen) {
    return _handleException(() async {
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