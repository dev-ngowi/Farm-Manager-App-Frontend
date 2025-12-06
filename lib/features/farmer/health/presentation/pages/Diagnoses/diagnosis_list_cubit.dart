// diagnosis_list_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'diagnosis_list_state.dart';

class DiagnosisListCubit extends Cubit<DiagnosisListState> {
  DiagnosisListCubit() : super(DiagnosisListInitial()) {
    fetchDiagnoses();
  }

  /// Simulates fetching a list of diagnoses from an API endpoint 
  /// (e.g., GET /api/farmer/diagnoses).
  Future<void> fetchDiagnoses() async {
    emit(DiagnosisListLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1)); 

      // Mocked list of diagnoses
      final mockDiagnoses = [
        {
          "diagnosis_id": "D001",
          "report_id": "H005",
          "condition": "Bovine Respiratory Disease (BRD)",
          "diagnosis_date": "2024-10-25T10:00:00Z",
          "vet": {"id": "V001", "name": "Dr. Emily Hayes"},
          "treatment_count": 3
        },
        {
          "diagnosis_id": "D002",
          "report_id": "H012",
          "condition": "Mastitis",
          "diagnosis_date": "2024-10-20T14:30:00Z",
          "vet": {"id": "V002", "name": "Dr. Alex Johnson"},
          "treatment_count": 5
        },
        {
          "diagnosis_id": "D003",
          "report_id": "H001",
          "condition": "Foot Rot",
          "diagnosis_date": "2024-10-15T08:00:00Z",
          "vet": {"id": "V001", "name": "Dr. Emily Hayes"},
          "treatment_count": 1
        },
      ];

      // Simulate an error occasionally for testing purposes
      // if (DateTime.now().minute % 2 == 0) {
      //   throw Exception('Simulated network failure on fetch.');
      // }

      emit(DiagnosisListLoaded(mockDiagnoses));
    } catch (e) {
      emit(DiagnosisListError('Could not load diagnoses: ${e.toString()}'));
    }
  }
}