import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/auth_repository.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart'; // 💡 NEW IMPORT
import '../../../../core/error/failure.dart';
import '../../../../core/networking/network_info.dart';
import '../datasources/auth/auth_remote_datasource.dart';
import '../datasources/auth/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final LocationRepository locationRepository; // 💡 NEW: Location Repository dependency

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.locationRepository, // 💡 REQUIRED FOR DI FIX
  });

  @override
  Future<Either<Failure, UserEntity>> login(String login, String password) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.login(login, password);
      final userModel = response.user;
      await localDataSource.cacheUser(userModel);
      await localDataSource.cacheToken(response.accessToken);
      
      // 🚀 CRITICAL UPDATE: Check and attach User Location Status
      final hasLocationResult = await locationRepository.userHasLocation();
      final bool hasLocation = hasLocationResult.getOrElse(() => false); 
      // This line now compiles due to the fix in UserEntity.copyWith
      return Right(userModel.toEntity().copyWith(
        token: response.accessToken,
        hasLocation: hasLocation, 
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during login.'));
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
      final userModel = await remoteDataSource.register(
        firstname: firstname,
        lastname: lastname,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );
      
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during registration.'));
    }
  }

  // ✅ FIXED: Assign Role Implementation with Better Error Handling
  @override
  Future<Either<Failure, UserEntity>> assignRole({required String role}) async {
    if (!await networkInfo.isConnected) {
      print('❌ Repository: No internet connection');
      return Left(NetworkFailure());
    }

    try {
      print('🌐 Repository: Sending role to API: $role');
      
      final userModel = await remoteDataSource.assignRole(role: role);
      
      print('✅ Repository: Received user model');
      print('✅ User ID: ${userModel.id}');
      print('✅ User Role: ${userModel.role}');
      
      // Cache the fully updated user model
      await localDataSource.cacheUser(userModel);
      
      final userEntity = userModel.toEntity();
      
      // 💡 OPTIONAL: Check location status again after assigning role
      final hasLocationResult = await locationRepository.userHasLocation();
      final bool hasLocation = hasLocationResult.getOrElse(() => false); 

      print('✅ Repository: Converted to entity, returning success');
      
      // This line now compiles due to the fix in UserEntity.copyWith
      return Right(userEntity.copyWith(hasLocation: hasLocation));
      
    } on ServerException catch (e) {
      // Log the actual server error
      print('❌ Repository: Server Exception - ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      // ✅ CRITICAL: Log the full error and stack trace
      print('❌ Repository: Unexpected Error - ${e.toString()}');
      print('❌ Stack Trace: $stackTrace');
      return Left(ServerFailure('Failed to assign role: ${e.toString()}'));
    }
  }
}