# Filter Operator

The `where()` operator filters values based on a predicate function, only propagating values that pass the test.

## where()

Creates a filtered ValueListenable that only notifies when values pass the predicate test.

### Basic Usage

<<< @/../code_samples/lib/listen_it/where_filter.dart#example

### How It Works

The predicate function is called for every source value. Only values where the predicate returns `true` are propagated to listeners.

```dart
final numbers = ValueNotifier<int>(1);

final evenNumbers = numbers.where((n) => n.isEven);

evenNumbers.listen((value, _) => print('Even: $value'));

numbers.value = 2; // Prints: Even: 2
numbers.value = 3; // No output (filtered out)
numbers.value = 4; // Prints: Even: 4
numbers.value = 5; // No output (filtered out)
```

### Common Use Cases

::: details Validation

```dart
final input = ValueNotifier<String>('');

// Only propagate non-empty strings
final validInput = input.where((text) => text.isNotEmpty);

// Only propagate strings meeting length requirement
final longEnoughInput = input.where((text) => text.length >= 3);
```
:::

::: details State-Based Filtering

```dart
class AppState {
  final bool isOnline;
  final String data;

  AppState(this.isOnline, this.data);
}

final appState = ValueNotifier<AppState>(AppState(true, ''));

// Only propagate when online
final onlineData = appState.where((state) => state.isOnline);
```
:::

::: details Range Filtering

```dart
final temperature = ValueNotifier<double>(20.0);

// Only alert on high temperatures
final highTemp = temperature.where((temp) => temp > 30.0);

highTemp.listen((temp, _) => showAlert('High temperature: $temp'));
```
:::

::: details Combining Conditions

```dart
final userAge = ValueNotifier<int>(0);

// Multiple conditions
final eligibleAge = userAge.where((age) {
  return age >= 18 && age <= 65;
});
```
:::

### Dynamic Predicates

The predicate can reference external state:

```dart
bool onlyEven = true;

final numbers = ValueNotifier<int>(0);

// Predicate references external variable
final filtered = numbers.where((n) => onlyEven ? n.isEven : true);

// Initially filters to even numbers
numbers.value = 2; // Passes
numbers.value = 3; // Blocked

// Change filter
onlyEven = false;

// Now all numbers pass
numbers.value = 5; // Passes
```

::: warning Caveat
The initial value always passes through the filter without being checked against the predicate. The filter only applies to subsequent value changes.

```dart
final numbers = ValueNotifier<int>(1); // Odd number

final evenNumbers = numbers.where((n) => n.isEven);

print(evenNumbers.value); // 1 (initial value passed through!)

numbers.value = 2; // Passes filter (even)
numbers.value = 3; // Blocked (odd)
print(evenNumbers.value); // Still 2
```

For this reason, `where()` is not recommended inside widget trees with `setState` that recreate the chain, as the current source value would pass through on each rebuild regardless of the predicate.
:::

### Chaining with Other Operators

`where()` is commonly chained with transformation operators:

```dart
final input = ValueNotifier<String>('');

input
    .where((text) => text.length >= 3)      // Min 3 characters
    .map((text) => text.toUpperCase())       // Transform to uppercase
    .debounce(Duration(milliseconds: 300))  // Debounce
    .listen((text, _) => search(text));
```

### where() vs select()

| Feature | where() | select() |
|---------|---------|----------|
| **Purpose** | Filter values | React to property changes |
| **Notifies when** | Predicate returns true | Selected value changes |
| **Initial value** | Always passes | Normal behavior |
| **Use for** | Conditional propagation | Property-specific updates |

```dart
final user = ValueNotifier<User>(User(age: 16));

// where() - filters based on condition
final adults = user.where((u) => u.age >= 18);
// Won't notify for age 16, 17 updates

// select() - reacts to age changes
final age = user.select<int>((u) => u.age);
// Notifies for every age change
```

### When to Use where()

Use `where()` when:
- ✅ You need to filter values based on conditions
- ✅ You only want to react to certain values
- ✅ You're implementing validation logic
- ✅ You need to filter based on runtime state

## Real-World Example

Search input with minimum length requirement:

```dart
final searchTerm = ValueNotifier<String>('');

searchTerm
    .where((term) => term.length >= 3)     // At least 3 characters
    .debounce(Duration(milliseconds: 300))  // Wait for typing pause
    .listen((term, _) => performSearch(term));
```

## Next Steps

- [Learn about transformation operators →](/documentation/listen_it/operators/transform)
- [Learn about combining operators →](/documentation/listen_it/operators/combine)
- [Learn about time-based operators →](/documentation/listen_it/operators/time)
