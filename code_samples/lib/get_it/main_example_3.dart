import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  final getIt = GetIt.instance;

  setUpAll(() {
    // Register all real dependencies once
    getIt.registerLazySingleton<ApiClient>(() => ApiClientImpl());
    getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl(getIt()));
    getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt(), getIt()));
  });

  group('UserRepository tests', () {
    late MockApiClient mockApi;
    late MockAuthService mockAuth;

    setUp(() {
      // Push scope and shadow only the services we want to mock
      getIt.pushNewScope();

      mockApi = MockApiClient();
      mockAuth = MockAuthService();

      getIt.registerSingleton<ApiClient>(mockApi);
      getIt.registerSingleton<AuthService>(mockAuth);

      // UserRepository will be created fresh with our mocks
    });

    tearDown(() async {
      await getIt.popScope();
    });

    test('fetchUser should call API with correct auth token', () async {
      // Arrange
      when(mockAuth.getToken()).thenReturn('test-token');
      when(mockApi.get('/users/123', headers: anyNamed('headers')))
          .thenAnswer((_) async => Response(data: {'id': '123', 'name': 'Alice'}));

      // Act
      final repo = getIt<UserRepository>();
      final user = await repo.fetchUser('123');

      // Assert
      expect(user.name, 'Alice');
      verify(mockAuth.getToken()).called(1);
      verify(mockApi.get('/users/123', headers: {'Authorization': 'Bearer test-token'})).called(1);
    });
  });
}
// #endregion example