// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/auth_repository.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/networking/network_info.dart';
import '../datasources/auth/auth_remote_datasource.dart';
import '../datasources/auth/auth_local_datasource.dart';
import '../models/user_model.dart'; // Assuming this provides UserModel and copyWithModel

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final LocationRepository locationRepository;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.locationRepository,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String login, String password) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.login(login, password);
      final userModel = response.user;
      
      // Ensure the token is cached before proceeding
      await localDataSource.cacheToken(response.accessToken); 
      await localDataSource.cacheUser(userModel);

      // Check and attach User Location Status
      final hasLocationResult = await locationRepository.userHasLocation();
      final bool hasLocation = hasLocationResult.getOrElse(() => false); 
      
      return Right(userModel.toEntity().copyWith(
        token: response.accessToken, // Token comes directly from response
        hasLocation: hasLocation, 
      ));
    } on ServerException catch (e) {
      // Use FailureConverter to map specific server errors (like AuthFailure for 401)
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred during login.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // 1. remoteDataSource.register sends data, receives user model + token, 
      //    and critically, saves the token to secure storage internally.
      final userModel = await remoteDataSource.register(
        firstname: firstname,
        lastname: lastname,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );
      
      // 2. Retrieve the saved token from local storage immediately.
      // This is the CRITICAL step to ensure the token is retrieved after the remote call.
      final token = await localDataSource.getToken();
      
      // 3. Attach the retrieved token to the model before caching and returning.
      final userWithToken = userModel.copyWithModel(token: token);
      
      await localDataSource.cacheUser(userWithToken);
      
      // 4. Return the UserEntity with the attached token.
      return Right(userWithToken.toEntity());
      
    } on ServerException catch (e) {
      // Use FailureConverter for specific registration errors (e.g., Validation)
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred during registration.'));
    }
  }

  // Fix for assignRole method (retained from previous fix)
  @override
  Future<Either<Failure, UserEntity>> assignRole({
    required String role,
    required String token, 
  }) async {
    if (!await networkInfo.isConnected) {
      print('❌ Repository: No internet connection');
      return Left(NetworkFailure());
    }

    try {
      print('🌐 Repository: Sending role to API: $role');
      
      final userModel = await remoteDataSource.assignRole(
        role: role,
        token: token,
      );
      
      print('✅ Repository: Received user model (Role: ${userModel.role})');
      
      await localDataSource.cacheUser(userModel);
      
      final userEntity = userModel.toEntity();
      
      final hasLocationResult = await locationRepository.userHasLocation();
      final bool hasLocation = hasLocationResult.getOrElse(() => false); 

      print('✅ Repository: Converted to entity, returning success');
      
      // Attach the token that was passed in, along with location status
      return Right(userEntity.copyWith(
        token: token,
        hasLocation: hasLocation,
      ));
      
    } on ServerException catch (e) {
      print('❌ Repository: Server Exception - ${e.message}');
      return Left(FailureConverter.fromException(e));
    } catch (e, stackTrace) {
      print('❌ Repository: Unexpected Error - ${e.toString()}');
      print('❌ Stack Trace: $stackTrace');
      return Left(UnknownFailure('Failed to assign role: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> submitFarmerDetails({
    required String farmName,
    required String farmPurpose,
    required double totalLandAcres,
    required int yearsExperience,
    required int locationId,
    required String token,
    required String profilePhotoBase64,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final userModel = await remoteDataSource.submitFarmerDetails(
        farmName: farmName,
        farmPurpose: farmPurpose,
        totalLandAcres: totalLandAcres,
        yearsExperience: yearsExperience,
        locationId: locationId,
        token: token,
        profilePhotoBase64: profilePhotoBase64,
      );
      
      await localDataSource.cacheUser(userModel);
      
      // Ensure token is attached
      final userEntity = userModel.toEntity().copyWith(token: token);
      
      return Right(userEntity);
      
    } on ServerException catch (e) {
      // Use FailureConverter to handle FarmerRegistrationFailure (409) or ValidationFailure (422)
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred during farmer details submission.'));
    }
  }

  // ========================================
  // ⭐ NEW: SUBMIT VET DETAILS IMPLEMENTATION
  // ========================================

  @override
  Future<Either<Failure, UserEntity>> submitVetDetails({
    required String? token,
    required String clinicName,
    required String licenseNumber,
    required String specialization,
    required double consultationFee,
    required int yearsExperience,
    required int locationId,
    required String certificateBase64,
    required String licenseBase64,
    required List<String> clinicPhotosBase64,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    // 1. Validate token presence (though the bloc should handle this)
    if (token == null || token.isEmpty) {
      return const Left(AuthFailure('Authentication token is missing.'));
    }

    try {
      // 2. Delegate the API call to the remote data source
      final userModel = await remoteDataSource.submitVetDetails(
        clinicName: clinicName,
        licenseNumber: licenseNumber,
        specialization: specialization,
        consultationFee: consultationFee,
        yearsExperience: yearsExperience,
        locationId: locationId,
        token: token,
        certificateBase64: certificateBase64,
        licenseBase64: licenseBase64,
        clinicPhotosBase64: clinicPhotosBase64,
      );
      
      // 3. Cache the updated user data
      await localDataSource.cacheUser(userModel);
      
      // 4. Convert to Entity and ensure the token is attached
      final userEntity = userModel.toEntity().copyWith(token: token);
      
      return Right(userEntity);
      
    } on ServerException catch (e) {
      // 5. Convert ServerException to a domain Failure (VetRegistrationFailure for 409/422)
      return Left(FailureConverter.fromException(e));
    } catch (e, stackTrace) {
      print('❌ Repository: Unexpected Error during vet submission - ${e.toString()}');
      print('❌ Stack Trace: $stackTrace');
      return Left(UnknownFailure('An unexpected error occurred during vet details submission.'));
    }
  }
}