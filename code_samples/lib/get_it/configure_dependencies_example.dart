import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// lib/service_locator.dart

void configureDependencies() {
  // Register your services
  getIt.registerLazySingleton<ApiClient>(
      () => ApiClient('https://api.example.com'));
  getIt.registerLazySingleton<Database>(() => Database('mydb.db'));
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
}
// #endregion example
