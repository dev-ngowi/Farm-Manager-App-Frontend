// lib/features/auth/data/domain/usecases/vet/submit_vet_details_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/auth_repository.dart';

/// Submits the detailed professional and clinic information for a Veterinarian.
class SubmitVetDetailsUseCase implements UseCase<UserEntity, VetDetailsParams> {
  final AuthRepository repository;

  SubmitVetDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(VetDetailsParams params) async {
    return await repository.submitVetDetails(
      token: params.token,
      clinicName: params.clinicName,
      licenseNumber: params.licenseNumber,
      specialization: params.specialization,
      consultationFee: params.consultationFee,
      yearsExperience: params.yearsExperience,
      locationId: params.locationId,
      certificateBase64: params.certificateBase64,
      licenseBase64: params.licenseBase64,
      clinicPhotosBase64: params.clinicPhotosBase64,
    );
  }
}

/// Parameters required for the Vet Details Submission.
class VetDetailsParams {
  final String? token;
  final String clinicName;
  final String licenseNumber;
  final String specialization;
  final double consultationFee;
  final int yearsExperience;
  final int locationId;
  final String certificateBase64;
  final String licenseBase64;
  final List<String> clinicPhotosBase64;

  VetDetailsParams({
    required this.token,
    required this.clinicName,
    required this.licenseNumber,
    required this.specialization,
    required this.consultationFee,
    required this.yearsExperience,
    required this.locationId,
    required this.certificateBase64,
    required this.licenseBase64,
    required this.clinicPhotosBase64,
  });
}