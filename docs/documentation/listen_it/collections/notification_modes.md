# Notification Modes

Control when listeners are notified with three notification modes: `always`, `normal`, and `manual`.

## Overview

All reactive collections (ListNotifier, MapNotifier, SetNotifier) support three notification modes via the `CustomNotifierMode` enum:

| Mode | Behavior | Use When |
|------|----------|----------|
| **always** | Notify on every operation, even if value doesn't change | Default for collections - prevents UI update confusion |
| **normal** | Only notify when value actually changes (using `==` or custom equality) | Default for CustomValueNotifier - optimizing performance |
| **manual** | No automatic notifications - call `notifyListeners()` manually | Full control over notifications |

**Why `always` is the default for collections:** Users expect the UI to rebuild when they perform an operation (like adding an item). If the operation doesn't trigger a notification, it could surprise users when the UI doesn't update as expected. The `always` mode ensures consistent behavior regardless of whether objects override `==`.

::: tip Different Defaults
**Reactive Collections** (ListNotifier, MapNotifier, SetNotifier) default to `always` mode.

**CustomValueNotifier** defaults to `normal` mode to be a **drop-in replacement for ValueNotifier**, matching its behavior of only notifying when the value actually changes.

[Learn more about CustomValueNotifier →](/documentation/listen_it/listen_it#customvaluenotifier)
:::

## Basic Usage

<<< @/../code_samples/lib/listen_it/notification_modes.dart#example

## always Mode (Default)

Notifies listeners on every operation, regardless of whether the value actually changed.

### Why It's the Default

```dart
class User {
  final String name;
  final int age;

  User(this.name, this.age);

  // ❌️ No equality override - each instance is unique
}

final users = ListNotifier<User>();  // Default: always mode

users.listen((list, _) => print('Users: ${list.length}'));

final user1 = User('John', 25);
users.add(user1);  // ✅️ Notifies
users.add(user1);  // ✅️ Notifies (duplicate reference, but UI updates)
```

**Problem with `normal` mode here:** Without overriding `==`, Dart uses reference equality. Even though it's the same object reference, users might expect the UI to update when they call `.add()`.

**Solution:** Default to `always` mode so UI always updates when operations are performed. This matches user expectations and prevents confusion.

### When to Use always

- ✅️ Default choice - works correctly regardless of equality implementation
- ✅️ When you want UI to update on every operation
- ✅️ When objects don't override `==` operator
- ✅️ When debugging - see every operation

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.always,
);

items.add('item');  // ✅️ Notifies
items.add('item');  // ✅️ Notifies (even though it's a duplicate)
items[0] = 'item';  // ✅️ Notifies (even though value didn't change)
```

## normal Mode

Only notifies listeners when the value actually changes, using `==` comparison (or custom equality function).

### Basic Usage

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.listen((list, _) => print('Changed: $list'));

items.add('item1');  // ✅️ Notifies (new item)
items.add('item2');  // ✅️ Notifies (new item)
items[0] = 'item1';  // ❌️ No notification (same value)
items.remove('xyz'); // ❌️ No notification (item not in list)
```

### With Custom Equality

Provide a custom comparison function for complex objects:

```dart
class Product {
  final String id;
  final String name;
  final double price;

  Product(this.id, this.name, this.price);
}

final products = ListNotifier<Product>(
  notificationMode: CustomNotifierMode.normal,
  customEquality: (a, b) => a.id == b.id,  // Compare by ID only
);

final product1 = Product('1', 'Widget', 9.99);
final product2 = Product('1', 'Widget Pro', 14.99);  // Same ID, different name

products.add(product1);
products[0] = product2;  // ❌️ No notification (same ID according to customEquality)
```

### Bulk Operations in normal Mode

Different bulk operations have different notification behavior:

**Append/Insert operations** - Always notify (even with empty input):
```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.addAll([]);       // ✅️ Notifies (even though empty)
items.insertAll(0, []); // ✅️ Notifies (even though empty)
items.setAll(0, []);    // ✅️ Notifies (even though empty)
```

**Replace operations** - Only notify if changes occurred:
```dart
items.fillRange(0, 2, 'a');    // Only notifies if values changed
items.replaceRange(0, 2, []); // Only notifies if values changed
```

### When to Use normal

- ✅️ Performance optimization - reduce unnecessary notifications
- ✅️ Objects override `==` operator correctly
- ✅️ You have custom equality logic
- ✅️ No-op operations shouldn't trigger UI updates

```dart
class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo(this.id, this.title, this.completed);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          completed == other.completed;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ completed.hashCode;
}

final todos = ListNotifier<Todo>(
  notificationMode: CustomNotifierMode.normal,
);

final todo1 = Todo('1', 'Buy milk', false);
todos.add(todo1);              // ✅️ Notifies
todos[0] = todo1;               // ❌️ No notification (same object)
todos[0] = Todo('1', 'Buy milk', false);  // ❌️ No notification (equal by ==)
```

## manual Mode

No automatic notifications - you must call `notifyListeners()` manually.

### Basic Usage

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

items.listen((list, _) => print('Manual notification: $list'));

items.add('item1');  // No notification
items.add('item2');  // No notification
items.add('item3');  // No notification

items.notifyListeners();  // ✅️ Single notification for all 3 adds
```

### When to Use manual

- ✅️ Complex operations requiring multiple steps
- ✅️ You want explicit control over when notifications fire
- ✅️ Batching operations for performance (use transactions instead!)
- ✅️ Conditional notifications based on custom logic

```dart
final cart = ListNotifier<Product>(
  notificationMode: CustomNotifierMode.manual,
);

void updateCart(List<Product> newProducts) {
  cart.clear();
  cart.addAll(newProducts);

  // Only notify if cart is not empty
  if (cart.isNotEmpty) {
    cart.notifyListeners();
  }
}
```

### manual vs Transactions

For batching operations, **transactions are usually better** than manual mode:

**❌️ With manual mode:**
```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

// Must remember to call notifyListeners()
items.add('a');
items.add('b');
items.notifyListeners();  // Easy to forget!
```

**✅️ With transactions (any mode):**
```dart
final items = ListNotifier<String>();  // Any mode works

items.startTransAction();
items.add('a');
items.add('b');
items.endTransAction();  // Guaranteed notification
```

[Learn more about transactions →](/documentation/listen_it/collections/transactions)

## Comparison Table

| Operation | always | normal | manual |
|-----------|--------|--------|--------|
| `add(newItem)` | ✅️ Notifies | ✅️ Notifies | ❌️ No notification |
| `add(duplicate)` (Set) | ✅️ Notifies | ❌️ No notification | ❌️ No notification |
| `[index] = sameValue` | ✅️ Notifies | ❌️ No notification | ❌️ No notification |
| `remove(nonExistent)` | ✅️ Notifies | ❌️ No notification | ❌️ No notification |
| `addAll([])` (empty) | ✅️ Notifies | ✅️ Notifies | ❌️ No notification |
| `fillRange()` no change | ✅️ Notifies | ❌️ No notification | ❌️ No notification |
| `notifyListeners()` | ✅️ Notifies | ✅️ Notifies | ✅️ Notifies |

## Choosing the Right Mode

### Decision Tree

```
Do you need full control over notifications?
├─ YES → Use manual mode
│         (But consider transactions instead!)
└─ NO → Do your objects override ==?
         ├─ YES → Use normal mode
         │         (Reduces unnecessary notifications)
         └─ NO/UNSURE → Use always mode (default)
                        (Prevents UI update confusion)
```

### Recommendations by Collection Type

**ListNotifier:**
- Default: `always` - Users expect UI updates on every operation
- Use `normal` if: List contains value types with proper `==` (String, int, etc.)
- Use `manual` if: You have complex batch operations

**MapNotifier:**
- Default: `always` - Safe choice for any value types
- Use `normal` if: You have custom key comparison or value equality
- Use `manual` if: You're building the map in stages

**SetNotifier:**
- Default: `always` - Prevents confusion when adding duplicates
- Use `normal` if: You want no notification when adding existing items
- Use `manual` if: You're bulk-loading data

## Real-World Examples

### Example 1: Shopping Cart (normal mode)

```dart
class CartItem {
  final String id;
  final String name;
  final int quantity;
  final double price;

  CartItem(this.id, this.name, this.quantity, this.price);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          id == other.id &&
          name == other.name &&
          quantity == other.quantity &&
          price == other.price;

  @override
  int get hashCode => Object.hash(id, name, quantity, price);
}

final cart = ListNotifier<CartItem>(
  notificationMode: CustomNotifierMode.normal,
);

// Only notifies when cart actually changes
void updateItemQuantity(String id, int newQuantity) {
  final index = cart.indexWhere((item) => item.id == id);
  if (index != -1) {
    final item = cart[index];
    cart[index] = CartItem(item.id, item.name, newQuantity, item.price);
    // Only notifies if quantity actually changed
  }
}
```

### Example 2: Selected Items (normal mode)

```dart
final selectedIds = SetNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

selectedIds.listen((ids, _) => print('Selection changed: $ids'));

selectedIds.add('item1');  // ✅️ Notifies
selectedIds.add('item1');  // ❌️ No notification (already in set)
selectedIds.add('item2');  // ✅️ Notifies
```

### Example 3: Form Data (manual mode)

```dart
final formData = MapNotifier<String, String>(
  notificationMode: CustomNotifierMode.manual,
);

void loadFormData(Map<String, String> data) {
  formData.clear();
  formData.addAll(data);
  // Only notify after all data is loaded
  formData.notifyListeners();
}

void validateAndSubmit() {
  if (isValid(formData)) {
    formData.notifyListeners();  // Notify only if valid
    submitForm(formData);
  }
}
```

## Performance Considerations

### always Mode
- **Pros:** Simple, predictable, prevents UI bugs
- **Cons:** May notify more often than necessary
- **Impact:** Usually negligible unless thousands of updates/second

### normal Mode
- **Pros:** Reduces unnecessary notifications, better performance
- **Cons:** Requires proper `==` implementation, slightly more complex
- **Impact:** Can significantly reduce rebuilds with frequent no-op operations

### manual Mode
- **Pros:** Maximum control, can batch multiple operations
- **Cons:** Easy to forget notifications, more error-prone
- **Impact:** Best performance when used correctly

## Next Steps

- [Transactions →](/documentation/listen_it/collections/transactions)
- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Back to Collections →](/documentation/listen_it/collections/introduction)
