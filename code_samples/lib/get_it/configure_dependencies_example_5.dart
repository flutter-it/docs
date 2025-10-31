// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
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