// injection.dart - OPTIMIZED FOR FAST BOOT

// --- CORE IMPORTS ---
import 'package:dio/dio.dart';
import 'package:farm_manager_app/core/localization/language_provider.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/data/datasources/delivery_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/repositories/delivery_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/usecases/add_delivery_usecase.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/usecases/delete_delivery_usecase.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/usecases/get_available_inseminations_usecase.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/usecases/get_deliveries_usecase.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/usecases/get_delivery_by_id_usecase.dart';
import 'package:farm_manager_app/features/farmer/breeding/delivery/domain/usecases/update_delivery_usecase.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/data/datasources/offspring_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/data/repositories/offspring_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/domain/repositories/offspring_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/offspring/domain/usecases/offspring_usecases.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/data/datasources/pregnancy_check_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/data/repositories/pregnancy_check_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/repositories/pregnancy_check_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/usecases/get_pregnancy_checks.dart';
import 'package:farm_manager_app/features/farmer/breeding/pregnancyCheck/domain/usecases/pregnancy_check_usecases.dart' hide GetPregnancyChecks;
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/delivery/delivery_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/offspring/offspring_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/pregnancyCheck/pregnancy_check_bloc.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/get_semen_dropdowns.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:farm_manager_app/core/networking/api_client.dart';
import 'package:farm_manager_app/core/networking/api_endpoints.dart'; 
import 'package:farm_manager_app/core/networking/network_info.dart';

// --- AUTH/FARMER/LOCATION IMPORTS ---
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
import 'package:farm_manager_app/features/vet/data/domain/usercases/submit_vet_details_usecase.dart';

// --- RESEARCHER IMPORTS ---
import 'package:farm_manager_app/features/reseacher/data/datasources/researcher_remote_datasource.dart';
import 'package:farm_manager_app/features/reseacher/data/repositories/researcher_repository_impl.dart';
import 'package:farm_manager_app/features/reseacher/domain/repositories/researcher_repository.dart';
import 'package:farm_manager_app/features/reseacher/domain/usecases/get_researcher_approval_status_usecase.dart';
import 'package:farm_manager_app/features/reseacher/domain/usecases/submit_researcher_details_usecase.dart';
import 'package:farm_manager_app/features/reseacher/presentation/blocs/researcher/researcher_bloc.dart';

// --- LIVESTOCK IMPORTS ---
import 'package:farm_manager_app/features/farmer/livestock/data/datasources/livestock_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/livestock/data/repositories/livestock_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/repositories/livestock_repository.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/add_livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/get_all_livestock.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/get_livestock_by_id.dart';
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/update_livestock.dart'; 
import 'package:farm_manager_app/features/farmer/livestock/domain/usecases/delete_livestock.dart'; 
import 'package:farm_manager_app/features/farmer/livestock/presentation/bloc/livestock_bloc.dart';

// --- INSEMINATION IMPORTS ---
import 'package:farm_manager_app/features/farmer/breeding/Insemination/data/datasources/insemination_remote_datasource.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/data/repositories/insemination_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/repositories/insemination_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/usecases/add_insemination.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/usecases/delete_insemination.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/usecases/fetch_insemination_detail.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/usecases/fetch_insemination_list.dart';
import 'package:farm_manager_app/features/farmer/breeding/Insemination/domain/usecases/update_insemination.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/insemination/insemination_bloc.dart';

// --- HEAT CYCLE IMPORTS ---
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/data/datasources/heat_cycle_remote_data_source.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/data/repositories_imp/heat_cycle_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/repositories/heat_cycle_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/HeatCycle/domain/usecases/heat_cycle_usecases.dart'; 
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/HeatCycle/heat_cycle_bloc.dart';

// --- SEMEN INVENTORY IMPORTS ---
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/data_resources/semen_data_resource.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/data/repositories/semen_repository_impl.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/repositories/semen_repository.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/create_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/delete_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/get_available_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/get_semen_details.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/semen_usecases.dart';
import 'package:farm_manager_app/features/farmer/breeding/semenInventory/domain/usecases/update_semen.dart';
import 'package:farm_manager_app/features/farmer/breeding/presentation/bloc/semenInventory/semen_bloc.dart';


final getIt = GetIt.instance;

/// ⚡ OPTIMIZED: Fast setup with lazy loading
Future<void> setupLocator() async {
  
  // ========================================
  // CORE LAYER - Register but DON'T initialize
  // ========================================
  
  // ⚡ CRITICAL: Initialize Dio FIRST (needed for network calls)
  ApiClient.init();
  getIt.registerLazySingleton<Dio>(() => ApiClient.dio);
  
  // ⚡ Secure Storage - Lazy
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  
  // ⚡ Network Info - Singleton (created immediately for startup check)
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl());

  // ========================================
  // DATA SOURCES LAYER - All LAZY
  // ========================================
  
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      storage: getIt<FlutterSecureStorage>(),
    ),
  );
  
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<FlutterSecureStorage>()),
  );
  
  getIt.registerLazySingleton<LocationDataSource>(
    () => LocationDataSourceImpl(dio: getIt<Dio>()),
  );
  
  getIt.registerLazySingleton<FarmerRemoteDataSource>(
    () => FarmerRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<ResearcherRemoteDataSource>(
    () => ResearcherRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  
  getIt.registerLazySingleton<LivestockRemoteDataSource>(
    () => LivestockRemoteDataSourceImpl(endpoints: ApiEndpoints.farmer),
  );
  
  getIt.registerLazySingleton<HeatCycleRemoteDataSource>(
    () => HeatCycleRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  
  getIt.registerLazySingleton<SemenRemoteDataSource>(
    () => SemenRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<InseminationRemoteDataSource>(
    () => InseminationRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<PregnancyCheckRemoteDataSource>(
    () => PregnancyCheckRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

   getIt.registerLazySingleton<DeliveryRemoteDataSource>(
    () => DeliveryRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<OffspringRemoteDataSource>(
    () => OffspringRemoteDataSourceImpl(dio: getIt<Dio>()),
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
  
  getIt.registerLazySingleton<InseminationRepository>(
    () => InseminationRepositoryImpl(
      remoteDataSource: getIt<InseminationRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<PregnancyCheckRepository>(
    () => PregnancyCheckRepositoryImpl(
      remoteDataSource: getIt<PregnancyCheckRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<DeliveryRepository>(
    () => DeliveryRepositoryImpl(
      remoteDataSource: getIt<DeliveryRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<OffspringRepository>(
    () => OffspringRepositoryImpl(
      remoteDataSource: getIt<OffspringRemoteDataSource>(),
    ),
  );

  // ========================================
  // USE CASES LAYER - All LAZY
  // ========================================

  getIt.registerLazySingleton( 
    () => GetResearcherApprovalStatusUseCase(getIt<ResearcherRepository>()),
  );
  
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => AssignRoleUseCase(getIt<AuthRepository>()));
  
  getIt.registerLazySingleton(
    () => RegisterFarmerUseCase(repository: getIt<FarmerRepository>()),
  );
  getIt.registerLazySingleton(
    () => SubmitVetDetailsUseCase(getIt<AuthRepository>()),
  );
  
  getIt.registerLazySingleton(
    () => SubmitResearcherDetailsUseCase(getIt<ResearcherRepository>()),
  );
  
  getIt.registerLazySingleton(() => GetAllLivestock(getIt<LivestockRepository>()));
  getIt.registerLazySingleton(() => GetLivestockById(getIt<LivestockRepository>()));
  getIt.registerLazySingleton(() => AddLivestock(getIt<LivestockRepository>()));
  getIt.registerLazySingleton(() => UpdateLivestock(getIt<LivestockRepository>()));
  getIt.registerLazySingleton(() => DeleteLivestock(getIt<LivestockRepository>()));
  
  getIt.registerLazySingleton(() => GetHeatCycles(getIt<HeatCycleRepository>()));
  getIt.registerLazySingleton(() => GetHeatCycleDetails(getIt<HeatCycleRepository>())); 
  getIt.registerLazySingleton(() => CreateHeatCycle(getIt<HeatCycleRepository>()));
  getIt.registerLazySingleton(() => UpdateHeatCycle(getIt<HeatCycleRepository>()));
  getIt.registerLazySingleton(() => DeleteHeatCycle(getIt<HeatCycleRepository>()));
  
  getIt.registerLazySingleton(() => GetAllSemen(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => GetSemenDetails(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => CreateSemen(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => UpdateSemen(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => DeleteSemen(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => GetAvailableSemen(getIt<SemenRepository>()));
  getIt.registerLazySingleton(() => GetSemenDropdowns(getIt())); 
  
  getIt.registerLazySingleton(() => FetchInseminationList(repository: getIt<InseminationRepository>()));
  getIt.registerLazySingleton(() => FetchInseminationDetail(repository: getIt<InseminationRepository>()));
  getIt.registerLazySingleton(() => AddInsemination(repository: getIt<InseminationRepository>()));
  getIt.registerLazySingleton(() => UpdateInsemination(repository: getIt<InseminationRepository>()));
  getIt.registerLazySingleton(() => DeleteInsemination(repository: getIt<InseminationRepository>()));

  getIt.registerLazySingleton(() => GetPregnancyChecks(getIt<PregnancyCheckRepository>()));
  getIt.registerLazySingleton(() => GetPregnancyCheckById(getIt<PregnancyCheckRepository>()));
  getIt.registerLazySingleton(() => AddPregnancyCheck(getIt<PregnancyCheckRepository>()));
  getIt.registerLazySingleton(() => UpdatePregnancyCheck(getIt<PregnancyCheckRepository>()));
  getIt.registerLazySingleton(() => DeletePregnancyCheck(getIt<PregnancyCheckRepository>()));
  getIt.registerLazySingleton(() => GetAvailableInseminations(getIt<PregnancyCheckRepository>()));
  getIt.registerLazySingleton(() => GetAvailableVets(getIt<PregnancyCheckRepository>()));

  getIt.registerLazySingleton(() => GetDeliveriesUseCase(getIt<DeliveryRepository>()));
  getIt.registerLazySingleton(() => GetDeliveryByIdUseCase(getIt<DeliveryRepository>()));
  getIt.registerLazySingleton(() => AddDeliveryUseCase(getIt<DeliveryRepository>()));
  getIt.registerLazySingleton(() => UpdateDeliveryUseCase(getIt<DeliveryRepository>()));
  getIt.registerLazySingleton(() => DeleteDeliveryUseCase(getIt<DeliveryRepository>()));
  getIt.registerLazySingleton(() => GetAvailableInseminationsUseCase(getIt<DeliveryRepository>()));


  getIt.registerLazySingleton(() => GetOffspringListUseCase(getIt<OffspringRepository>()));
  getIt.registerLazySingleton(() => GetOffspringByIdUseCase(getIt<OffspringRepository>()));
  getIt.registerLazySingleton(() => AddOffspringUseCase(getIt<OffspringRepository>()));
  getIt.registerLazySingleton(() => UpdateOffspringUseCase(getIt<OffspringRepository>()));
  getIt.registerLazySingleton(() => DeleteOffspringUseCase(getIt<OffspringRepository>()));
  getIt.registerLazySingleton(() => RegisterOffspringUseCase(getIt<OffspringRepository>()));
  getIt.registerLazySingleton(() => GetAvailableDeliveriesUseCase(getIt<OffspringRepository>()));

  // ========================================
  // PRESENTATION LAYER (BLoCs) - FACTORY
  // ========================================

  getIt.registerFactory<ResearcherBloc>(
    () => ResearcherBloc(
      submitResearcherDetailsUseCase: getIt<SubmitResearcherDetailsUseCase>(),
      getResearcherApprovalStatusUseCase: getIt<GetResearcherApprovalStatusUseCase>(), 
    ),
  );
  
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      assignRoleUseCase: getIt<AssignRoleUseCase>(),
      registerFarmerUseCase: getIt<RegisterFarmerUseCase>(),
      locationRepository: getIt<LocationRepository>(),
    ),
  );
  
  getIt.registerFactory(
    () => LivestockBloc(
      getAllLivestock: getIt<GetAllLivestock>(),
      getLivestockById: getIt<GetLivestockById>(),
      addLivestock: getIt<AddLivestock>(),
      updateLivestock: getIt<UpdateLivestock>(),
      deleteLivestock: getIt<DeleteLivestock>(),
    ),
  );
  
  getIt.registerFactory(
    () => HeatCycleBloc(
      getHeatCycles: getIt<GetHeatCycles>(),
      getHeatCycleDetails: getIt<GetHeatCycleDetails>(),
      createHeatCycle: getIt<CreateHeatCycle>(),
      updateHeatCycle: getIt<UpdateHeatCycle>(),
      deleteHeatCycle: getIt<DeleteHeatCycle>(),
    ),
  );
  
  getIt.registerFactory(
    () => SemenInventoryBloc(
      getAllSemen: getIt<GetAllSemen>(),
      getSemenDetails: getIt<GetSemenDetails>(),
      createSemen: getIt<CreateSemen>(),
      updateSemen: getIt<UpdateSemen>(),
      deleteSemen: getIt<DeleteSemen>(),
      getAvailableSemen: getIt<GetAvailableSemen>(),
      getSemenDropdowns: getIt(),
    ),
  );

  getIt.registerFactory(
    () => InseminationBloc(
      repository: getIt<InseminationRepository>(),
    ),
  );

  getIt.registerFactory(
    () => PregnancyCheckBloc(
      repository: getIt<PregnancyCheckRepository>(),
    ),
  );

  getIt.registerFactory(
    () => DeliveryBloc(
      repository: getIt<DeliveryRepository>(),
    ),
  );

  getIt.registerFactory(
    () => OffspringBloc(
      repository: getIt<OffspringRepository>(),
    ),
  );

  // ========================================
  // UTILITIES & PROVIDERS
  // ========================================
  
  getIt.registerLazySingleton<LanguageProvider>(() => LanguageProvider());
  
  // ⚡ Load locale in background (don't await)
  getIt<LanguageProvider>().loadSavedLocale().catchError((e) {
    // Silently handle errors
  });
}

/// Reset all dependencies (useful for testing)
Future<void> resetLocator() async {
  await getIt.reset();
}

/// Check if a dependency is registered
bool isDependencyRegistered<T extends Object>() {
  return getIt.isRegistered<T>();
}