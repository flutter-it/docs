import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  // 1. Config loads first (no dependencies)
  getIt.registerSingletonAsync<ConfigService>(
    () async {
      final config = ConfigService();
      await config.loadFromFile();
      return config;
    },
  );

  // 2. API client waits for config
  getIt.registerSingletonAsync<ApiClient>(
    () async {
      final apiUrl = getIt<ConfigService>().apiUrl;
      final client = ApiClient(apiUrl);
      await client.authenticate();
      return client;
    },
    dependsOn: [ConfigService],
  );

  // 3. Database waits for config
  getIt.registerSingletonAsync<Database>(
    () async {
      final dbPath = getIt<ConfigService>().databasePath;
      final db = Database(dbPath);
      await db.initialize();
      return db;
    },
    dependsOn: [ConfigService],
  );

  // 4. App model waits for everything
  getIt.registerSingletonWithDependencies<AppModel>(
    () => AppModel.withParams(
      api: getIt<ApiClient>(),
      db: getIt<Database>(),
      config: getIt<ConfigService>(),
    ),
    dependsOn: [ConfigService, ApiClient, Database],
  );
}
// #endregion example
