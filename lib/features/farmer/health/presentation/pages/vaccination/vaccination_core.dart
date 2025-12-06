// Core components for the Vaccination feature: Model, Service, and Shared UI/Mock classes.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// --- MOCK THEME & LOCALIZATION IMPORTS (Aligned with Treatment Files) ---

class AppColors {
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFF44336);   // Red
  static const Color info = Color(0xFFFF9800);    // Orange
  static const Color primary = Color(0xFF1976D2); // Blue
}

class BreedingColors {
  // Using the primary color from the Treatment list for consistency (a deep blue/purple)
  static const Color insemination = Color(0xFF4C52C7); 
}

class MockL10n {
  const MockL10n();
  // General Labels
  String get vaccinations => 'Vaccination Schedules';
  String get searchSchedules => 'Search vaccine or animal tag...';
  String get noSchedulesFound => 'No pending vaccination schedules found.';
  String get noResultsFound => 'No results found for your search.';
  String get animal => 'Animal';
  String get scheduledDate => 'Scheduled Date';
  String get vet => 'Vet';
  String get overdueSchedules => 'Show Overdue';
  String get scheduleDetails => 'Schedule Details';
  String get vaccineName => 'Vaccine';
  String get prevents => 'Prevents Disease';
  String get plannedBy => 'Planned By';
  String get completedDetails => 'Completion Details';
  String get completedOn => 'Completed On';
  String get batchNumber => 'Batch Number';
  String get completeVaccination => 'Complete Vaccination';
  String get confirmCompletion => 'Confirm Vaccination Completion';
  String get batchRequired => 'Batch Number is required.';
  String get completingVaccine => 'Completing vaccination...';
  String get completeSuccess => 'Vaccination completed successfully!';
  String get completeError => 'Error completing vaccination:';
}

// --- 1. Data Model ---

class VaccinationSchedule {
  final int scheduleId;
  final String vaccineName;
  final String diseasePrevented;
  final DateTime scheduledDate;
  final String status;
  final String animalTag;
  final String animalName;
  final String veterinarianName;
  final String? batchNumber;
  final DateTime? completedDate;
  
  final String statusSwahili;

  VaccinationSchedule({
    required this.scheduleId,
    required this.vaccineName,
    required this.diseasePrevented,
    required this.scheduledDate,
    required this.status,
    required this.animalTag,
    required this.animalName,
    required this.veterinarianName,
    required this.statusSwahili,
    this.batchNumber,
    this.completedDate,
  });

  factory VaccinationSchedule.fromJson(Map<String, dynamic> json) {
    final animal = json['animal'] ?? {};
    final veterinarian = json['veterinarian'] ?? {};

    String getSwahiliStatus(String status) {
        switch (status) {
            case 'Pending': return 'Inasubiri';
            case 'Completed': return 'Imekamilika';
            case 'Missed': return 'Imepitwa';
            default: return status;
        }
    }

    return VaccinationSchedule(
      scheduleId: json['schedule_id'],
      vaccineName: json['vaccine_name'],
      diseasePrevented: json['disease_prevented'] ?? 'N/A',
      scheduledDate: DateTime.parse(json['scheduled_date']),
      status: json['status'],
      animalTag: animal['tag_number'] ?? 'No Tag',
      animalName: animal['name'] ?? 'Unknown Animal',
      veterinarianName: veterinarian['name'] ?? 'Unknown Vet',
      batchNumber: json['batch_number'],
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null,
      statusSwahili: getSwahiliStatus(json['status']),
    );
  }

  Color get flutterStatusColor {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'Missed':
        return AppColors.error;
      case 'Pending':
      default:
        return AppColors.info; 
    }
  }

  String get searchableText =>
      '${vaccineName} ${diseasePrevented} ${animalTag} ${animalName} ${veterinarianName} ${statusSwahili}';
}

// --- 2. API Service ---

class VaccinationService {
  final String _baseUrl = 'http://your-laravel-api.com/api/farmer/vaccinations'; 
  final String _authToken = 'YOUR_AUTH_TOKEN'; 

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_authToken',
      };

  // MOCK Implementation for fetching schedules
  Future<List<VaccinationSchedule>> fetchSchedules({bool overdue = false}) async {
    final _mockRawBackendData = [
        {'schedule_id': 1, 'vaccine_name': 'Foot & Mouth', 'disease_prevented': 'FMD', 'scheduled_date': '2025-12-07', 'status': 'Pending', 'batch_number': null, 'completed_date': null, 
            'animal': {'tag_number': 'A001', 'name': 'Cow Lucy'}, 'veterinarian': {'name': 'Dr. Amina'}},
        {'schedule_id': 2, 'vaccine_name': 'Rinderpest', 'disease_prevented': 'Rinderpest', 'scheduled_date': '2025-11-20', 'status': 'Completed', 'batch_number': 'RP-9987', 'completed_date': '2025-11-20T11:00:00Z', 
            'animal': {'tag_number': 'B002', 'name': 'Goat Billy'}, 'veterinarian': {'name': 'Dr. Musa'}},
        {'schedule_id': 3, 'vaccine_name': 'Lumpy Skin Disease', 'disease_prevented': 'LSD', 'scheduled_date': '2025-12-01', 'status': 'Pending', 'batch_number': null, 'completed_date': null, 
            'animal': {'tag_number': 'C003', 'name': 'Bull Rex'}, 'veterinarian': {'name': 'Dr. Amina'}}, // Overdue (MOCK DATE: 2025-12-05)
        {'schedule_id': 4, 'vaccine_name': 'Rabies', 'disease_prevented': 'Rabies', 'scheduled_date': '2026-01-15', 'status': 'Pending', 'batch_number': null, 'completed_date': null, 
            'animal': {'tag_number': 'D004', 'name': 'Dog Max'}, 'veterinarian': {'name': 'Dr. Amina'}},
    ];

    await Future.delayed(const Duration(milliseconds: 500)); 

    List<Map<String, dynamic>> filteredData = _mockRawBackendData;
    
    if (overdue) {
        final mockToday = DateTime.parse('2025-12-05'); 
        filteredData = filteredData.where((item) {
            final scheduledDate = DateTime.parse(item['scheduled_date']);
            return item['status'] == 'Pending' && scheduledDate.isBefore(mockToday);
        }).toList();
    } else {
        // Show all except completed by default
        filteredData = filteredData.where((item) => item['status'] != 'Completed').toList();
    }

    return filteredData.map((json) => VaccinationSchedule.fromJson(json)).toList();
  }

  // MOCK Implementation for fetching schedule details
  Future<VaccinationSchedule> fetchScheduleDetails(int scheduleId) async {
    final Map<int, Map<String, dynamic>> mockData = {
        1: {'schedule_id': 1, 'vaccine_name': 'Foot & Mouth', 'disease_prevented': 'FMD', 'scheduled_date': '2025-12-07', 'status': 'Pending', 'batch_number': null, 'completed_date': null, 
            'animal': {'tag_number': 'A001', 'name': 'Cow Lucy'}, 'veterinarian': {'name': 'Dr. Amina'}},
        3: {'schedule_id': 3, 'vaccine_name': 'Lumpy Skin Disease', 'disease_prevented': 'LSD', 'scheduled_date': '2025-12-01', 'status': 'Pending', 'batch_number': null, 'completed_date': null, 
            'animal': {'tag_number': 'C003', 'name': 'Bull Rex'}, 'veterinarian': {'name': 'Dr. Amina'}},
        2: {'schedule_id': 2, 'vaccine_name': 'Rinderpest', 'disease_prevented': 'Rinderpest', 'scheduled_date': '2025-11-20', 'status': 'Completed', 'batch_number': 'RP-9987', 'completed_date': '2025-11-20T11:00:00Z', 
            'animal': {'tag_number': 'B002', 'name': 'Goat Billy'}, 'veterinarian': {'name': 'Dr. Musa'}},
    };

    await Future.delayed(const Duration(milliseconds: 300)); 
    final data = mockData[scheduleId];

    if (data != null) {
      return VaccinationSchedule.fromJson(data);
    }
    throw Exception('Schedule $scheduleId not found.');
  }

  // MOCK Implementation for marking as completed
  Future<VaccinationSchedule> markCompleted(int scheduleId, String batchNumber) async {
    await Future.delayed(const Duration(seconds: 1));

    if (scheduleId == 1) {
        return VaccinationSchedule.fromJson({
            'schedule_id': 1, 'vaccine_name': 'Foot & Mouth', 'disease_prevented': 'FMD', 
            'scheduled_date': '2025-12-07', 'status': 'Completed', 'batch_number': batchNumber, 
            'completed_date': '2025-12-05T15:00:00Z', 
            'animal': {'tag_number': 'A001', 'name': 'Cow Lucy'}, 'veterinarian': {'name': 'Dr. Amina'}
        });
    }

    throw Exception('Mock completion failed for ID $scheduleId');
  }
}

// --- 3. Shared UI Component ---

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({required this.text, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
        label: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
          ),
        ),
        backgroundColor: color.withOpacity(0.2),
        side: BorderSide(color: color, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}