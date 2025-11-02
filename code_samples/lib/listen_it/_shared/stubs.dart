// Stub classes used across listen_it code samples

import 'package:flutter/material.dart';

// Export commonly used packages so examples can just import stubs.dart
export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart';
export 'package:listen_it/listen_it.dart';
export 'package:watch_it/watch_it.dart';

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

// Todo and TodoTile for transaction examples
class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo({required this.id, required this.title, this.completed = false});

  @override
  String toString() => 'Todo($title${completed ? " ✓" : ""})';
}

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile(this.todo, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(todo.id),
      title: Text(todo.title),
      leading: Checkbox(value: todo.completed, onChanged: (_) {}),
    );
  }
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
