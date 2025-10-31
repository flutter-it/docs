// ignore_for_file: unused_import, unused_local_variable, missing_function_body, unused_element
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Quick Reference for Async Objects in GetIt

void quickReference() async {
  // Register an async singleton that will be created on first access
  getIt.registerSingletonAsync<ConfigService>(() async {
    final config = ConfigService();
    await config.loadFromFile();
    return config;
  });

  // Register with dependency on another async object
  getIt.registerSingletonAsync<Database>(
    () async {
      final db = Database(getIt<ConfigService>().databasePath);
      await db.initialize();
      return db;
    },
    dependsOn: [ConfigService],
  );

  // Wait for all async singletons to be ready
  await getIt.allReady();

  // Wait for specific type to be ready
  await getIt.isReady<Database>();

  // Check if an async object is ready (non-blocking)
  if (getIt.isReadySync<ConfigService>()) {
    // Safe to access
    final config = getIt<ConfigService>();
  }

  // Register factory with async initialization
  getIt.registerFactoryAsync<DatabaseConnection>(() async {
    final conn = DatabaseConnection();
    await conn.connect();
    return conn;
  });

  // Access will wait for initialization
  final connection = await getIt.getAsync<DatabaseConnection>();

  // Register with disposer for cleanup
  getIt.registerSingletonAsync<ApiClient>(
    () async {
      final client = ApiClient('https://api.example.com');
      await client.authenticate();
      return client;
    },
    dispose: (client) => client.close(),
  );

  // Unregister triggers disposal
  await getIt.unregister<ApiClient>();
}
// #endregion example
