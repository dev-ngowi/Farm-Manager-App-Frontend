// lib/features/auth/presentation/pages/role_selection_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';

class RoleSelectionPage extends StatelessWidget {
  static const String routeName = '/role-selection';
  static const _storage = FlutterSecureStorage(); // ← Make it static const

  const RoleSelectionPage({super.key}); // ← Add const constructor

  Future<void> _selectRole(BuildContext context, String role) async {
    await _storage.write(key: 'user_role', value: role);
    final route = switch (role) {
      'farmer' => '/farmer',
      'vet' => '/vet',
      'researcher' => '/researcher',
      _ => '/farmer',
    };
    if (context.mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                l10n.selectRole ?? 'Choose Your Role',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              _RoleCard(
                title: l10n.farmer ?? 'Farmer',
                icon: Icons.agriculture_outlined,
                color: AppColors.primary,
                onTap: () => _selectRole(context, 'farmer'),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                title: l10n.vet ?? 'Veterinarian',
                icon: Icons.local_hospital_outlined,
                color: AppColors.secondary,
                onTap: () => _selectRole(context, 'vet'),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                title: l10n.researcher ?? 'Researcher',
                icon: Icons.science_outlined,
                color: Colors.purple.shade600,
                onTap: () => _selectRole(context, 'researcher'),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }
}