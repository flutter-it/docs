// ignore_for_file: missing_function_body, unused_element
void configureDependencies() {
  // Singleton - created immediately, used for entire app lifetime
  getIt.registerSingleton<Logger>(Logger());

  // LazySingleton - created on first use, used for entire app lifetime
  getIt.registerLazySingleton<Database>(() => Database());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Factory - new instance every time you call getIt<ShoppingCart>()
  getIt.registerFactory<ShoppingCart>(() => ShoppingCart());
}
