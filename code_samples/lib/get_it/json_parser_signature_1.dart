// ignore_for_file: missing_function_body, unused_element
// Factory - always new, immediate cleanup
getIt.registerFactory<JsonParser>(() => JsonParser());
final p1 = getIt<JsonParser>(); // Creates instance 1
final p2 = getIt<JsonParser>(); // Creates instance 2 (different)

// Cached Factory - reuses if possible
getIt.registerCachedFactory<JsonParser>(() => JsonParser());
final p3 = getIt<JsonParser>(); // Creates instance 3
final p4 = getIt<JsonParser>(); // Returns instance 3 (if not GC'd)

// Lazy Singleton - reuses forever
getIt.registerLazySingleton<JsonParser>(() => JsonParser());
final p5 = getIt<JsonParser>(); // Creates instance 4
final p6 = getIt<JsonParser>(); // Returns instance 4 (always)