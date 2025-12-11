import 'package:flutter_bloc/flutter_bloc.dart';

// --- Cubit State Definitions ---
abstract class AddHealthReportState {}

class AddHealthReportInitial extends AddHealthReportState {}
class AddHealthReportLoading extends AddHealthReportState {}
class AddHealthReportDropdownsLoaded extends AddHealthReportState {
  final List<DropdownItem> animals;
  final List<DropdownItem> severities;
  final List<DropdownItem> priorities;

  AddHealthReportDropdownsLoaded({
    required this.animals,
    required this.severities,
    required this.priorities,
  });
}
class AddHealthReportSuccess extends AddHealthReportState {
  final String message;
  AddHealthReportSuccess(this.message);
}
class AddHealthReportError extends AddHealthReportState {
  final String error;
  AddHealthReportError(this.error);
}

// --- Data Model for Dropdowns (Matches API 'value' and 'label') ---
class DropdownItem {
  final String value;
  final String label;
  const DropdownItem({required this.value, required this.label});

  factory DropdownItem.fromMap(Map<String, dynamic> map) {
    return DropdownItem(
      value: map['value'] as String,
      label: map['label'] as String,
    );
  }
}

// --- Cubit Implementation ---
class AddHealthReportCubit extends Cubit<AddHealthReportState> {
  AddHealthReportCubit() : super(AddHealthReportInitial());

  // Mock data structure matching the backend dropdowns response
  final Map<String, dynamic> _mockDropdowns = {
    'animals': [
      {'value': 'A001', 'label': 'A001 - Cow 1'},
      {'value': 'B005', 'label': 'B005 - Goat 5'},
    ],
    'severities': [
      {'value': 'Mild', 'label': 'Mild'},
      {'value': 'Moderate', 'label': 'Moderate'},
      {'value': 'Severe', 'label': 'Severe'},
      {'value': 'Critical', 'label': 'Critical'},
    ],
    'priorities': [
      {'value': 'Low', 'label': 'Low'},
      {'value': 'Medium', 'label': 'Medium'},
      {'value': 'High', 'label': 'High'},
      {'value': 'Emergency', 'label': 'Emergency'},
    ],
  };

  Future<void> fetchDropdowns() async {
    // Check if data is already loaded to avoid redundant API calls
    if (state is AddHealthReportDropdownsLoaded) return;

    emit(AddHealthReportLoading());
    try {
      // Simulate API call to /api/farmer/health/reports/dropdowns
      await Future.delayed(const Duration(milliseconds: 500));

      final animals = (_mockDropdowns['animals'] as List).map((e) => DropdownItem.fromMap(e)).toList();
      final severities = (_mockDropdowns['severities'] as List).map((e) => DropdownItem.fromMap(e)).toList();
      final priorities = (_mockDropdowns['priorities'] as List).map((e) => DropdownItem.fromMap(e)).toList();

      emit(AddHealthReportDropdownsLoaded(
        animals: animals,
        severities: severities,
        priorities: priorities,
      ));
    } catch (e) {
      emit(AddHealthReportError('Failed to load dropdown data.'));
    }
  }

  // Submission function (Maps to API POST /api/farmer/health/reports)
  Future<void> submitReport(Map<String, dynamic> formData) async {
    emit(AddHealthReportLoading());
    try {
      // 1. Placeholder for API submission logic (e.g., using Dio or http)
      // Note: File uploads need special handling (MultipartForm data).

      // Simulate network delay and success
      await Future.delayed(const Duration(seconds: 2));

      // 2. Mock Validation (Checking required fields used in the API: animal_id, symptoms, severity, priority, symptom_onset_date)
      if (formData['animal_id'] == null ||
          formData['symptoms'] == null ||
          formData['severity'] == null ||
          formData['priority'] == null ||
          formData['symptom_onset_date'] == null) {
        throw Exception('Missing required fields.');
      }

      emit(AddHealthReportSuccess('Health report submitted successfully! Status: Pending Diagnosis.'));

    } catch (e) {
      // Handle API errors or mock validation errors
      emit(AddHealthReportError('Submission failed: ${e.toString()}'));
      // Reload dropdowns if they were overwritten by the loading state
      fetchDropdowns();
    }
  }
}