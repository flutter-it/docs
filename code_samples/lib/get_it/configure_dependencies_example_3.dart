import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Use interface when you have multiple versions
abstract class PaymentProcessor {
  Future<void> processPayment(double amount);
}

class StripePaymentProcessor implements PaymentProcessor { ... }
class PayPalPaymentProcessor implements PaymentProcessor { ... }

// Register by interface
void configureDependencies() {
  getIt.registerSingleton<PaymentProcessor>(StripePaymentProcessor());
}
// #endregion example