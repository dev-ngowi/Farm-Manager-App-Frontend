import 'package:farm_manager_app/core/localization/language_provider.dart';
import 'package:farm_manager_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:farm_manager_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:farm_manager_app/features/auth/data/domain/repositories/auth_repository.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/login_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/register_usecase.dart';
import 'package:farm_manager_app/features/auth/data/domain/usecases/assign_role_usecase.dart'; // NEW IMPORT
import 'package:farm_manager_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:farm_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../networking/api_client.dart';
import '../networking/network_info.dart';


final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Initialization
  ApiClient.init();
  getIt.registerLazySingleton<Dio>(() => ApiClient.dio);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(getIt()));

  // Repository
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ));

  // Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => AssignRoleUseCase(getIt())); // NEW REGISTRATION

  // Blocs
  getIt.registerFactory(() => AuthBloc(
        loginUseCase: getIt(),
        registerUseCase: getIt(),
        assignRoleUseCase: getIt(), // NEW INJECTION
      ));

  // Other Providers
  getIt.registerLazySingleton<LanguageProvider>(() => LanguageProvider());
  await getIt<LanguageProvider>().loadSavedLocale();
}