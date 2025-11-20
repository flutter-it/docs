import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// #region example
// Interface
abstract class PaymentProcessor {
  Future<void> processPayment(double amount);
}

// Real implementation
class StripePaymentProcessor implements PaymentProcessor {
  @override
  Future<void> processPayment(double amount) async {
    // Real Stripe API call
  }
}

// Mock implementation for testing
class MockPaymentProcessor implements PaymentProcessor {
  @override
  Future<void> processPayment(double amount) async {
    // Mock - no real API call
  }
}

// Configure with conditional registration
void configureDependencies({bool isTesting = false}) {
  if (isTesting) {
    // Register mock for testing
    getIt.registerSingleton<PaymentProcessor>(MockPaymentProcessor());
  } else {
    // Register real implementation for production
    getIt.registerSingleton<PaymentProcessor>(StripePaymentProcessor());
  }
}

// Business logic - works with either implementation!
class CheckoutService {
  Future<void> processOrder(double amount) {
    // The <PaymentProcessor> type parameter is what enables the switch
    // Without it, mock and real would register as different types
    final processor = getIt<PaymentProcessor>();
    return processor.processPayment(amount);
  }
}
// #endregion example

void main() {
  // Test scenario
  configureDependencies(isTesting: true);
  final testService = CheckoutService();
  testService.processOrder(99.99);

  // Reset for production scenario
  getIt.reset();
  configureDependencies(isTesting: false);
  final prodService = CheckoutService();
  prodService.processOrder(99.99);
}
