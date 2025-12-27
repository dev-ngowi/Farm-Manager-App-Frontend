import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/entities/heat_cycle_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HeatCycleDetailsPage extends StatefulWidget {
  final String heatCycleId;
  static const String routeName = 'heat-cycle-details';

  const HeatCycleDetailsPage({super.key, required this.heatCycleId});

  @override
  State<HeatCycleDetailsPage> createState() => _HeatCycleDetailsPageState();
}

class _HeatCycleDetailsPageState extends State<HeatCycleDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  String _getAuthToken() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return authState.user.token ?? '';
    }
    return '';
  }

  void _loadDetails() {
    final token = _getAuthToken();
    if (token.isNotEmpty) {
      context.read<HeatCycleBloc>().add(
            LoadHeatCycleDetails(id: widget.heatCycleId, token: token),
          );
    }
  }

  void _showDeleteDialog(HeatCycleEntity cycle) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Heat Cycle',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this heat cycle record for ${cycle.dam.name}?',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final token = _getAuthToken();
              // FIXED: Use positional parameters based on your event definition
              context.read<HeatCycleBloc>().add(
                    DeleteHeatCycleEvent(widget.heatCycleId, token),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
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
    final DateFormat formatter = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
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
          l10n.heatCycleDetails,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          BlocBuilder<HeatCycleBloc, HeatCycleState>(
            builder: (context, state) {
              if (state is HeatCycleDetailsLoaded) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.primary),
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push(
                        '/farmer/breeding/heat-cycles/${widget.heatCycleId}/edit',
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog(state.cycle);
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
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<HeatCycleBloc, HeatCycleState>(
        listener: (context, state) {
          if (state is HeatCycleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/farmer/breeding/heat-cycles');
          } else if (state is HeatCycleError) {
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
          }
        },
        builder: (context, state) {
          if (state is HeatCycleLoading || state is HeatCycleInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HeatCycleError) {
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
                        backgroundColor: BreedingColors.heat,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is HeatCycleDetailsLoaded) {
            final details = state.cycle;
            final isActive = _calculateIsActive(
              details.nextExpectedDate,
              details.inseminated,
            );

            return _buildDetailsContent(
              context,
              l10n,
              theme,
              formatter,
              details,
              isActive,
            );
          }

          return Center(child: Text(l10n.selectAHeatCycle));
        },
      ),
    );
  }

  Widget _buildDetailsContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    DateFormat formatter,
    HeatCycleEntity details,
    bool isActive,
  ) {
    final Color statusColor = isActive
        ? BreedingColors.heat
        : (details.inseminated ? AppColors.success : Colors.grey);

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
                      isActive
                          ? Icons.whatshot
                          : (details.inseminated ? Icons.check_circle : Icons.block),
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      details.dam.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${l10n.tagNumber}: ${details.dam.tagNumber}",
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
                        _calculateStatus(details.inseminated, details.nextExpectedDate, l10n),
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

          // Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Heat Cycle Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: l10n.observedDate,
                  value: formatter.format(details.observedDate),
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  icon: Icons.bolt,
                  title: l10n.intensity,
                  value: details.intensity,
                  color: BreedingColors.heat,
                ),
                if (details.nextExpectedDate != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    icon: Icons.event_available,
                    title: l10n.nextExpected,
                    value: formatter.format(details.nextExpectedDate!),
                    color: AppColors.secondary,
                  ),
                ],
                if (details.inseminated) ...[
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    icon: Icons.check_circle,
                    title: l10n.inseminationRecorded,
                    value: l10n.yes,
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notes Section
          if (details.notes != null && details.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(
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
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        details.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // // Action Buttons
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Column(
          //     children: [
          //       if (isActive)
          //         SizedBox(
          //           width: double.infinity,
          //           height: 50,
          //           child: ElevatedButton.icon(
          //             onPressed: () {
          //               context.push(
          //                 '/farmer/breeding/heat-cycles/${details.id}/inseminate',
          //               );
          //             },
          //             icon: const Icon(Icons.opacity),
          //             label: Text(l10n.recordInsemination),
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: BreedingColors.heat,
          //               foregroundColor: Colors.white,
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //               elevation: 2,
          //             ),
          //           ),
          //         ),
          //       if (isActive) const SizedBox(height: 12),
          //       Row(
          //         children: [
          //           Expanded(
          //             child: SizedBox(
          //               height: 50,
          //               child: OutlinedButton.icon(
          //                 onPressed: () {
          //                   context.push(
          //                     '/farmer/breeding/heat-cycles/${details.id}/edit',
          //                   );
          //                 },
          //                 icon: const Icon(Icons.edit),
          //                 label: const Text('Edit'),
          //                 style: OutlinedButton.styleFrom(
          //                   foregroundColor: AppColors.primary,
          //                   side: const BorderSide(color: AppColors.primary),
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(12),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //           const SizedBox(width: 12),
          //           Expanded(
          //             child: SizedBox(
          //               height: 50,
          //               child: OutlinedButton.icon(
          //                 onPressed: () => _showDeleteDialog(details),
          //                 icon: const Icon(Icons.delete),
          //                 label: const Text('Delete'),
          //                 style: OutlinedButton.styleFrom(
          //                   foregroundColor: AppColors.error,
          //                   side: const BorderSide(color: AppColors.error),
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(12),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(height: 24),
        ],
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

  bool _calculateIsActive(DateTime? nextExpectedDate, bool inseminated) {
    if (inseminated) return false;
    return nextExpectedDate != null && nextExpectedDate.isAfter(DateTime.now());
  }

  String _calculateStatus(
    bool inseminated,
    DateTime? nextExpectedDate,
    AppLocalizations l10n,
  ) {
    if (inseminated) return l10n.inseminatedStatus;
    if (_calculateIsActive(nextExpectedDate, inseminated)) {
      return l10n.activeStatus;
    }
    return l10n.completedStatus;
  }
}