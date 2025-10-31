import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies({bool testing = false}) {
  if (testing) {
    getIt.registerSingleton<ApiClient>(FakeApiClient());
    getIt.registerSingleton<Database>(InMemoryDatabase());
  } else {
    getIt.registerSingleton<ApiClient>(ApiClientImpl());
    getIt.registerSingleton<Database>(DatabaseImpl());
  }

  // Shared registrations
  getIt.registerLazySingleton<UserService>(() => UserServiceImpl(getIt()));
}

// In main.dart
void main() {
  configureDependencies();
  runApp(MyApp());
}

// In test
void main() {
  setUpAll(() {
    configureDependencies(testing: true);
  });

  // Tests...
}
// #endregion example
