# Command Properties

Commands expose multiple `ValueListenable` properties for different aspects of execution. Learn when and how to use each one.

## Overview

### Instance Properties

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

### Global Configuration

Static properties that affect all commands in the app:

| Property | Type | Default | Purpose |
|----------|------|---------|---------|
| [**globalExceptionHandler**](#globalexceptionhandler) | `Function?` | `null` | Global error handler for all commands |
| [**errorFilterDefault**](#errorfilterdefault) | `ErrorFilter` | `ErrorHandlerGlobalIfNoLocal()` | Default error filter |
| [**assertionsAlwaysThrow**](#assertionsalwaysthrow) | `bool` | `true` | AssertionErrors bypass filters |
| [**reportAllExceptions**](#reportallexceptions) | `bool` | `false` | Override filters, report all errors |
| [**detailedStackTraces**](#detailedstacktraces) | `bool` | `true` | Enhanced stack traces |
| [**loggingHandler**](#logginghandler) | `Function?` | `null` | Handler for all command executions |
| [**reportErrorHandlerExceptionsToGlobalHandler**](#reporterrorhandlerexceptionstoglobalhandler) | `bool` | `true` | Report error handler exceptions |
| [**useChainCapture**](#usechaincapture) | `bool` | `false` | Experimental detailed traces |

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

Notifies when errors occur during execution:

**Behavior:**
- Is set to `null` at start of execution (clears previous error without notification)
- Notifies with `CommandError<TParam>` if function throws
- `CommandError` contains:
  - `error`: The thrown exception
  - `paramData`: Parameter passed to command
  - `stackTrace`: Stack trace (enhanced if `Command.detailedStackTraces` is true)

**When to use:**
- Show error dialogs
- Display error messages
- Log errors to analytics
- Simple error handling without filters

**With watch_it:**

```dart
class SaveWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final error = watchValue((DataManager m) => m.saveCommand.errors);

    // Display error message if present
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => di<DataManager>().saveCommand(data),
          child: Text('Save'),
        ),
        if (error != null)
          ErrorBanner(
            message: error.error.toString(),
            onDismiss: () => di<DataManager>().saveCommand.clearErrors(),
          ),
      ],
    );
  }
}
```

**Without watch_it:** See [Using Commands without watch_it - Error Handling](/documentation/command_it/without_watch_it#error-handling)

## results - All Data Combined

Combines execution state, result data, errors, and parameters in a single observable:

```dart
ValueListenableBuilder<CommandResult<TParam, TResult>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    if (result.isRunning) return CircularProgressIndicator();
    if (result.hasError) return ErrorWidget(result.error);
    return DataWidget(result.data);
  },
)
```

**When to use:**
- Single `ValueListenableBuilder` instead of multiple nested builders
- Need comprehensive state (running, data, error) in one place
- Want parameter data for error messages or retry logic

**See [Command Results](/documentation/command_it/command_results) for complete CommandResult structure, examples, and the `includeLastResultInCommandResults` parameter.**

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

// Merge errors into single stream using listen_it
[saveCommand.errorsDynamic, deleteCommand.errorsDynamic]
  .merge()
  .where((error) => error != null)
  .listen((error, _) {
    showErrorDialog(error!.error.toString());
  });
```

## clearErrors() - Clear Error State

Manually clears the error state and triggers listeners:

```dart
void clearErrors()
```

**Behavior:**
- Sets `errors.value` to `null`
- Explicitly calls `notifyListeners()` to update UI

**When to use:**
- You're watching errors in UI and want to hide error display without waiting for next execution
- Implementing custom error recovery flows

```dart
// Example: Dismissible error banner
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final error = watchValue((Manager m) => m.command.errors);

    return Column(
      children: [
        if (error != null)
          ErrorBanner(
            error: error.error.toString(),
            onDismiss: () => di<Manager>().command.clearErrors(),
          ),
        // ... rest of UI
      ],
    );
  }
}
```

::: tip Using listen/registerHandler - No Clear Needed
If you use `.listen()` or `registerHandler()` to watch errors, they only get called when a new error appears (not when cleared to null). In this case, you typically don't need `clearErrors()` at all:

**With `.listen()`:**
```dart
command.errors.listen((error, _) {
  showSnackBar(error!.error.toString()); // Shows once per error, never null
});
```

**With `registerHandler()` (watch_it):**
```dart
registerHandler((Manager m) => m.command.errors, (context, error, cancel) {
  showSnackBar(error!.error.toString()); // Shows once per error, never null
});
```

Since listeners only fire on actual errors (never null), each error is shown once and you don't need to manually clear.

**Important:** If you DO call `clearErrors()` elsewhere in your code, handlers will receive `null` when the error is cleared. In that case, add a null check:

```dart
command.errors.listen((error, _) {
  if (error != null) {
    showSnackBar(error.error.toString());
  }
});
```

**Use `clearErrors()` when:**
- Watching errors with `watchValue` - rebuilds on every change, needs manual clear to hide UI
- Conditionally showing error widgets based on error state
:::

::: tip Clearing Errors Without Notification
You can also set `command.errors.value = null` directly to clear the error WITHOUT triggering listeners. This is useful if you want to silently reset the error state.

**Why manual mode?** The `errors` notifier uses `CustomNotifierMode.manual` because commands automatically set it to `null` at the start of every execution (to clear previous errors). This shouldn't trigger listeners - only actual errors should notify.

Use `clearErrors()` when you want UI updates (e.g., dismissing error messages). Use direct assignment when you don't.
:::

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

## See Also

- [Command Basics](/documentation/command_it/command_basics) — Creating and running commands
- [Command Results](/documentation/command_it/command_results) — Deep dive into CommandResult
- [Global Configuration](/documentation/command_it/global_configuration) — Static properties reference
- [Error Handling](/documentation/command_it/error_handling) — Handling errors
- [Command Restrictions](/documentation/command_it/restrictions) — Conditional execution
