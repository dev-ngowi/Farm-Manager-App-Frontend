import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/reseacher/domain/entities/researcher_details_entity.dart';

abstract class ResearcherRepository {
  /// Submits researcher profile details (initial completion or update)
  Future<Either<Failure, UserEntity>> submitResearcherDetails({
    required ResearcherDetailsEntity details,
    required String token,
  });
  
  /// Fetches the list of allowed research purposes
  Future<Either<Failure, List<String>>> getResearchPurposes({
    required String token,
  });

  // Future<Either<Failure, ResearcherEntity>> getResearcherProfile({required String token});
}