# Filter Operator

The `where()` operator filters values based on a predicate function, only propagating values that pass the test.

## where()

Creates a filtered ValueListenable that only notifies when values pass the predicate test.

### Signature

```dart
ValueListenable<T> where(
  bool Function(T) selector, {
  T? fallbackValue,
})
```

**Parameters:**
- `selector` - Predicate function that determines if a value should propagate
- `fallbackValue` - Optional fallback value to use as initial value if current value doesn't pass the predicate

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

### Initial Value Behavior

By default, if the current source value doesn't pass the predicate, it still becomes the initial value:

```dart
final numbers = ValueNotifier<int>(1); // Odd number

final evenNumbers = numbers.where((n) => n.isEven);

print(evenNumbers.value); // 1 (initial value, even though it's odd!)

numbers.value = 2; // Passes filter (even)
numbers.value = 3; // Blocked (odd)
print(evenNumbers.value); // Still 2
```

### Using fallbackValue

To handle cases where the initial value doesn't pass the predicate, provide a `fallbackValue`:

```dart
final numbers = ValueNotifier<int>(1); // Odd number

// Provide fallback for when initial value doesn't pass
final evenNumbers = numbers.where(
  (n) => n.isEven,
  fallbackValue: 0,  // Use 0 if current value is odd
);

print(evenNumbers.value); // 0 (fallback used!)

numbers.value = 2; // Passes filter (even)
print(evenNumbers.value); // 2

numbers.value = 3; // Blocked (odd)
print(evenNumbers.value); // Still 2 (not 0 - fallback only used at creation)
```

### Practical fallbackValue Examples

::: details Search Input with Minimum Length

```dart
final searchTerm = ValueNotifier<String>('');

// Use empty string as fallback when search term is too short
final validSearchTerm = searchTerm.where(
  (term) => term.length >= 3,
  fallbackValue: '',
);

validSearchTerm
    .debounce(Duration(milliseconds: 300))
    .listen((term, _) {
      if (term.isEmpty) {
        clearSearchResults();
      } else {
        performSearch(term);
      }
    });
```
:::

::: details Age Validation

```dart
final userAge = ValueNotifier<int>(0);

// Use 0 as fallback for invalid ages
final adultAge = userAge.where(
  (age) => age >= 18,
  fallbackValue: 0,
);

adultAge.listen((age, _) {
  if (age == 0) {
    showMessage('Must be 18 or older');
  } else {
    enableFeature();
  }
});
```
:::

::: details Temperature Alerts

```dart
final temperature = ValueNotifier<double>(20.0);

// Use safe temp as fallback
final dangerousTemp = temperature.where(
  (temp) => temp > 35.0 || temp < 5.0,
  fallbackValue: 20.0,  // Normal temp
);

dangerousTemp.listen((temp, _) {
  if (temp != 20.0) {
    showTemperatureAlert(temp);
  }
});
```
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
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You need to filter values based on conditions</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You only want to react to certain values</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You're implementing validation logic</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You need to filter based on runtime state</li>
</ul>

## Real-World Example

Search input with minimum length requirement:

```dart
final searchTerm = ValueNotifier<String>('');

// Without fallbackValue (backward compatible)
searchTerm
    .where((term) => term.length >= 3)     // At least 3 characters
    .debounce(Duration(milliseconds: 300))  // Wait for typing pause
    .listen((term, _) => performSearch(term));

// With fallbackValue (recommended for cleaner logic)
searchTerm
    .where(
      (term) => term.length >= 3,
      fallbackValue: '',  // Clear indicator when no search
    )
    .debounce(Duration(milliseconds: 300))
    .listen((term, _) {
      if (term.isEmpty) {
        clearResults();
      } else {
        performSearch(term);
      }
    });
```

## Next Steps

- [Learn about transformation operators →](/documentation/listen_it/operators/transform)
- [Learn about combining operators →](/documentation/listen_it/operators/combine)
- [Learn about time-based operators →](/documentation/listen_it/operators/time)
