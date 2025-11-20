# How Does It Work?

## Lifting the magic curtain

*It's not necessary to understand this chapter to use `watch_it` successfully.*

You might be wondering how it's possible to watch multiple objects without passing identifiers to the `watch*()` functions. The mechanism might feel like a clever hack, but it's the same pattern used by `flutter_hooks` and React Hooks, and the clean API it provides is worth it.

## The Concept

When you use `WatchingWidget`, `WatchingStatefulWidget`, or the mixins, you add a handler into Flutter's build mechanism.

**Before the `build()` function is called**, a `_WatchItState` object is assigned to a global variable `_activeWatchItState`. This object contains:
- A reference to the widget's Element (to trigger rebuilds)
- A list of watch entries

Through this global variable, the `watch*()` functions can access the Element and their stored data.

**On first build**: Each `watch*()` call creates a new watch entry in the list and increments a counter.

**On rebuilds**: The counter is reset to zero, and with each `watch*()` call it's incremented again to access the data stored during the previous build.

**After build completes**: The global variable is reset to `null`. This is why calling `watch*()` outside build throws an error.

**On widget disposal**: All watch entries are disposed, cleaning up all listeners and subscriptions automatically.

## Why Order Matters

Now it's clear why the `watch*()` functions must always be called in the **same order**:

Each `watch*()` call retrieves its data by index position in the list. If the order changes between builds, the wrong data gets retrieved, causing type errors.

```dart
// First build
final todos = watchValue(...);  // Index 0
final user = watchValue(...);   // Index 1

// Rebuild with different order - WRONG!
if (condition) {
  final user = watchValue(...);  // Index 0 - expects todos data!
}
final todos = watchValue(...);   // Index 1 - expects user data!
```

No conditionals are allowed that would change the order, because the relationship between the `watch*()` call and its stored entry would break.

For detailed rules and safe patterns, see [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md).

## Same Pattern as Hooks

If this sounds familiar, it's because the exact same mechanism is used by `flutter_hooks` and React Hooks. It's a proven pattern that trades a strict ordering requirement for a clean, intuitive API - but with a more intuitive API than `flutter_hooks` through deep integration with `get_it`.

## Further Reading

- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - CRITICAL ordering constraints
- [Debugging & Tracing](/documentation/watch_it/debugging_tracing.md) - Tools for finding ordering violations
- [Best Practices](/documentation/watch_it/best_practices.md) - Patterns for effective use
