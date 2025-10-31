import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  // Simple registration
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // With disposal and onCreated callback
  getIt.registerLazySingleton<Database>(
    () => Database(),
    dispose: (db) => db.close(),
    onCreated: (db) => print('Database initialized'),
  );
}

// First access - factory function runs NOW
final api = getIt<ApiClient>(); // ApiClient() constructor called

// Subsequent calls - returns existing instance
final sameApi = getIt<ApiClient>(); // Same instance, no constructor call
// #endregion example
