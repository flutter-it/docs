import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end user flow', () {
    setUpAll(() async {
      // Push scope for integration test environment
      getIt.pushNewScope(
        scopeName: 'integration-test',
        init: (scope) {
          // Mock only external dependencies
          scope.registerSingleton<ApiClient>(FakeApiClient());
          scope.registerSingleton<SecureStorage>(InMemoryStorage());

          // Use real implementations for everything else
          scope.registerLazySingleton<AuthService>(
              () => AuthServiceImpl(getIt()));
          scope.registerLazySingleton<UserRepository>(
              () => UserRepository(getIt()));
        },
      );
    });

    tearDownAll(() async {
      await getIt.popScope();
    });

    testWidgets('User can login and view profile', (tester) async {
      await tester.pumpWidget(MyApp());

      // Interact with real UI + real services + fake backend
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
// #endregion example
