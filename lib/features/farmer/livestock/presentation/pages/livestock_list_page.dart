// lib/features/livestock/presentation/pages/livestock_list_page.dart
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_event.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
// Note: Changed import for l10n package structure
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

class LivestockListView extends StatelessWidget {
  const LivestockListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          // ⭐ CRITICAL FIX: Use context.canPop() to prevent GoError
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // If it's the root, navigate to the dashboard instead of popping.
              // Assuming '/farmer/dashboard' is the main fallback route.
              context.go('/farmer/dashboard'); 
            }
          },
        ),
        // ⭐ L10N FIX: Use l10n key
        title: Text(l10n.myLivestock, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
      ),
      body: BlocConsumer<LivestockBloc, LivestockState>(
        listener: (context, state) {
          // Listener logic remains here if needed
        },
        builder: (context, state) {
          if (state is LivestockLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LivestockError) {
            // ⭐ L10N FIX: Use l10n key
            return Center(child: Text('${l10n.error} ${state.message}'));
          }
          if (state is LivestockListLoaded) {
            final livestock = state.livestock;
            if (livestock.isEmpty) {
              // ⭐ L10N FIX: Use l10n key
              return Center(child: Text(l10n.noLivestockRecords));
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
                    // ⭐ L10N FIX: Use l10n keys for Species and Status
                    subtitle: Text('${l10n.species}: ${animal.species?.speciesName ?? 'N/A'} • ${l10n.status}: ${status}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                    // Add null check for animalId before push.
                    onTap: animal.animalId == null 
                        ? null 
                        : () => context.push('/farmer/livestock/detail/${animal.animalId}'),
                  ),
                );
              },
            );
          }
          // ⭐ L10N FIX: Use l10n key
          return Center(child: Text(l10n.pressToAdd));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await context.push('/farmer/livestock/add');
          context.read<LivestockBloc>().add(const LoadLivestockList());
        },
      ),
    );
  }
}