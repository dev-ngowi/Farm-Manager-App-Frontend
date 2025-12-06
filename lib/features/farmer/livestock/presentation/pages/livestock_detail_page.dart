import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_event.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_state.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Assume this is the correct import path for generated localization class

class LivestockDetailPage extends StatelessWidget {
  final String animalId;

  const LivestockDetailPage({super.key, required this.animalId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final id = int.tryParse(animalId);
    
    if (id == null) {
      return Scaffold(
        // ⭐ L10N FIX: Use l10n key
        appBar: AppBar(title: Text(l10n.animalDetails)),
        // ⭐ L10N FIX: Use l10n key
        body: Center(child: Text(l10n.invalidAnimalId)),
      );
    }

    return BlocProvider(
      create: (context) => getIt<LivestockBloc>()..add(LoadLivestockDetail(id)),
      child: Scaffold(
        // ⭐ L10N FIX: Use l10n key and ID
        appBar: AppBar(title: Text('${l10n.animalDetails} (ID: $animalId)')),
        body: BlocBuilder<LivestockBloc, LivestockState>(
          builder: (context, state) {
            if (state is LivestockLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LivestockError) {
              // ⭐ L10N FIX: Use l10n key
              return Center(child: Text('${l10n.errorLoadingDetails} ${state.message}'));
            }
            if (state is LivestockDetailLoaded) {
              final animal = state.animal;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⭐ L10N FIX: Use l10n key
                    Text('${l10n.tagNumber} ${animal.tagNumber}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    // ⭐ L10N FIX: Use l10n key
                    Text('${l10n.name} ${animal.name ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                    const Divider(),
                    // ⭐ L10N FIX: Use l10n key
                    Text('${l10n.species} ${animal.species?.speciesName}', style: const TextStyle(fontSize: 16)),
                    // ⭐ L10N FIX: Use l10n key
                    Text('${l10n.breed} ${animal.breed?.breedName}', style: const TextStyle(fontSize: 16)),
                    // ⭐ L10N FIX: Use l10n key
                    Text('${l10n.sex} ${animal.sex}', style: const TextStyle(fontSize: 16)),
                    // ⭐ L10N FIX: Use l10n key
                    Text('${l10n.dateOfBirth} ${animal.dateOfBirth.toIso8601String().split('T').first}', style: const TextStyle(fontSize: 16)),
                    // ⭐ L10N FIX: Use l10n key
                    Text('${l10n.status} ${animal.status}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }
            // ⭐ L10N FIX: Use l10n key
            return Center(child: Text(l10n.selectAnimalDetails));
          },
        ),
      ),
    );
  }
}