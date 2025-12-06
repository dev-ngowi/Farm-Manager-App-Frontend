import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/models/farmer_details_model.dart';
import 'package:farm_manager_app/features/auth/data/models/farmer_model.dart';


/// Abstract repository contract for farmer operations
/// Domain layer defines WHAT, data layer defines HOW
abstract class FarmerRepository {
  /// Register farmer with details and optional photo
  /// Returns updated UserEntity with hasCompletedDetails = true
  Future<Either<Failure, UserEntity>> registerFarmer({ // ⭐ Changed return type
    required FarmerDetailsModel details,
    required String token,
    String? profilePhotoBase64,
  });

  /// Get farmer profile
  Future<Either<Failure, FarmerModel>> getFarmerProfile({
    required String token,
  });

  /// Update farmer profile
  Future<Either<Failure, FarmerModel>> updateFarmerProfile({
    required Map<String, dynamic> updates,
    required String token,
    String? profilePhotoBase64,
  });
}