// diagnosis_list_state.dart

/// Base class for all Diagnosis List states.
abstract class DiagnosisListState {
  const DiagnosisListState();
}

/// Initial state before any operation.
class DiagnosisListInitial extends DiagnosisListState {}

/// State while fetching data from the server.
class DiagnosisListLoading extends DiagnosisListState {}

/// State when data has been successfully loaded.
class DiagnosisListLoaded extends DiagnosisListState {
  final List<Map<String, dynamic>> diagnoses;

  const DiagnosisListLoaded(this.diagnoses);
}

/// State when an error occurs during data fetching.
class DiagnosisListError extends DiagnosisListState {
  final String error;

  const DiagnosisListError(this.error);
}