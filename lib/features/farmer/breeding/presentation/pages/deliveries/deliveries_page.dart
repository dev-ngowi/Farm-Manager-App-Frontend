// lib/features/farmer/breeding/presentation/pages/delivery/deliveries_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DeliveriesPage extends StatelessWidget {
  static const String routeName = '/farmer/breeding/deliveries';

  const DeliveriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DeliveryBloc>()..add(const LoadDeliveryList()),
      child: const DeliveriesView(),
    );
  }
}

class DeliveriesView extends StatefulWidget {
  const DeliveriesView({super.key});

  @override
  State<DeliveriesView> createState() => _DeliveriesViewState();
}

class _DeliveriesViewState extends State<DeliveriesView> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _currentFilters = {};
  bool _isSearching = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Load deliveries when page initializes
    _reloadList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // FIXED: This ensures data reloads properly
  void _reloadList() {
    print('🔄 Reloading deliveries list...');
    context.read<DeliveryBloc>().add(LoadDeliveryList(filters: _currentFilters));
  }

  void _applySearch(String value) {
    final searchText = value.trim();
    setState(() {
      _currentFilters = searchText.isEmpty ? {} : {'search': searchText};
    });
    _reloadList();
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return AppColors.success;
      case 'assisted':
        return AppColors.warning;
      case 'c-section':
      case 'dystocia':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  // FIXED: Navigate to add page and reload on return
  Future<void> _navigateToAdd() async {
    await context.pushNamed('add-delivery');
    // Reload list when returning from add page
    _reloadList();
  }

  // FIXED: Navigate to detail page and reload on return
  Future<void> _navigateToDetail(dynamic id) async {
    await context.pushNamed('delivery-detail', pathParameters: {'id': id.toString()});
    // Reload list when returning from detail page
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
                onPressed: () => context.canPop() ? context.pop() : context.go('/farmer/dashboard'),
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchDeliveries ?? 'Search Dam or Type...',
                  border: InputBorder.none,
                ),
                onChanged: _applySearch,
              )
            : Text(
                l10n.deliveries ?? 'Deliveries',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search, color: AppColors.primary),
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
      body: BlocConsumer<DeliveryBloc, DeliveryState>(
        listener: (context, state) {
          // REMOVED: No need to reload on these states anymore
          // The reload will happen when navigating back to this page
          if (state is DeliveryError) {
            // Only show error snackbar
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
          if (state is DeliveryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeliveryListLoaded) {
            final deliveries = _applyClientSideFilter(state.deliveries);

            return Column(
              children: [
                _buildHeader(l10n, state.deliveries),
                _buildFilterChips(l10n),
                Expanded(
                  child: deliveries.isEmpty
                      ? _buildEmptyState(l10n)
                      : _buildDeliveriesList(deliveries, l10n),
                ),
              ],
            );
          }

          if (state is DeliveryError) {
            return _buildErrorState(l10n, state.message);
          }

          return _buildEmptyState(l10n);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        onPressed: _navigateToAdd, // FIXED: Use new navigation method
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.recordDelivery ?? 'Record Delivery',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  List<DeliveryEntity> _applyClientSideFilter(List<DeliveryEntity> list) {
    if (_selectedFilter == 'all') return list;
    return list.where((d) => d.deliveryType.toLowerCase() == _selectedFilter).toList();
  }

  Widget _buildHeader(AppLocalizations l10n, List<DeliveryEntity> deliveries) {
    final live = deliveries.fold<int>(0, (sum, d) => sum + d.liveBorn);
    final total = deliveries.fold<int>(0, (sum, d) => sum + d.totalBorn);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              l10n.total ?? 'Deliveries',
              deliveries.length.toString(),
              Icons.inventory,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              l10n.offspring ?? 'Live/Total',
              '$live/$total',
              Icons.child_care,
              AppColors.secondary,
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
      {'id': 'normal', 'label': l10n.normal ?? 'Normal'},
      {'id': 'assisted', 'label': l10n.assisted ?? 'Assisted'},
      {'id': 'dystocia', 'label': 'Dystocia'},
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
              selectedColor: AppColors.secondary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeliveriesList(List<DeliveryEntity> deliveries, AppLocalizations l10n) {
    final df = DateFormat.yMMMd();

    return RefreshIndicator(
      onRefresh: () async => _reloadList(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deliveries.length,
        itemBuilder: (context, index) {
          final d = deliveries[index];
          final color = _getTypeColor(d.deliveryType);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              // FIXED: Use new navigation method
              onTap: () => _navigateToDetail(d.id),
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(Icons.pets, color: color, size: 20),
              ),
              title: Text(
                '${d.damTagNumber} - ${d.damName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${df.format(d.actualDeliveryDate)} • ${d.deliveryType}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${d.liveBorn}/${d.totalBorn}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const Text('Live', style: TextStyle(fontSize: 10)),
                ],
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
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.noResultsFound ?? 'No deliveries found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button below to add your first delivery',
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
              'Error Loading Deliveries',
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}