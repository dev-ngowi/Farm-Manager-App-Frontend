// lib/features/farmer/insemination/domain/usecases/usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:farm_manager_app/core/error/failure.dart'; // ⭐ Using the user's standard failure.dart

/// Abstract base class for all Use Cases (Interactors) in the application.
///
/// T is the return type of the Use Case.
/// P is the parameters class used to pass arguments.
abstract class UseCase<T, P> {
  /// The call operator makes the UseCase callable like a function.
  Future<Either<Failure, T>> call(P params);
}

/// Abstract base class for Use Case parameters.
abstract class Params extends Equatable {
  const Params();
}

/// Concrete class for Use Cases that do not require any parameters.
class NoParams extends Params {
  const NoParams();
  
  @override
  List<Object?> get props => [];
}

/// Params class for Use Cases that require data submission (e.g., Add, Update)
class DataParams extends Params {
  final Map<String, dynamic> data;
  const DataParams({required this.data});
  
  @override
  List<Object?> get props => [data];
}

/// Params class for Use Cases that require an ID (e.g., Detail, Delete)
class IdParams extends Params {
  final int id;
  const IdParams({required this.id});
  
  @override
  List<Object?> get props => [id];
}