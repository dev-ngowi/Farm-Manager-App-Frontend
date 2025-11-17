abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Error']);
}

class ServerFailure extends Failure {
  // FIX: Provide a default message and make the argument optional
  ServerFailure([String message = 'Server Error Occurred']) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure() : super('No internet connection');
}