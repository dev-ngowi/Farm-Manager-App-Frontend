import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_manager_app/core/config/app_theme.dart';
import 'package:farm_manager_app/l10n/app_localizations.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Helper method to submit registration
  void _submitRegistration(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterSubmitted(
              firstname: _firstnameController.text.trim(),
              lastname: _lastnameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              // Pass empty string if email is empty, as per your previous logic
              email: _emailController.text.trim().isEmpty
                  ? ''
                  : _emailController.text.trim(),
              password: _passwordController.text,
              passwordConfirmation: _confirmPasswordController.text,
              // Ensures role selection screen opens after successful login
              role: 'unassigned',
            ),
          );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        // ⭐ CRITICAL FIX: Wrap the body content with BlocListener
        child: BlocListener<AuthBloc, AuthState>(
          // Listen only for success and error states
          listener: (context, state) {
            // ✅ FIX 1: Listen for the new AuthNavigateToLogin state
            if (state is AuthNavigateToLogin) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 4),
                ),
              );
              // ✅ FIX 2: Navigate to login after successful registration
              context.go(LoginPage.routeName);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.secondary),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      l10n.register ?? 'Create Account',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.registerSubtitle ??
                          'Fill in your details to get started.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),

                    // --- Form Fields ---
                    TextFormField(
                      controller: _firstnameController,
                      decoration: InputDecoration(
                        labelText: l10n.firstname ?? 'First Name',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) => v?.trim().isEmpty == true
                          ? l10n.firstnameRequired ?? 'First name required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastnameController,
                      decoration: InputDecoration(
                        labelText: l10n.lastname ?? 'Last Name',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) => v?.trim().isEmpty == true
                          ? l10n.lastnameRequired ?? 'Last name required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.phoneNumber ?? 'Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                        hintText: 'e.g. 0712345678',
                      ),
                      validator: (v) {
                        if (v?.trim().isEmpty == true)
                          return l10n.phoneRequired ?? 'Phone number required';
                        if (!RegExp(r'^0[67]\d{8}$').hasMatch(v!.trim())) {
                          return l10n.validPhone ??
                              'Enter valid TZ phone (07xxxxxxxx)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.email ?? 'Email (Optional)',
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'you@example.com',
                      ),
                      validator: (v) {
                        if (v?.isNotEmpty == true &&
                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(v!)) {
                          return l10n.validEmail ?? 'Enter valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: l10n.password ?? 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => v?.length == null || v!.length < 6
                          ? l10n.passwordLength ?? 'Password too short'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: l10n.confirmPassword ?? 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) => v != _passwordController.text
                          ? l10n.passwordMatch ?? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button + BLoC Builder
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: state is AuthLoading
                              ? null
                              : () => _submitRegistration(context),
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(l10n.signUp ?? 'Jisajili',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.haveAccount ?? 'Already have an account? '),
                        TextButton(
                          onPressed: () => context.push(LoginPage.routeName),
                          child: Text(
                            l10n.login ?? 'Login',
                            style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}