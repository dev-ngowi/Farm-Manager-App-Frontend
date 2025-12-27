// lib/features/farmer/breeding/presentation/pages/pregnancyCheck/check_detailed_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/pregnancyCheck/edit_pregnancy_check_page.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PregnancyCheckDetailPage extends StatelessWidget {
  static const String routeName = 'pregnancyCheckDetail';
  final String checkId;

  const PregnancyCheckDetailPage({
    super.key,
    required this.checkId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final id = int.tryParse(checkId) ?? 0;

    if (id == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.pregnancyCheckDetails ?? 'Pregnancy Check Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.invalidCheckId ?? 'Invalid Check ID',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.goBack ?? 'Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => getIt<PregnancyCheckBloc>()
        ..add(LoadPregnancyCheckDetail(id)),
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
            l10n.pregnancyCheckDetails ?? 'Pregnancy Check Details',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            BlocBuilder<PregnancyCheckBloc, PregnancyCheckState>(
              builder: (context, state) {
                if (state is PregnancyCheckDetailLoaded) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.primary),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.pushNamed(
                          EditPregnancyCheckPage.routeName,
                          pathParameters: {'id': checkId},
                        );
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 12),
                            Text(l10n.edit ?? 'Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 20, color: Colors.red),
                            const SizedBox(width: 12),
                            Text(
                              l10n.delete ?? 'Delete',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<PregnancyCheckBloc, PregnancyCheckState>(
          listener: (context, state) {
            if (state is PregnancyCheckDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.pregnancyCheckDeletedSuccess ?? 'Pregnancy check deleted successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop(true);
            } else if (state is PregnancyCheckError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is PregnancyCheckLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PregnancyCheckError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingData ?? 'Error Loading Data',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<PregnancyCheckBloc>()
                          .add(LoadPregnancyCheckDetail(id)),
                      child: Text(l10n.retry ?? 'Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is PregnancyCheckDetailLoaded) {
              return _buildDetailContent(context, state.check, l10n);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, dynamic check, AppLocalizations l10n) {
    final dateFormatter = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final resultColor = _getResultColor(check.result);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result Status Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [resultColor.withOpacity(0.1), resultColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    check.result.toLowerCase() == 'pregnant'
                        ? Icons.favorite
                        : Icons.heart_broken,
                    size: 48,
                    color: resultColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    check.result,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dam Information
          _buildInfoCard(
            l10n.damInformation ?? 'Dam Information',
            Icons.pets,
            [
              _buildInfoRow(l10n.name ?? 'Name', check.damName),
              _buildInfoRow(l10n.tagNumber ?? 'Tag Number', check.damTagNumber),
            ],
          ),

          const SizedBox(height: 16),

          // Check Details
          _buildInfoCard(
            l10n.checkDetails ?? 'Check Details',
            Icons.monitor_heart,
            [
              _buildInfoRow(l10n.checkDate ?? 'Check Date', dateFormatter.format(check.checkDate)),
              _buildInfoRow(l10n.method ?? 'Method', check.method),
              _buildInfoRow(l10n.result ?? 'Result', check.result),
              if (check.fetusCount != null)
                _buildInfoRow(l10n.fetusCount ?? 'Fetus Count', check.fetusCount.toString()),
              if (check.expectedDeliveryDate != null)
                _buildInfoRow(
                  l10n.expectedDeliveryDate ?? 'Expected Delivery',
                  dateFormatter.format(check.expectedDeliveryDate),
                ),
              if (check.vetName != null)
                _buildInfoRow(l10n.veterinarian ?? 'Veterinarian', check.vetName!),
            ],
          ),

          const SizedBox(height: 16),

          // Notes
          if (check.notes.isNotEmpty)
            _buildInfoCard(
              l10n.notes ?? 'Notes',
              Icons.note_alt_outlined,
              [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    check.notes,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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

  void _showDeleteDialog(BuildContext context, int id) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDelete ?? 'Confirm Delete'),
        content: Text(
          l10n.deleteCheckConfirmation ?? 'Are you sure you want to delete this pregnancy check? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PregnancyCheckBloc>().add(DeletePregnancyCheck(id));
            },
            child: Text(l10n.delete ?? 'Delete'),
          ),
        ],
      ),
    );
  }
}