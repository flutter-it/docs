# Collections Introduction

Reactive collections automatically notify listeners when their contents change, making it easy to build reactive UIs without manual `notifyListeners()` calls.

## What Are Reactive Collections?

listen_it provides three reactive collection types that implement `ValueListenable`:

- **[ListNotifier\<T\>](/documentation/listen_it/collections/list_notifier)** - Reactive list with automatic notifications
- **[MapNotifier\<K,V\>](/documentation/listen_it/collections/map_notifier)** - Reactive map with automatic notifications
- **[SetNotifier\<T\>](/documentation/listen_it/collections/set_notifier)** - Reactive set with automatic notifications

Each collection type extends the standard Dart collection interface (List, Map, Set) and adds reactive capabilities.

## Quick Example

<<< @/../code_samples/lib/listen_it/list_notifier_basic.dart#example

## Key Features

### 1. Automatic Notifications

Every mutation operation automatically notifies listeners:

```dart
final items = ListNotifier<String>();

items.listen((list, _) => print('List changed: $list'));

items.add('item1');        // ✅ Notifies
items.addAll(['a', 'b']);  // ✅ Notifies
items[0] = 'updated';      // ✅ Notifies
items.removeAt(0);         // ✅ Notifies
```

### 2. Notification Modes

Control when notifications fire with three modes:

- **always** (default) - Notify on every operation, even if value doesn't change
- **normal** - Only notify when value actually changes (using `==` or custom equality)
- **manual** - No automatic notifications, call `notifyListeners()` manually

[Learn why the default notifies always →](/documentation/listen_it/collections/notification_modes)

### 3. Transactions

Batch multiple operations into a single notification:

```dart
final items = ListNotifier<int>();

items.startTransAction();
items.add(1);
items.add(2);
items.add(3);
items.endTransAction();  // Single notification for all 3 adds
```

[Learn more about transactions →](/documentation/listen_it/collections/transactions)

### 4. Immutable Values

The `.value` getter returns an unmodifiable view:

```dart
final items = ListNotifier<String>(data: ['a', 'b']);

final immutableView = items.value;  // UnmodifiableListView
// immutableView.add('c');  // ❌ Throws UnsupportedError
```

This ensures all mutations go through the notification system.

### 5. ValueListenable Interface

All collections implement `ValueListenable`, so they work with:

- `ValueListenableBuilder` - Standard Flutter reactive widget
- `watch_it` - For cleaner reactive code
- Any other state management solution that observes Listenables
- All listen_it [operators](/documentation/listen_it/operators/overview) - Chain transformations on collections

## Use Cases

### ListNotifier - Ordered Collections

Use when order matters and duplicates are allowed:

- Todo lists
- Chat message history
- Search results
- Activity feeds
- Recently viewed items

### MapNotifier - Key-Value Storage

Use when you need fast lookups by key:

- User preferences
- Form data
- Caches
- Configuration settings
- ID-to-object mappings

```dart
final preferences = MapNotifier<String, dynamic>(
  data: {'theme': 'dark', 'fontSize': 14},
);

preferences.listen((map, _) => savePreferences(map));

preferences['theme'] = 'light';  // ✅ Notifies
```

### SetNotifier - Unique Collections

Use when you need unique items and fast membership tests:

- Selected item IDs
- Active filters
- Tags
- Unique categories
- User permissions

```dart
final selectedIds = SetNotifier<String>(data: {});

selectedIds.listen((set, _) => print('Selection changed: $set'));

selectedIds.add('item1');  // ✅ Notifies
selectedIds.add('item1');  // No duplicate added (Set behavior)
```

## Integration with Flutter

### With ValueListenableBuilder

Standard Flutter approach:

<<< @/../code_samples/lib/listen_it/list_notifier_widget.dart#example

### With [watch_it](/documentation/watch_it/getting_started) (Recommended!)

Cleaner, more concise:

<<< @/../code_samples/lib/listen_it/list_notifier_watch_it.dart#example

## Choosing the Right Collection

| Collection | When to Use | Example |
|------------|-------------|---------|
| **ListNotifier\<T\>** | Order matters, duplicates allowed | Todo lists, message history |
| **MapNotifier\<K,V\>** | Need key-value lookups | Settings, caches, form data |
| **SetNotifier\<T\>** | Unique items, fast membership tests | Selected IDs, filters, tags |

## Common Patterns

### Initialize with Data

All collections accept initial data:

```dart
final items = ListNotifier<String>(data: ['a', 'b', 'c']);
final prefs = MapNotifier<String, int>(data: {'count': 42});
final tags = SetNotifier<String>(data: {'flutter', 'dart'});
```

### Listen to Changes

Use `.listen()` for side effects outside the widget tree:

```dart
final cart = ListNotifier<Product>();

cart.listen((products, _) {
  final total = products.fold(0.0, (sum, p) => sum + p.price);
  print('Cart total: \$$total');
});
```

### Batch Operations with Transactions

Improve performance by batching updates:

<<< @/../code_samples/lib/listen_it/transactions.dart#example

### Choose Notification Mode

Default is `always` because users expect the UI to rebuild on every operation. Using `normal` mode could surprise users if the UI doesn't update when they perform an operation (like adding an item that already exists), but you can optimize with `normal` when you understand the trade-offs:

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.add('item1');  // ✅ Notifies
items.add('item1');  // ❌ No notification (duplicate in set/map, or no change)
```

## Why Reactive Collections?

### Without Reactive Collections

```dart
class TodoList extends ValueNotifier<List<Todo>> {
  TodoList() : super([]);

  void addTodo(Todo todo) {
    value.add(todo);
    notifyListeners();  // Manual notification
  }

  void removeTodo(int index) {
    value.removeAt(index);
    notifyListeners();  // Manual notification
  }

  void updateTodo(int index, Todo todo) {
    value[index] = todo;
    notifyListeners();  // Manual notification
  }
}
```

### With ListNotifier

```dart
final todos = ListNotifier<Todo>();

todos.add(todo);           // ✅ Automatic notification
todos.removeAt(index);     // ✅ Automatic notification
todos[index] = updatedTodo; // ✅ Automatic notification
```

**Benefits:**
- ✅ Less boilerplate
- ✅ Standard List/Map/Set APIs
- ✅ Automatic notifications
- ✅ Transaction support for batching

## Next Steps

- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Notification Modes →](/documentation/listen_it/collections/notification_modes)
- [Transactions →](/documentation/listen_it/collections/transactions)
