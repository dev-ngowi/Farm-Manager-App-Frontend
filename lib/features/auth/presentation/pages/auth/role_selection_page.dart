import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/location/location_manager_page.dart';

class RoleSelectionPage extends StatelessWidget {
  static const String routeName = '/role-selection';
  const RoleSelectionPage({super.key});

  void _assignRole(BuildContext context, String role) {
    final state = context.read<AuthBloc>().state;
    final token = state is AuthSuccess ? state.user.token : null;

    if (token != null && token.isNotEmpty) {
      // ⭐ FIX: Pass the token to the event
      context.read<AuthBloc>().add(AssignRoleSubmitted(role: role, token: token));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Authentication error: Please re-login."),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  String _getSwahiliRole(String role) {
    return switch (role) {
      'Farmer' => 'Mkulima',
      'Vet' => 'Daktari wa Mifugo',
      'Researcher' => 'Mtafiti',
      _ => role,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Listen for AuthSuccess specifically triggered by the role assignment
          if (state is AuthSuccess &&
              state.message == "Role assigned successfully.") {
            final role = state.user.role ?? '';
            final message = "Hongera! Sasa wewe ni ${_getSwahiliRole(role)} 🎉";

            // 1. Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: role.toLowerCase() == 'vet'
                    ? AppColors.secondary
                    : AppColors.primary,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Navigate to the next required step (GoRouter redirect handles the actual path)
            context.go(LocationManagerPage.routeName);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade600,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          final user = state is AuthSuccess ? state.user : null;
          final currentRole = user?.role;
          final hasRole = currentRole != null && currentRole != 'unassigned';

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    l10n.selectRoleTitle ?? 'Who are you?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.selectRoleSubtitle ??
                        'Please choose the role that best describes your work.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (hasRole)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Current Role: ${currentRole!.toUpperCase()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Role Cards/Buttons
                  _RoleOption(
                    title: 'Farmer',
                    icon: Icons.grass,
                    subtitle:
                        l10n.roleFarmerDesc ?? 'Manages crops and livestock.',
                    isSelected: currentRole == 'Farmer',
                    onTap:
                        isLoading ? null : () => _assignRole(context, 'Farmer'),
                  ),
                  _RoleOption(
                    title: 'Vet',
                    icon: Icons.pets,
                    subtitle:
                        l10n.roleVetDesc ?? 'Provides animal health services.',
                    isSelected: currentRole == 'Vet',
                    onTap: isLoading ? null : () => _assignRole(context, 'Vet'),
                  ),
                  _RoleOption(
                    title: 'Researcher',
                    icon: Icons.science,
                    subtitle: l10n.roleResearcherDesc ??
                        'Studies agricultural practices.',
                    isSelected: currentRole == 'Researcher',
                    onTap: isLoading
                        ? null
                        : () => _assignRole(context, 'Researcher'),
                  ),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper Widget for role options (No Change)
class _RoleOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleOption({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.secondary : AppColors.primary;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : AppColors.secondary,
          width: isSelected ? 2.5 : 1,
        ),
      ),
      elevation: isSelected ? 4 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 36, color: color),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color)
            : ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size(80, 40),
                ),
                child: Text(l10n.select ?? 'Select',
                    style: const TextStyle(color: Colors.white)),
              ),
        onTap: onTap,
      ),
    );
  }
}