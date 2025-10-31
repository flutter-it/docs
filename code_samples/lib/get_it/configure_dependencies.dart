import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  // Singleton - created immediately, used for entire app lifetime
  getIt.registerSingleton<Logger>(Logger());

  // LazySingleton - created on first use, used for entire app lifetime
  getIt.registerLazySingleton<Database>(() => Database());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Factory - new instance every time you call getIt<ShoppingCart>()
  getIt.registerFactory<ShoppingCart>(() => ShoppingCart());
}
// #endregion example