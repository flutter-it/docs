// ignore_for_file: missing_function_body, unused_element
test('service lifecycle matches scope lifecycle', () async {
  // Base scope
  getIt.registerLazySingleton<CoreService>(() => CoreService());

  // Feature scope
  getIt.pushNewScope(scopeName: 'feature');
  getIt.registerLazySingleton<FeatureService>(() => FeatureService(getIt()));

  expect(getIt<CoreService>(), isNotNull);
  expect(getIt<FeatureService>(), isNotNull);

  // Pop feature scope
  await getIt.popScope();

  expect(getIt<CoreService>(), isNotNull); // Still available
  expect(() => getIt<FeatureService>(), throwsStateError); // Gone!
});