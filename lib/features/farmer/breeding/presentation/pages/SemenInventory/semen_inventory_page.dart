import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SemenInventoryPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/semen';

  const SemenInventoryPage({super.key});

  @override
  State<SemenInventoryPage> createState() => _SemenInventoryPageState();
}

class _SemenInventoryPageState extends State<SemenInventoryPage> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventory();
    });
  }

  void _loadInventory() {
    context.read<SemenInventoryBloc>().add(const SemenLoadInventory());
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/farmer/dashboard');
            }
          },
        ),
        title: Text(
          l10n.semenInventory,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            _loadInventory();
          }
        },
        builder: (context, state) {
          if (state is SemenInitial || state is SemenLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SemenError) {
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
                      onPressed: _loadInventory,
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

          if (state is SemenLoadedList) {
            final allInventory = state.semenList;

            // Filter inventory based on selection
            final filteredInventory = _selectedFilter == 'all'
                ? allInventory
                : _selectedFilter == 'available'
                    ? allInventory.where((s) => !s.used).toList()
                    : allInventory.where((s) => s.used).toList();

            return Column(
              children: [
                // Header with stats and filter
                _buildHeader(l10n, allInventory),

                // Filter chips
                _buildFilterChips(l10n),

                // List
                Expanded(
                  child: filteredInventory.isEmpty
                      ? _buildEmptyState(l10n)
                      : _buildInventoryList(filteredInventory, l10n, theme),
                ),
              ],
            );
          }

          return _buildEmptyState(l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: BreedingColors.semen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addSemen),
        onPressed: () => context.push('${SemenInventoryPage.routeName}/add'),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, List<dynamic> inventory) {
    final availableCount = inventory.where((s) => !s.used).length;
    final usedCount = inventory.where((s) => s.used).length;
    final totalValue = inventory.fold<double>(
      0.0,
      (sum, item) => sum + (item.costPerStraw ?? 0.0),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Semen Inventory Overview',
            style: TextStyle(
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
                  inventory.length.toString(),
                  Icons.storage,
                  BreedingColors.semen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Available',
                  availableCount.toString(),
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Used',
                  usedCount.toString(),
                  Icons.done_all,
                  Colors.grey,
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
            _buildFilterChip('available', l10n.available, Icons.check_circle),
            const SizedBox(width: 8),
            _buildFilterChip('used', l10n.used, Icons.block),
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
      selectedColor: BreedingColors.semen,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildInventoryList(List<dynamic> inventory, AppLocalizations l10n, ThemeData theme) {
    final currencyFormatter = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: 'TZS ',
    );
    final dateFormatter = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );

    return RefreshIndicator(
      onRefresh: () async => _loadInventory(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          final item = inventory[index];
          final isUsed = item.used;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.push('${SemenInventoryPage.routeName}/${item.id}'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isUsed
                            ? Colors.grey.withOpacity(0.1)
                            : BreedingColors.semen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isUsed ? Icons.block : Icons.storage,
                        color: isUsed ? Colors.grey : BreedingColors.semen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.strawCode,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${item.bullName} • ${item.breed?.breedName ?? l10n.unknown}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.attach_money, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                currencyFormatter.format(item.costPerStraw),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                dateFormatter.format(item.collectionDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUsed
                                  ? Colors.grey.withOpacity(0.1)
                                  : BreedingColors.semen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isUsed ? l10n.used : l10n.available,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isUsed ? Colors.grey[700] : BreedingColors.semen,
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
              Icons.storage,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No Semen Inventory',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'Start adding semen straws to your inventory'
                  : 'No ${_selectedFilter} semen straws found',
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