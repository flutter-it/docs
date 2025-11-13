# SetNotifier

A reactive Set that automatically notifies listeners when its contents change.

## Overview

`SetNotifier<T>` is a reactive set implementation that:
- Extends the standard Dart `Set<T>` interface
- Implements `ValueListenable<Set<T>>`
- Automatically notifies listeners on mutations
- Supports transactions for batching operations
- Provides configurable notification modes
- Guarantees uniqueness of elements (Set behavior)

## Basic Usage

```dart
final selectedIds = SetNotifier<String>(data: {});

selectedIds.listen((set, _) => print('Selected: $set'));

selectedIds.add('id1');  // ✅ Notifies
selectedIds.add('id2');  // ✅ Notifies
selectedIds.add('id1');  // No duplicate added (Set behavior)
```

## Creating a SetNotifier

### Empty Set

```dart
final tags = SetNotifier<String>();
```

### With Initial Data

```dart
final permissions = SetNotifier<String>(
  data: {'read', 'write'},
);
```

### With Notification Mode

```dart
final selectedItems = SetNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);
```

### No Custom Equality

**Important:** Unlike `ListNotifier` and `MapNotifier`, `SetNotifier` does **NOT** support custom equality functions. Sets inherently use `==` and `hashCode` for membership testing. Custom equality would only apply to notification decisions, which could be confusing.

```dart
// ❌ SetNotifier doesn't have customEquality parameter
// final items = SetNotifier<Product>(
//   customEquality: (a, b) => a.id == b.id,  // NOT SUPPORTED
// );

// ✅ Override == and hashCode in your class instead
class Product {
  final String id;
  final String name;

  Product(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

final products = SetNotifier<Product>();
```

## Standard Set Operations

SetNotifier supports all standard Set operations with automatic notifications:

### Adding Elements

```dart
final tags = SetNotifier<String>();

tags.add('flutter');           // Add single element
tags.addAll(['dart', 'web']);  // Add multiple elements
```

### Removing Elements

```dart
tags.remove('flutter');           // Remove by value
tags.removeAll({'dart', 'web'});  // Remove multiple
tags.retainAll({'flutter'});      // Keep only specified
tags.removeWhere((tag) => tag.startsWith('old_')); // Remove conditionally
tags.retainWhere((tag) => tag.length > 3);         // Keep only matching
tags.clear();                     // Remove all elements
```

### Set Operations

Standard set operations return **new sets** and don't modify the current set, so they don't trigger notifications:

```dart
final set1 = SetNotifier<int>(data: {1, 2, 3});
final set2 = {2, 3, 4};

// These return new sets, don't modify set1, no notifications
final union = set1.union(set2);            // {1, 2, 3, 4}
final intersection = set1.intersection(set2); // {2, 3}
final difference = set1.difference(set2);   // {1}
```

If you want to apply these operations and trigger notification:

```dart
final result = set1.union(set2);
set1.startTransAction();
set1.clear();
set1.addAll(result);
set1.endTransAction();  // Notification
```

### Membership Testing

```dart
tags.contains('flutter');     // Check if element exists
tags.containsAll({'flutter', 'dart'}); // Check if all exist
tags.lookup('flutter');       // Get canonical element
```

## Integration with Flutter

### With ValueListenableBuilder

<<< @/../code_samples/lib/listen_it/set_notifier_widget.dart#example

### With watch_it

<<< @/../code_samples/lib/listen_it/set_notifier_watch_it.dart#example

## Notification Modes

SetNotifier supports three notification modes:

### always (Default)

```dart
final items = SetNotifier<String>(
  data: {'item1'},
  notificationMode: CustomNotifierMode.always,
);

items.add('item1');  // ✅ Notifies (even though already exists)
items.add('item2');  // ✅ Notifies
items.remove('xyz'); // ✅ Notifies (even though doesn't exist)
```

**Why default?** Without seeing the return value of `add()` or `remove()`, users might expect UI updates when they perform operations.

### normal

```dart
final items = SetNotifier<String>(
  data: {'item1'},
  notificationMode: CustomNotifierMode.normal,
);

items.add('item1');  // ❌ No notification (already exists)
items.add('item2');  // ✅ Notifies (new element)
items.remove('xyz'); // ❌ No notification (doesn't exist)
```

**Best for:** Optimizing performance when you have many duplicate add/remove attempts.

### manual

```dart
final items = SetNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

items.add('item1');  // No notification
items.add('item2');  // No notification
items.notifyListeners();  // ✅ Manual notification
```

[Learn more about notification modes →](/documentation/listen_it/collections/notification_modes)

## Transactions

Batch multiple operations into a single notification:

```dart
final tags = SetNotifier<String>();

tags.startTransAction();
tags.add('flutter');
tags.add('dart');
tags.add('web');
tags.endTransAction();  // Single notification
```

[Learn more about transactions →](/documentation/listen_it/collections/transactions)

## Immutable Value

The `.value` getter returns an unmodifiable view:

```dart
final items = SetNotifier<String>(data: {'a', 'b'});

final immutableView = items.value;
print(immutableView);  // {a, b}

// ❌ Throws UnsupportedError
// immutableView.add('c');

// ✅ Mutate through the notifier
items.add('c');  // Works and notifies
```

This ensures all mutations go through the notification system.

## Bulk Operations Behavior

SetNotifier bulk operations **always notify** (even with empty input) in all modes except manual:

```dart
final items = SetNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.addAll({});       // ✅ Notifies (even though empty)
items.removeAll({});    // ✅ Notifies (even though empty)
items.retainAll({});    // ✅ Notifies (even though empty)
```

**Why?** For performance reasons - to avoid comparing all elements. These operations are typically used for bulk updates.

## Use Cases

::: details Selected Items

```dart
class SelectionModel<T> {
  final selected = SetNotifier<T>();

  bool isSelected(T item) => selected.contains(item);

  void toggle(T item) {
    if (selected.contains(item)) {
      selected.remove(item);
    } else {
      selected.add(item);
    }
  }

  void selectAll(Iterable<T> items) {
    selected.startTransAction();
    selected.addAll(items);
    selected.endTransAction();
  }

  void clearSelection() {
    selected.clear();
  }

  int get selectionCount => selected.length;
}
```
:::

::: details Active Filters

```dart
class FilterModel {
  final activeFilters = SetNotifier<String>(
    data: {},
    notificationMode: CustomNotifierMode.normal,
  );

  void toggleFilter(String filter) {
    if (activeFilters.contains(filter)) {
      activeFilters.remove(filter);
    } else {
      activeFilters.add(filter);
    }
  }

  void clearFilters() {
    activeFilters.clear();
  }

  void setFilters(Set<String> filters) {
    activeFilters.startTransAction();
    activeFilters.clear();
    activeFilters.addAll(filters);
    activeFilters.endTransAction();
  }

  bool isActive(String filter) => activeFilters.contains(filter);
}
```
:::

::: details Tags Management

```dart
class TagsModel {
  final tags = SetNotifier<String>();

  void addTag(String tag) {
    if (tag.trim().isNotEmpty) {
      tags.add(tag.trim().toLowerCase());
    }
  }

  void addTags(Iterable<String> newTags) {
    tags.startTransAction();
    for (final tag in newTags) {
      if (tag.trim().isNotEmpty) {
        tags.add(tag.trim().toLowerCase());
      }
    }
    tags.endTransAction();
  }

  void removeTag(String tag) {
    tags.remove(tag.toLowerCase());
  }

  bool hasTag(String tag) => tags.contains(tag.toLowerCase());

  void clearTags() {
    tags.clear();
  }

  List<String> get sortedTags => tags.toList()..sort();
}
```
:::

::: details User Permissions

```dart
class PermissionsModel {
  final permissions = SetNotifier<String>(
    data: {'read'},  // Default permission
    notificationMode: CustomNotifierMode.normal,
  );

  void grantPermission(String permission) {
    permissions.add(permission);
  }

  void revokePermission(String permission) {
    permissions.remove(permission);
  }

  void setPermissions(Set<String> newPermissions) {
    permissions.startTransAction();
    permissions.clear();
    permissions.addAll(newPermissions);
    permissions.endTransAction();
  }

  bool hasPermission(String permission) => permissions.contains(permission);

  bool hasAllPermissions(Iterable<String> required) =>
      permissions.containsAll(required);

  bool hasAnyPermission(Iterable<String> options) =>
      options.any((p) => permissions.contains(p));
}
```
:::

## Performance Considerations

### Memory

SetNotifier has minimal overhead compared to a regular Set:
- Extends `DelegatingSet` (from package:collection)
- Adds notification mechanism from `ChangeNotifier`
- Small overhead for notification mode and transaction flags

### Notifications

Each mutation triggers a notification (unless in transaction or manual mode):
- **Cost:** O(n) where n = number of listeners
- **Optimization:** Use transactions for bulk operations
- **Best practice:** Keep listener count reasonable (< 50)

### Set Operations Performance

- `add()`, `remove()`, `contains()`: O(1) average case
- `addAll()`, `removeAll()`: O(m) where m = input size
- `union()`, `intersection()`, `difference()`: O(n + m) where n, m are set sizes

### Large Sets

For very large sets (1000+ elements):
- Consider pagination or lazy loading
- Use transactions when adding/removing many elements
- Consider `normal` mode if you have many duplicate operations

```dart
// ❌ Bad: 1000 notifications
for (final item in items) {
  set.add(item);
}

// ✅ Good: 1 notification
set.startTransAction();
for (final item in items) {
  set.add(item);
}
set.endTransAction();

// ✅ Even better: addAll
set.startTransAction();
set.addAll(items);
set.endTransAction();
```

## Combining with Operators

You can chain listen_it operators on a SetNotifier:

```dart
final tags = SetNotifier<String>();

// React only when set size changes
final tagCount = tags.select<int>((set) => set.length);

// Filter to non-empty sets
final hasTags = tags.where((set) => set.isNotEmpty);

// Debounce rapid changes
final debouncedTags = tags.debounce(Duration(milliseconds: 300));

// Use in widget
ValueListenableBuilder<int>(
  valueListenable: tagCount,
  builder: (context, count, _) => Text('$count tags'),
);
```

[Learn more about operators →](/documentation/listen_it/operators/overview)

## API Reference

### Constructor

```dart
SetNotifier({
  Set<T>? data,
  CustomNotifierMode notificationMode = CustomNotifierMode.always,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `value` | `Set<T>` | Unmodifiable view of current set |
| `length` | `int` | Number of elements |
| `isEmpty` | `bool` | Whether set is empty |
| `isNotEmpty` | `bool` | Whether set has elements |
| `first` | `T` | First element (order not guaranteed) |
| `last` | `T` | Last element (order not guaranteed) |
| `single` | `T` | Single element (throws if not exactly one) |

### Methods

All standard `Set<T>` methods plus:

| Method | Description |
|--------|-------------|
| `startTransAction()` | Begin transaction |
| `endTransAction()` | End transaction and notify |
| `notifyListeners()` | Manually notify (useful with manual mode) |

### Return Values

Some methods return `bool` indicating whether the set was modified:

```dart
final added = items.add('item');        // true if added, false if already existed
final removed = items.remove('item');   // true if removed, false if didn't exist
```

In `normal` mode, notifications are based on these return values.

## Common Pitfalls

### 1. Modifying the .value View

```dart
// ❌ Don't try to modify the .value getter
final view = items.value;
view.add('item');  // Throws UnsupportedError!

// ✅ Modify through the notifier
items.add('item');
```

### 2. Forgetting Transactions

```dart
// ❌ Many notifications
for (final item in newItems) {
  items.add(item);
}

// ✅ Single notification
items.startTransAction();
for (final item in newItems) {
  items.add(item);
}
items.endTransAction();
```

### 3. Expecting Ordered Iteration

```dart
// ❌ Sets don't guarantee order
final items = SetNotifier<int>(data: {3, 1, 2});
print(items.toList());  // Might be [1, 2, 3] or [3, 1, 2] or any order

// ✅ Sort if you need specific order
final sorted = items.toList()..sort();
```

### 4. Not Overriding == and hashCode

```dart
// ❌ Without proper equality, duplicates based on identity
class User {
  final String id;
  final String name;

  User(this.id, this.name);
}

final users = SetNotifier<User>();
users.add(User('1', 'John'));
users.add(User('1', 'John'));  // Adds duplicate! (different instances)

// ✅ Override == and hashCode
class User {
  final String id;
  final String name;

  User(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

final users = SetNotifier<User>();
users.add(User('1', 'John'));
users.add(User('1', 'John'));  // No duplicate (same id)
```

## SetNotifier vs ListNotifier

| Feature | SetNotifier | ListNotifier |
|---------|-------------|--------------|
| **Duplicates** | No duplicates | Allows duplicates |
| **Order** | No guaranteed order | Maintains insertion order |
| **Lookup** | O(1) average | O(n) |
| **Use case** | Unique items, fast membership | Ordered collections |
| **Custom equality** | No (use == override) | Yes (customEquality param) |

**Choose SetNotifier when:**
- ✅ You need unique elements
- ✅ You need fast membership testing (contains)
- ✅ Order doesn't matter
- ✅ Examples: selected IDs, active filters, user permissions

**Choose ListNotifier when:**
- ✅ Order matters
- ✅ Duplicates are allowed
- ✅ You need indexed access
- ✅ Examples: todo lists, message history, search results

## Next Steps

- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [Notification Modes →](/documentation/listen_it/collections/notification_modes)
- [Transactions →](/documentation/listen_it/collections/transactions)
- [Back to Collections →](/documentation/listen_it/collections/introduction)
