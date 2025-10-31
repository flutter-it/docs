// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Use interface when you have multiple versions
abstract class PaymentProcessor {
  Future<void> processPayment(double amount);
}

class StripePaymentProcessor implements PaymentProcessor {
  @override
  Future<void> processPayment(double amount) async {}
}

class PayPalPaymentProcessor implements PaymentProcessor {
  @override
  Future<void> processPayment(double amount) async {}
}

// Register by interface
void configureDependencies() {
  getIt.registerSingleton<PaymentProcessor>(StripePaymentProcessor());
}

// #endregion example

void main() {
  // #region example
  configureDependencies();
  // #endregion example
}
