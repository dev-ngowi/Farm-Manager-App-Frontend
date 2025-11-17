import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_manager_app/features/startup/presentation/widgets/language_selector.dart';

class OnboardingPage extends StatelessWidget {
  static const String routeName = '/onboarding';
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Hero illustration
              Image.asset(
                'assets/images/onboarding_illustration.png',
                height: 240,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                l10n.welcomeTitle ?? 'Welcome to Farm Manager',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.welcomeSubtitle ??
                    'Keep livestock records, request vet services, and manage your farm offline.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),

              // Language Selector
              const LanguageSelector(),
              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'), // will be replaced later
                  child: Text(l10n.continueBtn ?? 'Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}