// lib/features/farmer/insemination/presentation/pages/insemination_detailed_page.dart

import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/insemination/edit_insemination_page.dart';

import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InseminationDetailPage extends StatelessWidget {
  final String recordId;

  const InseminationDetailPage({super.key, required this.recordId});

  void _navigateToEditPage(BuildContext context, InseminationEntity record) {
    context.pushNamed(
      EditInseminationPage.routeName,
      pathParameters: {'id': record.id.toString()},
      extra: record,
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, int id, String description) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmationTitle),
          content: Text(l10n.deleteConfirmationMessage(description)),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child:
                  Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<InseminationBloc>().add(DeleteInsemination(id));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      [String? secondaryValue]) {
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
                if (secondaryValue != null && secondaryValue.isNotEmpty)
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

  Widget _buildChip(
      {required String label, required IconData icon, required Color color}) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final id = int.tryParse(recordId);

    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.inseminationDetails)),
        body: Center(child: Text(l10n.invalidRecordId)),
      );
    }

    return BlocProvider(
      create: (context) =>
          getIt<InseminationBloc>()..add(LoadInseminationDetail(id)),
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
            l10n.inseminationDetails,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            BlocBuilder<InseminationBloc, InseminationState>(
              builder: (context, state) {
                if (state is InseminationDetailLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    tooltip: l10n.editRecord,
                    onPressed: () {
                      _navigateToEditPage(context, state.record);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocListener<InseminationBloc, InseminationState>(
          listener: (context, state) {
            if (state is InseminationDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.inseminationDeletedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state is InseminationUpdated) {
              context.read<InseminationBloc>().add(LoadInseminationDetail(id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.inseminationUpdatedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is InseminationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.error}: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<InseminationBloc, InseminationState>(
            builder: (context, state) {
              if (state is InseminationLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is InseminationError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.failedLoadDetails,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
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
                        label: Text(l10n.retry),
                        onPressed: () {
                          context
                              .read<InseminationBloc>()
                              .add(LoadInseminationDetail(id));
                        },
                      ),
                    ],
                  ),
                );
              } else if (state is InseminationDetailLoaded) {
                final record = state.record;
                final DateFormat formatter = DateFormat('dd MMM yyyy');

                String formatNa(String? value) =>
                    value?.isNotEmpty == true ? value! : l10n.notApplicable;
                String formatDate(DateTime? date) =>
                    date != null ? formatter.format(date) : l10n.notApplicable;

                Color statusColor;
                switch (record.status.toLowerCase()) {
                  case 'confirmed pregnant':
                    statusColor = Colors.green;
                    break;
                  case 'not pregnant':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.amber;
                    break;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HERO CARD - Primary Information
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.surface
                              ],
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
                                    backgroundColor:
                                        statusColor.withOpacity(0.2),
                                    child: Icon(
                                      Icons.pregnant_woman,
                                      color: statusColor,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.dam.tagNumber,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          '${l10n.animalName}: ${record.dam.name}',
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
                                    label: record.status,
                                    icon: Icons.circle,
                                    color: statusColor,
                                  ),
                                  _buildChip(
                                    label: record.breedingMethod,
                                    icon: Icons.repeat,
                                    color: record.breedingMethod == 'AI'
                                        ? AppColors.secondary
                                        : Colors.blueGrey,
                                  ),
                                  if (record.isPregnant)
                                    _buildChip(
                                      label:
                                          '${record.daysToDue} ${l10n.daysToDue}',
                                      icon: Icons.timer,
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // INSEMINATION EVENT DETAILS SECTION
                      _buildSectionCard(
                        title: l10n.inseminationEvent,
                        icon: Icons.date_range,
                        children: [
                          _buildDetailRow(
                            context,
                            l10n.inseminationDate,
                            formatDate(record.inseminationDate),
                          ),
                          _buildDetailRow(
                            context,
                            l10n.expectedDelivery,
                            formatDate(record.expectedDeliveryDate),
                          ),
                          _buildDetailRow(
                            context,
                            l10n.breedingMethod,
                            record.breedingMethod,
                          ),
                          if (record.notes?.isNotEmpty == true)
                            _buildDetailRow(context, l10n.notes, record.notes!),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ⭐ FIXED: SIRE/SEMEN DETAILS SECTION
                      _buildSectionCard(
                        title: l10n.sireInformation,
                        icon: Icons.male_outlined,
                        children: _buildSireInfoChildren(context, record, l10n),
                      ),

                      // PREGNANCY RESULT SECTION
                      _buildSectionCard(
                        title: l10n.pregnancyStatus,
                        icon: Icons.monitor_heart_outlined,
                        children: [
                          _buildDetailRow(
                            context,
                            l10n.isPregnant,
                            record.isPregnant ? l10n.yes : l10n.no,
                            record.isPregnant
                                ? '${l10n.daysToDue}: ${record.daysToDue}'
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // DELETE BUTTON
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.red[50],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.delete_forever,
                              color: Colors.red, size: 32),
                          title: Text(
                            l10n.deleteRecord,
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
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Colors.red, size: 16),
                          onTap: () => _showDeleteConfirmationDialog(
                            context,
                            record.id,
                            '${record.dam.tagNumber} on ${formatter.format(record.inseminationDate)}',
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

  // ⭐ NEW: Helper method to build sire info children
  List<Widget> _buildSireInfoChildren(
      BuildContext context, InseminationEntity record, AppLocalizations l10n) {
    // AI with semen
    if (record.breedingMethod == 'AI' && record.semen != null) {
      return [
        _buildDetailRow(
          context,
          l10n.bullName,
          record.semen!.bullName,
        ),
        _buildDetailRow(
          context,
          l10n.strawCode,
          record.semen!.strawCode,
          '${l10n.semenId}: ${record.semenId}',
        ),
      ];
    }

    // Natural with sire
    if (record.breedingMethod == 'Natural' && record.sire != null) {
      return [
        _buildDetailRow(
          context,
          l10n.sireTag,
          record.sire!.tagNumber,
        ),
        _buildDetailRow(
          context,
          l10n.sireName,
          record.sire!.name,
          '${l10n.sireId}: ${record.sireId}',
        ),
      ];
    }

    // No sire info available
    final bool noSireDataAtAll =
        record.sireId == null && record.semenId == null;
    return [
      Center(
        child: Text(
          noSireDataAtAll ? l10n.noSireInfo : l10n.sireInfoMissing,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: noSireDataAtAll ? Colors.grey[600] : Colors.red[400],
          ),
        ),
      ),
    ];
  }
}
