# More Watch Functions

You've learned [`watchValue()`](/documentation/watch_it/your_first_watch_functions.md) for watching `ValueListenable` properties. Now let's explore the other watch functions.

## watchIt - Watch Whole Object in get_it

When your registered object IS a `Listenable`, use `watchIt()`:

<<< @/../code_samples/lib/watch_it/watch_it_change_notifier_example.dart#example

**When to use `watchIt()`:**
- Your object extends `ChangeNotifier` or `ValueNotifier`
- You need to call methods on the object
- The whole object notifies changes

## watch - Watch Any Listenable

`watch()` is the most flexible - watch ANY `Listenable`:

<<< @/../code_samples/lib/watch_it/watch_local_listenable_example.dart#example

**When to use `watch()`:**
- Watching local `Listenable` objects
- You already have a reference to the `Listenable`
- Most generic case

::: tip watch() is the Foundation
`watch()` is the most flexible function - you could use it to replace `watchIt()` and `watchValue()`:

```dart
// These are equivalent:
final manager = watchIt<CounterManager>();
final manager = watch(di<CounterManager>());

// These are equivalent:
final count = watchValue((CounterManager m) => m.count);
final count = watch(di<CounterManager>().count).value;
```

**Why use the convenience functions?**
- `watchIt()` is cleaner for getting the whole object from get_it
- `watchValue()` provides better type inference and cleaner syntax
- Each is optimized for its specific use case
:::

### Using watch() Just to Trigger Rebuilds

Sometimes you don't need the return value - you just want to trigger a rebuild when a Listenable changes:

<<< @/../code_samples/lib/watch_it/watch_trigger_rebuild_example.dart#example

**Key points:**
- `watch(controller)` triggers rebuild when controller notifies
- We don't use the return value - just call `watch()` for the side effect
- The widget rebuilds, so `controller.text.length` is always current
- Button enable/disable state updates automatically

## watchPropertyValue - Selective Updates

Only rebuild when a specific property changes:

<<< @/../code_samples/lib/watch_it/watch_property_value_selective_example.dart#example

**The difference:**

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#property_value_difference

## Quick Comparison

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#quick_comparison

## Choosing the Right Function

**Start with `watchValue()`** - it's the most common:

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#watchValue_usage

**Use `watchIt()` when you need the whole object:**

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#watchIt_usage

**Use `watch()` for local Listenables:**

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#watch_usage

**Use `watchPropertyValue()` for optimization:**

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#watchPropertyValue_usage

## Practical Example

Mixing different watch functions:

<<< @/../code_samples/lib/watch_it/dashboard_mixed_watch_example.dart#example

## Key Takeaways

✅ `watchValue()` - Most common, for `ValueListenable` properties
✅ `watchIt()` - When object IS a `Listenable`
✅ `watch()` - Most flexible, any `Listenable`
✅ `watchPropertyValue()` - Performance optimization
✅ Mix and match based on your needs

**Next:** Learn [how watch_it works](/documentation/watch_it/how_it_works.md) to understand the mechanism.

## See Also

- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Start here
- [Watching Streams & Futures](/documentation/watch_it/watching_streams_and_futures.md) - Streams and Futures
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - Complete API
