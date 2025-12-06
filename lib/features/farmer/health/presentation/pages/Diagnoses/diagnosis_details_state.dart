// diagnosis_details_state.dart

/// Base class for all Diagnosis Details states.
abstract class DiagnosisDetailsState {
  const DiagnosisDetailsState();
}

/// Initial state before any operation.
class DiagnosisDetailsInitial extends DiagnosisDetailsState {}

/// State while fetching data from the server.
class DiagnosisDetailsLoading extends DiagnosisDetailsState {}

/// State when data has been successfully loaded.
class DiagnosisDetailsLoaded extends DiagnosisDetailsState {
  final Map<String, dynamic> diagnosis;
  
  const DiagnosisDetailsLoaded(this.diagnosis);
}

/// State when an error occurs during data fetching.
class DiagnosisDetailsError extends DiagnosisDetailsState {
  final String error;

  const DiagnosisDetailsError(this.error);
}