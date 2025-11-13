---
next:
  text: 'Operators'
  link: '/documentation/listen_it/operators/overview'
---

<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/listen_it.svg" alt="listen_it logo" width="100" />
  <h1 style="margin: 0;">listen_it</h1>
</div>

**Reactive primitives for Flutter** - observable collections and powerful operators for ValueListenable.

## Overview

`listen_it` provides two essential reactive primitives for Flutter development:

1. **Reactive Collections** - ListNotifier, MapNotifier, SetNotifier that automatically notify listeners when their contents change
2. **ValueListenable Operators** - Extension methods that let you transform, filter, combine, and react to value changes

These primitives work together to help you build reactive data flows in your Flutter apps without code generation or complex frameworks.

![listen_it Data Flow](/images/listen-it-flow.svg)

> Join our support Discord server: [https://discord.com/invite/Nn6GkYjzW](https://discord.com/invite/Nn6GkYjzW)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  listen_it: ^5.2.0
```

## Quick Start

### listen() - The Foundation

Lets you work with a `ValueListenable` (and `Listenable`) as it should be by installing a handler function that is called on any value change and gets the new value passed as an argument. **This gives you the same pattern as with Streams**, making it natural and consistent.

```dart
// For ValueListenable<T>
ListenableSubscription listen(
  void Function(T value, ListenableSubscription subscription) handler
)

// For Listenable
ListenableSubscription listen(
  void Function(ListenableSubscription subscription) handler
)
```

<<< @/../code_samples/lib/listen_it/listen_basic.dart#example

The returned `subscription` can be used to deactivate the handler. As you might need to uninstall the handler from inside the handler you get the subscription object passed to the handler function as second parameter.

This is particularly useful when you want a handler to run only once or a certain number of times:

<<< @/../code_samples/lib/listen_it/listen_basic.dart#self_cancel

For regular `Listenable` (not `ValueListenable`), the handler only receives the subscription parameter since there's no value to access:

<<< @/../code_samples/lib/listen_it/listen_basic.dart#listenable

::: tip Why listen()?
- **Same pattern as Streams** - Familiar API if you've used Stream.listen()
- **Self-cancellation** - Handlers can unsubscribe themselves from inside the handler
- **Works outside the widget tree** - For business logic, services, side effects
- **Multiple handlers** - Install multiple independent handlers on the same Listenable
:::

### ValueListenable Operators

Chain operators together to transform and react to value changes:

<<< @/../code_samples/lib/listen_it/chain_operators.dart#example

#### Available Operators

| Operator | Category | Description |
|----------|----------|-------------|
| [**listen()**](/documentation/listen_it/operators/overview#listening) | Listening | Install handlers that react to changes (Stream-like pattern) |
| [**map()**](/documentation/listen_it/operators/transform) | Transformation | Transform values to different types |
| [**select()**](/documentation/listen_it/operators/transform) | Transformation | React only when specific properties change |
| [**where()**](/documentation/listen_it/operators/filter) | Filtering | Filter which values propagate |
| [**debounce()**](/documentation/listen_it/operators/time) | Time-Based | Delay notifications until changes stop |
| [**async()**](/documentation/listen_it/operators/time) | Time-Based | Defer updates to next frame |
| [**combineLatest()**](/documentation/listen_it/operators/combine) | Combining | Merge 2-6 ValueListenables |
| [**mergeWith()**](/documentation/listen_it/operators/combine) | Combining | Combine value changes from multiple sources |

### Reactive Collections

Reactive versions of List, Map, and Set that implement ValueListenable and automatically notify listeners on mutations:

<<< @/../code_samples/lib/listen_it/list_notifier_basic.dart#example

Use with `ValueListenableBuilder` for reactive UI:

<<< @/../code_samples/lib/listen_it/list_notifier_widget.dart#example

Or with `watchValue` from [watch_it](/documentation/watch_it/getting_started) for cleaner code:

<<< @/../code_samples/lib/listen_it/list_notifier_watch_it.dart#example

#### Choosing the Right Collection

| Collection | Use When | Example Use Cases |
|------------|----------|-------------------|
| **ListNotifier\<T\>** | Order matters, duplicates allowed | Todo lists, chat messages, search history |
| **MapNotifier\<K,V\>** | Need key-value lookups | User preferences, caches, form data |
| **SetNotifier\<T\>** | Unique items only, fast membership tests | Selected item IDs, active filters, tags |

## When to Use What

### Use ValueListenable Operators When:
- ✅️ You need to transform values (map, select)
- ✅️ You need to filter updates (where)
- ✅️ You need to debounce rapid changes (search inputs)
- ✅️ You need to combine multiple ValueListenables
- ✅️ You're building data transformation pipelines

### Use Reactive Collections When:
- ✅️ You need a List, Map, or Set that notifies listeners on mutations
- ✅️ You want automatic UI updates without manual `notifyListeners()` calls
- ✅️ You're building reactive lists, caches, or sets in your UI layer
- ✅️ You want to batch multiple operations into a single notification

## Key Concepts

### Reactive Collections

All three collection types (ListNotifier, MapNotifier, SetNotifier) extend their standard Dart collection interfaces and add:

- **Automatic Notifications** - Every mutation triggers listeners
- **Notification Modes** - Control when notifications fire (always, normal, manual)
- **Transactions** - Batch operations into single notifications
- **Immutable Values** - `.value` getters return unmodifiable views
- **ValueListenable Interface** - Works with `ValueListenableBuilder` and watch_it

[Learn more about collections →](/documentation/listen_it/collections/introduction)

### ValueListenable Operators

Operators create transformation chains:

- **Chainable** - Each operator returns a new ValueListenable
- **Lazy Initialization** - Chains subscribe only when listeners are added
- **Hot Subscription** - Once subscribed, chains stay subscribed
- **Type Safe** - Full compile-time type checking

[Learn more about operators →](/documentation/listen_it/operators/overview)

## CustomValueNotifier

A ValueNotifier with configurable notification behavior and modes.

### Constructor

```dart
CustomValueNotifier<T>(
  T initialValue, {
  CustomNotifierMode mode = CustomNotifierMode.normal,
  bool asyncNotification = false,
  void Function(Object error, StackTrace stackTrace)? onError,
})
```

**Parameters:**
- `initialValue` - The initial value
- `mode` - Notification mode (default: `CustomNotifierMode.normal`)
- `asyncNotification` - If true, notifications are deferred asynchronously to avoid setState-during-build issues
- `onError` - Optional error handler called when a listener throws an exception. If not provided, exceptions are reported via `FlutterError.reportError()`

### Basic Usage

<<< @/../code_samples/lib/listen_it/custom_value_notifier.dart#example

### Notification Modes

CustomValueNotifier supports three modes via the `CustomNotifierMode` enum:

- **normal** (default for CustomValueNotifier) - Only notifies when value actually changes using `==` comparison
- **always** - Notifies on every assignment, even if value is the same
- **manual** - Only notifies when you explicitly call `notifyListeners()`

```dart
final counter = CustomValueNotifier<int>(
  0,
  mode: CustomNotifierMode.normal,  // default
);

counter.value = 0;  // ❌️ No notification (value unchanged)
counter.value = 1;  // ✅️ Notifies (value changed)
```

::: tip Different Defaults
**CustomValueNotifier** defaults to `normal` mode to be a **drop-in replacement for ValueNotifier**, which only notifies when the value actually changes using `==` comparison.

**Reactive Collections** (ListNotifier, MapNotifier, SetNotifier) default to `always` mode to ensure UI updates on every operation, even when objects don't override `==`.

[Learn more about notification modes →](/documentation/listen_it/collections/notification_modes)
:::

## Real-World Example

Combining operators and collections for reactive search:

<<< @/../code_samples/lib/listen_it/search_viewmodel.dart#example

## Integration with flutter_it Ecosystem

### With watch_it (Recommended!)

watch_it v2.0+ provides **automatic selector caching**, making inline chain creation completely safe:

<<< @/../code_samples/lib/listen_it/chain_watch_it_safe.dart#watchValue_safe

The default `allowObservableChange: false` caches the selector, so the chain is created only once!

[Learn more about watch_it integration →](/documentation/watch_it/getting_started)

### With get_it

Register your reactive collections and chains in get_it for global access:

```dart
void configureDependencies() {
  getIt.registerSingleton<ListNotifier<Todo>>(ListNotifier());
  getIt.registerLazySingleton(() => ValueNotifier<String>(''));
}
```

[Learn more about get_it →](/documentation/get_it/getting_started)

### With command_it

command_it uses listen_it operators internally for ValueListenable operations:

```dart
final command = Command.createAsync<String, void>(
  (searchTerm) async => performSearch(searchTerm),
  restriction: searchTerm.where((term) => term.length >= 3),
);
```

[Learn more about command_it →](/documentation/command_it/getting_started)

## Next Steps

- [Operators →](/documentation/listen_it/operators/overview)
- [Collections →](/documentation/listen_it/collections/introduction)
- [Best Practices →](/documentation/listen_it/best_practices)
- [Examples →](/examples/listen_it/listen_it)

## Previous Package Names

- Previously published as `functional_listener` (operators only)
- Reactive collections previously published as `listenable_collections`
- Both are now unified in `listen_it` v5.0+
