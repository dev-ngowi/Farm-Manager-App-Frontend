// lib/core/widgets/add_record_bottom_sheet.dart
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddRecordBottomSheet extends StatelessWidget {
  const AddRecordBottomSheet({super.key});

  // Reusable action tile
  Widget _buildAction({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.textSecondary.withOpacity(0.5),
      ),
      onTap: () {
        Navigator.pop(context); // Close sheet first
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen height to set max height for bottom sheet
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85; // 85% of screen height

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Add New Record',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose what you want to record today',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Action List
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  _buildAction(
                    context: context,
                    icon: Icons.pets,
                    title: 'Add Livestock',
                    subtitle: 'Register new animal (cow, goat, chicken, etc.)',
                    color: AppColors.primary,
                    onTap: () => context.push('/farmer/livestock/add'),
                  ),
                  const Divider(height: 16),

                  _buildAction(
                    context: context,
                    icon: Icons.local_hospital,
                    title: 'Health Record',
                    subtitle: 'Vaccination, treatment, or health issue',
                    color: AppColors.error,
                    onTap: () => context.push('/farmer/health/report-issue'),
                  ),
                  const Divider(height: 16),

                  _buildAction(
                    context: context,
                    icon: Icons.opacity,
                    title: 'Milk Yield',
                    subtitle: 'Record daily or per-session milk production',
                    color: AppColors.success,
                    onTap: () => context.push('/farmer/production/milk-yield'),
                  ),
                  const Divider(height: 16),

                  _buildAction(
                    context: context,
                    icon: Icons.monitor_weight,
                    title: 'Weight Record',
                    subtitle: 'Track animal growth and weight gain',
                    color: AppColors.secondary,
                    onTap: () => context.push('/farmer/production/weight'),
                  ),
                  const Divider(height: 16),

                  _buildAction(
                    context: context,
                    icon: Icons.attach_money,
                    title: 'Expense / Income',
                    subtitle: 'Feed, medicine, sales, or other transactions',
                    color: const Color(0xFF9C27B0),
                    onTap: () => context.push('/farmer/finance/add-transaction'),
                  ),
                  const Divider(height: 16),

                  _buildAction(
                    context: context,
                    icon: Icons.favorite,
                    title: 'Breeding Event',
                    subtitle: 'Insemination, pregnancy check, or birth',
                    color: const Color(0xFFE91E63),
                    onTap: () => context.push('/farmer/breeding/record'),
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