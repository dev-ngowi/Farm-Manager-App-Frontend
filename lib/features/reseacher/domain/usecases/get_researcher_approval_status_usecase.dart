// lib/features/reseacher/domain/usecases/get_researcher_approval_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/usecases/usercase.dart';
import 'package:farm_manager_app/features/reseacher/domain/entities/approval_status_entity.dart'; // NEW
import 'package:farm_manager_app/features/reseacher/domain/repositories/researcher_repository.dart';
import 'package:equatable/equatable.dart';

/// Use Case to fetch the current researcher approval status from the repository.
class GetResearcherApprovalStatusUseCase
    implements UseCase<ApprovalStatusEntity, GetResearcherApprovalStatusParams> {
  final ResearcherRepository repository;

  GetResearcherApprovalStatusUseCase(this.repository);

  @override
  Future<Either<Failure, ApprovalStatusEntity>> call(
      GetResearcherApprovalStatusParams params) async {
    return await repository.getResearcherApprovalStatus(
      token: params.token,
    );
  }
}

/// Parameters required for fetching the approval status.
/// We use Equatable here since this class is a simple data container.
class GetResearcherApprovalStatusParams extends Equatable {
  final String token;

  const GetResearcherApprovalStatusParams({
    required this.token,
  });

  @override
  List<Object?> get props => [token];
}