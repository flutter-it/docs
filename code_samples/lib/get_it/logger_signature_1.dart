// ignore_for_file: missing_function_body, unused_element
// Created immediately at app startup
getIt.registerSingleton<Logger>(Logger());

// Only created when first accessed (lazy)
getIt.registerLazySingleton<HeavyDatabase>(() => HeavyDatabase());