import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// [DetailedInsemination, Livestock, Semen, HeatCycle models remain unchanged]

class DetailedInsemination {
  final int id;
  final String breedingMethod;
  final String status;
  final String inseminationDate;
  final String expectedDeliveryDate;
  final String notes;

  // Nested Dam/Animal details
  final String damName;
  final String damTagNumber;
  final String speciesName;

  // Nested Sire/Semen details
  final String? sireName;
  final String? sireTagNumber;
  final String? semenStrawCode;
  final String? semenBullName;

  // Nested Technician details
  final String? technicianName;

  // Nested Pregnancy Check details
  final List<String> pregnancyCheckResults;

  DetailedInsemination({
    required this.id,
    required this.breedingMethod,
    required this.status,
    required this.inseminationDate,
    required this.expectedDeliveryDate,
    this.notes = '',
    required this.damName,
    required this.damTagNumber,
    required this.speciesName,
    this.sireName,
    this.sireTagNumber,
    this.semenStrawCode,
    this.semenBullName,
    this.technicianName,
    this.pregnancyCheckResults = const [],
  });

  // Factory to create from a JSON-like map (simulating API response)
  factory DetailedInsemination.fromJson(Map<String, dynamic> json) {
    String formatDate(String dateString) {
      if (dateString.isEmpty) return 'N/A';
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(dateString));
      } catch (e) {
        return dateString;
      }
    }

    // Extract Pregnancy Check results
    final checks = json['pregnancyChecks'] as List<dynamic>? ?? [];
    final pregnancyCheckResults = checks
        .map((check) =>
            '${check['result']} on ${formatDate(check['check_date'] as String)}')
        .toList();

    return DetailedInsemination(
      id: json['id'] as int,
      breedingMethod: json['breeding_method'] as String,
      status: json['status'] as String,
      inseminationDate: formatDate(json['insemination_date'] as String),
      expectedDeliveryDate:
          formatDate(json['expected_delivery_date'] as String),
      notes: json['notes'] as String? ?? '',

      // Dam details
      damName: json['dam']?['name'] ?? 'N/A',
      damTagNumber: json['dam']?['tag_number'] ?? 'N/A',
      // Assuming species is nested under dam.species, but using placeholder for simplicity
      speciesName: 'Cattle',

      // Sire details (for Natural)
      sireName: json['sire']?['name'],
      sireTagNumber: json['sire']?['tag_number'],

      // Semen details (for AI)
      semenStrawCode: json['semen']?['straw_code'],
      semenBullName: json['semen']?['bull_name'],

      // Technician details
      technicianName: json['technician']?['name'],

      pregnancyCheckResults: pregnancyCheckResults,
    );
  }
}

class InseminationDetailPage extends StatelessWidget {
  static const String routeName = '/farmer/breeding/inseminations/:id';
  final int inseminationId;

  const InseminationDetailPage({super.key, required this.inseminationId});

  // Mock data function to simulate fetching a single item
  DetailedInsemination _fetchMockData(int id) {
    // Mock response for ID 1 (AI)
    if (id == 1) {
      return DetailedInsemination.fromJson({
        'id': 1,
        'insemination_date': '2025-12-02',
        'expected_delivery_date': '2026-09-11',
        'breeding_method': 'AI',
        'status': 'Pending',
        'notes': 'First-time AI, monitored closely for success.',
        'dam': {'name': 'Cow', 'tag_number': '101'},
        'semen': {'straw_code': 'A901', 'bull_name': 'Champion Bull'},
        'technician': {'name': 'Dr. Mfumo'},
        'pregnancyChecks': [
          {'check_date': '2026-02-10', 'result': 'Not Checked'},
        ]
      });
    }
    // Mock response for ID 2 (Natural)
    return DetailedInsemination.fromJson({
      'id': 2,
      'insemination_date': '2025-11-25',
      'expected_delivery_date': '2026-09-04',
      'breeding_method': 'Natural',
      'status': 'Confirmed Pregnant',
      'notes': 'Successful natural breeding with established bull.',
      'dam': {'name': 'Cow', 'tag_number': '115'},
      'sire': {'name': 'Bull', 'tag_number': '10'},
      'technician': null,
      'pregnancyChecks': [
        {'check_date': '2026-02-01', 'result': 'Pregnant'},
        {'check_date': '2026-05-01', 'result': 'Pregnant'},
      ]
    });
  }

  // Helper method updated to map all backend statuses to colors
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed Pregnant':
      case 'Delivered':
        return AppColors.success;
      case 'Failed':
      case 'Not Pregnant':
        return AppColors.error;
      case 'Pending':
      default:
        return AppColors.secondary;
    }
  }
  
  // Action to navigate to the Edit Page
  void _handleEdit(BuildContext context, int id) {
    context.push('/farmer/breeding/inseminations/$id/edit');
  }

  // Action to show Delete Confirmation Dialog
  void _handleDelete(BuildContext context, AppLocalizations l10n, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteInsemination),
        // Use the plural key and pass the ID as an argument
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement API call to your backend 'destroy' endpoint
              print('Deleting Insemination ID: $id');
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to the list page
            },
            child:
                Text(l10n.delete, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = BreedingColors.insemination;

    final data = _fetchMockData(inseminationId);
    final statusColor = _getStatusColor(data.status);

    return Scaffold(
      // --- START: APPBAR MODIFICATION ---
      appBar: AppBar(
        title: Text('${l10n.inseminations} #${data.id}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            onPressed: () => _handleEdit(context, data.id),
          ),
        ],
      ),
      // --- END: APPBAR MODIFICATION ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Status and Dam Info ---
            _buildHeaderCard(l10n, theme, data, statusColor),

            const SizedBox(height: 20),

            _buildSectionHeader(l10n.breedingDetails, Icons.spa),
            _buildDetailCard(
              l10n,
              {
                l10n.method: data.breedingMethod,
                l10n.inseminationDate: data.inseminationDate,
                l10n.dueDate: data.expectedDeliveryDate,
                l10n.technician: data.technicianName ?? l10n.unknown,
              },
            ),

            const SizedBox(height: 20),

            // --- Sire/Semen Details Section ---
            _buildSectionHeader(l10n.breedingPartner, Icons.male),
            _buildSireOrSemenCard(l10n, data),

            const SizedBox(height: 20),

            // --- Notes ---
            _buildSectionHeader(l10n.notes, Icons.description),
            Text(
              data.notes.isNotEmpty ? data.notes : l10n.noNotes,
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 20),

            // --- Pregnancy Checks ---
            _buildSectionHeader(l10n.pregnancyChecks, Icons.monitor_heart),
            _buildPregnancyChecksList(l10n, theme, data.pregnancyCheckResults),
          ],
        ),
      ),
      // --- START: BOTTOM NAVIGATION BAR MODIFICATION ---
      bottomNavigationBar:
          _buildActionButtons(context, l10n, AppColors.error, data.id),
      // --- END: BOTTOM NAVIGATION BAR MODIFICATION ---
    );
  }

  // --- Widget Builders (Unchanged) ---

  Widget _buildHeaderCard(AppLocalizations l10n, ThemeData theme,
      DetailedInsemination data, Color statusColor) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(data.status),
              backgroundColor: statusColor.withOpacity(0.2),
              side: BorderSide(color: statusColor, width: 1),
              labelStyle: theme.textTheme.titleSmall
                  ?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${data.damName} #${data.damTagNumber}',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${data.speciesName} - ${l10n.dam}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: BreedingColors.insemination, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BreedingColors.insemination,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(AppLocalizations l10n, Map<String, String> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: details.entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text('${entry.key}:',
                            style: TextStyle(color: Colors.grey[700])),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(entry.value,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSireOrSemenCard(
      AppLocalizations l10n, DetailedInsemination data) {
    if (data.breedingMethod == 'Natural' && data.sireName != null) {
      return _buildDetailCard(l10n, {
        l10n.sireName: data.sireName!,
        l10n.tagNumber: data.sireTagNumber!,
      });
    } else if (data.breedingMethod == 'AI' && data.semenBullName != null) {
      return _buildDetailCard(l10n, {
        l10n.bullName: data.semenBullName!,
        l10n.strawCode: data.semenStrawCode!,
      });
    }
    return Text(l10n.detailsUnavailable,
        style: TextStyle(color: Colors.grey[600]));
  }

  Widget _buildPregnancyChecksList(
      AppLocalizations l10n, ThemeData theme, List<String> results) {
    if (results.isEmpty) {
      return Text(l10n.noPregnancyChecksRecorded,
          style: TextStyle(color: Colors.grey[600]));
    }

    return Card(
      child: Column(
        children: results
            .map(
              (result) => ListTile(
                dense: true,
                leading:
                    Icon(Icons.check_circle_outline, color: AppColors.info),
                title: Text(result),
                subtitle: Text(l10n.checkRecord),
                // TODO: Add onTap to view detailed check record
              ),
            )
            .toList(),
      ),
    );
  }

  // --- MODIFIED ACTION BUTTONS ---
  Widget _buildActionButtons(
      BuildContext context, AppLocalizations l10n, Color deleteColor, int id) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.delete_forever),
        label: Text(l10n.delete),
        onPressed: () => _handleDelete(context, l10n, id),
        style: OutlinedButton.styleFrom(
          foregroundColor: deleteColor,
          side: BorderSide(color: deleteColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}