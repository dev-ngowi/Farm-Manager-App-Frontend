import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/empty_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SemenInventoryPage extends StatefulWidget {
  static const String routeName = '/farmer/breeding/semen';

  const SemenInventoryPage({super.key});

  @override
  State<SemenInventoryPage> createState() => _SemenInventoryPageState();
}

class _SemenInventoryPageState extends State<SemenInventoryPage> {
  final primaryColor = BreedingColors.semen;

  @override
  void initState() {
    super.initState();
    // 💡 Dispatch the initial event to load the data when the page starts
    context.read<SemenInventoryBloc>().add(const SemenLoadInventory());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(l10n.semenInventory),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      // 💡 BlocBuilder to handle state changes
      body: BlocBuilder<SemenInventoryBloc, SemenState>(
        builder: (context, state) {
          // --- 1. Loading State ---
          if (state is SemenLoading || state is SemenInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- 2. Error State ---
          if (state is SemenError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: AppColors.error),
                ),
              ),
            );
          }

          // --- 3. Data Loaded State ---
          if (state is SemenLoadedList) {
            final inventory = state.semenList;
            
            // --- 3a. Empty State ---
            if (inventory.isEmpty) {
              return EmptyState(
                icon: Icons.storage,
                message: "${l10n.noSemenRecordsYet}\n${l10n.recordFirstSemenBatch}",
                iconColor: AppColors.iconPrimary,
              );
            }

            // --- 3b. Loaded List View ---
            return RefreshIndicator(
              // Allows pull-to-refresh action
              onRefresh: () async {
                context.read<SemenInventoryBloc>().add(const SemenLoadInventory());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: inventory.length,
                itemBuilder: (context, i) {
                  final item = inventory[i];
                  
                  // ⭐ UPDATED LOGIC: Determine status based on the 'used' flag
                  final isUsed = item.used;
                  final status = isUsed ? l10n.used : l10n.available;
                  final statusColor = _getStatusColor(status);
                  final cost = l10n.formatCurrency(item.costPerStraw);
                  final itemId = item.id.toString(); 

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Icon(Icons.storage, color: primaryColor),
                      ),
                      title: Text(
                        // 💡 Using Entity fields
                        item.strawCode,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 💡 Using Entity fields (assuming bull.name and breed.breedName exist)
                          // NOTE: item.bullName is the simple string field. 
                          // item.breed?.breedName is from the nested entity.
                          Text(
                            "${item.bullName} • ${item.breed?.breedName ?? l10n.unknown}", 
                            style: theme.textTheme.bodyMedium,
                          ),
                          // ⭐ UPDATED: Show cost per straw instead of placeholder available units
                          Text(
                            "${l10n.costPerStraw}: $cost", 
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(
                          status,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: statusColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                          ),
                        ),
                        backgroundColor: statusColor.withOpacity(0.2),
                        side: BorderSide(color: statusColor, width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      ),
                      onTap: () => context.push('${SemenInventoryPage.routeName}/$itemId'),
                    ),
                  );
                },
              ),
            );
          }
          
          // Default fallback (should not happen)
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addSemen),
        onPressed: () => context.push('${SemenInventoryPage.routeName}/add'),
      ),
    );
  }

  // ⭐ REMOVED: Placeholder logic is removed
  // ⭐ UPDATED: Simplified status determination based on the 'used' flag
  String _getInventoryStatus(int availableStraws) {
    // This function is no longer called/needed with the simplified logic, 
    // but keeping it here for completeness if you decide to re-implement stock checks.
    // For now, the status is set directly in ListView.builder based on item.used.
    return ''; 
  }

  // ⭐ UPDATED: Status color logic simplified to Available/Used.
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return AppColors.success;
      case 'Used':
      default:
        return AppColors.secondary; // Using secondary for "Used" status
    }
  }
}