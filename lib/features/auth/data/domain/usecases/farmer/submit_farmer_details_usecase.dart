import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/farmer_repository.dart';
import 'package:farm_manager_app/features/auth/data/models/farmer_details_model.dart';


/// Use case for registering a farmer with their farm details
/// Single Responsibility: Register farmer only
class RegisterFarmerUseCase {
  final FarmerRepository repository;

  RegisterFarmerUseCase({required this.repository});

  /// Execute the use case
  /// Returns UserEntity (domain layer type)
  Future<Either<Failure, UserEntity>> call({ 
    required String farmName,
    required String farmPurpose,
    required double totalLandAcres,
    required int yearsExperience,
    required int locationId,
    required String token,
    String? profilePhotoBase64,
  }) async {
    // 1. Create request model
    final details = FarmerDetailsModel(
      farmName: farmName.trim(),
      farmPurpose: farmPurpose,
      totalLandAcres: totalLandAcres,
      yearsExperience: yearsExperience,
      locationId: locationId,
    );

    // 2. Call repository
    // The repository method is defined to return Future<Either<Failure, UserEntity>>
    final result = await repository.registerFarmer(
      details: details,
      token: token,
      profilePhotoBase64: profilePhotoBase64,
    );

    // 3. Pass the result through, as the conversion is done in the repository impl
    // Renamed the variable to 'userEntity' for clarity.
    return result.fold(
      (failure) => Left(failure),
      (userEntity) => Right(userEntity), // ⭐ FIX: The object is already a UserEntity
    );
  }
}