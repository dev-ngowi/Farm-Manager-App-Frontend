// lib/features/farmer/livestock/presentation/pages/livestock_detail_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_event.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LivestockDetailPage extends StatelessWidget {
  final String animalId;

  const LivestockDetailPage({super.key, required this.animalId});

  // ⭐ FIX: Use path-based navigation instead of named route
  void _navigateToEditPage(BuildContext context, LivestockEntity animal) {
    // Option 1: Pass the entire animal object via extra
    context.push('/farmer/livestock/edit/${animal.animalId}', extra: animal);
    
    // Option 2: If you prefer to refetch the data in the edit page:
    // context.push('/farmer/livestock/edit/${animal.animalId}');
  }

  // Show a confirmation dialog for deletion
  Future<void> _showDeleteConfirmationDialog(BuildContext context, int id, String tag) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmationTitle),
          content: Text(l10n.deleteConfirmationMessage(tag)),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<LivestockBloc>().add(DeleteLivestock(id));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper widget for detail rows with improved styling
  Widget _buildDetailRow(BuildContext context, String label, String value, [String? secondaryValue]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (secondaryValue != null) 
                  Text(
                    secondaryValue,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build section cards
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final id = int.tryParse(animalId);
    
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.animalDetails)),
        body: Center(child: Text(l10n.invalidAnimalId)),
      );
    }

    return BlocProvider(
      create: (context) => getIt<LivestockBloc>()..add(LoadLivestockDetail(id)),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.animalDetails,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            BlocBuilder<LivestockBloc, LivestockState>(
              builder: (context, state) {
                if (state is LivestockDetailLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    tooltip: l10n.editAnimal,
                    onPressed: () {
                      _navigateToEditPage(context, state.animal);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocListener<LivestockBloc, LivestockState>(
          listener: (context, state) {
            if (state is LivestockDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.animalDeletedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state is LivestockUpdated) {
              context.read<LivestockBloc>().add(LoadLivestockDetail(id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.animalUpdatedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is LivestockError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.error}: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<LivestockBloc, LivestockState>(
            builder: (context, state) {
              if (state is LivestockLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LivestockError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.failedLoadDetails}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: () {
                          context.read<LivestockBloc>().add(LoadLivestockDetail(id));
                        },
                      ),
                    ],
                  ),
                );
              } else if (state is LivestockDetailLoaded) {
                final animal = state.animal;
                
                String formatNa(String? value) => value?.isNotEmpty == true ? value! : l10n.notApplicable;
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ⭐ HERO CARD - Primary Information
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [AppColors.primary.withOpacity(0.1), AppColors.surface],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppColors.primary.withOpacity(0.2),
                                    child: Text(
                                      animal.tagNumber.isNotEmpty ? animal.tagNumber[0] : '?',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          animal.tagNumber,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          animal.name ?? l10n.noName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  _buildChip(
                                    label: animal.status,
                                    icon: Icons.circle,
                                    color: animal.status.toLowerCase() == 'active' 
                                        ? Colors.green 
                                        : Colors.red,
                                  ),
                                  _buildChip(
                                    label: animal.species?.speciesName ?? 'Unknown',
                                    icon: Icons.pets,
                                    color: AppColors.primary,
                                  ),
                                  _buildChip(
                                    label: animal.sex,
                                    icon: animal.sex.toLowerCase() == 'male' 
                                        ? Icons.male 
                                        : Icons.female,
                                    color: AppColors.secondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ⭐ BASIC INFORMATION SECTION
                      _buildSectionCard(
                        title: l10n.basicInformation ?? 'Basic Information',
                        icon: Icons.info_outline,
                        children: [
                          _buildDetailRow(context, l10n.breed, animal.breed?.breedName ?? l10n.notSpecified),
                          _buildDetailRow(context, l10n.dateOfBirth, animal.dateOfBirth.toIso8601String().split('T').first),
                          _buildDetailRow(context, l10n.weightAtBirth, '${animal.weightAtBirthKg} kg'),
                        ],
                      ),

                      // ⭐ GENEALOGY SECTION
                      _buildSectionCard(
                        title: l10n.genealogy,
                        icon: Icons.family_restroom,
                        children: [
                          _buildDetailRow(
                            context,
                            l10n.sire,
                            formatNa(animal.sire?.tagNumber),
                            animal.sire?.name,
                          ),
                          _buildDetailRow(
                            context,
                            l10n.dam,
                            formatNa(animal.dam?.tagNumber),
                            animal.dam?.name,
                          ),
                        ],
                      ),

                      // ⭐ PURCHASE DETAILS SECTION
                      _buildSectionCard(
                        title: l10n.purchaseDetails,
                        icon: Icons.shopping_cart_outlined,
                        children: [
                          _buildDetailRow(
                            context,
                            l10n.purchaseDate,
                            animal.purchaseDate?.toIso8601String().split('T').first ?? l10n.notApplicable,
                          ),
                          _buildDetailRow(
                            context,
                            l10n.purchaseCost,
                            animal.purchaseCost != null 
                                ? 'TZS ${animal.purchaseCost!.toStringAsFixed(2)}' 
                                : l10n.notApplicable,
                          ),
                          _buildDetailRow(context, l10n.source, formatNa(animal.source)),
                        ],
                      ),

                      // ⭐ NOTES SECTION (if notes exist)
                      if (animal.notes?.isNotEmpty == true)
                        _buildSectionCard(
                          title: l10n.notes,
                          icon: Icons.note_outlined,
                          children: [
                            Text(
                              animal.notes!,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // ⭐ DELETE BUTTON
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.red[50],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red, size: 32),
                          title: Text(
                            l10n.deleteAnimal,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'This action cannot be undone',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
                          onTap: () => _showDeleteConfirmationDialog(
                            context,
                            animal.animalId,
                            animal.tagNumber,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  // Helper to build styled chips
  Widget _buildChip({required String label, required IconData icon, required Color color}) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}