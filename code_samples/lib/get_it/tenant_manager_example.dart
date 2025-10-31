import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class TenantManager {
  Future<void> switchTenant(String tenantId) async {
    // Pop previous tenant scope if exists
    if (getIt.hasScope('tenant')) {
      await getIt.popScope();
    }

    // Load new tenant
    await getIt.pushNewScopeAsync(
      scopeName: 'tenant',
      init: (getIt) async {
        final config = await loadTenantConfig(tenantId);
        getIt.registerSingleton<TenantConfig>(config);

        final database = await openTenantDatabase(tenantId);
        getIt.registerSingleton<Database>(database);

        final api = ApiClient(config.apiUrl);
        getIt.registerSingleton<TenantServices>(
          TenantServices(database, api),
        );
      },
    );
  }
}
// #endregion example
