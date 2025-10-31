import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
const featureFlagEnabled = true;

void main() async {
  // Setup base scope with original checkout
  final userService = await UserService.load();
  getIt.registerSingleton<CheckoutService>(CheckoutService(userService));

  if (featureFlagEnabled) {
    getIt.pushNewScope(scopeName: 'feature-new-checkout');
    getIt.registerSingleton<CheckoutService>(NewCheckoutService(userService));
  } else {
    // Uses base scope's original CheckoutService
  }

  print('Checkout service: ${getIt<CheckoutService>()}');
}
// #endregion example
