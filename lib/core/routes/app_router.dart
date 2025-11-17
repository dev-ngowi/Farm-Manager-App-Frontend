
import 'package:farm_manager_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/login_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/register_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/role_selection_page.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_manager_app/features/startup/presentation/pages/splash_page.dart';
import 'package:farm_manager_app/features/startup/presentation/pages/onboarding_page.dart';

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
    // Login will come next
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
    GoRoute(
      path: '/role-selection',
      name: 'role-selection',
      builder: (context, state) => const RoleSelectionPage(),
    ),
  ],
);
