// lib/features/farmer/breeding/presentation/pages/delivery/delivery_detail_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DeliveryDetailPage extends StatefulWidget {
  static const String routeName = 'delivery-detail';
  final dynamic deliveryId;

  const DeliveryDetailPage({super.key, required this.deliveryId});

  @override
  State<DeliveryDetailPage> createState() => _DeliveryDetailPageState();
}

class _DeliveryDetailPageState extends State<DeliveryDetailPage> {
  // Cache the loaded delivery details to prevent them from disappearing
  DeliveryEntity? _cachedDelivery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DeliveryBloc>()..add(LoadDeliveryDetail(widget.deliveryId)),
      child: DeliveryDetailView(
        deliveryId: widget.deliveryId,
        cachedDelivery: _cachedDelivery,
        onDeliveryLoaded: (delivery) {
          setState(() {
            _cachedDelivery = delivery;
          });
        },
      ),
    );
  }
}

class DeliveryDetailView extends StatelessWidget {
  final dynamic deliveryId;
  final DeliveryEntity? cachedDelivery;
  final Function(DeliveryEntity) onDeliveryLoaded;

  const DeliveryDetailView({
    super.key,
    required this.deliveryId,
    required this.cachedDelivery,
    required this.onDeliveryLoaded,
  });

  void _loadDetails(BuildContext context) {
    context.read<DeliveryBloc>().add(LoadDeliveryDetail(deliveryId));
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n, dynamic id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.confirmDelete ?? 'Confirm Delete',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          l10n.deleteDeliveryConfirmation ?? 'Are you sure you want to delete this delivery record? This action cannot be undone.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DeliveryBloc>().add(DeleteDelivery(id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.delete,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final formatter = DateFormat.yMMMd(Localizations.localeOf(context).toString());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.deliveryDetails ?? 'Delivery Details',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (cachedDelivery != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.primary),
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/farmer/breeding/deliveries/${deliveryId}/edit');
                } else if (value == 'delete') {
                  _showDeleteDialog(context, l10n, deliveryId);
                } else if (value == 'pdf') {
                  // PDF generation logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF generation coming soon')),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 20),
                      SizedBox(width: 12),
                      Text('Generate PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<DeliveryBloc, DeliveryState>(
        listener: (context, state) {
          if (state is DeliveryDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.deliveryDeletedSuccess ?? 'Delivery deleted successfully'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/farmer/breeding/deliveries');
          } else if (state is DeliveryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: l10n.retry ?? 'Retry',
                  textColor: Colors.white,
                  onPressed: () => _loadDetails(context),
                ),
              ),
            );
          } else if (state is DeliveryDetailLoaded) {
            onDeliveryLoaded(state.delivery);
          }
        },
        builder: (context, state) {
          // Show loading only if we don't have cached data
          if ((state is DeliveryLoading || state is DeliveryInitial) && cachedDelivery == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading delivery details...'),
                ],
              ),
            );
          }

          // Show error only if we don't have cached data
          if (state is DeliveryError && cachedDelivery == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Details',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _loadDetails(context),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry ?? 'Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BreedingColors.delivery,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Use cached delivery data if available
          if (cachedDelivery != null) {
            return _buildDetailsContent(context, l10n, theme, formatter, cachedDelivery!);
          }

          return Center(child: Text(l10n.selectADelivery ?? 'Select a delivery'));
        },
      ),
    );
  }

  Widget _buildDetailsContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    DateFormat formatter,
    DeliveryEntity delivery,
  ) {
    final primaryColor = BreedingColors.delivery;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Header Card with Dam Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.child_care,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${delivery.damName} (${delivery.damTagNumber})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.dam ?? 'Dam',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        delivery.deliveryType,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Offspring Statistics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    l10n.totalBorn ?? 'Total Born',
                    delivery.totalBorn.toString(),
                    Icons.child_care,
                    primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    l10n.liveBorn ?? 'Live Born',
                    delivery.liveBorn.toString(),
                    Icons.favorite,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    l10n.stillborn ?? 'Stillborn',
                    delivery.stillborn.toString(),
                    Icons.heart_broken,
                    AppColors.error,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Delivery Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deliverySummary ?? 'Delivery Summary',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: l10n.deliveryDate ?? 'Delivery Date',
                  value: formatter.format(delivery.actualDeliveryDate),
                  color: primaryColor,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.local_hospital,
                  title: l10n.deliveryType ?? 'Delivery Type',
                  value: delivery.deliveryType,
                  color: primaryColor,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.star,
                  title: l10n.calvingEaseScore ?? 'Calving Ease Score',
                  value: '${delivery.calvingEaseScore}/5',
                  color: _getEaseScoreColor(delivery.calvingEaseScore),
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.health_and_safety,
                  title: l10n.damConditionAfter ?? 'Dam Condition After',
                  value: delivery.damConditionAfter,
                  color: _getConditionColor(delivery.damConditionAfter),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Offspring Records Section
          if (delivery.offspring.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.offspringRecords ?? 'Offspring Records',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...delivery.offspring.map((off) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildOffspringCard(l10n, off, primaryColor),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Notes Section
          if (delivery.notes?.isNotEmpty == true) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notes ?? 'Notes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        delivery.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Related Insemination Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.relatedInsemination ?? 'Related Insemination',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: BreedingColors.insemination.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.vaccines,
                        color: BreedingColors.insemination,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '${l10n.insemination ?? "Insemination"} #${delivery.inseminationId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      l10n.tapToView ?? 'Tap to view details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => context.push('/farmer/breeding/inseminations/${delivery.inseminationId}'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/farmer/breeding/deliveries/${delivery.id}/edit');
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(l10n.edit ?? 'Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(context, l10n, delivery.id),
                      icon: const Icon(Icons.delete),
                      label: Text(l10n.delete ?? 'Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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

  Widget _buildOffspringCard(AppLocalizations l10n, OffspringEntity off, Color color) {
    final isStillborn = off.birthCondition == 'Stillborn';
    final genderColor = off.gender == 'Male' ? Colors.blue : Colors.pink;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isStillborn ? Colors.grey : genderColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                off.gender == 'Male' ? Icons.male : Icons.female,
                color: isStillborn ? Colors.grey : genderColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${off.gender} - ${off.temporaryTag ?? l10n.noTag ?? "No Tag"}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${off.birthWeightKg.toStringAsFixed(2)}kg • ${off.birthCondition}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (off.colostrumIntake.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Colostrum: ${off.colostrumIntake}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (off.navelTreated ? AppColors.success : Colors.grey[300])?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                off.navelTreated ? Icons.check_circle : Icons.cancel,
                color: off.navelTreated ? AppColors.success : Colors.grey[400],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEaseScoreColor(int score) {
    if (score <= 2) return AppColors.success;
    if (score == 3) return Colors.orange;
    return AppColors.error;
  }

  Color _getConditionColor(String condition) {
    if (condition.toLowerCase().contains('good') || condition.toLowerCase().contains('excellent')) {
      return AppColors.success;
    }
    if (condition.toLowerCase().contains('fair')) {
      return Colors.orange;
    }
    return AppColors.error;
  }
}