// lib/app_router.dart

import 'package:farm_manager_app/features/auth/presentation/pages/auth/forgot_password_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/auth/login_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/auth/register_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/auth/role_selection_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/entities/insemination_entity.dart';
import 'package:farm_manager_app/features/farmer/dashboard/presentation/pages/farmer_dashboard_page.dart';
import 'package:farm_manager_app/features/farmer/dashboard/presentation/pages/farmerDetailed/farmer_details_form_page.dart';
import 'package:farm_manager_app/features/auth/presentation/pages/location/location_manager_page.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/entities/livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/pages/edit_livestock_page.dart';
import 'package:farm_manager_app/features/reseacher/presentation/pages/dashboard/reseacher_dashboard_page.dart';
import 'package:farm_manager_app/features/reseacher/presentation/pages/reseacher_await_approval_page.dart';
import 'package:farm_manager_app/features/vet/presentation/pages/vet_dashboard_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/HeatCycle/add_heat_cycle_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/HeatCycle/heat_cycle_details_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/SemenInventory/add_semen_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/SemenInventory/edit_semen_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/SemenInventory/semen_detailed_page.dart';
// Breeding Feature Imports
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/breeding_dashboard_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/HeatCycle/heat_cycles_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/deliveries/add_delivery_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/deliveries/delivery_detail_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/deliveries/edit_delivery_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/insemination/add_insemination_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/insemination/edit_insemination_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/insemination/insemination_detailed_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/lactation/add_lactation_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/lactation/edit_lactation_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/lactation/lactation_list_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/lactation/show_lactation_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/offspring/add_offspring_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/offspring/edit_offspring_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/offspring/offspring_detail_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/offspring/offspring_list_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/SemenInventory/semen_inventory_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/insemination/inseminations_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/offspring/register_offspring_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/pregnancyCheck/add_pregnancy_check_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/pregnancyCheck/check_detailed_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/pregnancyCheck/edit_pregnancy_check_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/pregnancyCheck/pregnancy_checks_page.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/pages/deliveries/deliveries_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/Diagnoses/diagnoses_list_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/Diagnoses/diagnosis_details_cubit.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/Diagnoses/diagnosis_details_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/Diagnoses/diagnosis_list_cubit.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/healthReport/add_health_report_cubit.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/healthReport/add_health_report_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/healthReport/edit_health_report_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/healthReport/health_report_details_cubit.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/healthReport/health_report_details_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/healthReport/health_report_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/healthReport/health_report_update_cubit.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/treatment/overdue_treatments_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/treatment/treatment_details_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/treatment/treatments_list_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/vaccination/vaccination_detail_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/vaccination/vaccination_list_page.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
// Livestock Feature Imports
import 'package:farm_manager_app/features/farmer/livestock/presentation/pages/add_livestock_page.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/pages/livestock_detail_page.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/pages/livestock_list_page.dart';
// Other Farmer Feature Imports
import 'package:farm_manager_app/features/farmer/financial/presentation/pages/financial_dashboard_page.dart';
import 'package:farm_manager_app/features/farmer/health/presentation/pages/health_records_page.dart';
import 'package:farm_manager_app/features/farmer/reports/presentation/pages/reports_page.dart';
import 'package:farm_manager_app/features/farmer/vet_services/presentation/pages/vet_requests_page.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_bloc.dart';
// Other Role Imports
import 'package:farm_manager_app/features/reseacher/presentation/pages/reseacher_detailes_form_page.dart';
import 'package:farm_manager_app/features/vet/presentation/pages/details/vet_details_form_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/domain/entities/user_entity.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth/auth_state.dart';
import '../../features/startup/presentation/pages/onboarding_page.dart';
import '../../features/startup/presentation/pages/splash_page.dart';

class AppRoutes {
  // Public Routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Configuration
  static const String roleSelection = '/role-selection';
  static const String locationManager = '/location-manager';
  static const String farmerDetailsForm = '/farmer-details';
  static const String vetDetailsForm = '/vet-details';
  static const String researcherDetailsForm =
      '/researcher-details'; // Renamed for consistency
  static const String researcherAwaitingApproval =
      '/researcher/awaiting-approval';
  static const String vetAwaitingApproval =
      '/vet/awaiting-approval'; // 🎯 NEW Route

  // Farmer Main Routes (Sidebar Menu)
  static const String farmerDashboard = '/farmer/dashboard';

  // Livestock
  static const String livestock = '/farmer/livestock';
  static const String livestockDetail = '/farmer/livestock/detail/:animalId';
  static const String addLivestock = '/farmer/livestock/add';
  static const String editLivestock = '/farmer/livestock/edit/:animalId';

  // Breeding Module Routes (Base: /farmer/breeding)
  static const String breeding = '/farmer/breeding'; // Breeding Dashboard base
  static const String heatCycles = '/farmer/breeding/heat-cycles';
  static const String heatCycleDetails =
      '/farmer/breeding/heat-cycles/:heatCycleId';
  static const String addHeatCycle = '/farmer/breeding/heat-cycles/add';
  static const String semen = '/farmer/breeding/semen';
  static const String inseminations = '/farmer/breeding/inseminations';
  static const String pregnancyChecks = '/farmer/breeding/pregnancy-checks';
  static const String deliveries = '/farmer/breeding/deliveries';
  static const String offspring = '/farmer/breeding/offspring';
  static const String lactations = '/farmer/breeding/lactations';

  static const String vetServices = '/farmer/vet-services';
  static const String health = '/farmer/health';
  static const String finance = '/farmer/finance';
  static const String reports = '/farmer/reports';

  // Other Roles
  static const String vetDashboard = '/vet/dashboard';
  static const String researcherDashboard = '/researcher/dashboard';
}

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final targetPath = state.uri.path;

    final isLoggedIn = authState is AuthSuccess;
    final UserEntity? user = authState is AuthSuccess ? authState.user : null;
    final role = user?.role.toLowerCase();
    final hasLocation = user?.hasLocation == true;
    final hasCompletedDetails = user?.hasCompletedDetails == true;
    // 🎯 NEW: Get the approval status flag
    final hasDetailsApproved = user?.hasDetailsApproved == true;

    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
    ];

    final configRoutes = [
      AppRoutes.roleSelection,
      AppRoutes.locationManager,
      AppRoutes.farmerDetailsForm,
      AppRoutes.vetDetailsForm,
      AppRoutes.researcherDetailsForm, // Using corrected constant
      AppRoutes.researcherAwaitingApproval,
      AppRoutes.vetAwaitingApproval, // 🎯 NEW CONFIG ROUTE
    ];

    print('🔀 Router Redirect Check:');
    print('   Target: $targetPath');
    print('   Logged In: $isLoggedIn');
    print('   Role: $role');
    print('   Has Location: $hasLocation');
    print('   Has Details: $hasCompletedDetails');
    print('   Has Details Approved: $hasDetailsApproved'); // 🎯 NEW Log

    // 1. Allow splash always
    if (targetPath == AppRoutes.splash || authState is AuthInitial) {
      return null;
    }

    // Handle successful registration redirect
    if (authState is AuthNavigateToLogin && targetPath == AppRoutes.register) {
      return AppRoutes.login;
    }

    // 2. Not logged in → force login
    if (!isLoggedIn) {
      return publicRoutes.contains(targetPath) ? null : AppRoutes.login;
    }

    // --- LOGGED IN (AuthSuccess) FLOW ---

    // 3. Role not selected
    if (role == null || role.isEmpty || role == 'unassigned') {
      print('   → Redirecting to role selection');
      return targetPath == AppRoutes.roleSelection
          ? null
          : AppRoutes.roleSelection;
    }

    // 4. Location not set (Second step)
    if (!hasLocation) {
      print('   → Redirecting to location manager');
      return targetPath == AppRoutes.locationManager
          ? null
          : AppRoutes.locationManager;
    }

    // 5. Details not completed or Awaiting Approval (Third and Fourth steps)

    // Determine the details form route
    final detailsRoute = switch (role) {
      'farmer' => AppRoutes.farmerDetailsForm,
      'vet' => AppRoutes.vetDetailsForm,
      'researcher' => AppRoutes.researcherDetailsForm,
      _ => AppRoutes.farmerDetailsForm,
    };

    // Determine the awaiting approval route
    final awaitingRoute = switch (role) {
      'vet' => AppRoutes.vetAwaitingApproval,
      'researcher' => AppRoutes.researcherAwaitingApproval,
      _ => null, // Farmer does not have an approval stage
    };

    // --- Core Details/Approval Logic ---
    if (!hasCompletedDetails) {
      // User must fill details
      if (targetPath != detailsRoute) {
        print('   → Redirecting to details form: $detailsRoute');
        return detailsRoute;
      }
      return null; // Allow access to the details form
    }

    // Now hasCompletedDetails is TRUE

    // Handle Awaiting Approval or Final Dashboard for Vet/Researcher
    if (awaitingRoute != null) {
      if (!hasDetailsApproved) {
        // Details completed, but not approved
        if (targetPath != awaitingRoute) {
          print('   → Redirecting to Awaiting Approval: $awaitingRoute');
          return awaitingRoute;
        }
        return null; // Allow access to Awaiting Approval page
      } else {
        // Details completed AND approved
        if (targetPath == detailsRoute || targetPath == awaitingRoute) {
          // Redirect away from config pages to dashboard
          final dashboard = switch (role) {
            'vet' => AppRoutes.vetDashboard,
            'researcher' => AppRoutes.researcherDashboard,
            _ => AppRoutes.farmerDashboard,
          };
          print('   → Details Approved, redirecting to dashboard: $dashboard');
          return dashboard;
        }
      }
    }

    // 6. User fully configured (or farmer/approved vet/researcher)

    // Standard dashboard redirect for other roles (Farmer, Approved Vet/Researcher)
    final dashboard = switch (role) {
      'farmer' => AppRoutes.farmerDashboard,
      'vet' => AppRoutes.vetDashboard,
      'researcher' => AppRoutes.researcherDashboard,
      _ => AppRoutes.farmerDashboard,
    };

    if (publicRoutes.contains(targetPath) ||
        configRoutes.contains(targetPath) && targetPath != dashboard) {
      print('   → User fully configured, redirecting to dashboard: $dashboard');
      return dashboard;
    }

    print('   → No redirect needed');
    return null;
  },
  routes: [
    // Startup
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
    GoRoute(
        path: AppRoutes.onboarding, builder: (_, __) => const OnboardingPage()),

    // Auth
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
    GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterPage()),
    GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage()),

    // Configuration
    GoRoute(
        path: AppRoutes.roleSelection,
        builder: (_, __) => const RoleSelectionPage()),
    GoRoute(
        path: AppRoutes.locationManager,
        builder: (_, __) => const LocationManagerPage()),

    // Details Forms
    GoRoute(
        path: AppRoutes.farmerDetailsForm,
        builder: (_, __) => const FarmerDetailsFormPage()),

    // VET DETAILS
    GoRoute(
      path: AppRoutes.vetDetailsForm,
      builder: (_, __) => const VetDetailsFormPage(),
    ),
    // GoRoute(
    //   path: AppRoutes.vetAwaitingApproval, // 🎯 NEW ROUTE
    //   name: 'vet-awaiting-approval',
    //   builder: (_, __) => const VetAwaitingApprovalPage(), // Placeholder page
    // ),

    // RESEARCHER DETAILS
    GoRoute(
      path: AppRoutes.researcherDetailsForm, // Using corrected constant
      builder: (_, __) => BlocProvider<ResearcherBloc>(
        create: (context) => GetIt.instance<ResearcherBloc>(),
        child: const ResearcherDetailsFormPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.researcherAwaitingApproval,
      name: 'researcher-awaiting-approval',
      builder: (_, __) => BlocProvider<ResearcherBloc>(
        create: (context) => GetIt.instance<ResearcherBloc>(),
        child: const ResearcherAwaitingApprovalPage(),
      ),
    ),

    // Farmer Dashboard & Features
    GoRoute(
      path: AppRoutes.farmerDashboard,
      name: 'farmer-dashboard',
      builder: (_, __) => const FarmerDashboardScreen(),
    ),

    GoRoute(
      path: AppRoutes.livestock,
      name: 'livestock',
      builder: (_, __) => const LivestockListPage(),
      routes: [
        GoRoute(
          path: 'detail/:animalId',
          name: 'livestock-detail',
          builder: (context, state) {
            // Ensure animalId is parsed as an int if needed, though here it's passed as a String
            final animalId = state.pathParameters['animalId']!;
            return LivestockDetailPage(
              animalId: animalId,
            );
          },
        ),
        GoRoute(
          path: 'add',
          name: 'add-livestock',
          builder: (context, state) => const AddLivestockPage(),
        ),
        // ⭐ NEW: Edit Livestock Route
        GoRoute(
          path: 'edit/:animalId',
          name: 'edit-livestock',
          builder: (context, state) {
            final animalId = state.pathParameters['animalId']!;
            final animal = state.extra as LivestockEntity?;
            return EditLivestockPage(
              animalId: animalId,
              animal: animal,
            );
          },
        ),
      ],
    ),

    // 2. Breeding Routes (Base: /farmer/breeding)
    GoRoute(
      path: AppRoutes.breeding,
      name: 'breeding-dashboard',
      builder: (_, __) => const BreedingDashboardPage(),
      routes: [
        GoRoute(
          path: 'semen', // Path: /farmer/breeding/semen
          name: 'semen-inventory',
          builder: (context, state) => const SemenInventoryPage(),
          routes: [
            // 1. Add Semen Page (Path: /farmer/breeding/semen/add)
            GoRoute(
              path: 'add',
              name: 'add-semen',
              builder: (context, state) {
                // Must be wrapped with required BlocProviders (e.g., SemenBloc, BreedBloc)
                return const AddSemenPage();
              },
            ),

            // 2. Semen Detail Page (Parent for detail, edit, and logical delete context)
            GoRoute(
              path:
                  ':semenId', // Uses a path parameter to identify the specific straw
              name: 'semen-detail',
              builder: (context, state) {
                final semenId = state.pathParameters['semenId']!;
                // Must be wrapped with required BlocProviders (e.g., SemenBloc)
                return SemenDetailPage(semenId: semenId);
              },
              routes: [
                // 3. Edit Semen Page (Path: /farmer/breeding/semen/:semenId/edit)
                GoRoute(
                  path: 'edit',
                  name: 'edit-semen',
                  builder: (context, state) {
                    // 1. Extract the 'semenId' path parameter from the state
                    final semenId = state.pathParameters['semenId']!;

                    // 2. Return the actual EditSemenPage, passing the semenId
                    return EditSemenPage(semenId: semenId);
                  },
                ),
              ],
            ),
          ],
        ),
     // Inseminations Module
GoRoute(
  path: 'inseminations',
  name: InseminationListPage.routeName,
  builder: (context, state) => const InseminationListPage(),
  routes: [
    // Add new insemination
    GoRoute(
      path: 'add',
      name: AddInseminationPage.routeName,
      builder: (context, state) => const AddInseminationPage(),
    ),

    // View detail: /farmer/inseminations/123
    GoRoute(
      path: ':id',
      name: 'inseminationDetail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return InseminationDetailPage(recordId: id);
      },
      routes: [
        // Edit: /farmer/inseminations/123/edit
        GoRoute(
          path: 'edit',
          name: EditInseminationPage.routeName,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final record = state.extra as InseminationEntity?;

            if (record == null) {
              // Safety fallback
              context.pop();
              return const SizedBox.shrink();
            }

            return EditInseminationPage(
              recordId: id, record: record);
          },
        ),
      ],
    ),
  ],
),
        // Pregnancy Checks Module
        GoRoute(
          path: 'pregnancy-checks',
          name: PregnancyChecksPage.routeName, // Use the static routeName
          builder: (context, state) => const PregnancyChecksPage(),
          routes: [
            // 1. Detail Page (View single check by ID)
            GoRoute(
              // Path: /farmer/breeding/pregnancy-checks/:id
              path: ':id',
              name: PregnancyCheckDetailPage.routeName,
              builder: (context, state) {
                final checkId =
                    int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
                return PregnancyCheckDetailPage(checkId: checkId);
              },
              routes: [
                // 1b. Edit Page (Nested under detail)
                GoRoute(
                  // Path: /farmer/breeding/pregnancy-checks/:id/edit
                  path: 'edit',
                  name: EditPregnancyCheckPage.routeName,
                  builder: (context, state) {
                    final checkId =
                        int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
                    return EditPregnancyCheckPage(checkId: checkId);
                  },
                ),
              ],
            ),
            // 2. Add Page (New Check)
            GoRoute(
              // Path: /farmer/breeding/pregnancy-checks/add
              path: 'add',
              name: AddPregnancyCheckPage.routeName,
              builder: (context, state) => const AddPregnancyCheckPage(),
            ),
          ],
        ),
        // Deliveries Module
        GoRoute(
          path: 'deliveries',
          name: 'deliveries',
          builder: (context, state) => const DeliveriesPage(),
          routes: [
            // Child Route 1: Add Delivery Page
            // Path: /farmer/breeding/deliveries/add
            GoRoute(
              path: 'add',
              name: 'addDelivery',
              builder: (context, state) => const AddDeliveryPage(),
            ),

            // Child Route 2: Edit Delivery Page
            // Path: /farmer/breeding/deliveries/:id/edit
            GoRoute(
              path: ':id/edit',
              name: 'editDelivery',
              builder: (context, state) {
                // Ensure 'id' is extracted and converted to an integer
                final id = state.pathParameters['id'];
                final deliveryId = int.tryParse(id ?? '') ?? 0;
                return EditDeliveryPage(deliveryId: deliveryId);
              },
            ),

            // Child Route 3: Delivery Detail Page (Must come last to prevent ':id' from matching 'add')
            // Path: /farmer/breeding/deliveries/:id
            GoRoute(
              path: ':id',
              name: 'deliveryDetail',
              builder: (context, state) {
                // Ensure 'id' is extracted and converted to an integer
                final id = state.pathParameters['id'];
                final deliveryId = int.tryParse(id ?? '') ?? 0;
                return DeliveryDetailPage(deliveryId: deliveryId);
              },
            ),
          ],
        ),
        // Offspring Module
        GoRoute(
          path: 'offspring',
          name: 'offspring',
          builder: (context, state) => const OffspringPage(),
          routes: [
            // /offspring/store (Add Page)
            GoRoute(
              path: 'store',
              name: 'add_offspring',
              builder: (context, state) => const AddOffspringPage(),
            ),
            // /offspring/:id (Detail Page)
            GoRoute(
              path: ':id',
              name: 'offspring_detail',
              builder: (context, state) {
                final offspringId =
                    int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return OffspringDetailPage(offspringId: offspringId);
              },
              routes: [
                // /offspring/:id/edit (Edit Page)
                GoRoute(
                  path: 'edit',
                  name: 'edit_offspring',
                  builder: (context, state) {
                    final offspringId =
                        int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                    return EditOffspringPage(offspringId: offspringId);
                  },
                ),
                // /offspring/:id/register (Registration Page)
                GoRoute(
                  path: 'register',
                  name: 'register_offspring',
                  builder: (context, state) {
                    final offspringId =
                        int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                    // Note: Offspring ID is passed for context during registration
                    return RegisterOffspringPage(offspringId: offspringId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Lactations Module
        GoRoute(
          path: 'lactations',
          name: 'lactations',
          builder: (context, state) => const LactationsPage(),
          routes: [
            // Add Lactation Page (Path: /farmer/breeding/lactations/add)
            GoRoute(
              path: 'add',
              name: 'add-lactation',
              builder: (context, state) => const AddLactationPage(),
            ),
            // Detail/Show Lactation Page (Path: /farmer/breeding/lactations/:id/show)
            GoRoute(
              path: ':id/show',
              name: 'show-lactation',
              builder: (context, state) {
                final idString = state.pathParameters['id'];
                final lactationId = int.tryParse(idString ?? '') ?? 0;
                return ShowLactationPage(lactationId: lactationId);
              },
            ),
            // Edit Lactation Page (Path: /farmer/breeding/lactations/:id/edit)
            GoRoute(
              path: ':id/edit',
              name: 'edit-lactation',
              builder: (context, state) {
                final idString = state.pathParameters['id'];
                final lactationId = int.tryParse(idString ?? '') ?? 0;
                return EditLactationPage(lactationId: lactationId);
              },
            ),
          ],
        ),
      ],
    ),

    // 3. Heat Cycles Routes (FLATTENED - Outside nested routes)
    // Heat Cycles List
    GoRoute(
      path: AppRoutes.heatCycles,
      name: 'heat-cycles',
      builder: (context, state) {
        return BlocProvider<HeatCycleBloc>(
          create: (context) => GetIt.instance<HeatCycleBloc>(),
          child: const HeatCyclesPage(),
        );
      },
    ),

    // Add Heat Cycle
    GoRoute(
      path: AppRoutes.addHeatCycle,
      name: 'add-heat-cycle',
      builder: (context, state) {
        // 💡 FIX: Use MultiBlocProvider to provide both required BLoCs
        return MultiBlocProvider(
          providers: [
            // 1. HeatCycleBloc (for saving the heat cycle)
            BlocProvider<HeatCycleBloc>(
              create: (context) => GetIt.instance<HeatCycleBloc>(),
            ),
            // 2. LivestockBloc (for loading the animal list dropdown)
            BlocProvider<LivestockBloc>(
              create: (context) => GetIt.instance<LivestockBloc>(),
            ),
          ],
          child: const AddHeatCyclePage(),
        );
      },
    ),

    // Heat Cycle Details
    GoRoute(
      path: AppRoutes.heatCycleDetails,
      name: 'heat-cycle-details',
      builder: (context, state) {
        final heatCycleId = state.pathParameters['heatCycleId']!;
        return BlocProvider<HeatCycleBloc>(
          create: (context) => GetIt.instance<HeatCycleBloc>(),
          child: HeatCycleDetailsPage(heatCycleId: heatCycleId),
        );
      },
    ),

    // Other Farmer Routes
    GoRoute(
      path: AppRoutes.vetServices,
      name: 'vet-services',
      builder: (_, __) => const VetRequestsPage(),
    ),
    // Health Module - FULLY NESTED & COMPLETE
    GoRoute(
      path: AppRoutes.health,
      name: 'health-dashboard',
      builder: (_, __) => const HealthDashboardPage(),
      routes: [
        // Reports
        GoRoute(
          path: 'reports',
          name: 'health-reports',
          builder: (_, __) => BlocProvider(
            create: (context) => HealthReportsCubit(),
            child: const HealthReportsPage(),
          ),
          routes: [
            // GoRoute(
            //     path: 'high',
            //     name: 'high-priority-reports',
            //     builder: (_, __) => const HighPriorityReportsPage()),
            GoRoute(
              path: ':healthId', // This captures the dynamic ID (e.g., '1')
              name: 'health-report-details',
              builder: (context, state) {
                // Extract the healthId from the path parameters
                final healthId = state.pathParameters['healthId']!;

                return BlocProvider(
                  create: (context) =>
                      HealthReportDetailsCubit()..fetchReport(healthId),
                  child: HealthReportDetailsPage(healthId: healthId),
                );
              },
            ),
            GoRoute(
              path: 'add',
              name: 'add-health-report',
              // Inject the AddHealthReportCubit here
              builder: (_, __) => BlocProvider(
                  create: (context) => AddHealthReportCubit(),
                  child: const AddHealthReportPage()),
            ),
            GoRoute(
              path: 'edit',
              name: 'edit-health-report',
              builder: (context, state) {
                final healthId = state.pathParameters['healthId']!;
                final initialData = state.extra
                    as Map<String, dynamic>; // Requires data passed via 'extra'

                return BlocProvider(
                  create: (context) => HealthReportUpdateCubit(),
                  child: EditHealthReportPage(
                    healthId: healthId,
                    initialReportData: initialData,
                  ),
                );
              },
            ),
          ],
        ),

        //Diagnoses
        GoRoute(
          path: 'diagnoses',
          name: 'diagnoses',
          builder: (context, state) => BlocProvider(
            create: (context) => DiagnosisListCubit(),
            child: const DiagnosesListPage(),
          ),
          // You would also define nested routes for diagnosis details/edit here:
          routes: [
            GoRoute(
              path: ':diagnosisId',
              name: 'diagnosis-details',
              builder: (context, state) {
                final diagnosisId = state.pathParameters['diagnosisId']!;
                return BlocProvider(
                  create: (context) => DiagnosisDetailsCubit()
                    ..fetchDiagnosisDetails(diagnosisId),
                  child: DiagnosisDetailsPage(diagnosisId: diagnosisId),
                );
              },
            ),
          ],
        ),
        // Treatments
        GoRoute(
          path: 'treatments',
          name: 'treatments',
          // 1. REMOVED BlocProvider for the List Page
          builder: (context, state) => const TreatmentsListPage(),
          routes: [
            GoRoute(
              path: 'overdue',
              name: 'overdue-treatments',
              // OverdueTreatmentsPage internally uses TreatmentsListPage(isOverdueFilter: true)
              builder: (context, state) => const OverdueTreatmentsPage(),
            ),
            // The treatments list page will handle navigation to the detail page, which is nested here
            GoRoute(
              path: ':treatmentId',
              name: 'treatment-details',
              builder: (context, state) {
                final treatmentId = state.pathParameters['treatmentId']!;
                return TreatmentDetailsPage(treatmentId: 1);
              },
            ),
          ],
        ),
        // Vaccinations
        GoRoute(
          path: 'vaccinations',
          name: 'vaccinations',
          builder: (_, __) => const VaccinationListPage(),
          routes: [
            GoRoute(
              path: ':vaccinationId',
              name: 'vaccination-details',
              builder: (context, state) {
                final vaccinationId = state.pathParameters['vaccinationId']!;
                return VaccinationDetailPage(
                    vaccinationId: vaccinationId, scheduleId: 1);
              },
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.finance,
      name: 'finance',
      builder: (_, __) => const FinancialDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.reports,
      name: 'reports',
      builder: (_, __) => const ReportsPage(),
    ),

    // Other Roles Dashboards
    GoRoute(
        path: AppRoutes.vetDashboard,
        builder: (_, __) => const VetDashboardPage()),
    GoRoute(
        path: AppRoutes.researcherDashboard,
        builder: (_, __) => const ResearcherDashboardPage()),
  ],
);
