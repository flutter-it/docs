---
title: Operators
---

# Operators

ValueListenable operators are extension methods that let you transform, filter, combine, and react to value changes in a reactive, composable way.

## Introduction

Extension functions on `ValueListenable` allow you to work with them almost like synchronous streams. Each operator returns a new `ValueListenable` that updates when the source changes, enabling you to build complex reactive data pipelines through chaining.

## Key Concepts

### Chainable

Each operator (except `listen()`) returns a new `ValueListenable`, allowing you to chain multiple operators together:

<<< @/../code_samples/lib/listen_it/chain_operators.dart#example

### Type Safe

All operators maintain full compile-time type checking:

```dart
final intNotifier = ValueNotifier<int>(42);

// Type is inferred: ValueListenable<String>
final stringNotifier = intNotifier.map<String>((i) => i.toString());

// Compile error if types don't match
// final badNotifier = intNotifier.map<String>((i) => i); // ❌️ Error
```

### Eager Initialization

By default, operator chains use **eager initialization** - they subscribe to their source immediately, ensuring `.value` is always correct even before adding listeners. This fixes stale value issues but uses slightly more memory.

```dart
final source = ValueNotifier<int>(5);
final mapped = source.map((x) => x * 2); // Subscribes immediately

print(mapped.value); // Always correct: 10

source.value = 7;
print(mapped.value); // Immediately updated: 14 ✓
```

For memory-constrained scenarios, pass `lazy: true` to delay subscription until the first listener is added:

```dart
final lazy = source.map((x) => x * 2, lazy: true);
// Doesn't subscribe until addListener() is called
```

::: warning Chain Lifecycle
Once initialized (either eagerly or after first listener), operator chains maintain their subscription to the source even when they have zero listeners. This persistent subscription is by design for efficiency, but **can cause memory leaks if chains are created inline in build methods**.

See the [best practices guide](/documentation/listen_it/best_practices) for safe patterns.
:::

## Available Operators

### Transformation

Transform values to different types or select specific properties:

- **[map()](/documentation/listen_it/operators/transform#map)** - Transform values using a function
- **[select()](/documentation/listen_it/operators/transform#select)** - React only when selected property changes

### Filtering

Control which values propagate through the chain:

- **[where()](/documentation/listen_it/operators/filter)** - Filter values based on a predicate

### Combining

Merge multiple ValueListenables together:

- **[combineLatest()](/documentation/listen_it/operators/combine#combinelatest)** - Combine two ValueListenables
- **[mergeWith()](/documentation/listen_it/operators/combine#mergewith)** - Merge multiple ValueListenables

### Time-Based

Control timing of value propagation:

- **[debounce()](/documentation/listen_it/operators/time#debounce)** - Only propagate after a pause
- **[async()](/documentation/listen_it/operators/time#async)** - Defer updates to next frame

### Listening

React to value changes:

- **listen()** - Install a handler function that's called on every value change

## Basic Usage Pattern

All operators follow a similar pattern:

```dart
final source = ValueNotifier<int>(0);

// Create operator chain
final transformed = source
    .where((x) => x > 0)
    .map<String>((x) => x.toString())
    .debounce(Duration(milliseconds: 300));

// Use with ValueListenableBuilder
ValueListenableBuilder<String>(
  valueListenable: transformed,
  builder: (context, value, _) => Text(value),
);

// Or install a listener
transformed.listen((value, subscription) {
  print('Value changed to: $value');
});
```

### With watch_it

watch_it v2.0+ provides automatic selector caching, making inline chain creation completely safe:

<<< @/../code_samples/lib/listen_it/operators_watch_it.dart#example

The default `allowObservableChange: false` caches the selector, so the chain is created only once!

[Learn more about watch_it integration →](/documentation/watch_it/getting_started)

## Common Patterns

### Transform Then Filter

```dart
final intNotifier = ValueNotifier<int>(0);

intNotifier
    .map((i) => i * 2)              // Double the value
    .where((i) => i > 10)            // Only values > 10
    .listen((value, _) => print(value));
```

### Select Then Debounce

```dart
final userNotifier = ValueNotifier<User>(user);

userNotifier
    .select<String>((u) => u.searchTerm)  // Only when searchTerm changes
    .debounce(Duration(milliseconds: 300)) // Wait for pause
    .listen((term, _) => search(term));
```

### Combine Multiple Sources

```dart
final source1 = ValueNotifier<int>(0);
final source2 = ValueNotifier<String>('');

source1
    .combineLatest<String, Result>(
      source2,
      (int i, String s) => Result(i, s),
    )
    .listen((result, _) => print(result));
```

## Memory Management

::: danger Important
**Always** create chains outside build methods or use watch_it for automatic caching.

**❌️ DON'T:**
```dart
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: source.map((x) => x * 2), // NEW CHAIN EVERY BUILD!
    builder: (context, value, _) => Text('$value'),
  );
}
```

**✅️ DO:**
```dart
// Option 1: Create chain as field
late final chain = source.map((x) => x * 2);

Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: chain, // Same object every build
    builder: (context, value, _) => Text('$value'),
  );
}

// Option 2: Use watch_it (automatic caching)
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final value = watchValue((Model m) => m.source.map((x) => x * 2));
    return Text('$value');
  }
}
```
:::

[Read complete best practices guide →](/documentation/listen_it/best_practices)

## Next Steps

- [Learn about transformation operators →](/documentation/listen_it/operators/transform)
- [Learn about filtering operators →](/documentation/listen_it/operators/filter)
- [Learn about combining operators →](/documentation/listen_it/operators/combine)
- [Learn about time-based operators →](/documentation/listen_it/operators/time)
- [Using operators with watch_it →](/documentation/watch_it/watching_multiple_values)
