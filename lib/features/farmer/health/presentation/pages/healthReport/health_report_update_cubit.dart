// health_report_update_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

// --- State Definitions ---
abstract class HealthReportUpdateState {}

class HealthReportUpdateInitial extends HealthReportUpdateState {}
class HealthReportUpdateLoading extends HealthReportUpdateState {}
class HealthReportUpdateSuccess extends HealthReportUpdateState {
  final String message;
  final Map<String, dynamic> updatedReport;
  HealthReportUpdateSuccess(this.message, this.updatedReport);
}
class HealthReportUpdateError extends HealthReportUpdateState {
  final String error;
  HealthReportUpdateError(this.error);
}

// --- Cubit Implementation ---
class HealthReportUpdateCubit extends Cubit<HealthReportUpdateState> {
  HealthReportUpdateCubit() : super(HealthReportUpdateInitial());

  // Available options for Status and Priority (matching backend validation)
  static const List<String> statusOptions = [
    'Pending Diagnosis', 'Under Diagnosis', 'Awaiting Treatment',
    'Under Treatment', 'Recovered', 'Deceased'
  ];
  static const List<String> priorityOptions = [
    'Low', 'Medium', 'High', 'Emergency'
  ];

  Future<void> updateReport(String healthId, Map<String, dynamic> formData) async {
    emit(HealthReportUpdateLoading());
    try {
      // 1. Validate data structure (Client-side validation)
      if (formData['status'] == null) {
        throw Exception('Status is required.');
      }

      // 2. Simulate API call to PUT/PATCH /api/farmer/health/reports/{health_id}
      await Future.delayed(const Duration(seconds: 1)); 

      // 3. Mock the successful update response
      // In a real app, the API would return the updated report data.
      final updatedData = {
        'health_id': healthId,
        'status': formData['status'],
        'priority': formData['priority'] ?? 'Low', // Priority might be optional/defaulted
        'notes': formData['notes'] ?? '',
      };

      emit(HealthReportUpdateSuccess('Report updated successfully!', updatedData));

    } catch (e) {
      emit(HealthReportUpdateError('Failed to update report: ${e.toString()}'));
    }
  }
}