import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
final getIt = GetIt.instance;

void configureDependencies() {
  // Register your services
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Database>(() => Database());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}
// #endregion example
