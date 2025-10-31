// ignore_for_file: missing_function_body, unused_element
test('widget works with async services', () async {
  getIt.pushNewScope();

  // Register async mock
  getIt.registerSingletonAsync<Database>(() async {
    await Future.delayed(Duration(milliseconds: 100));
    return MockDatabase();
  });

  // Wait for all async registrations
  await getIt.allReady();

  // Now safe to test
  final db = getIt<Database>();
  expect(db, isA<MockDatabase>());

  await getIt.popScope();
});