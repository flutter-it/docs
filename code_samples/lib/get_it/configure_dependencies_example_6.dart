import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  void configureDependencies() {
    getIt.registerFactory<ShoppingCart>(() => ShoppingCart());
  }

// Each call creates a NEW instance
  final cart1 = getIt<ShoppingCart>();
  print('cart1: $cart1'); // New ShoppingCart()
  final cart2 = getIt<ShoppingCart>();
  print('cart2: $cart2'); // Different ShoppingCart()

  print(identical(cart1, cart2)); // false - different objects
}
// #endregion example
