import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/core/localization/language_provider.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_bloc.dart';
import 'package:farm_manager_app/core/networking/network_info.dart';

import 'app.dart';

void main() async {
  // 1. Ensure bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Check Internet (Optional: If you want to block app entry without net)
    final networkInfo = NetworkInfoImpl();
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      runApp(const _StaticErrorApp(type: _ErrorType.noInternet));
      return;
    }

    // 3. Setup Locator (Service Injection)
    await setupLocator();

    // 4. Run the actual App
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => getIt<LanguageProvider>()),
          BlocProvider<AuthBloc>(create: (context) => getIt<AuthBloc>()),
          BlocProvider<SemenInventoryBloc>(create: (context) => getIt<SemenInventoryBloc>()),
          BlocProvider<ResearcherBloc>(create: (context) => getIt<ResearcherBloc>()),
        ],
        child: const FarmBondApp(),
      ),
    );
  } catch (e) {
    runApp(_StaticErrorApp(type: _ErrorType.initError, message: e.toString()));
  }
}

/// --- Simple Error Handling if Init Fails ---

enum _ErrorType { noInternet, initError }

class _StaticErrorApp extends StatelessWidget {
  final _ErrorType type;
  final String? message;
  const _StaticErrorApp({required this.type, this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == _ErrorType.noInternet ? Icons.wifi_off : Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  type == _ErrorType.noInternet 
                      ? "No Internet Connection" 
                      : "Initialization Failed",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(message!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => main(), // Restarts the main function
                  child: const Text("Retry"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}