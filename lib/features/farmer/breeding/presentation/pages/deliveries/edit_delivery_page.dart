import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/entities/delivery_entity.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_event.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_state.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/widgets/delivery_form.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditDeliveryPage extends StatefulWidget {
  static const String routeName = 'edit';
  final dynamic deliveryId;

  const EditDeliveryPage({
    super.key,
    required this.deliveryId,
  });

  @override
  State<EditDeliveryPage> createState() => _EditDeliveryPageState();
}

class _EditDeliveryPageState extends State<EditDeliveryPage> {
  DeliveryEntity? _loadedDelivery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => getIt<DeliveryBloc>()
        ..add(LoadDeliveryDetail(widget.deliveryId)),
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
            l10n.editDelivery ?? 'Edit Delivery',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocConsumer<DeliveryBloc, DeliveryState>(
          buildWhen: (previous, current) => 
            current is DeliveryLoading || 
            current is DeliveryDetailLoaded || 
            current is DeliveryError,
          listener: (context, state) {
            if (state is DeliveryDetailLoaded) {
              setState(() => _loadedDelivery = state.delivery);
            }

            if (state is DeliveryUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.deliveryUpdatedSuccess ?? 'Delivery updated successfully.',
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
              
              // FIXED: Navigate to detail page with updated ID
              // This will reload the detail page with fresh data
              context.go('/farmer/breeding/deliveries/${widget.deliveryId}');
            } else if (state is DeliveryError && _loadedDelivery != null) {
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
                              l10n.submissionFailed ?? 'Update Failed',
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
            // 1. Initial Loading State
            if (state is DeliveryLoading && _loadedDelivery == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            // 2. Error State (Initial Load Failed)
            if (state is DeliveryError && _loadedDelivery == null) {
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.read<DeliveryBloc>().add(LoadDeliveryDetail(widget.deliveryId)),
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

            // 3. Data Loaded State
            final delivery = _loadedDelivery;
            if (delivery == null) return const SizedBox.shrink();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER INFO CARD
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            child: const Icon(Icons.edit_calendar, color: AppColors.primary, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.editDeliveryDetails ?? 'Edit Delivery Details',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dam: ${delivery.damName} (${delivery.damTagNumber})',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // THE FORM
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DeliveryForm(deliveryToEdit: delivery),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FOOTER INFO
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.reviewChangesNote ?? 'Review all changes before submitting.',
                            style: TextStyle(fontSize: 13, color: Colors.blue[900]),
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