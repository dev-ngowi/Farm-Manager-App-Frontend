import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';
import 'package:farm_manager_app/core/networking/network_info.dart';
import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/reseacher/data/datasources/researcher_remote_datasource.dart';
import 'package:farm_manager_app/features/reseacher/data/models/researcher_details_model.dart';
import 'package:farm_manager_app/features/reseacher/domain/entities/researcher_details_entity.dart';
import 'package:farm_manager_app/features/reseacher/domain/repositories/researcher_repository.dart';

/// Implementation of ResearcherRepository
class ResearcherRepositoryImpl implements ResearcherRepository {
  final ResearcherRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ResearcherRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ========================================
  // SUBMIT RESEARCHER DETAILS
  // ========================================

  @override
  Future<Either<Failure, UserEntity>> submitResearcherDetails({
    required ResearcherDetailsEntity details,
    required String token,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        'No internet connection. Please check your network.',
      ));
    }

    try {
      print('🔄 ResearcherRepository: Submitting details...');
      
      // Convert entity to model for remote source
      final detailsModel = ResearcherDetailsModel.fromEntity(details);

      final userModel = await remoteDataSource.submitResearcherDetails(
        detailsModel,
        token,
      );

      print('✅ ResearcherRepository: Submission successful');
      
      return Right(userModel.toEntity());
      
    } on ValidationException catch (e) {
      print('❌ ResearcherRepository: Validation error');
      return Left(ValidationFailure(e.message, errors: e.errors));
      
    } on AuthException catch (e) {
      print('❌ ResearcherRepository: Auth error');
      return Left(AuthFailure(e.message));
      
    } on ServerException catch (e) {
      print('❌ ResearcherRepository: Server error (${e.statusCode})');
      
      // ⭐ MODIFIED: Defensive null check for the error message
      final errorMessage = e.message?.isNotEmpty == true
          ? e.message!
          : 'Server communication failed or connection refused (Status: ${e.statusCode}).';
          
      return Left(ServerFailure(errorMessage, e.statusCode));
      
    } catch (e) {
      print('❌ ResearcherRepository: Unexpected error: $e');
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  // ========================================
  // GET RESEARCH PURPOSES
  // ========================================

  @override
  Future<Either<Failure, List<String>>> getResearchPurposes({
    required String token,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final purposes = await remoteDataSource.getResearchPurposes(token);
      return Right(purposes);
      
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
      
    } on ServerException catch (e) {
      // Added defensive check here too, just in case
      final errorMessage = e.message?.isNotEmpty == true
          ? e.message!
          : 'Server communication failed during purpose retrieval (Status: ${e.statusCode}).';
          
      return Left(ServerFailure(errorMessage, e.statusCode));
      
    } catch (e) {
      return Left(ServerFailure('Failed to load research purposes: $e'));
    }
  }
}