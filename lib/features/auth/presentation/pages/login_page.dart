import 'package:farm_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/core/di/locator.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

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
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginSuccess(String? userRole) async {
    if (!mounted) return;

    // Check if user needs to select a role
    if (userRole == null || userRole.isEmpty || userRole.toLowerCase() == 'unassigned') {
      // User has no role assigned, redirect to role selection
      context.go('/role-selection');
    } else {
      // User has a role, redirect to appropriate dashboard
      final route = switch (userRole.toLowerCase()) {
        'farmer' => '/farmer/dashboard',
        'vet' => '/vet/dashboard',
        'researcher' => '/researcher/dashboard',
        _ => '/farmer/dashboard', // Default fallback
      };
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: Scaffold(
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
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle ?? 'Welcome back! Please enter your credentials.',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                        // Pass the user's role to determine navigation
                        _handleLoginSuccess(state.user.role);
                      } else if (state is AuthError) {
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
                        onPressed: () => context.push(RegisterPage.routeName),
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
      ),
    );
  }
}