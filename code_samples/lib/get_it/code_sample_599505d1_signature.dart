// ignore_for_file: missing_function_body, unused_element
// Register lazy singletons
getIt.registerLazySingleton<CacheService>(() => CacheService());
getIt.registerLazySingleton<UserPreferences>(() => UserPreferences());

// Access them (creates instances)
final cache = getIt<CacheService>();
final prefs = getIt<UserPreferences>();

// Reset all lazy singletons in current scope
await getIt.resetLazySingletons();

// Next access creates fresh instances
final newCache = getIt<CacheService>(); // New instance