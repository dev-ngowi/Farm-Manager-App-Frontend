import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Model for Lactation Details (Matches API response) ---
class LactationDetailData {
  final int id;
  final String damTag;
  final String damName;
  final String startDate;
  final String? peakDate;
  final String? dryOffDate;
  final double totalMilkKg;
  final int daysInMilk;
  final String status;

  LactationDetailData({
    required this.id,
    required this.damTag,
    required this.damName,
    required this.startDate,
    this.peakDate,
    this.dryOffDate,
    required this.totalMilkKg,
    required this.daysInMilk,
    required this.status,
  });
}

class ShowLactationPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/lactations/:id/show';
  final int lactationId;

  const ShowLactationPage({super.key, required this.lactationId});

  @override
  State<ShowLactationPage> createState() => _ShowLactationPageState();
}

class _ShowLactationPageState extends State<ShowLactationPage> {
  final Color primaryColor = BreedingColors.lactation;
  bool _isLoading = true;
  LactationDetailData? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate API fetch delay
    await Future.delayed(const Duration(milliseconds: 700));

    // Mock Data Fetching based on ID
    final data = _fetchMockData(widget.lactationId);

    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  // Mock API Response
  LactationDetailData _fetchMockData(int id) {
    // Real data retrieval would use an API client to fetch the specific ID
    switch (id) {
      case 1:
        return LactationDetailData(
          id: 1,
          damTag: 'COW-101',
          damName: 'Daisy',
          startDate: '2025-09-10',
          peakDate: '2025-10-15',
          dryOffDate: null,
          totalMilkKg: 2450.5,
          daysInMilk: 95,
          status: 'Ongoing',
        );
      case 3:
        return LactationDetailData(
          id: 3,
          damTag: 'GOAT-205',
          damName: 'Gretchen',
          startDate: '2024-10-01',
          peakDate: '2024-11-20',
          dryOffDate: '2025-04-01',
          totalMilkKg: 180.2,
          daysInMilk: 183,
          status: 'Completed',
        );
      default:
        // Default mock for other IDs
        return LactationDetailData(
          id: id,
          damTag: 'ANIMAL-999',
          damName: 'Unknown',
          startDate: '2025-01-01',
          peakDate: '2025-02-01',
          dryOffDate: null,
          totalMilkKg: 1500.0,
          daysInMilk: 300,
          status: 'Ongoing',
        );
    }
  }

  // Format date strings for display
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      // Assuming date is in 'YYYY-MM-DD' format
      final dateTime = DateTime.parse(date);
      return DateFormat.yMMMd().format(dateTime); // e.g., Sep 10, 2025
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.lactationDetails),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.error),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text(l10n.lactationNotFound)),
      );
    }

    final data = _data!;
    final totalYieldString = "${data.totalMilkKg.toStringAsFixed(1)} kg";

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.lactations} #${widget.lactationId}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.editLactation,
            onPressed: () {
              // Navigate to edit page
              context.push('/farmer/breeding/lactations/${widget.lactationId}/edit');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Card: Dam Information & Status ---
            Card(
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(Icons.pets, size: 30, color: primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.damTag,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            data.damName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusPill(context, data.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Yield Summary Section ---
            Text(
              l10n.yieldSummary,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildYieldMetricCard(
              context, 
              label: l10n.totalMilkProduced, 
              value: totalYieldString, 
              icon: Icons.ssid_chart, 
              color: primaryColor,
            ),
            
            const SizedBox(height: 16),
            _buildYieldMetricCard(
              context, 
              label: l10n.daysInMilk, 
              value: l10n.daysInMilk, 
              icon: Icons.calendar_today, 
              color: Colors.orange.shade700,
            ),
            
            const SizedBox(height: 24),

            // --- Key Dates Section ---
            Text(
              l10n.keyDates,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Card(
              elevation: 1,
              child: Column(
                children: [
                  _buildDetailTile(
                    context,
                    l10n.startDate,
                    _formatDate(data.startDate),
                    Icons.event_available,
                    primaryColor,
                  ),
                  _buildDetailTile(
                    context,
                    l10n.peakDate,
                    _formatDate(data.peakDate),
                    Icons.trending_up,
                    data.peakDate != null ? Colors.green.shade700 : AppColors.textSecondary,
                  ),
                  _buildDetailTile(
                    context,
                    l10n.dryOffDate,
                    _formatDate(data.dryOffDate),
                    Icons.event_busy,
                    data.dryOffDate != null ? Colors.red.shade700 : AppColors.textSecondary,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, String status) {
    Color color = status == 'Ongoing' ? Colors.green.shade600 : Colors.red.shade600;
    final l10n = AppLocalizations.of(context)!;
    
    return Chip(
      label: Text(
        status == 'Ongoing' ? l10n.ongoing : l10n.completed,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  Widget _buildDetailTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          trailing: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: subtitle == 'N/A' ? AppColors.textSecondary : color,
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildYieldMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}