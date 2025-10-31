import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Note: This example demonstrates testing patterns
// In actual tests, use flutter_test and mockito packages

class MockApiClient extends ApiClient {
  MockApiClient() : super('http://mock');

  String token = 'test-token';
  @override
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? headers}) async {
    return {'id': '123', 'name': 'Alice'};
  }
}

class MockAuthService {
  String getToken() => 'test-token';

  Future<bool> login(String username, String password) async => true;
  Future<void> logout() async {}
  Future<void> cleanup() async {}
  bool get isAuthenticated => false;
}

void main() {
  // Simplified test example showing scope-based mocking
  void setupTests() {
    // Register all real dependencies once
    getIt.registerLazySingleton<ApiClient>(() => ApiClientImpl());
    getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
    getIt.registerLazySingleton<UserRepository>(
        () => UserRepository(getIt(), getIt()));
  }

  void runTest() async {
    // Push scope and shadow only the services we want to mock
    getIt.pushNewScope();

    final mockApi = MockApiClient();
    final mockAuth = MockAuthService();

    getIt.registerSingleton<ApiClient>(mockApi);
    getIt.registerSingleton<MockAuthService>(mockAuth);

    // UserRepository will be created fresh with our mocks
    final repo = getIt<UserRepository>();
    print('repo: $repo');
    final user = await repo.fetchUser('123');

    print('Fetched user: ${user?.name}');

    // Clean up
    await getIt.popScope();
  }

  setupTests();
  runTest();
}
// #endregion example
