// lib/features/vet_services/presentation/pages/vet_requests_page.dart
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:flutter/material.dart';

class VetRequestsPage extends StatelessWidget {
  static const String routeName = '/farmer/vet-services';

  const VetRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Vet Services', style: TextStyle(color: AppColors.primary)),
        leading: const BackButton(color: AppColors.primary),
      ),
      body: Center(
        child: Text(
          'Request Vet or Chat\nComing Soon',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}