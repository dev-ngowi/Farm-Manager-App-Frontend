import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/locator.dart';
import 'core/localization/language_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup DI
  await setupLocator();

  // Default language: Swahili (TZ)
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => languageProvider),
      ],
      child: const FarmManagerApp(),
    ),
  );
}