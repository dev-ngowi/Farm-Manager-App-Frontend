import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed correct theme path
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/empty_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LactationsPage extends StatelessWidget {
  static const String routeName = '/farmer/breeding/lactations';

  const LactationsPage({super.key});

  // Helper method to create a single mock lactation record matching the API response structure
  Map<String, dynamic> _mockLactation({
    required int id,
    required String damTag,
    required String damName,
    required String startDate,
    required int daysInMilk,
    required double totalMilkKg,
    required String status,
  }) {
    return {
      'id': id,
      'start_date': startDate,
      'total_milk_kg': totalMilkKg,
      'days_in_milk': daysInMilk,
      'status': status,
      'dam': {
        'tag_number': damTag,
        'name': damName,
      }
    };
  }

  // Mock data definition matching the API's 'data' structure
  List<Map<String, dynamic>> get _mockLactations => [
    _mockLactation(
      id: 1, 
      damTag: "COW-101", 
      damName: "Daisy",
      startDate: "2025-09-10", 
      daysInMilk: 95, 
      totalMilkKg: 2450.5, 
      status: "Ongoing"
    ),
    _mockLactation(
      id: 2, 
      damTag: "COW-102", 
      damName: "Bess",
      startDate: "2025-07-25", 
      daysInMilk: 142, 
      totalMilkKg: 5100.0, 
      status: "Ongoing"
    ),
    _mockLactation(
      id: 3, 
      damTag: "GOAT-205", 
      damName: "Gretchen",
      startDate: "2024-10-01", 
      daysInMilk: 180, 
      totalMilkKg: 180.2, 
      status: "Completed"
    ),
    _mockLactation(
      id: 4, 
      damTag: "COW-105", 
      damName: "Buttercup",
      startDate: "2025-12-15", 
      daysInMilk: 0, 
      totalMilkKg: 0.0, 
      status: "Ongoing"
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lactations = _mockLactations;
    final primaryColor = BreedingColors.lactation;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.lactations),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: lactations.isEmpty
          ? EmptyState(
              icon: Icons.local_drink,
              message: "${l10n.noLactationsYet}\n${l10n.recordFirstLactation}",
              iconColor: AppColors.iconPrimary,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: lactations.length,
              itemBuilder: (context, i) {
                final item = lactations[i];
                final dam = item['dam'] as Map<String, dynamic>;
                
                final totalMilkKg = item['total_milk_kg'] as double;
                final totalYieldString = "${totalMilkKg.toStringAsFixed(1)} kg"; // Use kg as per backend
                
                final daysInMilk = item['days_in_milk'] as int;
                final animalLabel = dam['tag_number'] as String;
                final startDate = item['start_date'] as String;
                final status = item['status'] as String;
                final id = item['id'] as int;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.2),
                      child: Icon(Icons.local_drink, color: primaryColor),
                    ),
                    title: Text(
                      "$animalLabel (${dam['name']})", // Display Animal Tag and Name
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${l10n.started}: $startDate", style: theme.textTheme.bodyMedium),
                        Text(
                          status == 'Ongoing'
                            ? l10n.daysInMilk // Use l10n for parameterized "X days in milk"
                            : l10n.statusCompleted,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic, 
                            color: status == 'Ongoing' ? primaryColor : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          totalYieldString,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: primaryColor),
                        ),
                        Text(
                          l10n.totalYield,
                          style: theme.textTheme.bodySmall,
                        )
                      ],
                    ),
                    // Navigate using the actual Lactation ID
                    onTap: () => context.push('$routeName/$id/show'), 
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.recordLactation),
        onPressed: () => context.push('$routeName/add'),
      ),
    );
  }
}