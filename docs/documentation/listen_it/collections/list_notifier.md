# ListNotifier

A reactive List that automatically notifies listeners when its contents change.

## Overview

`ListNotifier<T>` is a reactive list implementation that:
- Extends the standard Dart `List<T>` interface
- Implements `ValueListenable<List<T>>`
- Automatically notifies listeners on mutations
- Supports transactions for batching operations
- Provides configurable notification modes

## Basic Usage

<<< @/../code_samples/lib/listen_it/list_notifier_basic.dart#example

## Creating a ListNotifier

### Empty List

```dart
final items = ListNotifier<String>();
```

### With Initial Data

```dart
final items = ListNotifier<String>(
  data: ['item1', 'item2', 'item3'],
);
```

### With Notification Mode

```dart
final items = ListNotifier<String>(
  data: ['initial'],
  notificationMode: CustomNotifierMode.normal,
);
```

### With Custom Equality

```dart
class Product {
  final String id;
  final String name;

  Product(this.id, this.name);
}

final products = ListNotifier<Product>(
  notificationMode: CustomNotifierMode.normal,
  customEquality: (a, b) => a.id == b.id,  // Compare by ID only
);
```

## Standard List Operations

ListNotifier supports all standard List operations with automatic notifications:

### Adding Elements

```dart
final items = ListNotifier<String>();

items.add('item1');              // Add single item
items.addAll(['item2', 'item3']); // Add multiple items
items.insert(0, 'first');        // Insert at index
items.insertAll(1, ['a', 'b']);  // Insert multiple at index
```

### Removing Elements

```dart
items.remove('item1');           // Remove by value
items.removeAt(0);               // Remove by index
items.removeLast();              // Remove last item
items.removeRange(0, 2);         // Remove range
items.removeWhere((item) => item.startsWith('a')); // Remove conditionally
items.retainWhere((item) => item.length > 3);      // Keep only matching
items.clear();                   // Remove all items
```

### Updating Elements

```dart
items[0] = 'updated';            // Update by index
items.setAll(0, ['a', 'b']);     // Set multiple starting at index
items.setRange(0, 2, ['x', 'y']); // Replace range
items.fillRange(0, 3, 'same');   // Fill range with same value
```

### Reordering and Sorting

```dart
items.sort();                    // Sort items
items.sort((a, b) => a.compareTo(b)); // Custom sort
items.shuffle();                 // Randomize order
items.swap(0, 1);                // Swap two elements (ListNotifier-specific)
```

### Changing Length

```dart
items.length = 10;               // Grow or shrink the list
```

## Special ListNotifier Operations

### swap()

Swap two elements by index - only notifies if elements are different:

```dart
final items = ListNotifier<int>(data: [1, 2, 3]);

items.swap(0, 2);  // ✅️ Notifies: [3, 2, 1]

// With normal mode and equal elements
final items2 = ListNotifier<int>(
  data: [1, 1, 1],
  notificationMode: CustomNotifierMode.normal,
);

items2.swap(0, 1);  // ❌️ No notification (elements are equal)
```

## Integration with Flutter

### With ValueListenableBuilder

<<< @/../code_samples/lib/listen_it/list_notifier_widget.dart#example

### With watch_it

<<< @/../code_samples/lib/listen_it/list_notifier_watch_it.dart#example

## Notification Modes

ListNotifier supports three notification modes:

### always (Default)

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.always,
);

items.add('item');   // ✅️ Notifies
items[0] = 'item';   // ✅️ Notifies (even though value unchanged)
items.remove('xyz'); // ✅️ Notifies (even though not in list)
```

### normal

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.add('item');   // ✅️ Notifies
items[0] = 'item';   // ❌️ No notification (value unchanged)
items.remove('xyz'); // ❌️ No notification (not in list)
```

### manual

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

items.add('item1');  // No notification
items.add('item2');  // No notification
items.notifyListeners();  // ✅️ Manual notification
```

[Learn more about notification modes →](/documentation/listen_it/collections/notification_modes)

## Transactions

Batch multiple operations into a single notification:

<<< @/../code_samples/lib/listen_it/transactions.dart#example

[Learn more about transactions →](/documentation/listen_it/collections/transactions)

## Immutable Value

The `.value` getter returns an unmodifiable view:

```dart
final items = ListNotifier<String>(data: ['a', 'b', 'c']);

final immutableView = items.value;
print(immutableView);  // [a, b, c]

// ❌️ Throws UnsupportedError
// immutableView.add('d');

// ✅️ Mutate through the notifier
items.add('d');  // Works and notifies
```

This ensures all mutations go through the notification system.

## Bulk Operations Behavior

ListNotifier has special behavior for bulk operations:

### Append/Insert Operations

These **always notify** (even with empty input) in all modes except manual:

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.addAll([]);       // ✅️ Notifies (even though empty)
items.insertAll(0, []); // ✅️ Notifies (even though empty)
items.setAll(0, []);    // ✅️ Notifies (even though empty)
items.setRange(0, 0, []); // ✅️ Notifies (even though empty)
```

**Why?** For performance reasons - to avoid comparing all elements. These operations are typically used for bulk loading data.

### Replace Operations

These **only notify if changes occurred** in normal mode:

```dart
final items = ListNotifier<String>(
  data: ['a', 'a', 'a'],
  notificationMode: CustomNotifierMode.normal,
);

items.fillRange(0, 3, 'a');  // ❌️ No notification (values unchanged)
items.fillRange(0, 3, 'b');  // ✅️ Notifies (values changed)

items.replaceRange(0, 2, ['b', 'b']);  // ❌️ No notification (same values)
items.replaceRange(0, 2, ['c', 'd']);  // ✅️ Notifies (values changed)
```

### Always-Notify Operations

Some operations **always trigger hasChanged** flag:

- `shuffle()` - Order changes even if values don't
- `sort()` - Order likely changes
- `swap()` - Swapping elements (but checks equality first)
- `setAll()`, `setRange()` - Bulk updates

## Use Cases

::: details Todo List

```dart
class TodoListModel {
  final todos = ListNotifier<Todo>();

  void addTodo(String title) {
    todos.add(Todo(id: generateId(), title: title, completed: false));
  }

  void toggleTodo(String id) {
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final todo = todos[index];
      todos[index] = Todo(id: todo.id, title: todo.title, completed: !todo.completed);
    }
  }

  void removeTodo(String id) {
    todos.removeWhere((t) => t.id == id);
  }

  void reorderTodos(int oldIndex, int newIndex) {
    todos.startTransAction();
    final todo = todos.removeAt(oldIndex);
    todos.insert(newIndex, todo);
    todos.endTransAction();
  }
}
```
:::

::: details Chat Messages

```dart
class ChatModel {
  final messages = ListNotifier<Message>();

  void addMessage(Message message) {
    messages.add(message);
  }

  void loadHistory(List<Message> history) {
    messages.startTransAction();
    messages.clear();
    messages.addAll(history);
    messages.endTransAction();
  }

  void deleteMessage(String messageId) {
    messages.removeWhere((m) => m.id == messageId);
  }
}
```
:::

::: details Search Results

```dart
class SearchModel {
  final results = ListNotifier<SearchResult>();
  final isSearching = ValueNotifier<bool>(false);

  Future<void> search(String query) async {
    if (query.isEmpty) {
      results.clear();
      return;
    }

    isSearching.value = true;

    try {
      final newResults = await searchApi(query);

      results.startTransAction();
      results.clear();
      results.addAll(newResults);
      results.endTransAction();
    } finally {
      isSearching.value = false;
    }
  }
}
```
:::

::: details Shopping Cart

```dart
class ShoppingCart {
  final items = ListNotifier<CartItem>(
    notificationMode: CustomNotifierMode.normal,
    customEquality: (a, b) => a.productId == b.productId,
  );

  void addItem(Product product) {
    final existingIndex = items.indexWhere((item) => item.productId == product.id);

    if (existingIndex != -1) {
      // Update quantity
      final existing = items[existingIndex];
      items[existingIndex] = CartItem(
        productId: existing.productId,
        name: existing.name,
        quantity: existing.quantity + 1,
        price: existing.price,
      );
    } else {
      // Add new item
      items.add(CartItem(
        productId: product.id,
        name: product.name,
        quantity: 1,
        price: product.price,
      ));
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.productId == productId);
  }

  double get total => items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}
```
:::

## Performance Considerations

### Memory

ListNotifier has minimal overhead compared to a regular List:
- Extends `DelegatingList` (from package:collection)
- Adds notification mechanism from `ChangeNotifier`
- Small overhead for notification mode and transaction flags

### Notifications

Each mutation triggers a notification (unless in transaction or manual mode):
- **Cost:** O(n) where n = number of listeners
- **Optimization:** Use transactions for bulk operations
- **Best practice:** Keep listener count reasonable (< 50)

### Large Lists

For very large lists (1000+ items):
- Consider pagination instead of loading all at once
- Use transactions when adding/removing many items
- Consider `normal` mode if you have many no-op operations

```dart
// ❌️ Bad: 1000 notifications
for (var i = 0; i < 1000; i++) {
  items.add(i);
}

// ✅️ Good: 1 notification
items.startTransAction();
for (var i = 0; i < 1000; i++) {
  items.add(i);
}
items.endTransAction();

// ✅️ Even better: addAll
items.startTransAction();
items.addAll(List.generate(1000, (i) => i));
items.endTransAction();
```

## Combining with Operators

You can chain listen_it operators on a ListNotifier:

```dart
final todos = ListNotifier<Todo>();

// React only when list length changes
final todoCount = todos.select<int>((list) => list.length);

// Filter to incomplete todos
final incompleteTodos = todos.where((list) => list.any((t) => !t.completed));

// Debounce rapid changes
final debouncedTodos = todos.debounce(Duration(milliseconds: 300));

// Use in widget
ValueListenableBuilder<int>(
  valueListenable: todoCount,
  builder: (context, count, _) => Text('$count todos'),
);
```

[Learn more about operators →](/documentation/listen_it/operators/overview)

## API Reference

### Constructor

```dart
ListNotifier({
  List<T>? data,
  CustomNotifierMode notificationMode = CustomNotifierMode.always,
  bool Function(T, T)? customEquality,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `value` | `List<T>` | Unmodifiable view of current list |
| `length` | `int` | Number of elements (setter triggers notification) |
| `first` | `T` | First element |
| `last` | `T` | Last element |
| `isEmpty` | `bool` | Whether list is empty |
| `isNotEmpty` | `bool` | Whether list has elements |

### Methods

All standard `List<T>` methods plus:

| Method | Description |
|--------|-------------|
| `swap(int index1, int index2)` | Swap two elements |
| `startTransAction()` | Begin transaction |
| `endTransAction()` | End transaction and notify |
| `notifyListeners()` | Manually notify (useful with manual mode) |

## Common Pitfalls

### 1. Modifying the .value View

```dart
// ❌️ Don't try to modify the .value getter
final view = items.value;
view.add('item');  // Throws UnsupportedError!

// ✅️ Modify through the notifier
items.add('item');
```

### 2. Forgetting Transactions

```dart
// ❌️ Many notifications
for (final item in newItems) {
  items.add(item);
}

// ✅️ Single notification
items.startTransAction();
for (final item in newItems) {
  items.add(item);
}
items.endTransAction();
```

### 3. Nested Transactions

```dart
// ❌️ Will throw assertion error
items.startTransAction();
items.add('a');
items.startTransAction();  // ERROR!

// ✅️ End first transaction before starting another
items.startTransAction();
items.add('a');
items.endTransAction();

items.startTransAction();
items.add('b');
items.endTransAction();
```

## Next Steps

- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Notification Modes →](/documentation/listen_it/collections/notification_modes)
- [Transactions →](/documentation/listen_it/collections/transactions)
- [Back to Collections →](/documentation/listen_it/collections/introduction)
