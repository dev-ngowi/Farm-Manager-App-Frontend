import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Data Model reflecting Backend JSON (PregnancyCheckController::show) ---

class DetailedPregnancyCheck {
  final int id;
  final String checkDate;
  final String method;
  final String result; // Pregnant, Not Pregnant, Reabsorbed
  final int? fetusCount;
  final String? expectedDeliveryDate;
  final String notes;

  // Nested Insemination/Dam details
  final int inseminationId;
  final String damName;
  final String damTagNumber;
  final String damSpecies;
  
  // Nested Vet details
  final String? vetName;

  DetailedPregnancyCheck({
    required this.id,
    required this.checkDate,
    required this.method,
    required this.result,
    this.fetusCount,
    this.expectedDeliveryDate,
    this.notes = '',
    required this.inseminationId,
    required this.damName,
    required this.damTagNumber,
    this.damSpecies = 'Cattle', // Mocked species for display
    this.vetName,
  });

  // Factory to create from a JSON-like map (simulating API response)
  factory DetailedPregnancyCheck.fromJson(Map<String, dynamic> json) {
    String formatDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return 'N/A';
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(dateString));
      } catch (e) {
        return dateString ?? 'N/A';
      }
    }

    final insemination = json['insemination'] as Map<String, dynamic>?;
    final dam = insemination?['dam'] as Map<String, dynamic>?;
    final vet = json['vet'] as Map<String, dynamic>?;

    return DetailedPregnancyCheck(
      id: json['id'] as int,
      checkDate: formatDate(json['check_date'] as String?),
      method: json['method'] as String,
      result: json['result'] as String,
      fetusCount: json['fetus_count'] as int?,
      expectedDeliveryDate: formatDate(json['expected_delivery_date'] as String?),
      notes: json['notes'] as String? ?? '',
      
      inseminationId: insemination?['id'] as int? ?? 0,
      damName: dam?['name'] ?? 'N/A',
      damTagNumber: dam?['tag_number'] ?? 'N/A',
      vetName: vet?['name'],
    );
  }
}

class PregnancyCheckDetailPage extends StatelessWidget {
  static const String routeName = '/farmer/breeding/pregnancy-checks/:id';
  final int checkId;

  const PregnancyCheckDetailPage({super.key, required this.checkId});

  // Mock data function to simulate fetching a single item
  DetailedPregnancyCheck _fetchMockData(int id) {
    // Mock response for a Positive check
    if (id == 1) {
      return DetailedPregnancyCheck.fromJson({
        'id': 1,
        'insemination_id': 101,
        'check_date': '2025-12-05',
        'method': 'Ultrasound',
        'result': 'Pregnant',
        'fetus_count': 1,
        'expected_delivery_date': '2026-09-11',
        'notes': 'Single fetus confirmed in the left horn.',
        'insemination': {
          'id': 101,
          'dam_id': 1,
          'dam': {'id': 1, 'tag_number': '101', 'name': 'Cow'},
        },
        'vet': {'id': 5, 'name': 'Dr. Mfumo'},
      });
    }
    // Mock response for a Negative check
    return DetailedPregnancyCheck.fromJson({
      'id': 2,
      'insemination_id': 102,
      'check_date': '2025-11-20',
      'method': 'Palpation',
      'result': 'Not Pregnant',
      'fetus_count': null,
      'expected_delivery_date': null,
      'notes': 'No signs of pregnancy. Advised next insemination.',
      'insemination': {
        'id': 102,
        'dam_id': 2,
        'dam': {'id': 2, 'tag_number': '115', 'name': 'Cow'},
      },
      'vet': null,
    });
  }

  // Helper method updated to map check results to colors
  Color _getResultColor(String result) {
    switch (result) {
      case 'Pregnant':
        return AppColors.success;
      case 'Not Pregnant':
      case 'Reabsorbed':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }
  
  // Action to navigate to the Edit Page
  void _handleEdit(BuildContext context, int id) {
    // Navigation to the edit route (e.g., /pregnancy-checks/1/edit)
    context.push('/farmer/breeding/pregnancy-checks/$id/edit');
  }

  // Action to show Delete Confirmation Dialog
  void _handleDelete(BuildContext context, AppLocalizations l10n, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCheck), // Assuming you define this key
        content: Text(l10n.deleteCheckConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement API call to your backend 'destroy' endpoint
              print('Deleting Pregnancy Check ID: $id');
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
    final primaryColor = BreedingColors.pregnancy;

    // Fetch mock data based on ID
    final data = _fetchMockData(checkId);
    final resultColor = _getResultColor(data.result);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.pregnancyCheck} #${data.id}'), // Assuming singular key
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Result and Dam Info ---
            _buildHeaderCard(l10n, theme, data, resultColor),

            const SizedBox(height: 20),

            // --- Check Details Section ---
            _buildSectionHeader(l10n.checkDetails, Icons.checklist),
            _buildDetailCard(
              l10n,
              {
                l10n.checkDate: data.checkDate,
                l10n.method: data.method,
                l10n.technician: data.vetName ?? l10n.unknown,
                
                // Only show fetus count and due date if pregnant
                if (data.result == 'Pregnant') ...{
                  l10n.fetusCount: data.fetusCount.toString(),
                  l10n.dueDate: data.expectedDeliveryDate ?? l10n.unknown,
                },
              },
            ),

            const SizedBox(height: 20),

            // --- Notes ---
            _buildSectionHeader(l10n.notes, Icons.description),
            Text(
              data.notes.isNotEmpty ? data.notes : l10n.noNotes,
              style: theme.textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 20),

            // --- Insemination Link ---
            _buildSectionHeader(l10n.relatedInsemination, Icons.vaccines),
            _buildInseminationLinkCard(context, l10n, data.inseminationId, primaryColor),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildDeleteButton(context, l10n, AppColors.error, data.id),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeaderCard(AppLocalizations l10n, ThemeData theme,
      DetailedPregnancyCheck data, Color resultColor) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(data.result),
              backgroundColor: resultColor.withOpacity(0.2),
              side: BorderSide(color: resultColor, width: 1),
              labelStyle: theme.textTheme.titleSmall
                  ?.copyWith(color: resultColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${data.damName} #${data.damTagNumber}',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${data.damSpecies} - ${l10n.dam}',
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
          Icon(icon, color: BreedingColors.pregnancy, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BreedingColors.pregnancy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(AppLocalizations l10n, Map<String, String?> details) {
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
                        child: Text(entry.value ?? l10n.unknown,
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

  Widget _buildInseminationLinkCard(BuildContext context, AppLocalizations l10n, int inseminationId, Color primaryColor) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.link, color: primaryColor),
        title: Text('${l10n.inseminations}'),
        subtitle: Text(l10n.viewInseminationDetails), 
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to the Insemination Detail Page
          context.push('/farmer/breeding/inseminations/$inseminationId');
        },
      ),
    );
  }

  Widget _buildDeleteButton(
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
