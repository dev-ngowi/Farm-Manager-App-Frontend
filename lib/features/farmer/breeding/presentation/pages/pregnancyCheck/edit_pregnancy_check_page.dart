import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/entities/pregnancy_check_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/pregnancy_check_form.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditPregnancyCheckPage extends StatefulWidget {
  static const String routeName = 'edit';
  final int checkId;

  const EditPregnancyCheckPage({
    super.key,
    required this.checkId,
  });

  @override
  State<EditPregnancyCheckPage> createState() => _EditPregnancyCheckPageState();
}

class _EditPregnancyCheckPageState extends State<EditPregnancyCheckPage> {
  PregnancyCheckEntity? _loadedCheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => getIt<PregnancyCheckBloc>()
        ..add(LoadPregnancyCheckDetail(widget.checkId)),
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
            l10n.editPregnancyCheck ?? 'Edit Pregnancy Check',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocConsumer<PregnancyCheckBloc, PregnancyCheckState>(
          listener: (context, state) {
            // Store the loaded check so it's not lost when dropdowns load
            if (state is PregnancyCheckDetailLoaded) {
              setState(() {
                _loadedCheck = state.check;
              });
            }

            if (state is PregnancyCheckUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.pregnancyCheckUpdatedSuccess ?? 'Pregnancy check updated successfully.',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              context.pop(state.check);
            } else if (state is PregnancyCheckError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.submissionFailed ?? 'Submission Failed',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              state.message,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          builder: (context, state) {
            // Show loading while fetching check details (only initially)
            if (state is PregnancyCheckLoading && _loadedCheck == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show error if loading failed and no check is loaded
            if (state is PregnancyCheckError && _loadedCheck == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorLoadingData ?? 'Error Loading Data',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<PregnancyCheckBloc>().add(
                            LoadPregnancyCheckDetail(widget.checkId),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry ?? 'Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Use the stored check data
            final check = _loadedCheck;

            // If check is still null, show loading
            if (check == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER CARD
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.editCheckDetails ?? 'Edit Pregnancy Check Details',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${check.damName} (${check.damTagNumber})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FORM CARD
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PregnancyCheckForm(
                        checkToEdit: check,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // INFO BOX
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.reviewChangesNote ?? 'All fields marked with * are required. Review all changes before submitting.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}