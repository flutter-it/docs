import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  group('UserService Tests', () {
    setUp(() {
      // Call your app's real DI initialization
      configureDependencies();

      // Push scope to shadow specific services with test doubles
      getIt.pushNewScope();
      getIt.registerSingleton<ApiClient>(MockApiClient());
      getIt.registerSingleton<Database>(MockDatabase());

      // UserService uses real implementation but gets mock dependencies
    });

    tearDown(() async {
      // Pop scope - removes mocks, restores real services
      await getIt.popScope();
    });

    test('should load user data', () async {
      // UserService gets MockApiClient and MockDatabase automatically
      final service = getIt<UserService>();
      print('service: $service');
      final user = await service.loadUser('123');
      expect(user.id, '123');
    });
  });
  // #endregion example
}
