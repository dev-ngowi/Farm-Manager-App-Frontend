// lib/features/farmer/livestock/presentation/pages/livestock_list_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_event.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LivestockListPage extends StatelessWidget {
  static const String routeName = '/farmer/livestock';

  const LivestockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with BlocProvider to manage the state for this page
    // The initial event LoadLivestockList is dispatched here.
    return BlocProvider(
      create: (context) => getIt<LivestockBloc>()..add(const LoadLivestockList()),
      child: const LivestockListView(),
    );
  }
}

class LivestockListView extends StatefulWidget {
  const LivestockListView({super.key});

  @override
  State<LivestockListView> createState() => _LivestockListViewState();
}

class _LivestockListViewState extends State<LivestockListView> {
  final TextEditingController _searchController = TextEditingController();
  // Stores the active filters (e.g., {'search': 'tag123'}).
  Map<String, dynamic> _currentFilters = {};
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Helper method to dispatch the load event with the current filters
  void _reloadList() {
    // Load the list using the current active filters (if any)
    context.read<LivestockBloc>().add(LoadLivestockList(filters: _currentFilters));
  }
  
  // Helper to apply the search filter and dispatch the event
  void _applySearch(String value) {
    final searchText = value.trim();
    
    // ⭐ FIX: Explicitly type the empty map to resolve the assignment error
    final newFilters = searchText.isEmpty 
        ? <String, dynamic>{} 
        : {'search': searchText};
    
    // Get the current active search term (default to '' if no filter exists)
    final currentSearch = _currentFilters['search'] ?? '';
    
    // Only dispatch if the search filter actually changed
    if (currentSearch != searchText) {
      setState(() {
        _currentFilters = newFilters;
      });
      context.read<LivestockBloc>().add(LoadLivestockList(filters: _currentFilters));
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        // CONDITIONAL LEADING ICON for search/back navigation
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _applySearch(''); // Clear search filter and reload
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // If it's the root, navigate to the dashboard instead of popping.
                    context.go('/farmer/dashboard'); 
                  }
                },
              ),
        
        // CONDITIONAL TITLE/SEARCH FIELD
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  // ⭐ FIX: Use clear hintStyle and localization
                  hintText: l10n.searchByTagOrName ?? 'Search by Tag or Name',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
                ),
                style: const TextStyle(color: AppColors.primary),
                // Apply search on submit (Enter key on keyboard)
                onSubmitted: _applySearch, 
                // Apply search on change (good UX for filtering)
                onChanged: _applySearch,
              )
            : Text(l10n.myLivestock, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        
        // ACTION BUTTONS (Search/Clear)
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.primary),
                  onPressed: () {
                    _searchController.clear();
                    _applySearch(''); // Clear search filter and reload
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
        ],
      ),
      
      // BlocConsumer to handle list data and post-CRUD notifications
      body: BlocConsumer<LivestockBloc, LivestockState>(
        listener: (context, state) {
          if (state is LivestockUpdated) { 
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.animalUpdatedSuccess)), 
            );
            // Re-fetch the list, ensuring current filters are reapplied
            _reloadList(); 
          } else if (state is LivestockDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.animalDeletedSuccess)), 
            );
            // Re-fetch the list, ensuring current filters are reapplied
            _reloadList();
          } else if (state is LivestockError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.error}: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is LivestockLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LivestockError) {
            return Center(child: Text('${l10n.error} ${state.message}'));
          }
          
          if (state is LivestockListLoaded) {
            final livestock = state.livestock;
            
            if (livestock.isEmpty) {
              // Check if no results due to filter or no records at all
              final message = _currentFilters.isNotEmpty 
                  ? l10n.noResultsFound ?? 'No animals match your current search or filters.'
                  : l10n.noLivestockRecords;
              return Center(child: Text(message));
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: livestock.length,
              itemBuilder: (context, index) {
                final animal = livestock[index];
                
                final tagNumber = animal.tagNumber ?? 'N/A'; 
                final status = animal.status ?? 'Unknown';
                
                final avatarText = tagNumber.isEmpty ? '?' : tagNumber.substring(0, 1);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(avatarText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                    title: Text('${animal.name ?? 'N/A'} (${tagNumber})', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${l10n.species}: ${animal.species?.speciesName ?? 'N/A'} • ${l10n.status}: ${status}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                    
                    onTap: () async {
                      // Navigate to detail page. When returning, the pop() can return a result (e.g., the updated animal or a 'deleted' flag).
                      final result = await context.push('/farmer/livestock/detail/${animal.animalId}');
                      
                      // Reload the list if any result is returned
                      if (result != null) {
                          _reloadList();
                      }
                    },
                  ),
                );
              },
            );
          }
          
          return Center(child: Text(l10n.pressToAdd));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Await the result from the add page
          await context.push('/farmer/livestock/add');
          // Reload the list after returning from the add page to see the new animal
          _reloadList();
        },
      ),
    );
  }
}