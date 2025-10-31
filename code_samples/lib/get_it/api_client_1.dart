import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  test('complex service uses all dependencies correctly', () async {
    getIt.pushNewScope();

    // Mock all dependencies
    final mockApi = MockApiClient();
    final mockDb = MockDatabase();
    final mockAuth = MockAuthService();

    // Configure mocks directly
    mockAuth.isAuthenticated = true;
    mockApi.mockData = {'data': 'value'};

    getIt.registerSingleton<ApiClient>(mockApi);
    getIt.registerSingleton<Database>(mockDb);
    getIt.registerSingleton<AuthService>(mockAuth);

    // Service under test (uses real implementation)
    getIt.registerLazySingleton<SyncService>(() => SyncService(
          getIt<ApiClient>(),
          getIt<Database>(),
          getIt<AuthService>(),
        ));

    final sync = getIt<SyncService>();
    print('sync: $sync');
    // Test sync behavior...

    await getIt.popScope();
  });
}
// #endregion example
