# Side Effects with Handlers

You've learned [`watch()`](/documentation/watch_it/your_first_watch_functions.md) functions for rebuilding widgets. But what about actions that DON'T need a rebuild, like calling a function, navigation, showing toasts, or logging?

That's where **handlers** come in. Handlers can react to changes in [ValueListenables](#registerhandler-for-valuelistenables), [Listenables](#registerchangenotifierhandler-for-changenotifier), [Streams](#registerstreamhandler-for-streams), and [Futures](#registerfuturehandler-for-futures) without triggering widget rebuilds.

## registerHandler - The Basics

`registerHandler()` runs a callback when data changes, but doesn't trigger a rebuild:

<<< @/../code_samples/lib/watch_it/register_handler_basic_example.dart#example

**The pattern:**
1. `select` - What to watch (like `watchValue`)
2. `handler` - What to do when it changes
3. Handler receives `context`, `value`, and `cancel` function

## Common Handler Patterns

::: details Navigation on Success {open}

<<< @/../code_samples/lib/watch_it/handler_navigation_example.dart#example

:::

::: details Calling Business Functions

One of the most common uses of handlers is to call commands or methods on business objects in response to triggers:

<<< @/../code_samples/lib/watch_it/handler_trigger_business_object.dart#example

**Key points:**
- Handler watches a trigger (form submit, button press, etc.)
- Handler calls command/method on business object
- Same widget can optionally watch the command state (for loading indicators, etc.)
- Clear separation: handler triggers action, watch shows state

:::

::: details Show Snackbar

<<< @/../code_samples/lib/watch_it/handler_snackbar_example.dart#example

:::

## Watch vs Handler: When to Use Each

**Use `watch()` when you need to REBUILD the widget:**

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#watch_vs_handler_watch

**Use `registerHandler()` when you need a SIDE EFFECT (no rebuild):**

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#watch_vs_handler_handler

## Complete Example: Todo Creation

This example combines multiple handler patterns - navigation on success, error handling, and watching loading state:

<<< @/../code_samples/lib/watch_it/register_handler_example.dart#example

**This example demonstrates:**
- Watching command result for navigation
- Separate error handler with error UI
- Combining `registerHandler()` (side effects) with `watchValue()` (UI state)
- Using `createOnce()` for controllers

## The `cancel` Parameter

All handlers receive a `cancel` function. Call it to stop reacting:

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#cancel_parameter

**Common use case**: One-time actions

<<< @/../code_samples/lib/watch_it/handler_cancel_example.dart#example

## Handler Types

`watch_it` provides specialized handlers for different data types:

### registerHandler - For ValueListenables

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#register_handler_generic

### registerStreamHandler - For Streams

<<< @/../code_samples/lib/watch_it/register_stream_handler_example.dart#example

**Use when:**
- Watching a Stream
- Want to react to each event
- Don't need to display the value (no rebuild)

### registerFutureHandler - For Futures

<<< @/../code_samples/lib/watch_it/register_future_handler_example.dart#example

**Use when:**
- Watching a Future
- Want to run code when it completes
- Don't need to display the value

### registerChangeNotifierHandler - For ChangeNotifier

<<< @/../code_samples/lib/watch_it/register_change_notifier_handler_example.dart#example

**Use when:**
- Watching a `ChangeNotifier`
- Need access to the full notifier object
- Want to trigger actions on any change

## Advanced Patterns

::: details Chaining Actions

Handlers excel at chaining actions - triggering one operation after another completes:

<<< @/../code_samples/lib/watch_it/handler_chain_actions_reload.dart#example

**Key points:**
- Handler watches for save completion
- Handler triggers reload on another service
- Common pattern: save → reload list, update → refresh data
- Each service remains independent

:::

::: details Error Handling

<<< @/../code_samples/lib/watch_it/command_handler_error_example.dart#example

:::

::: details Debounced Actions

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#pattern4_debounced_actions

:::

## Optional Handler Configuration

All handler functions accept additional optional parameters:

**`target`** - Provide a local object to watch (instead of using get_it):
```dart
final myManager = UserManager();

registerHandler(
  select: (UserManager m) => m.currentUser,
  handler: (context, user, cancel) { /* ... */ },
  target: myManager, // Use this local object, not get_it
);

// Or provide the listenable/stream/future directly without selector
registerHandler(
  handler: (context, user, cancel) { /* ... */ },
  target: myValueNotifier, // Watch this ValueNotifier directly
);
```

::: warning Important
If `target` is used as the observable object (listenable/stream/future) and it changes during builds with `allowObservableChange: false` (the default), an exception will be thrown. Set `allowObservableChange: true` if the target observable needs to change between builds.
:::

**`allowObservableChange`** - Controls selector caching behavior (default: `false`):

See [Safety: Automatic Caching in Selector Functions](/documentation/watch_it/watching_multiple_values.md#safety-automatic-caching-in-selector-functions) for detailed explanation of this parameter.

**`executeImmediately`** - Execute handler on first build with current value (default: `false`):
```dart
registerHandler(
  select: (DataManager m) => m.data,
  handler: (context, value, cancel) { /* ... */ },
  executeImmediately: true, // Handler called immediately with current value
);
```

When `true`, the handler is called on the first build with the current value of the observed object, without waiting for a change. The handler then continues to execute on subsequent changes.

## Handler vs Watch Decision Tree

**Ask yourself: "Does this change need to update the UI?"**

**YES** → Use `watch()`:

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#decision_tree_watch

**NO (Should it call a function, navigate, show a toast, etc.)** → Use `registerHandler()`:

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#decision_tree_handler

**Important**: You cannot update local variables inside a handler that will be used in the build function outside the handler. Handlers don't trigger rebuilds, so any variable changes won't be reflected in the UI. If you need to update the UI, use `watch()` instead.

## Common Mistakes

### ❌️ Using watch() for navigation

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#mistake_bad

### ✅ Use handler for navigation

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#mistake_good

### ❌ Handler in widget that gets destroyed

If the widget containing the handler is destroyed during command execution, the handler is lost and misses state changes:

<<< @/../code_samples/lib/watch_it/handler_lifecycle_example.dart#bad

### ✅ Move handler to stable parent widget

<<< @/../code_samples/lib/watch_it/handler_lifecycle_example.dart#good

## What's Next?

Now you know when to rebuild (watch) vs when to run side effects (handlers). Next:

- [Observing Commands](/documentation/watch_it/observing_commands.md) - Comprehensive command_it integration
- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - CRITICAL constraints
- [Lifecycle Functions](/documentation/watch_it/lifecycle.md) - `callOnce`, `createOnce`, etc.

## Key Takeaways

✅ `watch()` = Rebuild the widget
✅ `registerHandler()` = Side effect (navigation, toast, etc.)
✅ Handlers receive `context`, `value`, and `cancel`
✅ Use `cancel()` for one-time actions
✅ Combine watch and handlers in same widget
✅ Choose based on: "Does this need to update the UI?"

## See Also

- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Learn watch basics
- [Observing Commands](/documentation/watch_it/observing_commands.md) - command_it integration
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - Complete API docs
