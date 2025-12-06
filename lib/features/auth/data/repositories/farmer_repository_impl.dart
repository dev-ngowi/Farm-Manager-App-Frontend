import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/networking/network_info.dart';
import 'package:farm_manager_app/features/auth/data/datasources/farmer/farmer_remote_datasource.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/farmer_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/data/domain/entities/user_entity.dart'; 
import '../models/farmer_details_model.dart';
import '../models/farmer_model.dart';

/// Implementation of FarmerRepository
/// Bridges domain layer with data sources
class FarmerRepositoryImpl implements FarmerRepository {
  final FarmerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FarmerRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ========================================
  // REGISTER FARMER
  // ========================================

  @override
  Future<Either<Failure, UserEntity>> registerFarmer({ // ⭐ Changed return type
    required FarmerDetailsModel details,
    required String token,
    String? profilePhotoBase64,
  }) async {
    // Check internet connection first
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        'No internet connection. Please check your network.',
      ));
    }

    try {
      print('🔄 FarmerRepository: Registering farmer...');
      print('   Farm: ${details.farmName}');
      print('   Location: ${details.locationId}');

      // Call remote datasource
      final userModel = await remoteDataSource.submitFarmerDetails(
        details,
        token,
        profilePhotoBase64: profilePhotoBase64,
      );

      print('✅ FarmerRepository: Registration successful');
      
      // ⭐ Convert UserModel to UserEntity
      return Right(userModel.toEntity());
      
    } on ValidationException catch (e) {
      print('❌ FarmerRepository: Validation error');
      return Left(ValidationFailure(
        e.message,
        errors: e.errors,
      ));
      
    } on AuthException catch (e) {
      print('❌ FarmerRepository: Auth error');
      return Left(AuthFailure(e.message));
      
    } on ServerException catch (e) {
      print('❌ FarmerRepository: Server error (${e.statusCode})');
      
      // Handle 409 specially - profile exists (not really an error)
      if (e.statusCode == 409) {
        return Left(FarmerRegistrationFailure.alreadyExists(
          message: e.message,
        ));
      }
      
      return Left(ServerFailure(e.message, e.statusCode));
      
    } catch (e) {
      print('❌ FarmerRepository: Unexpected error: $e');
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  // ========================================
  // GET FARMER PROFILE
  // ========================================

  @override
  Future<Either<Failure, FarmerModel>> getFarmerProfile({
    required String token,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final profileData = await remoteDataSource.getFarmerProfile(token);
      final farmerModel = FarmerModel.fromJson(profileData);
      
      return Right(farmerModel);
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
      
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return Left(FarmerRegistrationFailure.notFound());
      }
      return Left(ServerFailure(e.message, e.statusCode));
      
    } catch (e) {
      return Left(ServerFailure('Failed to load farmer profile: $e'));
    }
  }

  // ========================================
  // UPDATE FARMER PROFILE
  // ========================================

  @override
  Future<Either<Failure, FarmerModel>> updateFarmerProfile({
    required Map<String, dynamic> updates,
    required String token,
    String? profilePhotoBase64,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final updatedData = await remoteDataSource.updateFarmerProfile(
        updates,
        token,
        profilePhotoBase64: profilePhotoBase64,
      );
      
      final farmerModel = FarmerModel.fromJson(updatedData);
      return Right(farmerModel);
      
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
      
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return Left(FarmerProfileUpdateFailure.notFound());
      }
      return Left(ServerFailure(e.message, e.statusCode));
      
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: $e'));
    }
  }
}