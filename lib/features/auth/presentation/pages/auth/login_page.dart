// lib/features/auth/presentation/pages/auth/login_page.dart

import 'package:farm_manager_app/features/auth/presentation/pages/location/location_manager_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import 'role_selection_page.dart'; 

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _hasNavigated = false; // Flag to prevent multiple navigations

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper function to handle post-login navigation based on state
  void _handleLoginSuccess(AuthState state) {
    if (!mounted || _hasNavigated) return;

    final user = (state is AuthSuccess) ? state.user : null;
    if (user == null) return;

    final userRole = user.role;
    final hasLocation = user.hasLocation == true;
    
    _hasNavigated = true; // Set flag before navigation
    
    // 1. Check if user needs to select a role
    if (userRole.isEmpty || userRole.toLowerCase() == 'unassigned') {
      print('🔀 Login Success: Role unassigned, navigating to role selection');
      // Use pushReplacement or go to ensure clean history
      context.go(RoleSelectionPage.routeName); 
      return;
    } 
    
    // 2. Check if user needs to set a location
    if (!hasLocation) {
      print('🔀 Login Success: Location not set, navigating to location setup');
      context.go(LocationManagerPage.routeName);
      return;
    }
    
    // 3. Fully configured, redirect to appropriate dashboard
    final route = switch (userRole.toLowerCase()) {
      'farmer' => '/farmer/dashboard',
      'vet' => '/vet/dashboard',
      'researcher' => '/researcher/dashboard',
      _ => '/farmer/dashboard', // Default fallback
    };
    print('🔀 Login Success: Fully configured, navigating to dashboard: $route');
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Use BlocProvider here if not provided higher up the tree
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                Text(
                  l10n.login ?? 'Login',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),

                // Username / Email / Phone
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: l10n.username ?? 'Username / Email / Phone',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (v) => v?.isEmpty == true ? l10n.enterUsername ?? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password ?? 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v?.isEmpty == true ? l10n.enterPassword ?? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(ForgotPasswordPage.routeName),
                    child: Text(
                      l10n.forgotPassword ?? 'Forgot Password?',
                      style: const TextStyle(color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      _handleLoginSuccess(state);
                    } else if (state is AuthError) {
                      _hasNavigated = false; // Reset flag on error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _hasNavigated = false; // Reset flag before login
                                  context.read<AuthBloc>().add(LoginSubmitted(
                                    login: _usernameController.text.trim(),
                                    password: _passwordController.text,
                                  ));
                                }
                              },
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                l10n.login ?? 'Login',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.noAccount ?? "Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        _hasNavigated = false; // Reset flag when navigating away
                        context.push(RegisterPage.routeName);
                      },
                      child: Text(
                        l10n.signUp ?? 'Sign Up',
                        style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}