import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:farm_manager_app/core/config/app_theme.dart'; // Assume AppColors is here
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Uncomment in production

// --- 1. MOCK CUBIT & STATE (Replace with actual implementation) ---
// This Cubit mimics the API calls and state management
class HealthReportsCubit extends Cubit<HealthReportsState> {
  HealthReportsCubit() : super(HealthReportsInitial());

  // MOCK API Data Models (Simplified from backend response)
  final List<Map<String, dynamic>> _mockReports = [
    {
      'health_id': 1,
      'report_date': '2025-11-20',
      'symptoms': 'Fever, loss of appetite',
      'priority': 'Emergency',
      'status': 'Pending Diagnosis',
      'animal': {'tag_number': 'A001', 'name': 'Cow 1'},
      'diagnoses_count': 0,
    },
    {
      'health_id': 2,
      'report_date': '2025-11-15',
      'symptoms': 'Limping',
      'priority': 'High',
      'status': 'Under Treatment',
      'animal': {'tag_number': 'B005', 'name': 'Goat 5'},
      'diagnoses_count': 1,
    },
    // ... more reports
  ];

  // Filters from API: status, priority, animal_id, emergency, today, this_week
  Future<void> fetchReports({
    String? status,
    String? priority,
    String? animalId,
  }) async {
    emit(HealthReportsLoading());
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    // Simple filtering logic
    var filteredReports = _mockReports.where((report) {
      bool statusMatch = status == null || report['status'] == status;
      bool priorityMatch = priority == null || report['priority'] == priority;
      // bool animalMatch = animalId == null || report['animal']['animal_id'] == animalId; // Not implemented in mock
      return statusMatch && priorityMatch;
    }).toList();

    emit(HealthReportsLoaded(
      reports: filteredReports,
      currentPage: 1,
      totalPages: 1,
      totalReports: filteredReports.length,
    ));
  }
}

abstract class HealthReportsState {}
class HealthReportsInitial extends HealthReportsState {}
class HealthReportsLoading extends HealthReportsState {}
class HealthReportsLoaded extends HealthReportsState {
  final List<Map<String, dynamic>> reports;
  final int currentPage;
  final int totalPages;
  final int totalReports;
  HealthReportsLoaded({required this.reports, required this.currentPage, required this.totalPages, required this.totalReports});
}
class HealthReportsError extends HealthReportsState {
  final String message;
  HealthReportsError(this.message);
}

// --- 2. ENUMS for Filtering ---
// Matches the `priority` and `status` fields in the backend
enum ReportPriority {
  low,
  medium,
  high,
  emergency;

  String get apiValue {
    switch (this) {
      case ReportPriority.low: return 'Low';
      case ReportPriority.medium: return 'Medium';
      case ReportPriority.high: return 'High';
      case ReportPriority.emergency: return 'Emergency';
    }
  }
}

enum ReportStatus {
  pendingDiagnosis,
  underDiagnosis,
  awaitingTreatment,
  underTreatment,
  recovered,
  deceased;

  String get apiValue {
    switch (this) {
      case ReportStatus.pendingDiagnosis: return 'Pending Diagnosis';
      case ReportStatus.underDiagnosis: return 'Under Diagnosis';
      case ReportStatus.awaitingTreatment: return 'Awaiting Treatment';
      case ReportStatus.underTreatment: return 'Under Treatment';
      case ReportStatus.recovered: return 'Recovered';
      case ReportStatus.deceased: return 'Deceased';
    }
  }
}


// --- 3. HEALTH REPORTS PAGE WIDGET ---
class HealthReportsPage extends StatefulWidget {
  const HealthReportsPage({super.key});

  @override
  State<HealthReportsPage> createState() => _HealthReportsPageState();
}

class _HealthReportsPageState extends State<HealthReportsPage> {
  // Current filters for the API request
  ReportStatus? _selectedStatus;
  ReportPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    // Start fetching initial data
    context.read<HealthReportsCubit>().fetchReports();
  }

  void _applyFilters() {
    context.read<HealthReportsCubit>().fetchReports(
      status: _selectedStatus?.apiValue,
      priority: _selectedPriority?.apiValue,
    );
  }

  // Helper to map priority string to color (using mock colors)
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Emergency':
        return Colors.red.shade700;
      case 'High':
        return Colors.deepOrange;
      case 'Medium':
        return Colors.yellow.shade800;
      case 'Low':
      default:
        return Colors.green.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!; // Uncomment in production
    const l10n = _MockL10n();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthReports),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            // Calls the API's downloadExcel or downloadAllPdf endpoint
            onPressed: () => _showDownloadOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: _buildPriorityFilter(l10n)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusFilter(l10n)),
              ],
            ),
          ),
          // High Priority Alert Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: _buildHighPriorityAlert(context, l10n),
          ),

          const Divider(),

          // Report List
          Expanded(
            child: BlocBuilder<HealthReportsCubit, HealthReportsState>(
              builder: (context, state) {
                if (state is HealthReportsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is HealthReportsError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                if (state is HealthReportsLoaded) {
                  if (state.reports.isEmpty) {
                    return Center(
                      child: Text(l10n.noReportsFound, style: theme.textTheme.titleMedium),
                    );
                  }
                  return _buildReportList(context, state, l10n);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      // Floating Action Button for adding a new report
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('add-health-report'),
        icon: const Icon(Icons.add),
        label: Text(l10n.recordReport),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildPriorityFilter(_MockL10n l10n) {
    return DropdownButtonFormField<ReportPriority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: l10n.priority,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<ReportPriority>(
          value: null,
          child: Text(l10n.all),
        ),
        ...ReportPriority.values.map((p) => DropdownMenuItem<ReportPriority>(
              value: p,
              child: Text(p.apiValue),
            )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPriority = value;
          _applyFilters();
        });
      },
    );
  }

  Widget _buildStatusFilter(_MockL10n l10n) {
    return DropdownButtonFormField<ReportStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: l10n.status,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<ReportStatus>(
          value: null,
          child: Text(l10n.all),
        ),
        ...ReportStatus.values.map((s) => DropdownMenuItem<ReportStatus>(
              value: s,
              child: Text(s.apiValue),
            )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
          _applyFilters();
        });
      },
    );
  }

  Widget _buildHighPriorityAlert(BuildContext context, _MockL10n l10n) {
    // This alert card directly links to the nested High Priority Reports route.
    return Card(
      color: Colors.red.shade50,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(Icons.warning, color: Colors.red.shade700, size: 30),
        title: Text(l10n.highPriorityCases,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.red.shade800)),
        subtitle: Text(l10n.reviewImmediate),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigates to the nested route: /farmer/health/reports/high
          context.pushNamed('high-priority-reports');
        },
      ),
    );
  }

  Widget _buildReportList(BuildContext context, HealthReportsLoaded state, _MockL10n l10n) {
    return ListView.builder(
      itemCount: state.reports.length,
      itemBuilder: (context, index) {
        final report = state.reports[index];
        final healthId = report['health_id'];
        final reportDate = DateTime.parse(report['report_date']);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // Leading: Priority color indicator
            leading: Container(
              width: 8,
              decoration: BoxDecoration(
                color: _getPriorityColor(report['priority']),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Title: Animal Name and Tag
            title: Text(
              '${report['animal']['name']} (${report['animal']['tag_number']})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            // Subtitle: Symptoms and Date
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${l10n.symptoms}: ${report['symptoms']}', maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${l10n.reportedOn}: ${l10n.formatDate(reportDate)}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            // Trailing: Status and Diagnosis Count
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(report['priority']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report['status'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getPriorityColor(report['priority']), fontWeight: FontWeight.bold),
                  ),
                ),
                if (report['diagnoses_count'] > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${report['diagnoses_count']} ${l10n.diagnoses}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.blue.shade700),
                    ),
                  ),
              ],
            ),
            onTap: () {
              // Navigates to the SHOW page for the full report history
              // Assuming a route structure like: /farmer/health/reports/:health_id
              context.push('/farmer/health/reports/$healthId');
            },
          ),
        );
      },
    );
  }

  void _showDownloadOptions(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!; // Uncomment in production
    const l10n = _MockL10n();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(l10n.downloadAllReportsPDF),
                onTap: () {
                  // Call API: downloadAllPdf
                  Navigator.pop(bc);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.downloadingPDF)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(l10n.downloadAllReportsExcel),
                onTap: () {
                  // Call API: downloadExcel
                  Navigator.pop(bc);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.downloadingExcel)));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- MOCK LOCALIZATION CLASS ---
class _MockL10n {
  const _MockL10n();
  String get healthReports => 'Health Reports';
  String get recordReport => 'Record Report';
  String get priority => 'Priority';
  String get status => 'Status';
  String get all => 'All';
  String get noReportsFound => 'No health reports found matching the filters.';
  String get highPriorityCases => 'High Priority Cases Found!';
  String get reviewImmediate => 'Review emergency and high reports immediately.';
  String get symptoms => 'Symptoms';
  String get reportedOn => 'Reported On';
  String get diagnoses => 'Diagnoses';
  String get downloadAllReportsPDF => 'Download All Reports (PDF)';
  String get downloadAllReportsExcel => 'Download All Reports (Excel/XLSX)';
  String get downloadingPDF => 'Starting PDF download...';
  String get downloadingExcel => 'Starting Excel download...';

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}