# Transactions

Batch multiple operations into a single notification for better performance and atomic updates.

## Overview

Transactions allow you to make multiple changes to a reactive collection while triggering only one notification at the end. This is useful for:

- **Performance** - Reduce UI rebuilds from multiple operations
- **Atomic updates** - Ensure all changes complete before listeners are notified
- **Cleaner code** - Explicit batching of related operations

## Basic Usage

<<< @/../code_samples/lib/listen_it/transactions.dart#example

## How Transactions Work

When you call `startTransAction()`:
1. The `_inTransaction` flag is set to `true`
2. All mutation operations update the collection but don't notify listeners
3. The `_hasChanged` flag tracks whether any actual changes occurred
4. When `endTransAction()` is called, a single notification fires (if changes occurred)

```dart
final items = ListNotifier<int>();

items.listen((list, _) => print('Notification: $list'));

// Without transaction: 3 notifications
items.add(1);  // Notification 1
items.add(2);  // Notification 2
items.add(3);  // Notification 3

items.clear();

// With transaction: 1 notification
items.startTransAction();
items.add(1);  // No notification
items.add(2);  // No notification
items.add(3);  // No notification
items.endTransAction();  // Single notification with [1, 2, 3]
```

## Use Cases

### 1. Bulk Loading Data

Load multiple items without triggering notifications for each one:

```dart
final products = ListNotifier<Product>();

products.listen((list, _) => rebuildUI());

void loadProducts(List<Product> data) {
  products.startTransAction();
  products.clear();
  products.addAll(data);
  products.endTransAction();  // Single UI rebuild
}
```

### 2. Atomic State Updates

Ensure related changes happen together:

```dart
final cart = ListNotifier<CartItem>();

void updateItemQuantity(String itemId, int newQuantity) {
  cart.startTransAction();

  final index = cart.indexWhere((item) => item.id == itemId);
  if (index != -1) {
    if (newQuantity <= 0) {
      cart.removeAt(index);
    } else {
      final item = cart[index];
      cart[index] = CartItem(item.id, item.name, newQuantity, item.price);
    }
  }

  cart.endTransAction();  // Single notification for the complete operation
}
```

### 3. Multiple Related Operations

Batch operations that should be seen as a single logical change:

```dart
final todos = ListNotifier<Todo>();

void moveTodo(int fromIndex, int toIndex) {
  todos.startTransAction();

  final todo = todos.removeAt(fromIndex);
  todos.insert(toIndex, todo);

  todos.endTransAction();  // Single notification
}
```

### 4. Conditional Batching

Complex logic with multiple paths:

```dart
final items = ListNotifier<String>();

void processUpdates(List<String> updates) {
  items.startTransAction();

  for (final update in updates) {
    if (shouldAdd(update)) {
      items.add(update);
    } else if (shouldRemove(update)) {
      items.remove(update);
    } else if (shouldUpdate(update)) {
      final index = items.indexOf(update);
      if (index != -1) {
        items[index] = update;
      }
    }
  }

  items.endTransAction();  // Single notification for all changes
}
```

## Transaction Behavior with Notification Modes

Transactions work with all notification modes:

### With always Mode (Default)

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.always,
);

items.startTransAction();
items.add('a');
items.add('b');
items.endTransAction();  // ✅ Notifies (always mode)
```

### With normal Mode

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.startTransAction();
items.add('a');
items.add('a');  // Duplicate, no actual change
items.endTransAction();  // ✅ Notifies (something changed)

items.startTransAction();
items.remove('nonexistent');  // No actual change
items.endTransAction();  // ❌ No notification (nothing changed)
```

### With manual Mode

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

items.startTransAction();
items.add('a');
items.add('b');
items.endTransAction();  // ❌ No notification (manual mode)

// Must call notifyListeners() manually even after transaction
items.notifyListeners();  // ✅ Now notifies
```

[Learn more about notification modes →](/documentation/listen_it/collections/notification_modes)

## Nested Transactions

Nested transactions are **not allowed** and will cause an assertion error:

```dart
final items = ListNotifier<int>();

items.startTransAction();
items.add(1);

// ❌ ERROR: Assertion failed
items.startTransAction();  // Can't nest transactions!
```

**Why not allowed:**
- Simpler implementation
- Clearer code - one transaction at a time
- Avoid confusion about when notifications fire

**Alternative:** Complete the first transaction before starting another:

```dart
void operation1() {
  items.startTransAction();
  items.add(1);
  items.endTransAction();
}

void operation2() {
  items.startTransAction();
  items.add(2);
  items.endTransAction();
}

// Call separately
operation1();
operation2();
```

## Transaction Safety

### Always End Transactions

Make sure to always call `endTransAction()`, even if errors occur:

**❌ Unsafe:**
```dart
items.startTransAction();
items.add(data);  // Might throw exception
items.endTransAction();  // Might never be called!
```

**✅ Safe:**
```dart
items.startTransAction();
try {
  items.add(data);
} finally {
  items.endTransAction();  // Always called
}
```

### Assertions Help Catch Errors

The implementation includes assertions to help catch mistakes:

```dart
// Assertion when starting nested transaction
assert(!_inTransaction, 'Only one transaction at a time');

// Assertion when ending without active transaction
assert(_inTransaction, 'No active transaction');
```

These assertions only fire in debug mode but help catch bugs during development.

## Performance Benefits

### Without Transactions

```dart
final items = ListNotifier<String>();

items.listen((list, _) {
  // Expensive UI rebuild
  rebuildComplexWidget(list);
});

void loadData(List<String> data) {
  for (final item in data) {
    items.add(item);  // Rebuilds UI for EACH item!
  }
}

// Loading 100 items = 100 UI rebuilds!
loadData(List.generate(100, (i) => 'item$i'));
```

### With Transactions

```dart
final items = ListNotifier<String>();

items.listen((list, _) {
  // Expensive UI rebuild
  rebuildComplexWidget(list);
});

void loadData(List<String> data) {
  items.startTransAction();
  for (final item in data) {
    items.add(item);  // No notification
  }
  items.endTransAction();  // Single UI rebuild!
}

// Loading 100 items = 1 UI rebuild!
loadData(List.generate(100, (i) => 'item$i'));
```

**Performance improvement:** From O(n) rebuilds to O(1) rebuild!

## Real-World Examples

### Example 1: Shopping Cart Checkout

```dart
class CheckoutService {
  final cart = ListNotifier<CartItem>();
  final purchaseHistory = ListNotifier<Purchase>();

  Future<void> checkout() async {
    cart.startTransAction();

    // Create purchase record
    final purchase = Purchase(
      items: List.from(cart),
      total: calculateTotal(cart),
      timestamp: DateTime.now(),
    );

    // Process payment
    await processPayment(purchase);

    // Add to history
    purchaseHistory.add(purchase);

    // Clear cart
    cart.clear();

    cart.endTransAction();  // Single notification after checkout complete
  }
}
```

### Example 2: Drag and Drop Reordering

<<< @/../code_samples/lib/listen_it/transaction_reorder_widget.dart#example

### Example 3: Batch Data Sync

```dart
class DataSyncService {
  final cache = MapNotifier<String, User>();

  Future<void> syncUsers() async {
    final updates = await fetchUserUpdates();

    cache.startTransAction();

    for (final update in updates) {
      switch (update.type) {
        case UpdateType.add:
          cache[update.id] = update.user;
          break;
        case UpdateType.remove:
          cache.remove(update.id);
          break;
        case UpdateType.modify:
          cache[update.id] = update.user;
          break;
      }
    }

    cache.endTransAction();  // Single notification after all updates
  }
}
```

### Example 4: Form Bulk Updates

```dart
class FormModel {
  final fields = MapNotifier<String, String>();

  void loadFromJson(Map<String, dynamic> json) {
    fields.startTransAction();
    fields.clear();
    json.forEach((key, value) {
      fields[key] = value.toString();
    });
    fields.endTransAction();  // Single notification
  }

  void resetToDefaults() {
    fields.startTransAction();
    fields['name'] = '';
    fields['email'] = '';
    fields['phone'] = '';
    fields['address'] = '';
    fields.endTransAction();  // Single notification
  }
}
```

## Best Practices

### 1. Use Transactions for Bulk Operations

Any time you're making multiple related changes:

```dart
// ✅ Good
items.startTransAction();
for (final item in newItems) {
  items.add(item);
}
items.endTransAction();

// ❌ Bad
for (final item in newItems) {
  items.add(item);  // Notification for each!
}
```

### 2. Keep Transactions Short

Don't hold transactions open for long periods or across async operations:

```dart
// ❌ Bad - transaction held during async operation
items.startTransAction();
items.clear();
await fetchData();  // Long async operation
items.addAll(data);
items.endTransAction();

// ✅ Good - transaction only around sync operations
final data = await fetchData();
items.startTransAction();
items.clear();
items.addAll(data);
items.endTransAction();
```

### 3. Use try/finally for Safety

Always ensure transactions are ended:

```dart
items.startTransAction();
try {
  // Operations that might throw
  complexOperation();
} finally {
  items.endTransAction();
}
```

### 4. Prefer Transactions Over manual Mode

For batching operations, transactions are clearer than manual mode:

```dart
// ✅ Better - works with any notification mode
items.startTransAction();
items.add('a');
items.add('b');
items.endTransAction();

// ❌ Worse - requires manual mode, easy to forget notification
items.add('a');
items.add('b');
items.notifyListeners();
```

## Comparison: Transactions vs manual Mode

| Feature | Transactions | manual Mode |
|---------|-------------|-------------|
| **Syntax** | `startTransAction()` / `endTransAction()` | `notifyListeners()` |
| **Works with any mode** | ✅ Yes | ❌ No (requires manual mode) |
| **Clear intent** | ✅ Explicit batching | ❌ Easy to forget notification |
| **Assertions** | ✅ Helps catch errors | ❌ No safety checks |
| **Recommended** | ✅ Yes | ⚠️ Use transactions instead |

## Next Steps

- [Notification Modes →](/documentation/listen_it/collections/notification_modes)
- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Back to Collections →](/documentation/listen_it/collections/introduction)
