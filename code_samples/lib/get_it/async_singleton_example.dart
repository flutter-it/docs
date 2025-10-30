import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  // Simple async singleton
  getIt.registerSingletonAsync<Database>(
    () async {
      final db = Database();
      await db.initialize();
      return db;
    },
  );

  // With disposal
  getIt.registerSingletonAsync<ApiClient>(
    () async {
      final client = ApiClient();
      await client.authenticate();
      return client;
    },
    dispose: (client) => client.close(),
  );

  // With onCreated callback
  getIt.registerSingletonAsync<Logger>(
    () async => Logger.initialize(),
    onCreated: (logger) => print('Logger initialized'),
  );
}


// Wait for singleton to be ready

// Or wait for all async singletons

// Then access normally
// #endregion example
