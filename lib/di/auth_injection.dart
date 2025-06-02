import 'package:get_it/get_it.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/repositories/auth_repository.dart';

import '../domain/usecases/sign_in_usecase.dart';
import '../presentation/viewmodels/sign_in_viewmodel.dart';

void setupAuthDependencies() {
  GetIt getIt = GetIt.instance;

  // Register data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  getIt.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSource());

  // Register repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      authRemoteDataSource: getIt<AuthRemoteDataSource>(),
      authLocalDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Register use cases
  getIt.registerLazySingleton<RequestOtpUseCase>(
        () => RequestOtpUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<VerifyOtpUseCase>(
        () => VerifyOtpUseCase(repository: getIt<AuthRepository>()),
  );

  // Register ViewModel
  getIt.registerFactory<SignInViewModel>(
        () => SignInViewModel(
      requestOtpUseCase: getIt<RequestOtpUseCase>(),
      verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
    ),
  );
}