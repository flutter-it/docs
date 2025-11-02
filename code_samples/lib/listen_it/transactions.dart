import '_shared/stubs.dart';

// #region example
void main() {
  final products = ListNotifier<Product>(data: []);

  // Listen to changes
  products.listen((list, _) => print('Products updated: ${list.length} items'));

  final product1 = Product(id: '1', name: 'Widget', price: 9.99);
  final product2 = Product(id: '2', name: 'Gadget', price: 19.99);
  final product3 = Product(id: '3', name: 'Doohickey', price: 29.99);

  print('--- Without transaction: 3 notifications ---');
  products.add(product1); // Notification 1
  products.add(product2); // Notification 2
  products.add(product3); // Notification 3

  products.clear();

  print('\n--- With transaction: 1 notification ---');
  products.startTransAction();
  products.add(product1); // No notification
  products.add(product2); // No notification
  products.add(product3); // No notification
  products.endTransAction(); // Single notification for all 3 adds
}
// #endregion example
