import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  await getIt.pushNewScopeAsync(
    scopeName: 'tenant-workspace',
    init: (getIt) async {
      // Load tenant configuration from file/database
      final config = await loadTenantConfig(tenantId);
      getIt.registerSingleton<TenantConfig>(config);

      // Establish database connection
      final database = await DatabaseConnection.connect(config.dbUrl);
      getIt.registerSingleton<DatabaseConnection>(database);

      // Load cached data
      final cache = await CacheManager.initialize(tenantId);
      getIt.registerSingleton<CacheManager>(cache);
    },
    dispose: () async {
      // Close connections
      await getIt<DatabaseConnection>().close();
      await getIt<CacheManager>().flush();
    },
  );
}
// #endregion example
