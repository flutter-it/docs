# Your First Watch Functions

Now that you know [why you need special widgets](/documentation/watch_it/watching_widgets.md), let's learn how to actually **watch** data and make your widgets reactive.

## The Simplest Watch: watchValue

The most common way to watch data is with `watchValue()`. It watches a `ValueListenable` property from an object registered in get_it.

### Basic Counter Example

<<< @/../code_samples/lib/watch_it/counter_simple_example.dart#example

**What happens:**
- `watchValue()` accesses `CounterManager` from get_it
- Watches the `count` property
- Widget rebuilds automatically when count changes
- No manual listeners, no cleanup needed

## Why This Is Better

**Without watch_it:**

<<< @/../code_samples/lib/watch_it/counter_manual_listener_example.dart#example

**With watch_it:**

<<< @/../code_samples/lib/watch_it/counter_simple_example.dart#example

From 25+ lines to 3 lines!

## Watching Multiple Values

Just add more watch calls:

<<< @/../code_samples/lib/watch_it/user_profile_multiple_values_example.dart#example

When ANY of them change, the widget rebuilds. That's it!

## Real Example: Todo List

<<< @/../code_samples/lib/watch_it/todo_manager_example.dart#example

Add a todo? Widget rebuilds automatically. No `setState`, no `StreamBuilder`.

## Common Pattern: Loading States

<<< @/../code_samples/lib/watch_it/data_widget_loading_example.dart#example

## Try It Yourself

1. Create a `ValueNotifier` in your manager:
   ```dart
   class MyManager {
     final message = ValueNotifier<String>('Hello');
   }
   ```

2. Register it:
   ```dart
   di.registerLazySingleton<MyManager>(() => MyManager());
   ```

3. Watch it:
   ```dart
   class MyWidget extends WatchingWidget {
     @override
     Widget build(BuildContext context) {
       final message = watchValue((MyManager m) => m.message);
       return Text(message);
     }
   }
   ```

4. Change it and watch the magic:
   ```dart
   di<MyManager>().message.value = 'World!';  // Widget rebuilds!
   ```

## Key Takeaways

✅ `watchValue()` is your go-to function
✅ One line replaces manual listeners and `setState`
✅ Works with any `ValueListenable<T>`
✅ Automatic subscription and cleanup
✅ Multiple watch calls = multiple subscriptions

**Next:** Learn about [more watch functions](/documentation/watch_it/more_watch_functions.md) for different scenarios.

## See Also

- [WatchingWidgets](/documentation/watch_it/watching_widgets.md) - Which widget type to use
- [More Watch Functions](/documentation/watch_it/more_watch_functions.md) - Other watch functions
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - Complete API reference
