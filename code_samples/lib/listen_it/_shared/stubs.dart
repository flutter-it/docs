// Stub classes used across listen_it code samples

// Export commonly used packages so examples can just import stubs.dart
export 'package:flutter/foundation.dart';
export 'package:listen_it/listen_it.dart';

// User model for select() examples
class User {
  final int age;
  final String name;

  User({required this.age, required this.name});

  @override
  String toString() => 'User(age: $age, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          age == other.age &&
          name == other.name;

  @override
  int get hashCode => age.hashCode ^ name.hashCode;
}

// Product and CartItem for shopping cart examples
class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  @override
  String toString() => 'Product($id: $name, \$$price)';
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get price => product.price;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() =>
      'CartItem(${product.name} x$quantity = \$${price * quantity})';
}

// SearchResult for search examples
class SearchResult {
  final String title;
  final String description;

  SearchResult({required this.title, required this.description});

  @override
  String toString() => 'SearchResult($title)';
}

// StringIntWrapper for combineLatest examples
class StringIntWrapper {
  final String s;
  final int i;

  StringIntWrapper(this.s, this.i);

  @override
  String toString() => '$s:$i';
}

// Mock API functions
Future<void> callRestApi(String searchTerm) async {
  // Simulate API call
  await Future.delayed(Duration(milliseconds: 100));
  print('API called with: $searchTerm');
}

Future<List<SearchResult>> searchApi(String term) async {
  // Simulate API call
  await Future.delayed(Duration(milliseconds: 200));
  return [
    SearchResult(title: 'Result for $term', description: 'Description'),
    SearchResult(title: 'Another $term result', description: 'More details'),
  ];
}
