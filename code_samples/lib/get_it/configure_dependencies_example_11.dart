import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt()));
  getIt.registerLazySingleton<UserRepository>(
      () => UserRepository(getIt(), getIt()));
  // ... 50 more registrations
}
// #endregion example
