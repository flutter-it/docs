# Side Effects with Handlers

You've learned [`watch()`](/documentation/watch_it/your_first_watch_functions.md) functions for rebuilding widgets. But what about actions that DON'T need a rebuild, like navigation, showing toasts, or logging?

That's where **handlers** come in.

## Watch vs Handler: When to Use Each

**Use `watch()` when you need to REBUILD the widget:**
```dart
final todos = watchValue((TodoManager m) => m.todos);
return ListView.builder(...);  // Rebuild with new todos
```

**Use `registerHandler()` when you need a SIDE EFFECT (no rebuild):**
```dart
registerHandler(
  select: (TodoManager m) => m.createCommand,
  handler: (context, result, cancel) {
    // Navigate to detail page (no rebuild needed)
    Navigator.of(context).push(...);
  },
);
```

## registerHandler - The Basics

`registerHandler()` runs a callback when data changes, but doesn't trigger a rebuild:

<<< @/../code_samples/lib/watch_it/register_handler_example.dart#example

**The pattern:**
1. `select` - What to watch (like `watchValue`)
2. `handler` - What to do when it changes
3. Handler receives `context`, `value`, and `cancel` function

## Common Use Cases

### 1. Navigation on Success

<<< @/../code_samples/lib/watch_it/handler_navigation_example.dart#example

### 2. Show Snackbar

<<< @/../code_samples/lib/watch_it/handler_snackbar_example.dart#example

### 3. Show Error Dialog

<<< @/../code_samples/lib/watch_it/command_handler_error_example.dart#example

### 4. Logging / Analytics

```dart
registerHandler(
  select: (UserManager m) => m.user,
  handler: (context, user, cancel) {
    if (user != null) {
      analytics.logEvent('user_logged_in', {
        'userId': user.id,
      });
    }
  },
);
```

## Handler Types

watch_it provides specialized handlers for different data types:

### registerHandler - Generic Handler

```dart
registerHandler(
  select: (Manager m) => m.data,
  handler: (context, value, cancel) {
    print('Data changed: $value');
  },
);
```

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

```dart
registerHandler(
  select: (Service s) => s.data,
  handler: (context, value, cancel) {
    if (value == 'STOP') {
      cancel();  // Stop listening to future changes
    }
  },
);
```

**Common use case**: One-time actions

<<< @/../code_samples/lib/watch_it/handler_cancel_example.dart#example

## Combining Handlers and Watch

You can use both in the same widget:

<<< @/../code_samples/lib/watch_it/handler_combining_watch_example.dart#example

## Handler Patterns

### Pattern 1: Conditional Navigation

```dart
registerHandler(
  select: (AuthService s) => s.user,
  handler: (context, user, cancel) {
    if (user == null) {
      // User logged out - navigate to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  },
);
```

### Pattern 2: Show Loading Dialog

```dart
registerHandler(
  select: (Manager m) => m.longRunningCommand.isExecuting,
  handler: (context, isExecuting, cancel) {
    if (isExecuting) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing...'),
            ],
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();  // Close dialog
    }
  },
);
```

### Pattern 3: Chain Actions

```dart
// When create succeeds, refresh the list
registerHandler(
  select: (TodoManager m) => m.createTodoCommand,
  handler: (context, command, cancel) {
    if (command?.value != null) {
      // Create succeeded - refresh the list
      di<TodoManager>().fetchTodosCommand.execute();
    }
  },
);
```

### Pattern 4: Debounced Actions

```dart
Timer? _debounce;

registerHandler(
  select: (SearchManager m) => m.query,
  handler: (context, query, cancel) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      // Debounced search
      di<SearchManager>().searchCommand.execute(query);
    });
  },
);
```

## Handler vs Watch Decision Tree

**Ask yourself: "Does this change need to update the UI?"**

**YES** → Use `watch()`:
```dart
final todos = watchValue((Manager m) => m.todos);
return ListView(...);  // UI shows the todos
```

**NO** → Use `registerHandler()`:
```dart
registerHandler(
  select: (Manager m) => m.createCommand,
  handler: (context, result, cancel) {
    Navigator.push(...);  // Navigate, don't rebuild
  },
);
```

## Common Mistakes

### ❌ Using watch() for navigation
```dart
// BAD - rebuilds entire widget just to navigate
final loginResult = watchValue((Auth m) => m.loginCommand);
if (loginResult?.value == true) {
  Navigator.push(...);  // Triggers unnecessary rebuild
}
```

### ✅ Use handler for navigation
```dart
// GOOD - navigate without rebuild
registerHandler(
  select: (Auth m) => m.loginCommand,
  handler: (context, command, cancel) {
    if (command?.value == true) {
      Navigator.push(...);
    }
  },
);
```

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
