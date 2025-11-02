# Combine Operators

Combine operators let you merge multiple ValueListenables into a single observable, updating whenever any source changes.

## combineLatest()

Combines two ValueListenables using a combiner function. The result updates whenever either source changes.

### Basic Usage

<<< @/../code_samples/lib/listen_it/combine_latest.dart#example

### How It Works

`combineLatest()` creates a new ValueListenable that:
1. Holds the latest value from both sources
2. Calls the combiner function whenever either source changes
3. Notifies listeners with the combined result

### Type Parameters

`combineLatest<TIn2, TOut>()` takes two type parameters:
- `TIn2` - Type of the second ValueListenable
- `TOut` - Type of the combined result

```dart
final ageNotifier = ValueNotifier<int>(25);
final nameNotifier = ValueNotifier<String>('John');

// Combine int and String into custom type
final user = ageNotifier.combineLatest<String, User>(
  nameNotifier,
  (int age, String name) => User(age: age, name: name),
);
```

### Common Use Cases

::: details Form Validation

```dart
final email = ValueNotifier<String>('');
final password = ValueNotifier<String>('');

final isValid = email.combineLatest<String, bool>(
  password,
  (e, p) => e.contains('@') && p.length >= 8,
);

ValueListenableBuilder<bool>(
  valueListenable: isValid,
  builder: (context, valid, _) => ElevatedButton(
    onPressed: valid ? _submit : null,
    child: Text('Submit'),
  ),
);
```
:::

::: details Computed Values

```dart
final quantity = ValueNotifier<int>(1);
final price = ValueNotifier<double>(9.99);

final total = quantity.combineLatest<double, double>(
  price,
  (qty, p) => qty * p,
);

print(total.value); // 9.99

quantity.value = 3;
print(total.value); // 29.97
```
:::

::: details Conditional UI

```dart
final isDarkMode = ValueNotifier<bool>(false);
final fontSize = ValueNotifier<double>(14.0);

final textStyle = isDarkMode.combineLatest<double, TextStyle>(
  fontSize,
  (dark, size) => TextStyle(
    color: dark ? Colors.white : Colors.black,
    fontSize: size,
  ),
);
```
:::

::: details Multi-Source State

```dart
final isLoading = ValueNotifier<bool>(false);
final hasError = ValueNotifier<bool>(false);

final uiState = isLoading.combineLatest<bool, UIState>(
  hasError,
  (loading, error) {
    if (loading) return UIState.loading;
    if (error) return UIState.error;
    return UIState.ready;
  },
);
```
:::

### Combining More Than Two Sources

For combining 3-6 ValueListenables, use `combineLatest3` through `combineLatest6`:

```dart
final source1 = ValueNotifier<int>(1);
final source2 = ValueNotifier<int>(2);
final source3 = ValueNotifier<int>(3);

final sum = source1.combineLatest3<int, int, int>(
  source2,
  source3,
  (a, b, c) => a + b + c,
);

print(sum.value); // 6
```

Similarly available: `combineLatest4`, `combineLatest5`, `combineLatest6`

### When to Use combineLatest()

Use `combineLatest()` when:
- ✅ You need values from 2-6 ValueListenables
- ✅ You want to update whenever any source changes
- ✅ You need to combine values into a new type
- ✅ You're implementing derived state or computed properties

## mergeWith()

Merges value changes from multiple ValueListenables of the same type. Updates whenever any source changes, emitting that source's value.

### Basic Usage

<<< @/../code_samples/lib/listen_it/merge_with.dart#example

### How It Works

`mergeWith()` creates a new ValueListenable that:
1. Subscribes to the primary source and all sources in the list
2. Whenever any source changes, emits that source's current value
3. All sources must be of the same type

```dart
final source1 = ValueNotifier<int>(1);
final source2 = ValueNotifier<int>(2);
final source3 = ValueNotifier<int>(3);

final merged = source1.mergeWith([source2, source3]);

print(merged.value); // 1 (initial value from source1)

source2.value = 20;
print(merged.value); // 20 (source2 changed)

source3.value = 30;
print(merged.value); // 30 (source3 changed)

source1.value = 10;
print(merged.value); // 10 (source1 changed)
```

### Common Use Cases

::: details Multiple Event Sources

```dart
final userInput = ValueNotifier<String>('');
final apiResult = ValueNotifier<String>('');
final cacheData = ValueNotifier<String>('');

// React to updates from any source
final dataStream = userInput.mergeWith([apiResult, cacheData]);

dataStream.listen((data, _) => updateUI(data));
```
:::

::: details Multiple Triggers

```dart
final saveButton = ValueNotifier<DateTime?>(null);
final autoSave = ValueNotifier<DateTime?>(null);
final shortcutKey = ValueNotifier<DateTime?>(null);

// Save triggered by any action
final saveTrigger = saveButton.mergeWith([autoSave, shortcutKey]);

saveTrigger.listen((timestamp, _) {
  if (timestamp != null) performSave();
});
```
:::

::: details Aggregating Similar Sources

```dart
final sensor1 = ValueNotifier<double>(0.0);
final sensor2 = ValueNotifier<double>(0.0);
final sensor3 = ValueNotifier<double>(0.0);

// Monitor any sensor change
final anySensorChange = sensor1.mergeWith([sensor2, sensor3]);

anySensorChange.listen((value, _) => checkThreshold(value));
```
:::

### combineLatest() vs mergeWith()

| Feature | combineLatest() | mergeWith() |
|---------|-----------------|-------------|
| **Number of sources** | 2-6 | 1 + N (array) |
| **Source types** | Can be different | Must be same type |
| **Output type** | Custom (via combiner) | Same as source type |
| **Use for** | Combining different values | Merging similar events |
| **Output value** | Result of combiner function | Value from whichever source changed |

**Example: Two loading states**

```dart
final isLoadingData = ValueNotifier<bool>(false);
final isLoadingUser = ValueNotifier<bool>(false);

// combineLatest - combines both values with logic (OR operation)
final isLoading = isLoadingData.combineLatest<bool, bool>(
  isLoadingUser,
  (dataLoading, userLoading) => dataLoading || userLoading,
);

isLoadingData.value = true;
print(isLoading.value); // true (data is loading)

isLoadingUser.value = true;
print(isLoading.value); // true (both loading)

isLoadingData.value = false;
print(isLoading.value); // true (user still loading)

// mergeWith - just takes whichever one changed
final anyLoading = isLoadingData.mergeWith([isLoadingUser]);

isLoadingData.value = true;
print(anyLoading.value); // true (from isLoadingData)

isLoadingUser.value = false;
print(anyLoading.value); // false (from isLoadingUser - not what you want!)

isLoadingData.value = false;
print(anyLoading.value); // false (from isLoadingData)
```

**Key difference:** `combineLatest()` applies logic to **both** values, while `mergeWith()` just emits whichever source changed - making it wrong for this use case!

### When to Use mergeWith()

Use `mergeWith()` when:
- ✅ You have multiple sources of the same type
- ✅ You want to react to changes from any source
- ✅ You don't need to combine values, just monitor any change
- ✅ You're aggregating similar event streams

## Chaining with Other Operators

Combine operators work well with other operators:

```dart
final firstName = ValueNotifier<String>('');
final lastName = ValueNotifier<String>('');

firstName
    .combineLatest<String, String>(
      lastName,
      (first, last) => '$first $last',
    )
    .where((name) => name.trim().isNotEmpty)
    .map((name) => name.toUpperCase())
    .listen((name, _) => print(name));
```

## Real-World Example

Shopping cart total with tax:

```dart
final subtotal = ValueNotifier<double>(0.0);
final taxRate = ValueNotifier<double>(0.1);

final total = subtotal.combineLatest<double, double>(
  taxRate,
  (sub, rate) => sub * (1 + rate),
);

// Use in UI
ValueListenableBuilder<double>(
  valueListenable: total,
  builder: (context, value, _) => Text('Total: \$${value.toStringAsFixed(2)}'),
);
```

## Next Steps

- [Learn about transformation operators →](/documentation/listen_it/operators/transform)
- [Learn about filtering operators →](/documentation/listen_it/operators/filter)
- [Learn about time-based operators →](/documentation/listen_it/operators/time)
