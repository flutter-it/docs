// ignore_for_file: missing_function_body, unused_element
void main() {
  setUpAll(() {
    // Register app dependencies
    getIt.registerLazySingleton<ThemeService>(() => ThemeServiceImpl());
    getIt.registerLazySingleton<UserService>(() => UserServiceImpl());
  });

  testWidgets('LoginPage displays user after successful login', (tester) async {
    // Arrange - push scope with mock
    getIt.pushNewScope();
    final mockUser = MockUserService();
    when(mockUser.login(any, any)).thenAnswer((_) async => User(name: 'Alice'));
    getIt.registerSingleton<UserService>(mockUser);

    // Act
    await tester.pumpWidget(MyApp());
    await tester.enterText(find.byKey(Key('username')), 'alice');
    await tester.enterText(find.byKey(Key('password')), 'secret');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Welcome, Alice'), findsOneWidget);

    // Cleanup
    await getIt.popScope();
  });
}
