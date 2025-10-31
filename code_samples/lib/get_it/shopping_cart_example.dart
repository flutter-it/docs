import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  getIt.registerFactory<ShoppingCart>(() => ShoppingCart());
  final cart1 = getIt<ShoppingCart>();
  print('cart1: $cart1'); // New instance
  final cart2 = getIt<ShoppingCart>();
  print('cart2: $cart2'); // Different instance
  // #endregion example
}
