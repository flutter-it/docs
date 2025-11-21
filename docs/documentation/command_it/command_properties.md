# Command Properties

Commands expose multiple `ValueListenable` properties for different aspects of execution. Learn when and how to use each one.

## Overview

Every command provides these observable properties:

| Property | Type | Purpose |
|----------|------|---------|
| [**value**](#value---the-command-itself) | `TResult` | Last successful result |
| [**isRunning**](#isrunning---async-execution-state) | `ValueListenable<bool>` | Async execution state (async only) |
| [**isRunningSync**](#isrunningsync---synchronous-state) | `ValueListenable<bool>` | Sync execution state |
| [**canRun**](#canrun---combined-state) | `ValueListenable<bool>` | Combined restriction + running |
| [**errors**](#errors---error-notifications) | `ValueListenable<CommandError?>` | Error notifications |
| [**results**](#results---all-data-combined) | `ValueListenable<CommandResult>` | All data combined |
| [**errorsDynamic**](#errorsdynamic---dynamic-error-type) | `ValueListenable<CommandError<dynamic>?>` | Errors with dynamic type |
| [**name**](#name---debug-identifier) | `String?` | Debug name identifier |
| [**clearErrors()**](#clearerrors---clear-error-state) | `void` | Clear error state manually |

::: warning Sync Commands and isRunning
**Accessing `.isRunning` on sync commands throws an assertion error.** Sync commands execute immediately without giving the UI time to react, so tracking execution state isn't meaningful.

Use `.isRunningSync` instead if you need a boolean for restrictions or other purposes - it always returns `false` for sync commands and works for both sync and async.
:::

## value - The Command Itself

The command **is** a `ValueListenable<TResult>`. It publishes the last successful result:

```dart
final loadCommand = Command.createAsyncNoParam<List<Todo>>(
  () => api.fetchTodos(),
  initialValue: [],
);

// Command is ValueListenable<List<Todo>>
ValueListenableBuilder<List<Todo>>(
  valueListenable: loadCommand, // The command itself
  builder: (context, todos, _) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => TodoTile(todos[index]),
    );
  },
)
```

**When to use:**
- Displaying the result data
- Simple cases where you only care about success
- Most common use case

**Note:** Only updates on successful completion. Doesn't update during execution or on errors.

::: tip Setting .value Directly
You can set `.value` directly to update or reset the command's result:

```dart
// Clear the command result
loadCommand.value = [];

// Set a specific value
loadCommand.value = [Todo(id: 1, title: 'Default')];
```

**Behavior:**
- Setting `.value` automatically triggers `notifyListeners()` and rebuilds UI
- By default (without `notifyOnlyWhenValueChanges`), listeners are notified even if the new value equals the old value
- With `notifyOnlyWhenValueChanges: true`, only notifies if the value actually changed

**When to use:**
- Reset command to initial/empty state
- Set a cached or default value without running the command
- Clear error state by setting a known good value

**Note:** This bypasses the command function - use `.run()` if you want to execute the command logic.
:::

## isRunning - Async Execution State

Tracks whether an async command is currently executing:

<<< @/../code_samples/lib/command_it/loading_state_watch_it_example.dart#example

**When to use:**
- Show loading indicators
- Disable buttons during execution
- Display "Processing..." messages

**Important limitations:**
- **Async commands only** - `createAsync*` functions
- Throws assertion if accessed on sync commands
- Updates **asynchronously** - brief delay before true

### Why Async Updates?

`isRunning` uses asynchronous notifications (via `asyncNotification: true` on `CustomValueNotifier`) to avoid race conditions. The update happens after a brief delay:

```dart
command.run();
print(command.isRunning.value); // Still false!

await Future.microtask(() {});
print(command.isRunning.value); // Now true
```

**Implication:**
- Use `isRunning` whenever you want to update UI elements (it's designed for UI updates)
- Use `isRunningSync` if you need immediate state changes for command restrictions or business logic

## isRunningSync - Synchronous State

Synchronous version of `isRunning`, updated immediately:

```dart
command.run();
print(command.isRunningSync.value); // Immediately true
```

**When to use:**
- **As restriction for other commands** (prevents race conditions)
- When you need immediate state for business logic (not for UI)

```dart
final saveCommand = Command.createAsync<Data, void>(
  (data) => api.save(data),
  restriction: loadCommand.isRunningSync, // Can't save while loading
);
```

**Why not for UI?**
`isRunningSync` updates immediately when a command runs. If a button triggers a command, `isRunningSync` changes synchronously, which triggers a rebuild during the build phase and throws a Flutter exception. Use `isRunning` for UI updates - its async notifications prevent this issue.

## canRun - Combined State

Automatically combines `!isRunning && !restriction`:

```dart
final isLoggedIn = ValueNotifier<bool>(false);

final deleteCommand = Command.createAsync<String, void>(
  (id) => api.delete(id),
  restriction: isLoggedIn.map((logged) => !logged),
);

// canRun is true when:
// 1. NOT running
// 2. NOT restricted (isLoggedIn == true)
ValueListenableBuilder<bool>(
  valueListenable: deleteCommand.canRun,
  builder: (context, canRun, _) {
    return ElevatedButton(
      onPressed: canRun ? () => deleteCommand('123') : null,
      child: Text('Delete'),
    );
  },
)
```

**When to use:**
- Enable/disable buttons based on multiple conditions
- Single property instead of combining manually
- Simpler than `isRunning` + `restriction` checks

**Formula:** `canRun = !isRunning.value && !restriction.value`

## errors - Error Notifications

Stream of errors that occur during execution:

<<< @/../code_samples/lib/command_it/error_handling_basic_example.dart#example

**Behavior:**
- Emits `null` at start of execution (clears previous error)
- Emits `CommandError<TParam>` if function throws
- `CommandError` contains:
  - `error`: The thrown exception
  - `paramData`: Parameter passed to command
  - `stackTrace`: Stack trace (if enabled)

**Filtering null values:**

```dart
command.errors.where((e) => e != null).listen((error, _) {
  // Only called for actual errors, not null clears
  showErrorDialog(error!.error.toString());
});
```

**When to use:**
- Show error dialogs
- Display error messages
- Log errors to analytics
- Simple error handling without filters

## results - All Data Combined

Single property containing execution state, result, error, and parameter:

<<< @/../code_samples/lib/command_it/command_result_example.dart#example

**CommandResult properties:**

```dart
class CommandResult<TParam, TResult> {
  final TParam? paramData;             // Parameter passed to command
  final TResult? data;                 // Result value
  final bool isUndoValue;              // True if this is from an undo operation
  final Object? error;                 // Error if thrown
  final bool isRunning;                // Execution state
  final ErrorReaction? errorReaction;  // How error was handled (if error occurred)
  final StackTrace? stackTrace;        // Error stack trace (if error occurred)

  // Convenience getters
  bool get hasData => data != null;
  bool get hasError => error != null && !isUndoValue;  // Excludes undo errors
  bool get isSuccess => !isRunning && !hasError;
}
```

**When to use:**
- Single `ValueListenableBuilder` instead of multiple
- Need parameter data for error messages
- Want comprehensive state in one place
- Using `CommandBuilder` widget

**Trade-off:** More updates (updates for running, success, error) vs convenience.

## includeLastResultInCommandResults

By default, `results.data` is `null` while loading or on error. Set `includeLastResultInCommandResults: true` to keep showing last success:

```dart
Command.createAsyncNoParam<List<Todo>>(
  () => api.fetchTodos(),
  initialValue: [],
  includeLastResultInCommandResults: true, // Keep showing old data
);
```

**Behavior:**

| State | `includeLastResultInCommandResults: false` | `includeLastResultInCommandResults: true` |
|-------|-------------------------------------------|------------------------------------------|
| Initial | `data = []` | `data = []` |
| First load success | `data = [todos]` | `data = [todos]` |
| Second load (running) | `data = null` | `data = [todos]` (keeps old) |
| Second load error | `data = null` | `data = [todos]` (keeps old) |
| Second load success | `data = [new todos]` | `data = [new todos]` |

**When to use:**
- Keep displaying old data while refreshing
- Avoid empty screens during reload
- Better UX for pull-to-refresh scenarios

## errorsDynamic - Dynamic Error Type

Same as `errors` but with dynamic error type:

```dart
ValueListenable<CommandError<dynamic>?> get errorsDynamic => _errors;
```

**When to use:**
- Merging error listeners from commands with different parameter types
- Shared error handling across multiple commands

```dart
// Combine errors from different command types
final saveCommand = Command.createAsync<Data, void>(...);
final deleteCommand = Command.createAsync<String, void>(...);

// Both can share the same error handler
void handleError(CommandError<dynamic>? error, _) {
  if (error != null) showErrorDialog(error.error.toString());
}

saveCommand.errorsDynamic.listen(handleError);
deleteCommand.errorsDynamic.listen(handleError);
```

## clearErrors() - Clear Error State

Manually clears the error state and triggers listeners:

```dart
void clearErrors()
```

**Behavior:**
- Sets `errors.value` to `null`
- Explicitly calls `notifyListeners()` to update UI
- Useful when dismissing error dialogs/messages

**When to use:**
- User dismisses an error message
- Manually clearing error state before retry
- Implementing custom error handling flows

```dart
// Error handling with manual dismissal
command.errors.listen((error, _) {
  if (error != null) {
    showErrorDialog(
      error.error.toString(),
      onDismiss: () => command.clearErrors(),
    );
  }
});
```

::: tip Clearing Errors Without Notification
You can also set `command.errors.value = null` directly to clear the error WITHOUT triggering listeners. This is useful if you want to silently reset the error state.

**Why manual mode?** The `errors` notifier uses `CustomNotifierMode.manual` because commands automatically set it to `null` at the start of every execution (to clear previous errors). This shouldn't trigger listeners - only actual errors should notify.

Use `clearErrors()` when you want UI updates (e.g., dismissing error messages). Use direct assignment when you don't.
:::

**Note:** Preferred error handling is via `registerHandler` or `listen` in `initState` of a `StatefulWidget`, but `clearErrors()` is especially useful with watch_it.

## name - Debug Identifier

Returns the debug name set via `debugName` parameter:

```dart
String? get name
```

**When to use:**
- Logging and debugging
- Identifying which command triggered an error
- Available in `CommandError.commandName` and logging handlers

```dart
final saveCommand = Command.createAsync<Data, void>(
  (data) => api.save(data),
  debugName: 'SaveUserData',
);

Command.globalExceptionHandler = (error, stackTrace) {
  print('Command ${error.commandName} failed: ${error.error}');
  // Output: "Command SaveUserData failed: ..."
};
```

## Choosing the Right Property

**For simple success display:**
```dart
ValueListenableBuilder(valueListenable: command, ...)
```

**For loading states:**
```dart
ValueListenableBuilder(valueListenable: command.isRunning, ...)
```

**For button enable/disable:**
```dart
ValueListenableBuilder(valueListenable: command.canRun, ...)
```

**For error handling:**
```dart
command.errors.listen((error, _) => showError(error))
```

**For comprehensive state:**
```dart
ValueListenableBuilder(valueListenable: command.results, ...)
```

## Watching Commands with watch_it

If using watch_it, you can watch command properties without builders:

```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.loadCommand);
    final isLoading = watchValue((TodoManager m) => m.loadCommand.isRunning);
    final canRun = watchValue((TodoManager m) => m.loadCommand.canRun);

    if (isLoading) return CircularProgressIndicator();
    return TodoList(todos: todos);
  }
}
```

See [Integration with watch_it](/documentation/command_it/watch_it_integration) for details.

## See Also

- [Command Basics](/documentation/command_it/command_basics) — Creating and running commands
- [Command Results](/documentation/command_it/command_results) — Deep dive into CommandResult
- [Error Handling](/documentation/command_it/error_handling) — Handling errors
- [Command Restrictions](/documentation/command_it/restrictions) — Conditional execution
