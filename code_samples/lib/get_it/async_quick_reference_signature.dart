// ignore_for_file: unused_import, unused_local_variable
import 'package:get_it/get_it.dart';

// Quick Reference for Async Objects in GetIt

// Register an async singleton that will be created on first access
getIt.registerSingletonAsync<SharedPreferences>(() async {
  return await SharedPreferences.getInstance();
});

// Register with dependency on another async object
getIt.registerSingletonAsync<Database>(
  () async => Database(getIt<SharedPreferences>()),
  dependsOn: [SharedPreferences],
);

// Wait for all async singletons to be ready
await getIt.allReady();

// Wait for specific type to be ready
await getIt.isReady<Database>();

// Check if an async object is ready (non-blocking)
if (getIt.isReadySync<SharedPreferences>()) {
  // Safe to access
  final prefs = getIt<SharedPreferences>();
}

// Register factory with async initialization
getIt.registerFactoryAsync<Connection>(() async {
  final conn = Connection();
  await conn.initialize();
  return conn;
});

// Access will wait for initialization
final connection = await getIt.getAsync<Connection>();

// Register with disposer for cleanup
getIt.registerSingletonAsync<ApiClient>(
  () async => ApiClient(),
  dispose: (client) => client.dispose(),
);

// Unregister triggers disposal
await getIt.unregister<ApiClient>();
