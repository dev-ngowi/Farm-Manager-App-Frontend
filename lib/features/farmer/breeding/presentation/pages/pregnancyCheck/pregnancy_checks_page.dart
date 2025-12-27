// lib/features/farmer/breeding/presentation/pages/pregnancy_check/pregnancy_checks_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PregnancyChecksPage extends StatelessWidget {
  static const String routeName = '/farmer/breeding/pregnancy-checks';

  const PregnancyChecksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PregnancyCheckBloc>()..add(const LoadPregnancyCheckList()),
      child: const PregnancyChecksView(),
    );
  }
}

class PregnancyChecksView extends StatefulWidget {
  const PregnancyChecksView({super.key});

  @override
  State<PregnancyChecksView> createState() => _PregnancyChecksViewState();
}

class _PregnancyChecksViewState extends State<PregnancyChecksView> {
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
    context.read<PregnancyCheckBloc>().add(LoadPregnancyCheckList(filters: _currentFilters));
  }

  void _applySearch(String value) {
    final searchText = value.trim();
    final newFilters = searchText.isEmpty ? <String, dynamic>{} : {'search': searchText};
    final currentSearch = _currentFilters['search'] ?? '';

    if (currentSearch != searchText) {
      setState(() => _currentFilters = newFilters);
      context.read<PregnancyCheckBloc>().add(LoadPregnancyCheckList(filters: _currentFilters));
    }
  }

  Color _getResultColor(String result) {
    switch (result.toLowerCase()) {
      case 'pregnant':
        return AppColors.success;
      case 'not pregnant':
      case 'reabsorbed':
        return AppColors.error;
      default:
        return AppColors.secondary;
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
                  hintText: l10n.searchChecks ?? 'Search by Dam Tag or Method',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
                ),
                style: const TextStyle(color: AppColors.primary),
                onSubmitted: _applySearch,
                onChanged: _applySearch,
              )
            : Text(
                l10n.pregnancyChecks,
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
      body: BlocConsumer<PregnancyCheckBloc, PregnancyCheckState>(
        listener: (context, state) {
          if (state is PregnancyCheckUpdated || state is PregnancyCheckDeleted || state is PregnancyCheckAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is PregnancyCheckUpdated
                      ? l10n.pregnancyCheckUpdatedSuccess ?? 'Updated successfully'
                      : state is PregnancyCheckDeleted
                          ? l10n.pregnancyCheckDeletedSuccess ?? 'Deleted successfully'
                          : l10n.pregnancyCheckAddedSuccess ?? 'Added successfully',
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _reloadList();
          } else if (state is PregnancyCheckError) {
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
          if (state is PregnancyCheckLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PregnancyCheckError) {
            return _buildErrorState(l10n, state.message);
          }

          if (state is PregnancyCheckListLoaded) {
            final allChecks = state.checks;

            // Filter checks based on selection
            final filteredChecks = _selectedFilter == 'all'
                ? allChecks
                : _selectedFilter == 'pregnant'
                    ? allChecks.where((c) => c.result.toLowerCase() == 'pregnant').toList()
                    : allChecks.where((c) => c.result.toLowerCase() == 'not pregnant').toList();

            return Column(
              children: [
                _buildHeader(l10n, allChecks),
                _buildFilterChips(l10n),
                Expanded(
                  child: filteredChecks.isEmpty
                      ? _buildEmptyState(l10n)
                      : _buildChecksList(filteredChecks, l10n),
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
        label: Text(l10n.recordCheck ?? 'Record Check'),
        onPressed: () async {
          await context.pushNamed('add-pregnancy-check');
          _reloadList();
        },
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, List<dynamic> checks) {
    final pregnantCount = checks.where((c) => c.result.toLowerCase() == 'pregnant').length;
    final notPregnantCount = checks.where((c) => c.result.toLowerCase() == 'not pregnant').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pregnancyChecksOverview ?? 'Pregnancy Checks Overview',
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
                  l10n.total ?? 'Total',
                  checks.length.toString(),
                  Icons.list_alt,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.pregnant ?? 'Pregnant',
                  pregnantCount.toString(),
                  Icons.favorite,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.notPregnant ?? 'Not Pregnant',
                  notPregnantCount.toString(),
                  Icons.heart_broken,
                  AppColors.error,
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
            _buildFilterChip('all', l10n.all ?? 'All', Icons.list),
            const SizedBox(width: 8),
            _buildFilterChip('pregnant', l10n.pregnant ?? 'Pregnant', Icons.favorite),
            const SizedBox(width: 8),
            _buildFilterChip('not_pregnant', l10n.notPregnant ?? 'Not Pregnant', Icons.heart_broken),
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

  Widget _buildChecksList(List<dynamic> checks, AppLocalizations l10n) {
    final dateFormatter = DateFormat.yMMMd(Localizations.localeOf(context).toString());

    return RefreshIndicator(
      onRefresh: () async => _reloadList(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: checks.length,
        itemBuilder: (context, index) {
          final check = checks[index];
          final resultColor = _getResultColor(check.result);

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
                  'pregnancyCheckDetail',
                  pathParameters: {'id': check.id.toString()},
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
                        color: resultColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        check.result.toLowerCase() == 'pregnant' ? Icons.favorite : Icons.monitor_heart,
                        color: resultColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${check.damName} (${check.damTagNumber})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.checkDate}: ${dateFormatter.format(check.checkDate)} • ${check.method}',
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
                                  color: resultColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  check.result,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: resultColor,
                                  ),
                                ),
                              ),
                              if (check.result.toLowerCase() == 'pregnant' && check.expectedDeliveryDate != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${l10n.dueDate}: ${dateFormatter.format(check.expectedDeliveryDate)}',
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
            Icon(Icons.monitor_heart, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              l10n.noChecksYet ?? 'No Pregnancy Checks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? l10n.recordFirstCheck ?? 'Start recording pregnancy checks'
                  : l10n.noResultsFound ?? 'No ${_selectedFilter.replaceAll('_', ' ')} records found',
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingData ?? 'Error Loading Data',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
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