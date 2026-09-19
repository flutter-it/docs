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

### Chain Lifecycle

Operator chains subscribe to their source when they are created, **detach when their last listener is removed** and re-attach on the next listener. While detached, `.value` is derived from the current source value on read, so it is never stale:

```dart
final source = ValueNotifier<int>(5);
final mapped = source.map((x) => x * 2);

print(mapped.value); // 10

source.value = 7;
print(mapped.value); // 14 ✅ - correct with or without listeners
```

Pass `lazy: true` to delay the first subscription until the first listener is added - a pure memory optimisation, `.value` stays correct:

```dart
final lazy = source.map((x) => x * 2, lazy: true);
print(lazy.value); // derived on read, no subscription yet
```

::: tip Keep Transformations Pure
The transformation may run on read while the chain is detached, so transformation functions must not have side effects.

See the [best practices guide](/documentation/listen_it/best_practices#chain-lifecycle) for the full lifecycle.
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

watch_it caches the selector, so creating a chain inline in a selector is safe - it is created once per widget instance and detaches from its source when the widget is disposed:

<<< @/../code_samples/lib/listen_it/operators_watch_it.dart#example

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

::: warning Important
Create chains once - outside build methods or inside a watch_it selector. A chain created in `build()` is a new object on every rebuild; it detaches once its listeners are gone, so it doesn't leak, but it does needless work.

**❌️ DON'T:**
```dart
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: source.map((x) => x * 2), // NEW CHAIN EVERY BUILD!
    builder: (context, value, _) => Text('$value'),
  );
}
```

**✅ DO:**
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
