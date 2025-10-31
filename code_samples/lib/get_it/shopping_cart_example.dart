import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.registerFactory<ShoppingCart>(() => ShoppingCart());
  final cart1 = getIt<ShoppingCart>(); // New instance
  final cart2 = getIt<ShoppingCart>(); // Different instance
}
// #endregion example
