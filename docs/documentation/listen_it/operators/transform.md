# Transform Operators

Transform operators let you convert values from one type to another or react only to specific property changes.

## map()

Transforms each value using a function. The mapped ValueListenable updates whenever the source changes.

### Basic Usage

<<< @/../code_samples/lib/listen_it/map_transform.dart#example

### Type Transformation

You can change the type by providing a type parameter:

```dart
final intNotifier = ValueNotifier<int>(42);

// Explicit type transformation
final stringNotifier = intNotifier.map<String>((i) => 'Value: $i');

// Type is inferred as ValueListenable<String>
print(stringNotifier.value); // "Value: 42"
```

### Common Use Cases

::: details Format Values for Display

```dart
import 'package:intl/intl.dart';

final priceNotifier = ValueNotifier<double>(19.99);

final formatter = NumberFormat.currency(symbol: '\$');
final formattedPrice = priceNotifier.map((price) => formatter.format(price));

ValueListenableBuilder<String>(
  valueListenable: formattedPrice,
  builder: (context, price, _) => Text(price), // "$19.99"
);
```
:::

::: details Extract Nested Properties

```dart
final userNotifier = ValueNotifier<User>(user);

final userName = userNotifier.map((user) => user.name);
final userEmail = userNotifier.map((user) => user.email);
```
:::

::: details Complex Transformations

```dart
final dataNotifier = ValueNotifier<RawData>(data);

final processed = dataNotifier.map((raw) {
  return ProcessedData(
    value: raw.value * 2,
    formatted: raw.toString().toUpperCase(),
    timestamp: DateTime.now(),
  );
});
```
:::

### When to Use map()

Use `map()` when:
- ✅ You need to transform every value
- ✅ You need to change the type
- ✅ The transformation is always valid
- ✅ You want to be notified on every source change

::: tip Performance
The transformation function is called on **every** source value change. For expensive transformations, consider using `select()` if you only need to react to specific property changes.
:::

## select()

Reacts only when a selected property of the value changes. This is more efficient than `map()` when you only care about specific properties of a complex object.

### Basic Usage

<<< @/../code_samples/lib/listen_it/select_property.dart#example

### How It Works

The selector function is called on every value change, but the result is only propagated when it's **different** from the previous result (using `==` comparison).

```dart
final userNotifier = ValueNotifier<User>(User(age: 18, name: "John"));

final ageNotifier = userNotifier.select<int>((u) => u.age);

ageNotifier.listen((age, _) => print('Age: $age'));

userNotifier.value = User(age: 18, name: "Johnny");
// No output - age didn't change

userNotifier.value = User(age: 19, name: "Johnny");
// Prints: Age: 19
```

### Common Use Cases

::: details Track Specific Model Properties

```dart
class AppState {
  final bool isLoading;
  final String? error;
  final List<Item> items;

  AppState({required this.isLoading, this.error, required this.items});
}

final appState = ValueNotifier<AppState>(initialState);

// Only rebuild when loading state changes
final isLoading = appState.select<bool>((state) => state.isLoading);

// Only rebuild when error changes
final error = appState.select<String?>((state) => state.error);

// Only rebuild when item count changes
final itemCount = appState.select<int>((state) => state.items.length);
```
:::

::: details Avoid Unnecessary Rebuilds

```dart
class Settings {
  final String theme;
  final String language;
  final bool notifications;

  Settings({required this.theme, required this.language, required this.notifications});
}

final settings = ValueNotifier<Settings>(defaultSettings);

// Widget only rebuilds when theme changes, not when language or notifications change
final theme = settings.select<String>((s) => s.theme);

ValueListenableBuilder<String>(
  valueListenable: theme,
  builder: (context, theme, _) => ThemedWidget(theme: theme),
);
```
:::

::: details Select Computed Properties

```dart
class ShoppingCart {
  final List<Item> items;

  ShoppingCart(this.items);

  double get total => items.fold(0.0, (sum, item) => sum + item.price);
}

class Item {
  final double price;
  Item(this.price);
}

final cart = ValueNotifier<ShoppingCart>(ShoppingCart([]));

// Only notify when total changes
final total = cart.select<double>((c) => c.total);
```
:::

### map() vs select()

| Feature | map() | select() |
|---------|-------|----------|
| **Notifies when** | Source changes | Selected value changes |
| **Use for** | Always transform all changes | Only react to specific properties |
| **Performance** | Every source change | Only when selected value differs |
| **Type change** | Yes | Yes |

```dart
final user = ValueNotifier<User>(User(age: 18, name: "John"));

// map() - notifies on EVERY user change
final userMap = user.map((u) => u.age);
user.value = User(age: 18, name: "Johnny"); // ✅ Notifies (age still 18)

// select() - notifies only when age ACTUALLY changes
final userSelect = user.select<int>((u) => u.age);
user.value = User(age: 18, name: "Johnny"); // ❌ No notification (age unchanged)
```

### When to Use select()

Use `select()` when:
- ✅ You only care about specific properties of a complex object
- ✅ You want to avoid unnecessary notifications
- ✅ The object changes frequently but the property you care about doesn't
- ✅ You want to optimize widget rebuilds

::: tip Best Practice
`select()` is ideal for view models or state objects that have many properties but your widget only depends on a few of them.
:::

## Chaining Transforms

You can chain `map()` and `select()` with other operators:

```dart
final user = ValueNotifier<User>(user);

user
    .select<int>((u) => u.age)           // Only when age changes
    .where((age) => age >= 18)            // Only adults
    .map<String>((age) => 'Age: $age')    // Format for display
    .listen((text, _) => print(text));
```

## Next Steps

- [Learn about filtering operators →](/documentation/listen_it/operators/filter)
- [Learn about combining operators →](/documentation/listen_it/operators/combine)
- [Learn about time-based operators →](/documentation/listen_it/operators/time)
