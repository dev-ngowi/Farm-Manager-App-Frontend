import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';

abstract class LocationRepository {
  Future<Either<Failure, List<dynamic>>> getRegions();
  Future<Either<Failure, List<dynamic>>> getDistricts(int regionId);
  Future<Either<Failure, List<dynamic>>> getWards(int districtId);
  Future<Either<Failure, List<dynamic>>> searchWards(String query, int districtId);
  Future<Either<Failure, dynamic>> createWard(String wardName, int districtId);
  Future<Either<Failure, void>> saveUserLocation({
    required int regionId,
    required int districtId,
    required int wardId,
    required double latitude,
    required double longitude,
    String? addressDetails,
  });
  Future<Either<Failure, bool>> userHasLocation();
}