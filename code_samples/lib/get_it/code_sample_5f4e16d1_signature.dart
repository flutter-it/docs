// ignore_for_file: missing_function_body, unused_element
test('factory param passes parameters correctly', () {
  getIt.pushNewScope();

  getIt.registerFactoryParam<UserViewModel, String, void>(
    (userId, _) => UserViewModel(userId),
  );

  final vm = getIt<UserViewModel>(param1: 'user-123');
  expect(vm.userId, 'user-123');

  await getIt.popScope();
});