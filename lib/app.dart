// lib/app.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/app_theme.dart';
import 'core/localization/language_provider.dart';
import 'core/routes/app_router.dart';
import 'l10n/app_localizations.dart';

class FarmManagerApp extends StatelessWidget {
  const FarmManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Meneja wa Shamba',

      // Beautiful Theme with Your Colors
      theme: AppTheme.light(context),     // ← Fixed
      darkTheme: AppTheme.dark(context),  // ← Fixed (optional)
      themeMode: ThemeMode.light, 

      // Multi-Language Support (English & Swahili)
      locale: languageProvider.locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('sw'), // Swahili
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null) {
          for (var locale in supportedLocales) {
            if (deviceLocale.languageCode == locale.languageCode) {
              return deviceLocale;
            }
          }
        }
        return const Locale('sw'); // Default to Swahili (Tanzania)
      },

      // GoRouter Configuration
      routerConfig: router,

      // Optional: Custom Scroll Behavior for better UX
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),

      builder: (context, child) {
        return MediaQuery(
          // Prevent font scaling issues for better UX
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}