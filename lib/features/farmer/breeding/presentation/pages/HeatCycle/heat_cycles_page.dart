import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
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
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHeatCycles();
    });
  }

  void _loadHeatCycles() {
    final token = _getAuthToken();
    if (token.isNotEmpty) {
      context.read<HeatCycleBloc>().add(LoadHeatCycles(token: token));
    }
  }

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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            // FIX: Check if popping is possible, otherwise navigate to a known route.
            if (context.canPop()) {
              context.pop();
            } else {
              // Assuming '/farmer/dashboard' is the main hub for the farmer role.
              // If not, use the correct main navigation route, e.g., '/'
              context.go('/farmer/dashboard');
            }
          },
        ),
        title: Text(
          l10n.heatCycles,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            _loadHeatCycles();
          }
        },
        builder: (context, state) {
          if (state is HeatCycleInitial || state is HeatCycleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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
                      'Error Loading Data',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadHeatCycles,
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

          if (state is HeatCycleListLoaded) {
            final allCycles = state.cycles;

            // Filter cycles based on selection
            final filteredCycles = _selectedFilter == 'all'
                ? allCycles
                : _selectedFilter == 'active'
                    ? allCycles.where((c) => c.isActive).toList()
                    : _selectedFilter == 'inseminated'
                        ? allCycles.where((c) => c.inseminated).toList()
                        : allCycles.where((c) => !c.isActive && !c.inseminated).toList();

            return Column(
              children: [
                // Header with stats and filter
                _buildHeader(l10n, allCycles),

                // Filter chips
                _buildFilterChips(l10n),

                // List
                Expanded(
                  child: filteredCycles.isEmpty
                      ? _buildEmptyState(l10n)
                      : _buildCyclesList(filteredCycles, l10n, theme),
                ),
              ],
            );
          }

          return _buildEmptyState(l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: BreedingColors.heat,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.recordHeatCycle),
        onPressed: () => context.push('/farmer/breeding/heat-cycles/add'),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, List<dynamic> cycles) {
    final activeCount = cycles.where((c) => c.isActive).length;
    final inseminatedCount = cycles.where((c) => c.inseminated).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heat Cycle Overview',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  cycles.length.toString(),
                  Icons.whatshot,
                  BreedingColors.heat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  activeCount.toString(),
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Bred',
                  inseminatedCount.toString(),
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
              ),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
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

  Widget _buildFilterChips(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'All', Icons.list),
            const SizedBox(width: 8),
            _buildFilterChip('active', 'Active', Icons.local_fire_department),
            const SizedBox(width: 8),
            _buildFilterChip('inseminated', 'Bred', Icons.check_circle),
            const SizedBox(width: 8),
            _buildFilterChip('completed', 'Completed', Icons.done_all),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      selectedColor: BreedingColors.heat,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildCyclesList(List<dynamic> cycles, AppLocalizations l10n, ThemeData theme) {
    final DateFormat formatter = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );

    return RefreshIndicator(
      onRefresh: () async => _loadHeatCycles(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cycles.length,
        itemBuilder: (context, index) {
          final cycle = cycles[index];
          final isActive = cycle.isActive;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.push('/farmer/breeding/heat-cycles/${cycle.id}'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isActive
                            ? BreedingColors.heat.withOpacity(0.1)
                            : cycle.inseminated
                                ? AppColors.success.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isActive
                            ? Icons.whatshot
                            : cycle.inseminated
                                ? Icons.check_circle
                                : Icons.block,
                        color: isActive
                            ? BreedingColors.heat
                            : cycle.inseminated
                                ? AppColors.success
                                : Colors.grey,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${cycle.dam.name} (${cycle.dam.tagNumber})",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${l10n.observedDate}: ${formatter.format(cycle.observedDate)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (cycle.nextExpectedDate != null)
                            Text(
                              "${l10n.nextExpected}: ${formatter.format(cycle.nextExpectedDate!)}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                color: isActive ? BreedingColors.heat : Colors.grey[600],
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? BreedingColors.heat.withOpacity(0.1)
                                  : cycle.inseminated
                                      ? AppColors.success.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cycle.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? BreedingColors.heat
                                    : cycle.inseminated
                                        ? AppColors.success
                                        : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.whatshot,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No Heat Cycles Recorded',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking heat cycles for your female animals',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}