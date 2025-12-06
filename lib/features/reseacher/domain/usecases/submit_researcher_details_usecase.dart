import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/reseacher/domain/entities/researcher_details_entity.dart';
import 'package:farm_manager_app/features/reseacher/domain/repositories/researcher_repository.dart';

class SubmitResearcherDetailsUseCase
    implements UseCase<UserEntity, SubmitResearcherDetailsParams> {
  final ResearcherRepository repository;

  SubmitResearcherDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
      SubmitResearcherDetailsParams params) async {
    return await repository.submitResearcherDetails(
      details: params.details,
      token: params.token,
    );
  }
}

class SubmitResearcherDetailsParams {
  final ResearcherDetailsEntity details;
  final String token;

  SubmitResearcherDetailsParams({
    required this.details,
    required this.token,
  });
}