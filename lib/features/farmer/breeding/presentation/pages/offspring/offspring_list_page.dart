import 'package:farm_manager_app/core/config/app_theme.dart'; // Assumed correct theme path
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/empty_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OffspringPage extends StatelessWidget {
  static const String routeName = '/farmer/breeding/offspring';

  const OffspringPage({super.key});

  // --- Mock Data Definition (Matching OffspringController@index output) ---
  List<Map<String, dynamic>> get _mockOffspring => [
    // 1. Ready to Register (livestock_id is null)
    _mockOffspringItem(1, "CALF-001", "Female", 32.5, '2025-09-10', null, "COW-101"),
    
    // 2. Registered (livestock_id is set)
    _mockOffspringItem(2, "LAMB-005", "Male", 4.1, '2025-12-05', 55, "EWE-203"),
    
    // 3. Registered (livestock_id is set)
    _mockOffspringItem(3, "KID-012", "Male", 3.8, '2025-12-01', 56, "DOE-312"),
    
    // 4. Ready to Register (livestock_id is null)
    _mockOffspringItem(4, "CALF-002", "Female", 35.0, '2025-09-15', null, "COW-115"),
    
    // 5. Stillborn/Critical Condition (may need review)
    _mockOffspringItem(5, "STILLBORN", "Male", 3.0, '2025-09-16', null, "COW-116", condition: "Stillborn"),
  ];

  // Helper to format the date from YYYY-MM-DD
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  // Helper to determine the status text and color
  (String status, Color statusColor) _getStatus(AppLocalizations l10n, Map<String, dynamic> item) {
    final bool isRegistered = item['livestock_id'] != null;
    final String condition = item['birth_condition'] ?? 'Vigorous';

    if (isRegistered) {
      return (l10n.registered, Colors.green[700]!);
    }
    
    if (condition == 'Stillborn' || condition == 'Weak') {
      return (l10n.condition, AppColors.warning);
    }
    
    return (l10n.readyToRegister, AppColors.secondary);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final offspring = _mockOffspring;
    final primaryColor = BreedingColors.offspring;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.offspring),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: offspring.isEmpty
          ? EmptyState(
              icon: Icons.child_friendly,
              message: "${l10n.noOffspringYet}\n${l10n.recordFirstOffspring}",
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: offspring.length,
              itemBuilder: (context, i) {
                final item = offspring[i];
                final bool isRegistered = item['livestock_id'] != null;
                final (statusText, statusColor) = _getStatus(l10n, item);
                final String damTag = item['delivery']['insemination']['dam']['tag_number'] ?? l10n.unknown;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(Icons.child_care, color: primaryColor),
                    ),
                    title: Text(
                      item['temporary_tag'] ?? l10n.noTemporaryTag,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "${item['gender']} • ${item['birth_weight_kg'].toStringAsFixed(1)} kg • Dam: $damTag",
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text("${l10n.born}: ${_formatDate(item['delivery']['actual_delivery_date'])}", style: theme.textTheme.bodySmall),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusText,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: !isRegistered
                        ? SizedBox(
                            width: 100, // Fixed width for consistent alignment
                            child: ElevatedButton(
                              onPressed: () => context.push('$routeName/${item['id']}/register'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                textStyle: theme.textTheme.labelLarge,
                                elevation: 0,
                              ),
                              child: Text(l10n.register),
                            ),
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                    onTap: () => context.push('$routeName/${item['id']}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.recordOffspring),
        // Navigate to a generic "Add Offspring" page, or you might link to the 
        // "Add Delivery" page if you only want to add offspring via a delivery.
        // Assuming this means "Add Offspring to an existing Delivery":
        onPressed: () => context.push('$routeName/store'), 
      ),
    );
  }

  // Mock data generator function matching backend model keys
  Map<String, dynamic> _mockOffspringItem(
    int id, 
    String temporaryTag, 
    String gender, 
    double birthWeightKg, 
    String deliveryDate, 
    int? livestockId,
    String damTagNumber,
    {String condition = 'Vigorous'}
  ) {
    return {
      'id': id,
      'temporary_tag': temporaryTag,
      'gender': gender,
      'birth_weight_kg': birthWeightKg,
      'birth_condition': condition,
      'livestock_id': livestockId,
      'delivery': {
        'actual_delivery_date': deliveryDate,
        'insemination': {
          'dam': {'tag_number': damTagNumber}
        }
      }
    };
  }
}

