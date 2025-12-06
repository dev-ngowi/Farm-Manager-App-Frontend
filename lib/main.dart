import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/core/localization/language_provider.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_bloc.dart'; // <--- ADDED IMPORT

import 'app.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚡ Start initialization WITHOUT blocking
  final initFuture = setupLocator();

  runApp(
    FutureBuilder(
      future: initFuture,
      builder: (context, snapshot) {
        // Show splash screen while initializing
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _SplashScreen(),
          );
        }

        // Handle initialization errors
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _ErrorScreen(error: snapshot.error.toString()),
          );
        }

        // Once initialized, show the real app
        return MultiProvider(
          providers: [
            // Language Provider (loaded asynchronously in background)
            ChangeNotifierProvider(
              create: (_) => getIt<LanguageProvider>(),
            ),

            // AuthBloc – Global & Available Everywhere
            BlocProvider<AuthBloc>(
              create: (context) => getIt<AuthBloc>(),
            ),
            
            // SemenInventoryBloc - Global & Available Everywhere
            BlocProvider<SemenInventoryBloc>(
              create: (context) => getIt<SemenInventoryBloc>(),
            ),
            
            // ResearcherBloc - Global & Available Everywhere (FIXED)
            BlocProvider<ResearcherBloc>( // <--- ADDED BLOC PROVIDER
              create: (context) => getIt<ResearcherBloc>(),
            ),
          ],
          child: const FarmManagerApp(),
        );
      },
    ),
  );
}

/// ⚡ Fast splash screen (shown immediately)
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32), // Your primary green
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app icon/logo
            const Icon(
              Icons.agriculture,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            
            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App title
            const Text(
              'Meneja wa Shamba',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            const Text(
              'Livestock Management System',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen (shown if initialization fails)
class _ErrorScreen extends StatelessWidget {
  final String error;
  
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade700,
              ),
              const SizedBox(height: 24),
              Text(
                'Initialization Error',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart app (you may need to implement this)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}