import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Corrected Placeholder/Mock Data Definitions ---
class SemenDetail {
  final int id;
  final String strawCode;
  final String bullName;
  final String bullTag;
  final String breedName;
  final DateTime collectionDate;
  final double? doseMl;
  final int? motilityPercentage;
  final double costPerStraw;
  final String? sourceSupplier;
  final bool used;
  final Bull? bull; // Nested bull details from Livestock
  final List<InseminationRecord> inseminations; // Usage history

  // FIX: Explicitly define the constructor
  const SemenDetail({
    required this.id,
    required this.strawCode,
    required this.bullName,
    required this.bullTag,
    required this.breedName,
    required this.collectionDate,
    this.doseMl,
    this.motilityPercentage,
    required this.costPerStraw,
    this.sourceSupplier,
    required this.used,
    this.bull,
    required this.inseminations,
  });
}

class Bull {
  final int id;
  final String tagNumber;
  final String name;

  // FIX: Explicitly define the constructor
  const Bull({
    required this.id,
    required this.tagNumber,
    required this.name,
  });
}

class InseminationRecord {
  final int id;
  final String damTag;
  final DateTime date;
  final String status; // e.g., 'Confirmed Pregnant', 'Failed'

  // FIX: Explicitly define the constructor
  const InseminationRecord({
    required this.id,
    required this.damTag,
    required this.date,
    required this.status,
  });
}

// --- Detailed View Page ---
class SemenDetailPage extends StatelessWidget {
  final String semenId;

  const SemenDetailPage({super.key, required this.semenId});

  // Mock function to load data based on ID
  SemenDetail _getMockData(String id) {
    // FIX: Class instantiation is now correct with the defined constructors
    return SemenDetail(
      id: int.parse(id),
      strawCode: 'HOL-007',
      bullName: 'James Bond Bull',
      bullTag: '9005',
      breedName: 'Holstein',
      collectionDate: DateTime(2024, 5, 15),
      doseMl: 0.5,
      motilityPercentage: 85,
      costPerStraw: 1500.00,
      sourceSupplier: 'KenGenetics Ltd',
      used: false,
      bull: const Bull(id: 101, tagNumber: 'BULL-001', name: 'King'), // Added const
      inseminations: [ // Added const
        InseminationRecord(id: 1, damTag: 'DAM-045', date: DateTime(2025, 1, 1), status: 'Confirmed Pregnant'),
        InseminationRecord(id: 2, damTag: 'DAM-062', date: DateTime(2025, 3, 10), status: 'Failed'),
        InseminationRecord(id: 3, damTag: 'DAM-080', date: DateTime(2025, 4, 20), status: 'Pending Check'),
      ],
    );
  }

  // ... (Rest of the SemenDetailPage code remains unchanged)
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final semen = _getMockData(semenId); // Replace with BlocBuilder later
    final primaryColor = BreedingColors.semen;
    final formatter = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final currencyFormatter = NumberFormat.currency(locale: Localizations.localeOf(context).toString(), symbol: 'Ksh ');

    // --- Stats calculated from mock data (matches backend 'stats' key) ---
    final int timesUsed = semen.inseminations.length;
    final int conceptions = semen.inseminations.where((i) => i.status == 'Confirmed Pregnant').length;
    final String successRate = timesUsed > 0 ? ((conceptions / timesUsed) * 100).toStringAsFixed(0) : '0';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('${l10n.strawCode}: ${semen.strawCode}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 🎯 UPDATED: Navigate to the nested edit page using GoRouter's name
              // Path: /farmer/breeding/semen/:semenId/edit
              context.goNamed(
                'edit-semen',
                pathParameters: {'semenId': semen.id.toString()},
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 2. Statistics Card (Matches backend 'stats' key)
          _buildStatsCard(l10n, theme, primaryColor, timesUsed, conceptions, successRate),
          const SizedBox(height: 24),

          // 3. Technical Details Section
          _buildSectionHeader(l10n.generalDetails, Icons.science, primaryColor),
          const SizedBox(height: 8),
          _buildDetailCard(
            children: [
              _buildDetailRow(l10n.bullName, semen.bullName),
              _buildDetailRow(l10n.breed, semen.breedName),
              _buildDetailRow(l10n.collectionDate, formatter.format(semen.collectionDate)),
              _buildDetailRow(l10n.sourceSupplier, semen.sourceSupplier ?? l10n.notRecorded),
              _buildDetailRow(l10n.costPerStraw, currencyFormatter.format(semen.costPerStraw)),
              _buildDetailRow(l10n.dose, '${semen.doseMl ?? 'N/A'} ml'),
              _buildDetailRow(l10n.motility, '${semen.motilityPercentage ?? 'N/A'}%'),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Bull Source Details (Only if bull is internal)
          if (semen.bull != null) ...[
            _buildSectionHeader(l10n.internalBullSource, Icons.vpn_key, primaryColor),
            const SizedBox(height: 8),
            _buildDetailCard(
              children: [
                _buildDetailRow(l10n.internalBullId, semen.bull!.tagNumber),
                _buildDetailRow(l10n.bullName, semen.bull!.name),
                _buildDetailRow(l10n.bullTag, semen.bullTag),
              ],
            ),
            const SizedBox(height: 24),
          ],
          
          // 5. Usage History (Matches backend 'inseminations' key)
          _buildSectionHeader(l10n.usageHistory, Icons.history, primaryColor),
          const SizedBox(height: 8),
          _buildUsageHistoryList(semen.inseminations, l10n, theme, primaryColor, formatter),

          const SizedBox(height: 20),
          // Delete button (with confirmation)
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, l10n, primaryColor),
            icon: const Icon(Icons.delete_forever),
            label: Text(l10n.deleteRecord),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Methods ---

  Widget _buildStatsCard(
    AppLocalizations l10n,
    ThemeData theme,
    Color primaryColor,
    int timesUsed,
    int conceptions,
    String successRate,
  ) {
    return Card(
      color: primaryColor.withOpacity(0.05),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(l10n.timesUsed, timesUsed.toString(), Icons.science, primaryColor),
            _buildStatItem(l10n.conceptions, conceptions.toString(), Icons.favorite, AppColors.success),
            _buildStatItem(l10n.successRate, '$successRate%', Icons.trending_up, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          Flexible(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageHistoryList(
    List<InseminationRecord> records,
    AppLocalizations l10n,
    ThemeData theme,
    Color primaryColor,
    DateFormat formatter,
  ) {
    if (records.isEmpty) {
      return Text(l10n.noUsageRecords, style: theme.textTheme.bodyMedium);
    }
    
    return Column(
      children: records.map((record) => ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Icon(Icons.date_range, color: primaryColor),
        ),
        title: Text('${l10n.dam}: ${record.damTag}'),
        subtitle: Text('${l10n.date}: ${formatter.format(record.date)}'),
        trailing: Chip(
          label: Text(record.status),
          backgroundColor: _getStatusColor(record.status).withOpacity(0.1),
          side: BorderSide(color: _getStatusColor(record.status)),
        ),
        onTap: () {
          // Navigate to individual insemination record detail
          // context.push('/farmer/breeding/inseminations/${record.id}');
        },
      )).toList(),
    );
  }
  
  Color _getStatusColor(String status) {
    if (status.contains('Pregnant')) return AppColors.success;
    if (status.contains('Failed')) return AppColors.error;
    return AppColors.secondary;
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n, Color primaryColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteSemenWarning), // Localize: "Are you sure you want to delete this semen straw? This action cannot be undone."
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.cancel, style: TextStyle(color: primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              // Actual deletion logic (Bloc call) goes here
              context.pop(); 
              // Example: context.read<SemenBloc>().add(DeleteSemenEvent(semenId: semenId, token: _getToken()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}