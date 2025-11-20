# Debugging & Troubleshooting

Common errors, solutions, debugging techniques, and troubleshooting strategies for `watch_it`.

## Common Errors

### "Watch ordering violation detected!"

**Error message:**
```
Watch ordering violation detected!

You have conditional watch calls (inside if/switch statements) that are
causing `watch_it` to retrieve the wrong objects on rebuild.

Fix: Move ALL conditional watch calls to the END of your build method.
Only the LAST watch call can be conditional.
```

**Cause:** Watch calls inside `if` statements followed by other watches, causing order to change between builds.

**Solution:** See [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) for detailed explanation, examples, and safe patterns.

**Debugging tip:** Call `enableTracing()` in your build method to see exact source locations of conflicting watch statements.

### "watch() called outside build"

**Error message:**
```
watch() can only be called inside build()
```

**Cause:** Trying to use watch functions in callbacks, constructors, or other methods.

**Example:**

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#watch_outside_build_bad

**Solution:** Only call watch functions directly in `build()`:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#watch_outside_build_good

### "Type 'X' is not a subtype of type 'Listenable'"

**Error message:**
```
type 'MyManager' is not a subtype of type 'Listenable'
```

**Cause:** Using `watchIt<T>()` on an object that isn't a `Listenable`.

**Example:**

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_listenable_bad

**Solution:** Use `watchValue()` instead:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_listenable_good_watch_value

Or make your manager extend `ChangeNotifier`:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_listenable_good_change_notifier

### "get_it: Object/factory with type X is not registered"

**Error message:**
```
get_it: Object/factory with type TodoManager is not registered inside GetIt
```

**Cause:** Trying to watch an object that hasn't been registered in `get_it`.

**Solution:** Register it before using:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_registered_solution

See [get_it Object Registration](/documentation/get_it/object_registration.md) for all registration methods.

### Widget doesn't rebuild when data changes

**Symptoms:**
- Data changes but UI doesn't update
- `print()` shows new values but widget still shows old data

**Common causes:**

#### 1. Not watching the data

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_watching_bad

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_watching_good

#### 2. Not notifying changes

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_notifying_bad

**Option 1 - Use ListNotifier from `listen_it` (recommended):**

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_notifying_good_list_notifier

**Option 2 - Use custom ValueNotifier with manual notification:**

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_notifying_good_custom_notifier

See [listen_it Collections](/documentation/listen_it/collections/introduction.md) for ListNotifier, MapNotifier, and SetNotifier.

### Memory leaks - subscriptions not cleaned up

**Symptoms:**
- Memory usage grows over time
- Old widgets still reacting to changes
- Performance degrades

**Cause:** Not using `WatchingWidget` or `WatchItMixin` - doing manual subscriptions.

**Solution:** Always use `watch_it` widgets:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#memory_leak_bad

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#memory_leak_good

### registerHandler not firing

**Symptoms:**
- Handler callback never executes
- Side effects (navigation, dialogs) don't happen
- No errors thrown

**Common causes:**

#### 1. Handler registered after conditional return

<<< @/../code_samples/lib/watch_it/debugging_registerhandler.dart#handler_registered_after_return_bad

**Solution:** Register handlers BEFORE any conditional returns:

<<< @/../code_samples/lib/watch_it/debugging_registerhandler.dart#handler_registered_before_return_good

## Debugging Techniques

### Enable `watch_it` Tracing

Get detailed logs of watch subscriptions and source locations for ordering violations:

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Call at the start of build to enable tracing
    enableTracing(
      logRebuilds: true,
      logHandlers: true,
      logHelperFunctions: true,
    );

    final todos = watchValue((TodoManager m) => m.todos);
    // ... rest of build
  }
}
```

**Benefits:**
- Shows which watch triggered the rebuild of your widget
- Shows exact source locations of watch calls
- Helps identify ordering violations
- Tracks rebuild activity
- Shows handler executions

**Use case:** When your widget rebuilds unexpectedly, enable tracing to see exactly which watched value changed and triggered the rebuild. This helps you identify if you're watching too much data or the wrong properties.

**Alternative:** Use `WatchItSubTreeTraceControl` widget to enable tracing for a specific subtree:

```dart
// First, enable subtree tracing globally (typically in main())
enableSubTreeTracing = true;

// Then wrap ONLY the problematic widget/screen - NOT the whole app!
// Otherwise you'll drown in logs from every widget
return Scaffold(
  body: WatchItSubTreeTraceControl(
    logRebuilds: true,        // Required: log rebuild events
    logHandlers: true,        // Required: log handler executions
    logHelperFunctions: true, // Required: log helper function calls
    child: ProblematicWidget(), // Only the widget you're debugging
  ),
);
```

**Important:** Wrap only the specific widget or screen causing issues, not your entire app. Tracing the whole app generates overwhelming amounts of logs.

**Note:**
- You can nest multiple `WatchItSubTreeTraceControl` widgets - the nearest ancestor's settings apply
- Must set `enableSubTreeTracing = true` globally for subtree controls to work

### Isolate the problem

Create minimal reproduction:

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#isolate_problem

This isolates:
- Does the watch subscription work?
- Does the widget rebuild on data change?
- Are there ordering issues?

## Getting Help

When reporting issues:

1. **Minimal reproduction** - Isolate the problem
2. **Versions** - `watch_it`, Flutter, Dart versions
3. **Error messages** - Full stack trace
4. **Expected vs actual** - What should happen vs what happens
5. **Code sample** - Complete, runnable example

**Where to ask:**
- **Discord:** [Join flutter_it community](https://discord.gg/ZHYHYCM38h)
- **GitHub Issues:** [watch_it issues](https://github.com/escamoteur/watch_it/issues)
- **Stack Overflow:** Tag with `flutter` and `watch-it`

## See Also

- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - CRITICAL constraints
- [Best Practices](/documentation/watch_it/best_practices.md) - Patterns and tips
- [How watch_it Works](/documentation/watch_it/how_it_works.md) - Understanding the mechanism
