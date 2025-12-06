// heat_cycles_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/empty_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HeatCyclesPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/heat-cycles';

  const HeatCyclesPage({super.key});

  @override
  State<HeatCyclesPage> createState() => _HeatCyclesPageState();
}

class _HeatCyclesPageState extends State<HeatCyclesPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch event to load heat cycles on page init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = _getAuthToken();
      if (token.isNotEmpty) {
        context.read<HeatCycleBloc>().add(LoadHeatCycles(token: token));
      }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    const Color trailingIconColor = Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // 🚀 ADDED BACK BUTTON/TITLE ENHANCEMENTS 🚀
        automaticallyImplyLeading: true, // Ensures a back button is shown if the route allows
        title: Text(l10n.heatCycles),
        backgroundColor: BreedingColors.heat,
        foregroundColor: AppColors.onSecondary,
        elevation: 1,
      ),
      body: BlocBuilder<HeatCycleBloc, HeatCycleState>(
        builder: (context, state) {
          // Loading State
          if (state is HeatCycleInitial || state is HeatCycleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error State
          if (state is HeatCycleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmptyState(
                    message: state.message,
                    icon: Icons.error_outline,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final token = _getAuthToken();
                      context.read<HeatCycleBloc>().add(LoadHeatCycles(token: token));
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry ?? 'Retry'),
                  ),
                ],
              ),
            );
          }

          // Data Loaded State
          if (state is HeatCycleListLoaded) {
            final cycles = state.cycles;

            if (cycles.isEmpty) {
              return EmptyState(
                message: l10n.heatCycleEmptyStateMessage,
                icon: Icons.whatshot,
              );
            }

            final DateFormat formatter = DateFormat.yMMMd(
              Localizations.localeOf(context).toString(),
            );

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cycles.length,
              itemBuilder: (context, i) {
                final cycle = cycles[i];
                final isActive = cycle.isActive;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isActive
                          ? BreedingColors.heat.withOpacity(0.2)
                          : Colors.green.shade100,
                      child: Icon(
                        isActive
                            ? Icons.whatshot
                            : (cycle.inseminated
                                ? Icons.favorite_border
                                : Icons.block),
                        color: isActive
                            ? BreedingColors.heat
                            : (cycle.inseminated
                                ? Colors.green.shade700
                                : Colors.blueGrey),
                      ),
                    ),
                    title: Text(
                      "${cycle.dam.name} (${cycle.dam.tagNumber})",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${l10n.observedDate}: ${formatter.format(cycle.observedDate)}",
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (cycle.nextExpectedDate != null)
                          Text(
                            "${l10n.nextExpected}: ${formatter.format(cycle.nextExpectedDate!)}",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isActive
                                  ? BreedingColors.heat
                                  : Colors.grey.shade600,
                            ),
                          ),
                        Text(
                          "${l10n.status}: ${cycle.status}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? BreedingColors.heat
                                : (cycle.inseminated
                                    ? Colors.green.shade700
                                    : Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: trailingIconColor,
                    ),
                    onTap: () {
                      // Navigate using the full path
                      context.push('/farmer/breeding/heat-cycles/${cycle.id}');
                    },
                  ),
                );
              },
            );
          }

          // Default: Show empty state
          return EmptyState(
            message: l10n.heatCycleEmptyStateMessage,
            icon: Icons.whatshot,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: BreedingColors.heat,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.recordHeatCycle),
        onPressed: () {
          // Navigate using the full path
          context.push('/farmer/breeding/heat-cycles/add');
        },
      ),
    );
  }
}