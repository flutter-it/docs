// ignore_for_file: missing_function_body, unused_element
test('complex service uses all dependencies correctly', () {
  getIt.pushNewScope();

  // Mock all dependencies
  final mockApi = MockApiClient();
  final mockDb = MockDatabase();
  final mockAuth = MockAuthService();

  getIt.registerSingleton<ApiClient>(mockApi);
  getIt.registerSingleton<Database>(mockDb);
  getIt.registerSingleton<AuthService>(mockAuth);

  // Service under test (uses real implementation)
  getIt.registerLazySingleton<SyncService>(() => SyncService(
    getIt<ApiClient>(),
    getIt<Database>(),
    getIt<AuthService>(),
  ));

  when(mockAuth.isAuthenticated).thenReturn(true);
  when(mockApi.fetchData()).thenAnswer((_) async => ['data']);

  final sync = getIt<SyncService>();
  // Test sync behavior...

  await getIt.popScope();
});