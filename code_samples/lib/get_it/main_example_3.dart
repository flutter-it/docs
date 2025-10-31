// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '_shared/stubs.dart'
    hide group, setUpAll, tearDownAll, testWidgets, expect;

final getIt = GetIt.instance;

void main() {
  // #region example
  group('End-to-end user flow', () {
    setUpAll(() async {
      // Push scope for integration test environment
      getIt.pushNewScope(
        scopeName: 'integration-test',
        init: (scope) {
          // Mock only external dependencies
          scope.registerSingleton<ApiClient>(FakeApiClient());
          scope.registerSingleton<SecureStorage>(SecureStorage());

          // Use real implementations for everything else
          scope.registerLazySingleton<AuthService>(() => AuthServiceImpl());
          scope.registerLazySingleton<UserRepository>(() => UserRepository());
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
  // #endregion example
}
