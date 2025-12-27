// lib/features/farmer/breeding/presentation/pages/offspring/offspring_list_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/domain/entities/offspring_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OffspringPage extends StatelessWidget {
  static const String routeName = '/farmer/breeding/offspring';

  const OffspringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OffspringBloc>()..add(const LoadOffspringList()),
      child: const OffspringView(),
    );
  }
}

class OffspringView extends StatefulWidget {
  const OffspringView({super.key});

  @override
  State<OffspringView> createState() => _OffspringViewState();
}

class _OffspringViewState extends State<OffspringView> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _currentFilters = {};
  bool _isSearching = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _reloadList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadList() {
    print('🔄 Reloading offspring list...');
    context.read<OffspringBloc>().add(LoadOffspringList(filters: _currentFilters));
  }

  void _applySearch(String value) {
    final searchText = value.trim();
    setState(() {
      _currentFilters = searchText.isEmpty ? {} : {'search': searchText};
    });
    _reloadList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return AppColors.success;
      case 'ready':
        return AppColors.secondary;
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _navigateToAdd() async {
    await context.pushNamed('add-offspring');
    _reloadList();
  }

  Future<void> _navigateToDetail(dynamic id) async {
    await context.pushNamed('offspring_detail', pathParameters: {'id': id.toString()});
    _reloadList();
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
                icon: const Icon(Icons.arrow_back, color: BreedingColors.offspring),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _applySearch('');
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: BreedingColors.offspring),
                onPressed: () => context.canPop() ? context.pop() : context.go('/farmer/dashboard'),
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchOffspring ?? 'Search Tag or Dam...',
                  border: InputBorder.none,
                ),
                onChanged: _applySearch,
              )
            : Text(
                l10n.offspring ?? 'Offspring',
                style: const TextStyle(color: BreedingColors.offspring, fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search, color: BreedingColors.offspring),
            onPressed: () {
              if (_isSearching) {
                _searchController.clear();
                _applySearch('');
              }
              setState(() => _isSearching = !_isSearching);
            },
          ),
        ],
      ),
      body: BlocConsumer<OffspringBloc, OffspringState>(
        listener: (context, state) {
          if (state is OffspringError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: l10n.retry ?? 'Retry',
                  textColor: Colors.white,
                  onPressed: _reloadList,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OffspringLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OffspringListLoaded) {
            final offspring = state.offspringList;

            return Column(
              children: [
                _buildHeader(l10n, offspring),
                _buildFilterChips(l10n),
                Expanded(
                  child: offspring.isEmpty
                      ? _buildEmptyState(l10n)
                      : _buildOffspringList(offspring, l10n),
                ),
              ],
            );
          }

          if (state is OffspringError) {
            return _buildErrorState(l10n, state.message);
          }

          return _buildEmptyState(l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: BreedingColors.offspring,
        onPressed: _navigateToAdd,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.recordOffspring ?? 'Record Offspring',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, List<OffspringEntity> offspring) {
    final total = offspring.length;
    final registered = offspring.where((o) => o.isRegistered).length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              l10n.total ?? 'Total',
              total.toString(),
              Icons.child_care,
              BreedingColors.offspring,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              l10n.registered ?? 'Registered',
              registered.toString(),
              Icons.badge,
              AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final filters = [
      {'id': 'all', 'label': l10n.all ?? 'All'},
      {'id': 'registered', 'label': l10n.registered ?? 'Registered'},
      {'id': 'pending', 'label': l10n.pending ?? 'Pending'},
      {'id': 'critical', 'label': l10n.critical ?? 'Critical'},
    ];

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = f['id']!),
              selectedColor: BreedingColors.offspring,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOffspringList(List<OffspringEntity> offspring, AppLocalizations l10n) {
    final df = DateFormat('dd MMM yyyy');

    return RefreshIndicator(
      onRefresh: () async => _reloadList(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offspring.length,
        itemBuilder: (context, index) {
          final item = offspring[index];
          final statusColor = item.isRegistered ? AppColors.success : AppColors.secondary;
          final statusText = item.isRegistered ? l10n.registered : l10n.pending;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              onTap: () => _navigateToDetail(item.id),
              leading: CircleAvatar(
                backgroundColor: BreedingColors.offspring.withOpacity(0.1),
                child: const Icon(Icons.child_care, color: BreedingColors.offspring, size: 20),
              ),
              title: Text(
                item.temporaryTag ?? l10n.noTemporaryTag ?? 'No Tag',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${item.gender} • ${item.birthWeightKg.toStringAsFixed(1)} kg • Dam: ${item.damTag}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${l10n.born ?? "Born"}: ${df.format(DateTime.parse(item.deliveryDate))}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText ?? '',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: !item.isRegistered
                  ? SizedBox(
                      width: 90,
                      child: ElevatedButton(
                        onPressed: () => context.push('/farmer/breeding/offspring/${item.id}/register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          elevation: 0,
                        ),
                        child: Text(l10n.register ?? 'Register', style: const TextStyle(fontSize: 11)),
                      ),
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
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
            Icon(Icons.child_friendly, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.noOffspringYet ?? 'No offspring records found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button below to record your first offspring',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Offspring',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reloadList,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry ?? 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BreedingColors.offspring,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}