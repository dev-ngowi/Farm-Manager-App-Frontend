// lib/features/farmer/livestock/presentation/pages/add_livestock_page.dart

import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/livestock_form.dart'; 

class AddLivestockPage extends StatelessWidget {
  const AddLivestockPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get localization instance
    final l10n = AppLocalizations.of(context)!;
    
    // Retrieve the repository instance from the locator
    final LivestockRepository livestockRepository = getIt<LivestockRepository>();
    
    return BlocProvider(
      create: (context) => getIt<LivestockBloc>(),
      child: Scaffold(
        // ⭐ L10N FIX: Use l10n key
        appBar: AppBar(title: Text(l10n.addNewLivestock)),
        body: BlocListener<LivestockBloc, LivestockState>(
          listener: (context, state) {
            if (state is LivestockAdded) { 
              ScaffoldMessenger.of(context).showSnackBar(
                // ⭐ L10N FIX: Use l10n key
                SnackBar(content: Text(l10n.animalAddedSuccess)),
              );
              context.pop();
            } else if (state is LivestockError) {
              ScaffoldMessenger.of(context).showSnackBar(
                // ⭐ L10N FIX: Use l10n key and state message
                SnackBar(content: Text('${l10n.submissionFailed} ${state.message}')),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: LivestockForm(livestockRepository: livestockRepository), 
          ),
        ),
      ),
    );
  }
}