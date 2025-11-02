import '_shared/stubs.dart';

// #region example
class ShoppingCart {
  final items = MapNotifier<String, CartItem>();

  void addItem(Product product) {
    items[product.id] = CartItem(product: product, quantity: 1);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      items.remove(productId);
    } else {
      final currentItem = items[productId];
      if (currentItem != null) {
        items[productId] = currentItem.copyWith(quantity: quantity);
      }
    }
  }

  double get total =>
      items.values.fold(0.0, (sum, item) => sum + item.price * item.quantity);
}

void main() {
  final cart = ShoppingCart();

  // Listen to cart changes
  cart.items.listen((items, _) {
    print('Cart updated: ${items.length} items, total: \$${cart.total}');
  });

  final widget = Product(id: '1', name: 'Widget', price: 9.99);
  final gadget = Product(id: '2', name: 'Gadget', price: 19.99);

  cart.addItem(widget);
  // Cart updated: 1 items, total: $9.99

  cart.addItem(gadget);
  // Cart updated: 2 items, total: $29.98

  cart.updateQuantity('1', 3);
  // Cart updated: 2 items, total: $49.96

  cart.updateQuantity('2', 0); // Remove gadget
  // Cart updated: 1 items, total: $29.97
}
// #endregion example
