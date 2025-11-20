// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/core/localization/language_provider.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'app.dart'; // App widget yako yenye MaterialApp + GoRouter + Theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup Dependency Injection (getIt)
  await setupLocator();

  // 2. Load saved language (Swahili default)
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLocale();

  runApp(
    MultiProvider(
      providers: [
        // Language Provider (for English/Swahili switching)
        ChangeNotifierProvider(create: (_) => languageProvider),

        // AuthBloc – Global & Available Everywhere!
        // This fixes "Provider<AuthBloc> not found" error forever
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),

        // Ongeza blocs zingine hapa baadaye (FarmerBloc, VetBloc, etc.)
      ],
      child: const FarmManagerApp(),
    ),
  );
}