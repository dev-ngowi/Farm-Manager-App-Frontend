import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Data Models reflecting Backend JSON (DeliveryController::show) ---

class OffspringData {
  final int id;
  final String temporaryTag;
  final String gender;
  final double birthWeightKg;
  final String birthCondition;
  final String colostrumIntake;
  final bool navelTreated;
  final String? notes;

  OffspringData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        temporaryTag = json['temporary_tag'] as String? ?? 'N/A',
        gender = json['gender'] as String,
        birthWeightKg = (json['birth_weight_kg'] as num?)?.toDouble() ?? 0.0,
        birthCondition = json['birth_condition'] as String,
        colostrumIntake = json['colostrum_intake'] as String,
        navelTreated = json['navel_treated'] as bool? ?? false,
        notes = json['notes'] as String?;
}

class DetailedDelivery {
  final int id;
  final String actualDeliveryDate;
  final String deliveryType;
  final int calvingEaseScore;
  final int totalBorn;
  final int liveBorn;
  final int stillborn;
  final String damConditionAfter;
  final String notes;

  // Nested Dam/Insemination details
  final int inseminationId;
  final String damTagNumber;
  final String damName;
  final String damSpecies; // Assuming Species is available via dam model
  
  final List<OffspringData> offspring;

  DetailedDelivery({
    required this.id,
    required this.actualDeliveryDate,
    required this.deliveryType,
    required this.calvingEaseScore,
    required this.totalBorn,
    required this.liveBorn,
    required this.stillborn,
    required this.damConditionAfter,
    this.notes = '',
    required this.inseminationId,
    required this.damTagNumber,
    required this.damName,
    this.damSpecies = 'Cattle', // Mocked species
    required this.offspring,
  });

  factory DetailedDelivery.fromJson(Map<String, dynamic> json) {
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
    final offspringList = (json['offspring'] as List<dynamic>?)
        ?.map((o) => OffspringData.fromJson(o as Map<String, dynamic>))
        .toList() ?? [];

    return DetailedDelivery(
      id: json['id'] as int,
      actualDeliveryDate: formatDate(json['actual_delivery_date'] as String?),
      deliveryType: json['delivery_type'] as String,
      calvingEaseScore: json['calving_ease_score'] as int,
      totalBorn: json['total_born'] as int,
      liveBorn: json['live_born'] as int,
      stillborn: json['stillborn'] as int,
      damConditionAfter: json['dam_condition_after'] as String,
      notes: json['notes'] as String? ?? '',
      
      inseminationId: insemination?['id'] as int? ?? 0,
      damTagNumber: dam?['tag_number'] ?? 'N/A',
      damName: dam?['name'] ?? 'N/A',
      
      offspring: offspringList,
    );
  }
}

class DeliveryDetailPage extends StatelessWidget {
  static const String routeName = '/farmer/breeding/deliveries/:id';
  final int deliveryId;

  const DeliveryDetailPage({super.key, required this.deliveryId});

  // Mock data function to simulate fetching a single item
  DetailedDelivery _fetchMockData(int id) {
    // Mock response for a twin delivery (ID=2)
    if (id == 2) {
      return DetailedDelivery.fromJson({
        'id': 2,
        'insemination_id': 102,
        'actual_delivery_date': '2025-09-08',
        'delivery_type': 'Assisted',
        'calving_ease_score': 3,
        'total_born': 2,
        'live_born': 2,
        'stillborn': 0,
        'dam_condition_after': 'Weak',
        'notes': 'Twins required some pulling, but both are healthy.',
        'insemination': {
          'id': 102,
          'dam_id': 2,
          'dam': {'id': 2, 'tag_number': '108', 'name': 'Cow'},
        },
        'offspring': [
          {
            'id': 3, 'temporary_tag': 'T-001A', 'gender': 'Male', 
            'birth_weight_kg': 35.0, 'birth_condition': 'Weak', 
            'colostrum_intake': 'Partial', 'navel_treated': true,
          },
          {
            'id': 4, 'temporary_tag': 'T-001B', 'gender': 'Female', 
            'birth_weight_kg': 33.0, 'birth_condition': 'Vigorous', 
            'colostrum_intake': 'Adequate', 'navel_treated': true,
          },
        ],
      });
    }
    // Mock response for a normal single calf delivery (ID=1)
    return DetailedDelivery.fromJson({
      'id': 1,
      'insemination_id': 101,
      'actual_delivery_date': '2025-09-10',
      'delivery_type': 'Normal',
      'calving_ease_score': 1,
      'total_born': 1,
      'live_born': 1,
      'stillborn': 0,
      'dam_condition_after': 'Good',
      'notes': 'Easy birth, calf stood quickly.',
      'insemination': {
        'id': 101,
        'dam_id': 1,
        'dam': {'id': 1, 'tag_number': '105', 'name': 'Cow'},
      },
      'offspring': [
        {
          'id': 1, 'temporary_tag': 'T-001', 'gender': 'Female', 
          'birth_weight_kg': 38.5, 'birth_condition': 'Vigorous', 
          'colostrum_intake': 'Adequate', 'navel_treated': true,
        },
      ],
    });
  }

  // --- Actions ---

  void _handleEdit(BuildContext context, int id) {
    context.push('/farmer/breeding/deliveries/$id/edit');
  }

  void _handleDelete(BuildContext context, AppLocalizations l10n, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDelivery), // Assuming you define this key
        // Assuming you define a key like deleteDeliveryConfirmation
        content: Text(l10n.deleteDeliveryConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement API call to your backend 'destroy' endpoint
              print('Deleting Delivery ID: $id');
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
    final primaryColor = BreedingColors.delivery;

    // Fetch mock data based on ID
    final data = _fetchMockData(deliveryId);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.delivery} #${data.id}'), // Assuming singular key
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            onPressed: () => _handleEdit(context, data.id),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: l10n.downloadPdf, // Assuming this key exists
            onPressed: () {
              // TODO: Implement PDF download logic (GET /api/farmer/deliveries/{id}/pdf)
              print('Downloading PDF for Delivery ID: ${data.id}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Dam Info ---
            _buildHeaderCard(l10n, theme, data),

            const SizedBox(height: 20),

            // --- Delivery Summary Section ---
            _buildSectionHeader(l10n.deliverySummary, Icons.event, primaryColor),
            _buildDetailCard(
              l10n,
              {
                l10n.deliveryDate: data.actualDeliveryDate,
                l10n.deliveryType: data.deliveryType,
                l10n.calvingEaseScore: data.calvingEaseScore.toString(),
                l10n.damConditionAfter: data.damConditionAfter,
              },
            ),
            
            const SizedBox(height: 20),
            
            // --- Offspring Section ---
            _buildSectionHeader(l10n.offspringRecords, Icons.child_care, primaryColor),
            _buildOffspringSummaryCard(l10n, data),
            
            const SizedBox(height: 12),
            ...data.offspring.map((offspring) => 
              _buildOffspringDetailCard(l10n, theme, offspring, primaryColor)
            ).toList(),

            const SizedBox(height: 20),

            // --- Notes ---
            _buildSectionHeader(l10n.notes, Icons.description, primaryColor),
            Text(
              data.notes.isNotEmpty ? data.notes : l10n.noNotes,
              style: theme.textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 20),

            // --- Insemination Link ---
            _buildSectionHeader(l10n.relatedInsemination, Icons.vaccines, primaryColor),
            _buildInseminationLinkCard(context, l10n, data.inseminationId, primaryColor),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildDeleteButton(context, l10n, AppColors.error, data.id),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeaderCard(AppLocalizations l10n, ThemeData theme, DetailedDelivery data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(data.deliveryType),
              backgroundColor: BreedingColors.delivery.withOpacity(0.2),
              side: BorderSide(color: BreedingColors.delivery, width: 1),
              labelStyle: theme.textTheme.titleSmall
                  ?.copyWith(color: BreedingColors.delivery, fontWeight: FontWeight.bold),
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

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
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

  Widget _buildOffspringSummaryCard(AppLocalizations l10n, DetailedDelivery data) {
    return Card(
      color: BreedingColors.delivery.withOpacity(0.05),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(data.totalBorn.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: BreedingColors.delivery)),
                Text(l10n.totalBorn, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Column(
              children: [
                Text(data.liveBorn.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
                Text(l10n.liveBorn, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Column(
              children: [
                Text(data.stillborn.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.error)),
                Text(l10n.stillborn, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffspringDetailCard(AppLocalizations l10n, ThemeData theme, OffspringData offspring, Color color) {
    final isStillborn = offspring.birthCondition == 'Stillborn';
    final chipColor = isStillborn ? AppColors.error : AppColors.success;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isStillborn 
                      ? l10n.stillbornCalf // Specific title for stillborn
                      : '${offspring.gender} Calf #${offspring.temporaryTag}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isStillborn ? AppColors.error : color,
                  ),
                ),
                Chip(
                  label: Text(offspring.birthCondition),
                  backgroundColor: chipColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildOffspringRow(l10n.birthWeight, '${offspring.birthWeightKg.toStringAsFixed(1)} kg'),
            _buildOffspringRow(l10n.colostrumIntake, offspring.colostrumIntake),
            _buildOffspringRow(l10n.navelTreated, offspring.navelTreated ? l10n.yes : l10n.no),
            
            if (offspring.notes != null && offspring.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('${l10n.notes}:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(offspring.notes!, style: theme.textTheme.bodyMedium),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOffspringRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInseminationLinkCard(BuildContext context, AppLocalizations l10n, int inseminationId, Color primaryColor) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.link, color: primaryColor),
        title: Text('${l10n.insemination} #${inseminationId}'),
        subtitle: Text(l10n.viewInseminationDetails), // Assuming you define this key
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

