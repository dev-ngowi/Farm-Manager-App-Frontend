// lib/features/farmer/insemination/presentation/pages/inseminations_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InseminationListPage extends StatelessWidget {
  static const String routeName = '/farmer/inseminations';

  const InseminationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InseminationBloc>()..add(const LoadInseminationList()),
      child: const InseminationListView(),
    );
  }
}

class InseminationListView extends StatefulWidget {
  const InseminationListView({super.key});

  @override
  State<InseminationListView> createState() => _InseminationListViewState();
}

class _InseminationListViewState extends State<InseminationListView> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _currentFilters = {};
  bool _isSearching = false;
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _reloadList() {
    context.read<InseminationBloc>().add(LoadInseminationList(filters: _currentFilters));
  }
  
  void _applySearch(String value) {
    final searchText = value.trim();
    final newFilters = searchText.isEmpty ? <String, dynamic>{} : {'search': searchText};
    final currentSearch = _currentFilters['search'] ?? '';
    
    if (currentSearch != searchText) {
      setState(() => _currentFilters = newFilters);
      context.read<InseminationBloc>().add(LoadInseminationList(filters: _currentFilters));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _applySearch('');
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/farmer/dashboard'); 
                  }
                },
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchByAnimalTag ?? 'Search by Animal Tag or Date',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
                ),
                style: const TextStyle(color: AppColors.primary),
                onSubmitted: _applySearch,
                onChanged: _applySearch,
              )
            : Text(
                l10n.inseminationRecords,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.primary),
                  onPressed: () {
                    _searchController.clear();
                    _applySearch('');
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  onPressed: () => setState(() => _isSearching = true),
                ),
        ],
      ),
      body: BlocConsumer<InseminationBloc, InseminationState>(
        listener: (context, state) {
          if (state is InseminationUpdated || state is InseminationDeleted || state is InseminationAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is InseminationUpdated
                      ? l10n.inseminationUpdatedSuccess ?? 'Updated successfully'
                      : state is InseminationDeleted
                          ? l10n.inseminationDeletedSuccess ?? 'Deleted successfully'
                          : l10n.inseminationAddedSuccess ?? 'Added successfully',
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _reloadList();
          } else if (state is InseminationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.error}: ${state.message}'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InseminationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InseminationError) {
            return _buildErrorState(l10n, state.message);
          }
          
          if (state is InseminationListLoaded) {
            final allRecords = state.records;

            // Filter records based on selection
            final filteredRecords = _selectedFilter == 'all'
                ? allRecords
                : _selectedFilter == 'pregnant'
                    ? allRecords.where((r) => r.isPregnant).toList()
                    : allRecords.where((r) => !r.isPregnant && r.status == 'Pending').toList();

            return Column(
              children: [
                _buildHeader(l10n, allRecords),
                _buildFilterChips(l10n),
                Expanded(
                  child: filteredRecords.isEmpty
                      ? _buildEmptyState(l10n)
                      : _buildRecordsList(filteredRecords, l10n),
                ),
              ],
            );
          }
          
          return _buildEmptyState(l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addInseminationRecord ?? 'Add Insemination'),
        onPressed: () async {
          await context.pushNamed('add-insemination');
          _reloadList();
        },
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, List<dynamic> records) {
    final pregnantCount = records.where((r) => r.isPregnant).length;
    final pendingCount = records.where((r) => !r.isPregnant && r.status == 'Pending').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insemination Overview',
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
                  records.length.toString(),
                  Icons.list_alt,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pregnant',
                  pregnantCount.toString(),
                  Icons.favorite,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  pendingCount.toString(),
                  Icons.schedule,
                  Colors.amber,
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
            _buildFilterChip('pregnant', 'Pregnant', Icons.favorite),
            const SizedBox(width: 8),
            _buildFilterChip('pending', 'Pending', Icons.schedule),
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
      onSelected: (selected) => setState(() => _selectedFilter = value),
      selectedColor: AppColors.secondary,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildRecordsList(List<dynamic> records, AppLocalizations l10n) {
    final dateFormatter = DateFormat.yMMMd(Localizations.localeOf(context).toString());

    return RefreshIndicator(
      onRefresh: () async => _reloadList(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final statusColor = record.isPregnant ? AppColors.success : Colors.amber;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await context.pushNamed(
                  'inseminationDetail',
                  pathParameters: {'id': record.id.toString()},
                );
                _reloadList();
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        record.isPregnant ? Icons.favorite : Icons.pregnant_woman,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${record.dam.name} (${record.dam.tagNumber})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.date}: ${dateFormatter.format(record.inseminationDate)} • ${record.breedingMethod}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  record.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              if (record.isPregnant) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${record.daysToDue} days to due',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
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
            Icon(Icons.pregnant_woman, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No Insemination Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'Start recording insemination events'
                  : 'No ${_selectedFilter} records found',
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

  Widget _buildErrorState(AppLocalizations l10n, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reloadList,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry ?? 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}