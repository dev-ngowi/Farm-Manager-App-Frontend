import 'package:farm_manager_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/login_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/register_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/role_selection_page.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_manager_app/features/startup/presentation/pages/splash_page.dart';
import 'package:farm_manager_app/features/startup/presentation/pages/onboarding_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc
import 'package:farm_manager_app/features/auth/presentation/bloc/auth_bloc.dart'; // Import AuthBloc
import 'package:farm_manager_app/core/di/locator.dart'; // Import locator

final GoRouter router = GoRouter(
  initialLocation: SplashPage.routeName,
  routes: [
    GoRoute(
      path: SplashPage.routeName,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: OnboardingPage.routeName,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    // Login
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    // Role Selection route now requires AuthBloc from the locator/parent context
    GoRoute(
      path: '/role-selection',
      name: 'role-selection',
      builder: (context, state) {
        // We use BlocProvider.value and fetch the AuthBloc from the DI/context 
        // if it's not already available in the tree higher up.
        // It's safer to ensure the AuthBloc is provided higher in the tree after login success.
        return BlocProvider(
          create: (context) => getIt<AuthBloc>(), // Re-create or fetch new instance
          child: const RoleSelectionPage(),
        );
      },
    ),
    
  ],
);