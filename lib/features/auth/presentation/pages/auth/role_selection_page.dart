// lib/features/auth/presentation/pages/auth/role_selection_page.dart

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
    context.read<AuthBloc>().add(AssignRoleSubmitted(role: role));
  }

  // Navigation after successful role assignment
  void _navigateToNextStep(BuildContext context) {
    // Next step is always Location Setup if the role was just assigned.
    context.go(LocationManagerPage.routeName);
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
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          String? role;
          String? message;

          if (state is RoleAssigned) {
            role = state.role;
            message = "Hongera! Sasa wewe ni ${_getSwahiliRole(role)} 🎉";
            
            // 1. Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: role == 'Vet' ? AppColors.secondary : AppColors.primary,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            // 2. Navigate to the next required step
            _navigateToNextStep(context);

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
          
          // Determine the user's role and if a role is already set
          final currentRole = state is RoleAssigned
              ? state.role
              : (state is AuthSuccess ? state.user.role : null);
              
          final hasRole = currentRole != null && currentRole != 'unassigned';
          
          return SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        hasRole 
                          ? "Jukumu Lako Limechaguliwa" 
                          : l10n.selectRole ?? "Chagua Jukumu Lako",
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        hasRole
                            ? "Sasa unaweza kuendelea na hatua inayofuata ya kuweka eneo la shamba/huduma."
                            : l10n.selectRoleSubtitle ?? "Tafadhali chagua utakavyotumia app hii",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      Expanded(
                        child: ListView(
                          children: [
                            _RoleCard(
                              title: l10n.farmer ?? "Mkulima",
                              subtitle: "Farmer",
                              icon: Icons.agriculture_rounded,
                              color: AppColors.primary,
                              isSelected: currentRole == "Farmer",
                              isDisabled: isLoading || hasRole, // Disabled if loading OR already has a role
                              onTap: () => _assignRole(context, "Farmer"),
                            ),
                            const SizedBox(height: 24),
                            _RoleCard(
                              title: l10n.vet ?? "Daktari wa Mifugo",
                              subtitle: "Veterinarian",
                              icon: Icons.local_hospital_rounded,
                              color: AppColors.secondary,
                              isSelected: currentRole == "Vet",
                              isDisabled: isLoading || hasRole,
                              onTap: () => _assignRole(context, "Vet"),
                            ),
                            const SizedBox(height: 24),
                            _RoleCard(
                              title: l10n.researcher ?? "Mtafiti",
                              subtitle: "Researcher",
                              icon: Icons.science_rounded,
                              color: const Color(0xFF6A1B9A),
                              isSelected: currentRole == "Researcher",
                              isDisabled: isLoading || hasRole,
                              onTap: () => _assignRole(context, "Researcher"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Card(
                        elevation: 20,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 6),
                              const SizedBox(height: 24),
                              Text(
                                l10n.processing ?? "Inakamilisha...",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Card(
        elevation: isSelected ? 20 : 14,
        shadowColor: color.withOpacity(0.4),
        color: isSelected ? color.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: isDisabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: color.withOpacity(0.18),
                  child: Icon(icon, size: 64, color: color),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(subtitle, style: TextStyle(fontSize: 17, color: Colors.grey[700])),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 48)
                else if (!isDisabled)
                  Icon(Icons.arrow_forward_ios, color: color, size: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }
}