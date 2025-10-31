// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
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
