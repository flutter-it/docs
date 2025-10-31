// ignore_for_file: missing_function_body, unused_element
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
    final user = await service.loadUser('123');
    expect(user.id, '123');
  });
});