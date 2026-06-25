import 'package:get_it/get_it.dart';
import '../config/appwrite_config.dart';

// Auth Imports
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/domain/usecases/recover_password_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Provincial Imports
import '../../features/provincial/domain/repositories/provincial_repository.dart';
import '../../features/provincial/domain/usecases/get_recintos_usecase.dart';
import '../../features/provincial/domain/usecases/create_recinto_usecase.dart';
import '../../features/provincial/domain/usecases/create_coordinador_recinto_usecase.dart';
import '../../features/provincial/domain/usecases/get_actas_count_by_recinto_usecase.dart';
import '../../features/provincial/data/datasources/provincial_remote_datasource.dart';
import '../../features/provincial/data/repositories/provincial_repository_impl.dart';
import '../../features/provincial/presentation/bloc/provincial_bloc.dart';

// Recinto Imports
import '../../features/recinto/domain/repositories/coordinador_recinto_repository.dart';
import '../../features/recinto/domain/usecases/get_mesas_by_recinto_usecase.dart';
import '../../features/recinto/domain/usecases/create_mesa_usecase.dart';
import '../../features/recinto/domain/usecases/create_veedor_mesa_usecase.dart';
import '../../features/recinto/data/datasources/recinto_remote_datasource.dart';
import '../../features/recinto/data/repositories/coordinador_recinto_repository_impl.dart';
import '../../features/recinto/presentation/bloc/recinto_bloc.dart';

// Veedor Imports
import '../../features/veedor/domain/repositories/veedor_repository.dart';
import '../../features/veedor/domain/usecases/get_acta_mesa_usecase.dart';
import '../../features/veedor/domain/usecases/get_actas_by_mesa_usecase.dart';
import '../../features/veedor/domain/usecases/get_mesas_by_veedor_usecase.dart';
import '../../features/veedor/domain/usecases/submit_acta_usecase.dart';
import '../../features/veedor/data/datasources/veedor_remote_datasource.dart';
import '../../features/veedor/data/repositories/veedor_repository_impl.dart';
import '../../features/veedor/presentation/bloc/veedor_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core / Config
  sl.registerLazySingleton(() => AppwriteConfig());

// Features - Auth
  
  // 1. DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AppwriteAuthDataSource(sl()),
  );

  // 2. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // 3. UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => RecoverPasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // 4. Blocs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      checkAuthUseCase: sl(),
      changePasswordUseCase: sl(),
      recoverPasswordUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Features - Provincial

  sl.registerLazySingleton<ProvincialRemoteDataSource>(
    () => AppwriteProvincialDataSource(sl()),
  );

  sl.registerLazySingleton<ProvincialRepository>(
    () => ProvincialRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetRecintosUseCase(sl()));
  sl.registerLazySingleton(() => CreateRecintoUseCase(sl()));
  sl.registerLazySingleton(() => CreateCoordinadorRecintoUseCase(sl()));
  sl.registerLazySingleton(() => GetActasCountByRecintoUseCase(sl()));

  sl.registerFactory(
    () => ProvincialBloc(
      getRecintosUseCase: sl(),
      createRecintoUseCase: sl(),
      createCoordinadorRecintoUseCase: sl(),
    ),
  );

  // Features - Recinto

  sl.registerLazySingleton<RecintoRemoteDataSource>(
    () => AppwriteRecintoDataSource(sl()),
  );

  sl.registerLazySingleton<CoordinadorRecintoRepository>(
    () => CoordinadorRecintoRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetMesasByRecintoUseCase(sl()));
  sl.registerLazySingleton(() => CreateMesaUseCase(sl()));
  sl.registerLazySingleton(() => CreateVeedorMesaUseCase(sl()));

  sl.registerFactory(
    () => RecintoBloc(
      getMesasUseCase: sl(),
      createMesaUseCase: sl(),
      createVeedorMesaUseCase: sl(),
    ),
  );

  // Features - Veedor

  sl.registerLazySingleton<VeedorRemoteDataSource>(
    () => AppwriteVeedorDataSource(sl()),
  );

  sl.registerLazySingleton<VeedorRepository>(
    () => VeedorRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetActaMesaUseCase(sl()));
  sl.registerLazySingleton(() => GetActasByMesaUseCase(sl()));
  sl.registerLazySingleton(() => GetMesasByVeedorUseCase(sl()));
  sl.registerLazySingleton(() => SubmitActaUseCase(sl()));

  sl.registerFactory(
    () => VeedorBloc(
      getActaMesaUseCase: sl(),
      getActasByMesaUseCase: sl(),
      getMesasByVeedorUseCase: sl(),
      submitActaUseCase: sl(),
    ),
  );
}
