// lib/features/farmer/insemination/presentation/pages/inseminations_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_state.dart';
// ⭐ NEW IMPORT: Import the AddInseminationPage to access its routeName
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/insemination/add_insemination_page.dart'; 
// ⭐ NEW IMPORT: Import the Detail Page to access its route name if possible (or rely on the path)
// Assuming InseminationDetailPage is where the 'inseminationDetail' name is defined implicitly/explicitly

import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Needed for date formatting

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
    
    final newFilters = searchText.isEmpty 
        ? <String, dynamic>{} 
        : {'search': searchText};
    
    final currentSearch = _currentFilters['search'] ?? '';
    
    if (currentSearch != searchText) {
      setState(() {
        _currentFilters = newFilters;
      });
      context.read<InseminationBloc>().add(LoadInseminationList(filters: _currentFilters));
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
                  hintText: l10n.searchByAnimalTag ?? 'Search by Animal Tag or Date',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
                ),
                style: const TextStyle(color: AppColors.primary),
                onSubmitted: _applySearch, 
                onChanged: _applySearch,
              )
            : Text(l10n.inseminationRecords, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        
        // ACTION BUTTONS (Search/Clear)
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
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
        ],
      ),
      
      // BlocConsumer to handle list data and post-CRUD notifications
      body: BlocConsumer<InseminationBloc, InseminationState>(
        listener: (context, state) {
          if (state is InseminationUpdated) { 
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.inseminationUpdatedSuccess ?? 'Insemination updated successfully.')), 
            );
            _reloadList(); 
          } else if (state is InseminationDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.inseminationDeletedSuccess ?? 'Insemination deleted successfully.')), 
            );
            _reloadList();
          } else if (state is InseminationAdded) { 
            // This listener might catch a success from another page's pop(result)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.inseminationAddedSuccess ?? 'Insemination record added.')), 
            );
            _reloadList();
          } else if (state is InseminationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.error}: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is InseminationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InseminationError) {
            return Center(child: Text('${l10n.error} ${state.message}'));
          }
          
          if (state is InseminationListLoaded) {
            final records = state.records;
            
            if (records.isEmpty) {
              final message = _currentFilters.isNotEmpty 
                  ? l10n.noResultsFound ?? 'No records match your current search or filters.'
                  : l10n.noInseminationRecords ?? 'No insemination records found.';
              return Center(child: Text(message));
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                
                // ⭐ FIX: Accessing Dam/Animal details from InseminationEntity
                final tagNumber = record.dam.tagNumber;
                final date = DateFormat('dd MMM yyyy').format(record.inseminationDate);
                final status = record.status;
                
                final avatarText = tagNumber.isEmpty ? '?' : tagNumber.substring(0, 1);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(avatarText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                    // ⭐ FIX: Displaying the dam's name and tag number
                    title: Text('${record.dam.name} (${tagNumber})', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${l10n.date}: ${date} • ${l10n.status}: ${status}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                    
                    onTap: () async {
                      // ⭐ FIX: Use the named route 'inseminationDetail' as defined in your GoRouter config
                      // You need to pass the route parameter 'id'
                      final result = await context.pushNamed(
                        'inseminationDetail', // Name from GoRouter config
                        pathParameters: {'id': record.id.toString()}, // Pass the ID
                      );
                      
                      if (result != null) {
                          _reloadList();
                      }
                    },
                  ),
                );
              },
            );
          }
          
          return Center(child: Text(l10n.pressToAdd ?? 'Press the add button to record a new insemination.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // ⭐ FIX: Use context.pushNamed with the AddInseminationPage's static routeName
          await context.pushNamed(AddInseminationPage.routeName);
          _reloadList();
        },
      ),
    );
  }
}