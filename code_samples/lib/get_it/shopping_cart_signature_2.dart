// ignore_for_file: missing_function_body, unused_element
test('factory creates new instance each time', () {
  getIt.pushNewScope();

  getIt.registerFactory<ShoppingCart>(() => ShoppingCart());

  final cart1 = getIt<ShoppingCart>();
  final cart2 = getIt<ShoppingCart>();

  expect(identical(cart1, cart2), false); // Different instances

  await getIt.popScope();
});