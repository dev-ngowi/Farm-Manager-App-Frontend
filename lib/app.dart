import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/app_theme.dart';
import 'core/localization/language_provider.dart'; // Your provider
import 'core/routes/app_router.dart';

class FarmManagerApp extends StatelessWidget {
  const FarmManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp.router(
      title: 'Farm Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(context),
      locale: languageProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('sw'),
      ],
      routerConfig: router,
    );
  }
}