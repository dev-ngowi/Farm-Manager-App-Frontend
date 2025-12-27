import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/entities/semen_entity.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SemenDetailPage extends StatefulWidget {
  final String semenId;
  static const String routeName = 'semen-details';

  const SemenDetailPage({super.key, required this.semenId});

  @override
  State<SemenDetailPage> createState() => _SemenDetailPageState();
}

class _SemenDetailPageState extends State<SemenDetailPage> {
  // Cache the loaded semen details to prevent them from disappearing
  SemenEntity? _cachedSemen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  void _loadDetails() {
    context.read<SemenInventoryBloc>().add(SemenLoadDetails(widget.semenId));
  }

  void _showDeleteDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.confirmDelete,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          l10n.deleteSemenWarning ?? 'Are you sure you want to delete this semen straw? This action cannot be undone.',
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
              context.read<SemenInventoryBloc>().add(
                    SemenDelete(widget.semenId),
                  );
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
    final currencyFormatter = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: 'TZS ',
    );

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
          l10n.semenDetails ?? 'Semen Details',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_cachedSemen != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.primary),
              onSelected: (value) {
                if (value == 'edit') {
                  context.push(
                    '/farmer/breeding/semen/${widget.semenId}/edit',
                  );
                } else if (value == 'delete') {
                  _showDeleteDialog();
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
      body: BlocConsumer<SemenInventoryBloc, SemenState>(
        listener: (context, state) {
          if (state is SemenActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/farmer/breeding/semen');
          } else if (state is SemenError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: l10n.retry ?? 'Retry',
                  textColor: Colors.white,
                  onPressed: _loadDetails,
                ),
              ),
            );
          } else if (state is SemenLoadedDetails) {
            // Cache the loaded details so they don't disappear
            setState(() {
              _cachedSemen = state.semen;
            });
          }
        },
        builder: (context, state) {
          // Show loading only if we don't have cached data
          if ((state is SemenLoading || state is SemenInitial) && _cachedSemen == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading details...'),
                ],
              ),
            );
          }

          // Show error only if we don't have cached data
          if (state is SemenError && _cachedSemen == null) {
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
                      onPressed: _loadDetails,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry ?? 'Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BreedingColors.semen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Use cached semen data if available
          if (_cachedSemen != null) {
            final semen = _cachedSemen!;
            final timesUsed = semen.timesUsed;
            final successRate = semen.successRate;

            return _buildDetailsContent(
              context,
              l10n,
              theme,
              formatter,
              currencyFormatter,
              semen,
              timesUsed,
              successRate,
            );
          }

          return Center(child: Text(l10n.selectASemen ?? 'Select a semen straw'));
        },
      ),
    );
  }

  Widget _buildDetailsContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    DateFormat formatter,
    NumberFormat currencyFormatter,
    SemenEntity semen,
    int timesUsed,
    String successRate,
  ) {
    final statusColor = semen.used ? Colors.grey : BreedingColors.semen;
    final statusText = semen.used ? l10n.used : l10n.available;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Header Card
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
                      statusColor,
                      statusColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      semen.used ? Icons.block : Icons.storage,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      semen.strawCode,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      semen.bullName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
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
                        statusText,
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

          // Statistics Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    l10n.timesUsed,
                    timesUsed.toString(),
                    Icons.science,
                    BreedingColors.semen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    l10n.successRate,
                    successRate,
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // General Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'General Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.pets,
                  title: l10n.bullName,
                  value: semen.bullName,
                  color: BreedingColors.semen,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.catching_pokemon,
                  title: l10n.breed,
                  value: semen.breed?.breedName ?? l10n.unknown,
                  color: BreedingColors.semen,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: l10n.collectionDate,
                  value: formatter.format(semen.collectionDate),
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.attach_money,
                  title: l10n.costPerStraw,
                  value: currencyFormatter.format(semen.costPerStraw),
                  color: AppColors.success,
                ),
                if (semen.doseMl > 0) ...[
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    icon: Icons.water_drop,
                    title: l10n.dose,
                    value: '${semen.doseMl} ml',
                    color: Colors.blue,
                  ),
                ],
                if (semen.motilityPercentage != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    icon: Icons.insights,
                    title: l10n.motility,
                    value: '${semen.motilityPercentage}%',
                    color: Colors.orange,
                  ),
                ],
                if (semen.sourceSupplier != null && semen.sourceSupplier!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    icon: Icons.business,
                    title: l10n.sourceSupplier,
                    value: semen.sourceSupplier!,
                    color: AppColors.secondary,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bull Source Details (if internal bull)
          if (semen.bull != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Internal Bull Source',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.vpn_key,
                    title: l10n.internalBullId,
                    value: semen.bull!.tagNumber,
                    color: BreedingColors.semen,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    icon: Icons.pets,
                    title: l10n.bullName,
                    value: semen.bull!.name,
                    color: BreedingColors.semen,
                  ),
                  if (semen.bullTag != null && semen.bullTag!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      icon: Icons.tag,
                      title: l10n.bullTag,
                      value: semen.bullTag!,
                      color: BreedingColors.semen,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Usage History (if available)
          if (semen.inseminations != null && semen.inseminations!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usage History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...semen.inseminations!.map((record) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: BreedingColors.semen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.date_range,
                                color: BreedingColors.semen,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              '${l10n.dam}: ${record.dam.tagNumber} (${record.dam.name})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${l10n.date}: ${formatter.format(record.inseminationDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(record.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(record.status),
                                ),
                              ),
                              child: Text(
                                record.status ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(record.status),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                        context.push(
                          '/farmer/breeding/semen/${widget.semenId}/edit',
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
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
                      onPressed: _showDeleteDialog,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.contains('Pregnant')) return AppColors.success;
    if (status.contains('Failed')) return AppColors.error;
    return AppColors.secondary;
  }
}