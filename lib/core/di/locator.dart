// injection.dart

// --- NEW SEMEN IMPORTS ---
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_bloc.dart';
// -------------------------

import 'package:dio/dio.dart';
import 'package:farm_manager_app/features/auth/data/datasources/auth/auth_local_datasource.dart';
import 'package:farm_manager_app/features/auth/data/datasources/auth/auth_remote_datasource.dart';
import 'package:farm_manager_app/features/auth/data/datasources/farmer/farmer_remote_datasource.dart';
import 'package:farm_manager_app/features/auth/data/datasources/location/location_datasource.dart'; 
import 'package:farm_manager_app/features/auth/data/domain/repositories/auth_repository.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/farmer_repository.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/assign_role_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/login_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/register_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/farmer/submit_farmer_details_usecase.dart';
import 'package:farm_manager_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:farm_manager_app/features/auth/data/repositories/farmer_repository_impl.dart';
import 'package:farm_manager_app/features/auth/data/repositories/location_repository_impl.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';

// --- RESEARCHER IMPORTS (NEW) ---
import 'package:farm_manager_app/features/reseacher/data/datasources/researcher_remote_datasource.dart';
import 'package:farm_manager_app/features/reseacher/data/repositories/researcher_repository_impl.dart';
import 'package:farm_manager_app/features/reseacher/domain/repositories/researcher_repository.dart';
import 'package:farm_manager_app/features/reseacher/domain/usecases/submit_researcher_details_usecase.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_bloc.dart';
// ---------------------------------

import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/data/datasources/heat_cycle_remote_data_source.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/data/repositories_imp/heat_cycle_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/repositories/heat_cycle_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/usecases/heat_cycle_usecases.dart'; 
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/data_resources/semen_data_resource.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/repositories/semen_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/create_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/delete_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/get_available_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/get_semen_details.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/semen_usecases.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/update_semen.dart';

import 'package:farm_manager_app/features/farmer/livestock/data/datasources/livestock_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/repositories/livestock_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/add_livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/get_all_livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/get_livestock_by_id.dart';
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';
import 'package:farm_manager_app/features/vet/data/domain/usercases/submit_vet_details_usecase.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/widgets.dart'; // Required for WidgetsFlutterBinding

import '../localization/language_provider.dart';
import '../networking/api_client.dart';
import '../networking/api_endpoints.dart'; 
import '../networking/network_info.dart';

final getIt = GetIt.instance;

/// ⚡ OPTIMIZED: Setup all dependency injection
Future<void> setupLocator() async {
  
  // ========================================
  // CORE LAYER - Only essential init here
  // ========================================
  
  // Register Dio instance LAZILY (created only when first used)
  getIt.registerLazySingleton<Dio>(() {
    ApiClient.init(); // Initialize only when Dio is first accessed
    return ApiClient.dio;
  });
  
  // Register Secure Storage LAZILY
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  
  // Register Network Info LAZILY
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // ========================================
  // DATA SOURCES LAYER - All LAZY
  // ========================================
  
  // Auth Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      storage: getIt<FlutterSecureStorage>(),
    ),
  );
  
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<FlutterSecureStorage>()),
  );
  
  // Location Data Sources
  getIt.registerLazySingleton<LocationDataSource>(
    () => LocationDataSourceImpl(dio: getIt<Dio>()),
  );
  
  // Farmer Data Sources
  getIt.registerLazySingleton<FarmerRemoteDataSource>(
    () => FarmerRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // ⭐ RESEARCHER DATA SOURCE (NEW)
  getIt.registerLazySingleton<ResearcherRemoteDataSource>(
    () => ResearcherRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  
  // Livestock Data Sources
  getIt.registerLazySingleton<LivestockRemoteDataSource>(
    () => LivestockRemoteDataSourceImpl(endpoints: ApiEndpoints.farmer),
  );
  
  // Heat Cycle Data Sources
  getIt.registerLazySingleton<HeatCycleRemoteDataSource>(
    () => HeatCycleRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Semen Data Source
  getIt.registerLazySingleton<SemenRemoteDataSource>(
    () => SemenRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // ========================================
  // REPOSITORIES LAYER - All LAZY
  // ========================================
  
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      getIt<LocationDataSource>(),
      getIt<NetworkInfo>(),
    ),
  );
  
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      locationRepository: getIt<LocationRepository>(),
    ),
  );
  
  getIt.registerLazySingleton<FarmerRepository>(
    () => FarmerRepositoryImpl(
      remoteDataSource: getIt<FarmerRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // ⭐ RESEARCHER REPOSITORY (NEW)
  getIt.registerLazySingleton<ResearcherRepository>(
    () => ResearcherRepositoryImpl(
      remoteDataSource: getIt<ResearcherRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  
  getIt.registerLazySingleton<LivestockRepository>(
    () => LivestockRepositoryImpl(
      remoteDataSource: getIt<LivestockRemoteDataSource>(),
    ),
  );
  
  getIt.registerLazySingleton<HeatCycleRepository>(
    () => HeatCycleRepositoryImpl(
      remoteDataSource: getIt<HeatCycleRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  
  getIt.registerLazySingleton<SemenRepository>(
    () => SemenRepositoryImpl(
      remoteDataSource: getIt<SemenRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // ========================================
  // USE CASES LAYER - All LAZY
  // ========================================
  
  // Auth Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => AssignRoleUseCase(getIt<AuthRepository>()));
  
  // Farmer Use Cases
  getIt.registerLazySingleton(
    () => RegisterFarmerUseCase(repository: getIt<FarmerRepository>()),
  );
  
  getIt.registerLazySingleton(
    () => SubmitVetDetailsUseCase(getIt<AuthRepository>()),
  );

  // ⭐ RESEARCHER USE CASE (NEW)
  getIt.registerLazySingleton(
    () => SubmitResearcherDetailsUseCase(getIt<ResearcherRepository>()),
  );
  
  // Livestock Use Cases
  getIt.registerLazySingleton(() => GetAllLivestock(getIt<LivestockRepository>()));
  getIt.registerLazySingleton(() => GetLivestockById(getIt<LivestockRepository>()));
  getIt.registerLazySingleton(() => AddLivestock(getIt<LivestockRepository>()));
  
  // Heat Cycle Use Cases
  getIt.registerLazySingleton(() => GetHeatCycles(getIt<HeatCycleRepository>()));
  getIt.registerLazySingleton(() => GetHeatCycleDetails(getIt<HeatCycleRepository>())); 
  getIt.registerLazySingleton(() => CreateHeatCycle(getIt<HeatCycleRepository>()));
  getIt.registerLazySingleton(() => UpdateHeatCycle(getIt<HeatCycleRepository>()));
  
  // Semen Use Cases
  getIt.registerLazySingleton(() => GetAllSemen(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => GetSemenDetails(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => CreateSemen(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => UpdateSemen(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => DeleteSemen(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => GetAvailableSemen(getIt<SemenRepository>()));

  // ========================================
  // PRESENTATION LAYER (BLoCs) - FACTORY
  // ========================================
  
  // AuthBloc - Factory (new instance per screen)
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      assignRoleUseCase: getIt<AssignRoleUseCase>(),
      registerFarmerUseCase: getIt<RegisterFarmerUseCase>(),
      locationRepository: getIt<LocationRepository>(),
    ),
  );
  
  // LivestockBloc - Factory
  getIt.registerFactory(
    () => LivestockBloc(
      getAllLivestock: getIt<GetAllLivestock>(),
      getLivestockById: getIt<GetLivestockById>(),
      addLivestock: getIt<AddLivestock>(),
    ),
  );
  
  // HeatCycleBloc - Factory
  getIt.registerFactory(
    () => HeatCycleBloc(
      getHeatCycles: getIt<GetHeatCycles>(),
      getHeatCycleDetails: getIt<GetHeatCycleDetails>(),
      createHeatCycle: getIt<CreateHeatCycle>(),
      updateHeatCycle: getIt<UpdateHeatCycle>(),
    ),
  );
  
  // SemenInventoryBloc - Factory
  getIt.registerFactory(
    () => SemenInventoryBloc(
      getAllSemen: getIt<GetAllSemen>(),
      getSemenDetails: getIt<GetSemenDetails>(),
      createSemen: getIt<CreateSemen>(),
      updateSemen: getIt<UpdateSemen>(),
      deleteSemen: getIt<DeleteSemen>(),
      getAvailableSemen: getIt<GetAvailableSemen>(),
    ),
  );

  // ⭐ ResearcherBloc - Factory (FIXED)
  getIt.registerFactory<ResearcherBloc>(
    () => ResearcherBloc(
      submitResearcherDetailsUseCase: getIt<SubmitResearcherDetailsUseCase>(),
    ),
  );

  // ========================================
  // UTILITIES & PROVIDERS
  // ========================================
  
  getIt.registerLazySingleton<LanguageProvider>(() => LanguageProvider());
  
  getIt<LanguageProvider>().loadSavedLocale().catchError((e) {
    // Silently handle errors
  });
}

/// Optional: Helper function to reset all dependencies (useful for testing)
Future<void> resetLocator() async {
  await getIt.reset();
}

/// Optional: Check if a dependency is registered
bool isDependencyRegistered<T extends Object>() {
  return getIt.isRegistered<T>();
}