# Side Effects with Handlers

You've learned [`watch()`](/documentation/watch_it/your_first_watch_functions.md) functions for rebuilding widgets. But what about actions that DON'T need a rebuild, like navigation, showing toasts, or logging?

That's where **handlers** come in.

## registerHandler - The Basics

`registerHandler()` runs a callback when data changes, but doesn't trigger a rebuild:

<<< @/../code_samples/lib/watch_it/register_handler_example.dart#example

**The pattern:**
1. `select` - What to watch (like `watchValue`)
2. `handler` - What to do when it changes
3. Handler receives `context`, `value`, and `cancel` function

## Key Handler Patterns

### Triggering Actions on Business Objects

One of the most common uses of handlers is to call commands or methods on business objects in response to triggers:

<<< @/../code_samples/lib/watch_it/handler_trigger_business_object.dart#example

**Key points:**
- Handler watches a trigger (form submit, button press, etc.)
- Handler calls command/method on business object
- Same widget can optionally watch the command state (for loading indicators, etc.)
- Clear separation: handler triggers action, watch shows state

### Chaining Actions (Reload After Save)

Handlers excel at chaining actions - triggering one operation after another completes:

<<< @/../code_samples/lib/watch_it/handler_chain_actions_reload.dart#example

**Key points:**
- Handler watches for save completion
- Handler triggers reload on another service
- Common pattern: save → reload list, update → refresh data
- Each service remains independent

## Watch vs Handler: When to Use Each

**Use `watch()` when you need to REBUILD the widget:**

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#watch_vs_handler_watch

**Use `registerHandler()` when you need a SIDE EFFECT (no rebuild):**

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#watch_vs_handler_handler

## Common Use Cases

### 1. Navigation on Success

<<< @/../code_samples/lib/watch_it/handler_navigation_example.dart#example

### 2. Show Snackbar

<<< @/../code_samples/lib/watch_it/handler_snackbar_example.dart#example

### 3. Show Error Dialog

<<< @/../code_samples/lib/watch_it/command_handler_error_example.dart#example

### 4. Logging / Analytics

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#logging_analytics

## Handler Types

`watch_it` provides specialized handlers for different data types:

### registerHandler - Generic Handler

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

## The `cancel` Parameter

All handlers receive a `cancel` function. Call it to stop watching:

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#cancel_parameter

**Common use case**: One-time actions

<<< @/../code_samples/lib/watch_it/handler_cancel_example.dart#example

## Combining Handlers and Watch

You can use both in the same widget:

<<< @/../code_samples/lib/watch_it/handler_combining_watch_example.dart#example

## Handler Patterns

### Pattern 1: Conditional Navigation

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#pattern1_conditional_navigation

### Pattern 2: Show Loading Dialog

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#pattern2_loading_dialog

### Pattern 3: Chain Actions

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#pattern3_chain_actions

### Pattern 4: Debounced Actions

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#pattern4_debounced_actions

## Handler vs Watch Decision Tree

**Ask yourself: "Does this change need to update the UI?"**

**YES** → Use `watch()`:

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#decision_tree_watch

**NO** → Use `registerHandler()`:

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#decision_tree_handler

## Common Mistakes

### ❌ Using watch() for navigation

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#mistake_bad

### ✅ Use handler for navigation

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#mistake_good

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
