import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Service under test - uses get_it directly when accessing dependencies
class SyncService {
  Future<void> syncData() async {
    if (!getIt<AuthService>().isAuthenticated) return;
    final data = await getIt<ApiClient>().fetchData();
    await getIt<Database>().save(data);
  }
}

void main() {
  test('SyncService uses mocked dependencies', () async {
    getIt.pushNewScope();

    // Register mocks - SyncService will get these via getIt<Type>()
    getIt.registerSingleton<AuthService>(MockAuthService()..isAuthenticated = true);
    getIt.registerSingleton<ApiClient>(MockApiClient()..mockData = {'data': 'value'});
    getIt.registerSingleton<Database>(MockDatabase());

    // Service under test uses get_it to access mocks
    final sync = SyncService();
    await sync.syncData();

    // Test assertions would go here...

    await getIt.popScope();
  });
  // #endregion example
}
