// ignore_for_file: missing_function_body, unused_element
// Register lazy singleton
getIt.registerLazySingleton<HeavyService>(() => HeavyService());

// Check if it's been created yet
if (getIt.checkLazySingletonInstanceExists<HeavyService>()) {
  print('HeavyService already created');
} else {
  print('HeavyService not created yet - will be lazy loaded');
}

// Access triggers creation
final service = getIt<HeavyService>();

// Now it exists
assert(getIt.checkLazySingletonInstanceExists<HeavyService>() == true);