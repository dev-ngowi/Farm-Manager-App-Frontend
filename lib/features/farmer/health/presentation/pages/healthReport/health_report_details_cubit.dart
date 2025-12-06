// health_report_details_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

// --- State Definitions ---
abstract class HealthReportDetailsState {}

class HealthReportDetailsInitial extends HealthReportDetailsState {}
class HealthReportDetailsLoading extends HealthReportDetailsState {}
class HealthReportDetailsLoaded extends HealthReportDetailsState {
  final Map<String, dynamic> report;
  HealthReportDetailsLoaded(this.report);
}
class HealthReportDetailsError extends HealthReportDetailsState {
  final String error;
  HealthReportDetailsError(this.error);
}

// --- Cubit Implementation ---
class HealthReportDetailsCubit extends Cubit<HealthReportDetailsState> {
  HealthReportDetailsCubit() : super(HealthReportDetailsInitial());

  // Mock data structure matching the backend SHOW response
  final Map<String, dynamic> _mockReport = {
    'health_id': 1,
    'report_date': '2025-11-20',
    'symptoms': 'Severe fever, heavy coughing, and visible swelling in the joints.',
    'symptom_onset_date': '2025-11-18',
    'severity': 'Critical',
    'priority': 'Emergency',
    'status': 'Under Treatment',
    'notes': 'Farmer administered preliminary antibiotics, but symptoms worsened quickly.',
    'location_latitude': -6.8,
    'location_longitude': 37.6,
    'animal': {
      'animal_id': 'A001',
      'tag_number': 'A001',
      'name': 'Cow 1',
      'sex': 'Female',
    },
    'media': [
      {'id': 1, 'url': 'https://mock.com/img/cow-eye.jpg', 'type': 'photo'},
      {'id': 2, 'url': 'https://mock.com/vid/cough.mp4', 'type': 'video'},
    ],
    'diagnoses': [
      {
        'diagnosis_id': 101,
        'diagnosis_date': '2025-11-21',
        'condition': 'Pneumonia (Confirmed)',
        'vet_notes': 'Confirmed via initial lab results. Immediate aggressive treatment needed.',
        'vet': {'id': 50, 'name': 'Dr. Mshana', 'phone': '555-1234'},
        'treatments': [
          {'id': 501, 'drug_name': 'Oxytetracycline', 'dosage': '5ml/day'}
        ]
      }
    ],
    'treatments': [
      {'id': 501, 'treatment_date': '2025-11-21', 'drug_name': 'Oxytetracycline', 'details': 'Administered first dose intravenously.', 'follow_up_date': '2025-11-25'},
      {'id': 502, 'treatment_date': '2025-11-22', 'drug_name': 'Vitamin B12', 'details': 'Supportive care.', 'follow_up_date': null},
    ],
  };

  Future<void> fetchReport(String healthId) async {
    emit(HealthReportDetailsLoading());
    try {
      // Simulate API call to /api/farmer/health/reports/{health_id}
      await Future.delayed(const Duration(milliseconds: 700));

      // In a real app, you would check if the fetched ID matches the requested ID.
      // We will just return the mock report since the ID is simulated.
      if (healthId == '1') {
         emit(HealthReportDetailsLoaded(_mockReport));
      } else {
        emit(HealthReportDetailsError('Report with ID $healthId not found.'));
      }

    } catch (e) {
      emit(HealthReportDetailsError('Failed to load report details: ${e.toString()}'));
    }
  }
}