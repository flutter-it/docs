import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  // Simple async singleton - starts initialization immediately
  getIt.registerSingletonAsync<Database>(
    () async {
      final db = Database('/data/myapp.db');
      await db.initialize();
      return db;
    },
  );

  // With disposal function
  getIt.registerSingletonAsync<ApiClient>(
    () async {
      final client = ApiClient('https://api.example.com');
      await client.authenticate();
      return client;
    },
    dispose: (client) => client.close(),
  );

  // Wait for all async singletons to be ready
  await getIt.allReady();

  // Now access them normally
  final db = getIt<Database>();
  final api = getIt<ApiClient>();

  print('Database and API client ready!');
}
// #endregion example
