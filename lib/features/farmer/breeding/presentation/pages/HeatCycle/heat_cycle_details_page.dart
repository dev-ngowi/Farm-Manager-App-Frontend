// heat_cycle_details_page.dart

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
    // Load details when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  // Get authentication token from AuthBloc
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.heatCycleDetails),
        backgroundColor: BreedingColors.heat,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: BlocConsumer<HeatCycleBloc, HeatCycleState>(
        listener: (context, state) {
          // Show snackbar on error
          if (state is HeatCycleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
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
          // Loading State
          if (state is HeatCycleLoading || state is HeatCycleInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error State
          if (state is HeatCycleError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '❌ ${l10n.errorFetchingDetails}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
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

          // Loaded State (Success)
          if (state is HeatCycleDetailsLoaded) {
            final HeatCycleEntity details = state.cycle;
            final isActive = _calculateIsActive(
              details.nextExpectedDate,
              details.inseminated,
            );

            final Color statusColor = isActive
                ? BreedingColors.heat
                : (details.inseminated
                    ? Colors.green.shade700
                    : Colors.blueGrey);

            final String primaryButtonLabel =
                isActive ? l10n.recordInsemination : l10n.edit;
            final IconData primaryButtonIcon =
                isActive ? Icons.opacity : Icons.edit;

            return _buildDetailsContent(
              context,
              l10n,
              theme,
              formatter,
              details,
              isActive,
              statusColor,
              primaryButtonLabel,
              primaryButtonIcon,
            );
          }

          // Default State
          return Center(
            child: Text(l10n.selectAHeatCycle),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context, theme, l10n),
    );
  }

  // Helper method to conditionally build the FAB
  Widget? _buildFloatingActionButton(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final state = context.watch<HeatCycleBloc>().state;
    if (state is HeatCycleDetailsLoaded) {
      final details = state.cycle;
      final isActive = _calculateIsActive(
        details.nextExpectedDate,
        details.inseminated,
      );

      final String primaryButtonLabel =
          isActive ? l10n.recordInsemination : l10n.edit;
      final IconData primaryButtonIcon = isActive ? Icons.opacity : Icons.edit;

      return FloatingActionButton.extended(
        backgroundColor: isActive ? BreedingColors.heat : Colors.blueGrey,
        foregroundColor: Colors.white,
        icon: Icon(primaryButtonIcon),
        label: Text(primaryButtonLabel),
        onPressed: () {
          if (isActive) {
            // Navigate to insemination page
            context.push(
              '/farmer/breeding/heat-cycles/${details.id}/inseminate',
            );
          } else {
            // Navigate to edit page
            context.push(
              '/farmer/breeding/heat-cycles/${details.id}/edit',
            );
          }
        },
      );
    }
    return null;
  }

  // Build the main scrollable content
  Widget _buildDetailsContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    DateFormat formatter,
    HeatCycleEntity details,
    bool isActive,
    Color statusColor,
    String primaryButtonLabel,
    IconData primaryButtonIcon,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    isActive
                        ? Icons.whatshot
                        : (details.inseminated
                            ? Icons.favorite_border
                            : Icons.block),
                    color: statusColor,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.dam.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${l10n.tagNumber}: ${details.dam.tagNumber}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Details Section
          Text(
            l10n.details,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),

          _buildDetailRow(
            l10n.status,
            _calculateStatus(details.inseminated, details.nextExpectedDate, l10n),
            statusColor,
            theme,
          ),
          _buildDetailRow(
            l10n.observedDate,
            formatter.format(details.observedDate),
            Colors.black87,
            theme,
          ),
          _buildDetailRow(
            l10n.intensity,
            details.intensity,
            Colors.black87,
            theme,
          ),

          if (details.nextExpectedDate != null)
            _buildDetailRow(
              l10n.nextExpected,
              formatter.format(details.nextExpectedDate!),
              BreedingColors.heat,
              theme,
            ),

          if (details.inseminated)
            _buildDetailRow(
              l10n.inseminationRecorded,
              l10n.yes,
              Colors.green.shade700,
              theme,
            ),

          const SizedBox(height: 24),

          // Notes Section
          Text(
            l10n.notes,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),

          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              details.notes ?? l10n.noNotesProvided,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for building a detail row
  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logic to determine if the cycle is active
  bool _calculateIsActive(DateTime? nextExpectedDate, bool inseminated) {
    if (inseminated) return false;
    return nextExpectedDate != null &&
        nextExpectedDate.isAfter(DateTime.now());
  }

  // Logic to determine the status string
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