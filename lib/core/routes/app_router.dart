import 'package:farm_manager_app/features/auth/data/domain/entities/user_entity.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/auth/forgot_password_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/auth/login_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/auth/register_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/auth/role_selection_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/farmer/farmer_dashboard_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/location/location_manager_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/reseacher/reseacher_dashboard_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/vet/vet_dashboard_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/startup/presentation/pages/splash_page.dart';
import '../../features/startup/presentation/pages/onboarding_page.dart';


final GoRouter router = GoRouter(
  initialLocation: SplashPage.routeName,
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final targetPath = state.uri.path;

    // --- State Check ---
    final isLoggedIn = authState is AuthSuccess || authState is RoleAssigned;
    final UserEntity? user = isLoggedIn 
        ? (authState is AuthSuccess ? authState.user : (authState as RoleAssigned).user)
        : null;
    
    // --- Determine Role and Location Status ---
    final role = user?.role;
    final hasLocation = user?.hasLocation == true;

    // Determine the expected dashboard route based on role
    final expectedRoute = switch (role?.toLowerCase()) {
        'farmer' => '/farmer/dashboard',
        'vet' => '/vet/dashboard',
        'researcher' => '/researcher/dashboard',
        _ => '/farmer/dashboard', // Default fallback
    };


    // 1. Loading/Splash: Allow
    if (authState is AuthInitial || targetPath == SplashPage.routeName) {
      return null;
    }

    // 2. Not Logged In: Redirect to Login/Onboarding
    if (!isLoggedIn && ![
      '/login',
      '/register',
      '/forgot-password',
      '/onboarding',
      SplashPage.routeName,
    ].contains(targetPath)) {
      return '/login';
    }
    
    // 3. Fully Configured: Redirect away from config pages to dashboard
    // This is the CRITICAL fix: if the user now has a location, force them to the dashboard,
    // even if they were previously trying to access the location manager page.
    if (isLoggedIn && role != null && role != 'unassigned' && hasLocation) {
        // If the user is trying to access any auth/config page, redirect to their dashboard
        if (targetPath == '/login' || 
            targetPath == '/register' || 
            targetPath == '/forgot-password' ||
            targetPath == RoleSelectionPage.routeName || 
            targetPath == LocationManagerPage.routeName) {
            return expectedRoute; // Force redirect to dashboard
        }
        
        // Allow navigation (including to their expected dashboard or other app routes)
        return null;
    }


    // 4. Logged In, but Role Not Selected: Redirect to Role Selection
    if (isLoggedIn && (role == null || role == 'unassigned')) {
      // Allow navigation to Role Selection, otherwise redirect there.
      if (targetPath != RoleSelectionPage.routeName) {
        return RoleSelectionPage.routeName;
      }
      return null; // Stay on role selection
    }

    // 5. Logged In, Role Selected, but Location Not Set: Redirect to Location Manager
    if (isLoggedIn && role != null && role != 'unassigned' && !hasLocation) {
      // Allow navigation to Location Manager, otherwise redirect there.
      if (targetPath != LocationManagerPage.routeName) {
        return LocationManagerPage.routeName;
      }
      return null; // Stay on location manager
    }
    
    // Default: Allow navigation
    return null;
  },
  routes: [
    GoRoute(path: SplashPage.routeName, name: 'splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: OnboardingPage.routeName, name: 'onboarding', builder: (_, __) => const OnboardingPage()),

    GoRoute(path: '/login', name: 'login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', name: 'register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/forgot-password', name: 'forgot-password', builder: (_, __) => const ForgotPasswordPage()),

    GoRoute(
      path: RoleSelectionPage.routeName,
      name: 'role-selection',
      builder: (_, __) => const RoleSelectionPage(),
    ),

    GoRoute(
      path: LocationManagerPage.routeName,
      name: 'location-manager',
      builder: (_, __) => const LocationManagerPage(),
    ),

    // Role-based Dashboards
    GoRoute(path: '/farmer/dashboard', name: 'farmer-dashboard', builder: (_, __) => FarmerDashboardPage()),
    GoRoute(path: '/vet/dashboard', name: 'vet-dashboard', builder: (_, __) => VetDashboardPage()),
    GoRoute(path: '/researcher/dashboard', name: 'researcher-dashboard', builder: (_, __) => ResearcherDashboardPage()),
  ],
);