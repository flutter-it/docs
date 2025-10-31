import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  test('factory creates new instance each time', () async {
    getIt.pushNewScope();

    getIt.registerFactory<ShoppingCart>(() => ShoppingCart());

    final cart1 = getIt<ShoppingCart>();
    print('cart1: $cart1');
    final cart2 = getIt<ShoppingCart>();
    print('cart2: $cart2');

    expect(identical(cart1, cart2), false); // Different instances

    await getIt.popScope();
  });
}
// #endregion example
