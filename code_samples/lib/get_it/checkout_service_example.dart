import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  if (featureFlagEnabled) {
    getIt.pushNewScope(scopeName: 'feature-new-checkout');
    getIt.registerSingleton<CheckoutService>(NewCheckoutService());
  } else {
    // Uses base scope's original CheckoutService
  }
}
// #endregion example
