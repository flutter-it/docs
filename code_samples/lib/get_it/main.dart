import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  setUpAll(() {
    // Register app dependencies
    getIt.registerLazySingleton<ThemeService>(() => ThemeServiceImpl());
    getIt.registerLazySingleton<UserService>(
        () => UserServiceImpl(ApiClient('http://localhost')));
  });

  testWidgets('LoginPage displays user after successful login', (tester) async {
    // Arrange - push scope with mock
    getIt.pushNewScope();
    final mockUser = MockUserService();
    getIt.registerSingleton<UserService>(mockUser);

    // Act
    await tester.pumpWidget(const MyApp());
    await tester.enterText(find.byKey(const Key('username')), 'alice');
    await tester.enterText(find.byKey(const Key('password')), 'secret');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Welcome, Alice'), findsOneWidget);

    // Cleanup
    await getIt.popScope();
  });
}
// #endregion example
