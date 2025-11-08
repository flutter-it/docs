# More Watch Functions

You've learned [`watchValue()`](/documentation/watch_it/your_first_watch_functions.md) for watching `ValueListenable` properties. Now let's explore the other watch functions.

## watchIt - Watch the Whole Object

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

## watchPropertyValue - Selective Updates

Only rebuild when a specific property changes:

<<< @/../code_samples/lib/watch_it/watch_property_value_selective_example.dart#example

**The difference:**
```dart
// Rebuilds on EVERY SettingsModel change
final settings = watchIt<SettingsModel>();
final darkMode = settings.darkMode;

// Rebuilds ONLY when darkMode changes
final darkMode = watchPropertyValue((SettingsModel m) => m.darkMode);
```

## Quick Comparison

```dart
// 1. watchValue - Most common
final todos = watchValue((TodoManager m) => m.todos);

// 2. watchIt - When manager IS a Listenable
final manager = watchIt<TodoManager>();

// 3. watch - Local or direct Listenable
final counter = createOnce(() => ValueNotifier(0));
final count = watch(counter).value;

// 4. watchPropertyValue - Selective updates
final darkMode = watchPropertyValue((Settings m) => m.darkMode);
```

## Choosing the Right Function

**Start with `watchValue()`** - it's the most common:
```dart
final data = watchValue((Manager m) => m.data);
```

**Use `watchIt()` when you need the whole object:**
```dart
final manager = watchIt<TodoManager>();
manager.addTodo('New todo');
```

**Use `watch()` for local Listenables:**
```dart
final controller = createOnce(() => TextEditingController());
final text = watch(controller).value.text;
```

**Use `watchPropertyValue()` for optimization:**
```dart
// Only rebuild when THIS specific property changes
final darkMode = watchPropertyValue((Settings m) => m.darkMode);
```

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
- [Async Data](/documentation/watch_it/async_data.md) - Streams and Futures
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - Complete API
