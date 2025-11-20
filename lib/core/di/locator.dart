// lib/core/di/locator.dart
import 'package:dio/dio.dart';
import 'package:farm_manager_app/features/auth/data/datasources/auth/auth_local_datasource.dart';
import 'package:farm_manager_app/features/auth/data/datasources/auth/auth_remote_datasource.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/auth_repository.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/location_repository.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/assign_role_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/login_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/auth/register_usecase.dart';
import 'package:farm_manager_app/features/auth/data/repositories/location_repository_impl.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../localization/language_provider.dart';
import '../networking/api_client.dart';
import '../networking/network_info.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';


final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // ========================== CORE ==========================
  ApiClient.init();
  getIt.registerLazySingleton<Dio>(() => ApiClient.dio);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // ========================== AUTH ==========================
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(getIt()));

  // ========================== LOCATION ==========================
  getIt.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl());

  // 💡 FIX: AuthRepositoryImpl now requires LocationRepository
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        networkInfo: getIt(),
        locationRepository: getIt(), // 💡 Dependency added here to fix the compile error
      ));

  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => AssignRoleUseCase(getIt()));

  // AuthBloc is registered as Factory because we want a fresh instance when needed
  // but we also provide it globally in main.dart via BlocProvider.value
  getIt.registerFactory(() => AuthBloc(
        loginUseCase: getIt(),
        registerUseCase: getIt(),
        assignRoleUseCase: getIt(),
      ));

  // ========================== OTHER PROVIDERS ==========================
  getIt.registerLazySingleton<LanguageProvider>(() => LanguageProvider());

  // Load saved language at startup
  await getIt<LanguageProvider>().loadSavedLocale();
}