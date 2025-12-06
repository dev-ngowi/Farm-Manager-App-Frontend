import 'package:dartz/dartz.dart';
import 'package:farm_manager_app/core/error/failure.dart';

/// Base class for all use cases.
///
/// Every UseCase will take a type `Type` and a type `Params`.
/// The `Type` is the return type of the use case (e.g., [LivestockEntity]).
/// The `Params` is the type of the parameters passed to the use case (e.g., [int], [Map<String, dynamic>]).
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case for calls that require no parameters.
class NoParams {}