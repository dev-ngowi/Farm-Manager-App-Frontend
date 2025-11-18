import 'package:farm_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth_bloc.dart';

class RoleSelectionPage extends StatelessWidget {
  static const String routeName = '/role-selection';
  const RoleSelectionPage({super.key});

  void _assignRole(BuildContext context, String role) {
    // Triggers the BLoC to call the 'api/v1/assign-user-role' endpoint
    context.read<AuthBloc>().add(AssignRoleSubmitted(role: role));
  }

  // Helper to navigate to dashboard based on the assigned role
  void _navigateToDashboard(BuildContext context, String role) {
    final roleLower = role.toLowerCase();
    if (roleLower == 'farmer') {
      context.go('/farmer/dashboard');
    } else if (roleLower == 'vet') {
      context.go('/vet/dashboard');
    } else if (roleLower == 'researcher') {
      context.go('/researcher/dashboard');
    } else {
      // Fallback if the role is unexpected or empty
      context.go('/login'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // --- SUCCESS HANDLING: Role successfully assigned ---
          // NOTE: AuthSuccess state should contain the new User object with the updated role
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.roleAssigned ?? "Role set successfully!"),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
            _navigateToDashboard(context, state.user.role);
          } 
          
          // --- ERROR HANDLING ---
          else if (state is AuthError) {
            
            String displayMessage = state.message;
            
            if (state.message.contains('Invalid role selected')) {
                 displayMessage = l10n.validationError ?? "Invalid role selected. Please try again.";
            } 
            else if (state.message.contains('No internet connection')) {
                 displayMessage = l10n.networkError ?? "No internet connection. Please check your network.";
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(displayMessage),
                backgroundColor: AppColors.secondary,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        l10n.selectRole ?? "Chagua Jukumu Lako",
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.selectRoleSubtitle ?? "Tafadhali chagua utakavyotumia app hii",
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
                              icon: Icons.agriculture_outlined,
                              color: AppColors.primary,
                              onTap: isLoading ? null : () => _assignRole(context, "Farmer"),
                            ),
                            const SizedBox(height: 24),
                            _RoleCard(
                              title: l10n.vet ?? "Daktari wa Mifugo",
                              subtitle: "Veterinarian",
                              icon: Icons.local_hospital_outlined,
                              color: AppColors.secondary,
                              onTap: isLoading ? null : () => _assignRole(context, "Vet"),
                            ),
                            const SizedBox(height: 24),
                            _RoleCard(
                              title: l10n.researcher ?? "Mtafiti",
                              subtitle: "Researcher",
                              icon: Icons.science_outlined,
                              color: const Color(0xFF6A1B9A),
                              onTap: isLoading ? null : () => _assignRole(context, "Researcher"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  // Loading Overlay
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Card(
                        elevation: 15,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 6,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.creatingAccount ?? "Inaunda akaunti yako...",
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
  final VoidCallback? onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.6 : 1.0,
      child: Card(
        elevation: 14,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
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
                Icon(Icons.arrow_forward_ios, color: color, size: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }
}