// diagnosis_details_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'diagnosis_details_state.dart';

class DiagnosisDetailsCubit extends Cubit<DiagnosisDetailsState> {
  DiagnosisDetailsCubit() : super(DiagnosisDetailsInitial());

  // Mock data source for details (typically fetched from a repository/API)
  final Map<String, Map<String, dynamic>> _mockDetails = {
    "D001": {
      "diagnosis_id": "D001",
      "report_id": "H005",
      "condition": "Bovine Respiratory Disease (BRD)",
      "vet_notes": "Identified bilateral lung congestion and high fever. Likely caused by P. multocida. Immediate isolation required.",
      "diagnosis_date": "2024-10-25T10:00:00Z",
      "vet": {"id": "V001", "name": "Dr. Emily Hayes", "contact": "555-001"},
      "treatments": [
        {"drug_name": "Tilmicosin", "dosage": "10mg/kg", "frequency": "Once", "administered_date": "2024-10-25T11:00:00Z"},
        {"drug_name": "Flunixin Meglumine", "dosage": "2.2mg/kg", "frequency": "Daily for 3 days", "administered_date": "2024-10-25T11:00:00Z"},
      ],
      "health_report_summary": {
        "animal_name": "Cow #456",
        "tag_number": "A123",
        "symptoms": "Coughing, nasal discharge, anorexia, fever (105°F)",
        "status": "Under Treatment",
      }
    },
    "D002": {
      "diagnosis_id": "D002",
      "report_id": "H012",
      "condition": "Mastitis",
      "vet_notes": "Culture confirmed Streptococcus uberis. Quarter is swollen and hot. Starting intramammary antibiotics.",
      "diagnosis_date": "2024-10-20T14:30:00Z",
      "vet": {"id": "V002", "name": "Dr. Alex Johnson", "contact": "555-002"},
      "treatments": [
        {"drug_name": "Pirsue", "dosage": "Intramammary", "frequency": "Daily for 5 days", "administered_date": "2024-10-20T15:00:00Z"},
      ],
      "health_report_summary": {
        "animal_name": "Cow #101",
        "tag_number": "M45B",
        "symptoms": "Swollen, red udder quarter, watery milk.",
        "status": "Awaiting Treatment",
      }
    },
    "D003": {
      "diagnosis_id": "D003",
      "report_id": "H001",
      "condition": "Foot Rot",
      "vet_notes": "Typical presentation of Dichelobacter nodosus infection. Trimmed foot and applied topical treatment.",
      "diagnosis_date": "2024-10-15T08:00:00Z",
      "vet": {"id": "V001", "name": "Dr. Emily Hayes", "contact": "555-001"},
      "treatments": [
        {"drug_name": "Excede", "dosage": "1.0 ml/100lb", "frequency": "Once", "administered_date": "2024-10-15T09:00:00Z"},
      ],
      "health_report_summary": {
        "animal_name": "Bull #12",
        "tag_number": "X99X",
        "symptoms": "Severe lameness, swelling between the toes, foul odor.",
        "status": "Recovered",
      }
    },
  };

  /// Fetches the detailed information for a specific diagnosis ID.
  Future<void> fetchDiagnosisDetails(String diagnosisId) async {
    emit(DiagnosisDetailsLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 700));

      final data = _mockDetails[diagnosisId];
      if (data == null) {
        throw Exception('Diagnosis not found for ID: $diagnosisId');
      }

      emit(DiagnosisDetailsLoaded(data));
    } catch (e) {
      emit(DiagnosisDetailsError('Failed to load diagnosis details: ${e.toString()}'));
    }
  }
}