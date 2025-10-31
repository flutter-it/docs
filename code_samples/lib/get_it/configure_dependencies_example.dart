import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// lib/service_locator.dart


void configureDependencies() {
  // Register your services
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Database>(() => Database());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}
// #endregion example
