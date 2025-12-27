// lib/features/farmer/breeding/presentation/pages/offspring/offspring_detail_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/utils/breeding_colors.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OffspringDetailPage extends StatefulWidget {
  static const String routeName = 'offspring_detail';
  final dynamic offspringId;

  const OffspringDetailPage({super.key, required this.offspringId});

  @override
  State<OffspringDetailPage> createState() => _OffspringDetailPageState();
}

class _OffspringDetailPageState extends State<OffspringDetailPage> {
  dynamic _cachedOffspring;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OffspringBloc>()..add(LoadOffspringDetail(widget.offspringId)),
      child: OffspringDetailView(
        offspringId: widget.offspringId,
        cachedOffspring: _cachedOffspring,
        onOffspringLoaded: (offspring) {
          setState(() {
            _cachedOffspring = offspring;
          });
        },
      ),
    );
  }
}

class OffspringDetailView extends StatelessWidget {
  final dynamic offspringId;
  final dynamic cachedOffspring;
  final Function(dynamic) onOffspringLoaded;

  const OffspringDetailView({
    super.key,
    required this.offspringId,
    required this.cachedOffspring,
    required this.onOffspringLoaded,
  });

  void _loadDetails(BuildContext context) {
    context.read<OffspringBloc>().add(LoadOffspringDetail(offspringId));
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n, dynamic id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.confirmDelete ?? 'Confirm Delete',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          l10n.deleteOffspringConfirmation ?? 'Are you sure you want to delete this offspring record? This action cannot be undone.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel ?? 'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OffspringBloc>().add(DeleteOffspring(id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.delete ?? 'Delete',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
          icon: const Icon(Icons.arrow_back, color: BreedingColors.offspring),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.offspringDetails ?? 'Offspring Details',
          style: const TextStyle(
            color: BreedingColors.offspring,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (cachedOffspring != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: BreedingColors.offspring),
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/farmer/breeding/offspring/${offspringId}/edit');
                } else if (value == 'delete') {
                  _showDeleteDialog(context, l10n, offspringId);
                } else if (value == 'register') {
                  context.push('/farmer/breeding/offspring/${offspringId}/register');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'register',
                  child: Row(
                    children: [
                      Icon(Icons.badge, size: 20),
                      SizedBox(width: 12),
                      Text('Register as Livestock'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<OffspringBloc, OffspringState>(
        listener: (context, state) {
          if (state is OffspringDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.offspringDeletedSuccess ?? 'Offspring deleted successfully'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/farmer/breeding/offspring');
          } else if (state is OffspringError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: l10n.retry ?? 'Retry',
                  textColor: Colors.white,
                  onPressed: () => _loadDetails(context),
                ),
              ),
            );
          } else if (state is OffspringDetailLoaded) {
            onOffspringLoaded(state.offspring);
          }
        },
        builder: (context, state) {
          if ((state is OffspringLoading || state is OffspringInitial) && cachedOffspring == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading offspring details...'),
                ],
              ),
            );
          }

          if (state is OffspringError && cachedOffspring == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Details',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _loadDetails(context),
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

          if (cachedOffspring != null) {
            return _buildDetailsContent(context, l10n, theme);
          }

          return Center(child: Text(l10n.selectAnOffspring ?? 'Select an offspring'));
        },
      ),
    );
  }

  Widget _buildDetailsContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    // TODO: Replace with actual entity data
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      BreedingColors.offspring,
                      BreedingColors.offspring.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.child_care,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'TEMP-TAG-001',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.temporaryTag ?? 'Temporary Tag',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Pending Registration',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    l10n.gender ?? 'Gender',
                    'Female',
                    Icons.female,
                    Colors.pink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    l10n.weight ?? 'Weight',
                    '32.5 kg',
                    Icons.fitness_center,
                    BreedingColors.offspring,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.birthDetails ?? 'Birth Details',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: l10n.birthDate ?? 'Birth Date',
                  value: 'Data from API',
                  color: BreedingColors.offspring,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/farmer/breeding/offspring/${offspringId}/register');
                    },
                    icon: const Icon(Icons.badge),
                    label: Text(l10n.registerAsLivestock ?? 'Register as Livestock'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/farmer/breeding/offspring/${offspringId}/edit');
                          },
                          icon: const Icon(Icons.edit),
                          label: Text(l10n.edit ?? 'Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: BreedingColors.offspring,
                            side: const BorderSide(color: BreedingColors.offspring),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteDialog(context, l10n, offspringId),
                          icon: const Icon(Icons.delete),
                          label: Text(l10n.delete ?? 'Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}