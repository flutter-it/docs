import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

// Stub classes for the example
class Cart {
  final List<String> items;
  final double total;

  Cart(this.items, this.total);

  static Cart empty() => Cart([], 0.0);
}

class Order {
  final String id;
  final List<String> items;

  Order(this.id, this.items);
}

class CheckoutState {
  final Cart cart;
  final Order? order;

  CheckoutState(this.cart, this.order);
}

// Extend ApiClient with checkout methods
extension CheckoutApi on ApiClient {
  Future<String> reserveInventory(List<String> items) async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'reservation-123';
  }

  Future<String> processPayment(double total) async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'payment-456';
  }

  Future<Order> createOrder(String reservation, String payment) async {
    await Future.delayed(Duration(milliseconds: 100));
    return Order('order-789', ['item1', 'item2']);
  }
}

// #region example
class CheckoutService {
  final cart = ValueNotifier<Cart>(Cart.empty());
  final order = ValueNotifier<Order?>(null);

  late final checkoutCommand =
      Command.createUndoableNoParamNoResult<CheckoutState>(
    (stack) async {
      // Capture state snapshot before execution
      stack.push(CheckoutState(cart.value, order.value));

      // Step 1: Reserve inventory
      final reservation =
          await getIt<ApiClient>().reserveInventory(cart.value.items);

      // Step 2: Process payment
      final payment = await getIt<ApiClient>().processPayment(cart.value.total);

      // Step 3: Create order
      final newOrder =
          await getIt<ApiClient>().createOrder(reservation, payment);

      // Update state
      order.value = newOrder;
      cart.value = Cart.empty();

      // If any step fails, all state automatically rolls back
    },
    undo: (stack, reason) async {
      // Restore previous state
      final previousState = stack.pop();
      cart.value = previousState.cart;
      order.value = previousState.order;
    },
  );
}
// #endregion example

void main() {
  setupDependencyInjection();

  final service = CheckoutService();
  service.cart.value = Cart(['item1', 'item2'], 29.99);

  // Test checkout
  service.checkoutCommand();
}
