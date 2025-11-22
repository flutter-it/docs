# Command Results

Deep dive into `CommandResult` - the comprehensive state object that combines execution state, result data, errors, and parameters in a single observable property.

## Overview

The `.results` property is a `ValueListenable<CommandResult<TParam, TResult>>` that provides all command execution information in a single value class. This property updates on every state change of the command (running, success, error):

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

**Access via `.results` property:**

```dart
ValueListenableBuilder<CommandResult<String, List<Todo>>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    // Use result.data, result.error, result.isRunning, etc.
  },
)
```

## When to Use CommandResult

<p>Use <code>.results</code> when you need:</p>

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ All state in one place (running, data, error)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Parameter data for error messages</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Single builder instead of multiple nested builders</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Comprehensive state handling</li>
</ul>

**Use individual properties when:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">Just need the data: Use command itself (<code>ValueListenable&lt;TResult&gt;</code>)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">Just need loading state: Use `.isRunning`</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">Just need errors: Use `.errors`</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">Want to avoid rebuilds on every state change (individual properties only update for their specific state)</li>
</ul>

## Result State Transitions

### Normal Flow (Success)

```
Initial:    { data: null, error: null, isRunning: false }
            ↓ command.run('query')
Running:    { data: null, error: null, isRunning: true }
            ↓ async operation completes
Success:    { data: [results], error: null, isRunning: false }
```

**Note:** Initial `data` is `null` unless you set an `initialValue` parameter when creating the command.

### Error Flow

```
Initial:    { data: null, error: null, isRunning: false }
            ↓ command.run('query')
Running:    { data: null, error: null, isRunning: true }
            ↓ exception thrown
Error:      { data: null, error: Exception(), isRunning: false }
```

### includeLastResultInCommandResults

By default, `CommandResult.data` becomes `null` during command execution and when errors occur. Set `includeLastResultInCommandResults: true` to keep the last successful value visible in both states:

```dart
Command.createAsync<String, List<Todo>>(
  (query) => api.search(query),
  initialValue: [],
  includeLastResultInCommandResults: true, // Keep old data visible
);
```

**When this flag affects behavior:**

1. **During execution** (`isRunning: true`) - Old data remains in `result.data` instead of becoming `null`
2. **During error states** (`hasError: true`) - Old data remains in `result.data` instead of becoming `null`

**Modified flow (with `initialValue: []`):**

```
Initial:    { data: [], error: null, isRunning: false }
            ↓ command.run('query')
Running:    { data: [], error: null, isRunning: true }  ← Old data kept
            ↓ success
Success:    { data: [new results], error: null, isRunning: false }

            ↓ command.run('query2')
Running:    { data: [old results], error: null, isRunning: true }  ← Still visible
            ↓ error
Error:      { data: [old results], error: Exception(), isRunning: false }  ← Still visible
```

**Common use cases:**

- **Pull-to-refresh** - Show stale data while loading fresh data
- **Stale-while-revalidate** - Keep showing old content during updates
- **Error recovery** - Display last known good data even when errors occur
- **Optimistic UI** - Maintain UI stability during background refreshes

**When to use:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ List/feed refresh scenarios where empty states look jarring</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Search results that update incrementally</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Data that's better stale than absent</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Login/authentication where stale data is misleading</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Critical data where showing old values during errors is unsafe</li>
</ul>

## Complete Example

### With watch_it (Recommended)

<<< @/../code_samples/lib/command_it/command_result_watch_it_example.dart#example

**How it works:**
1. `watchValue` observes `.results` property
2. Widget rebuilds automatically when state changes
3. Check `result.isRunning` first → show loading
4. Check `result.hasError` next → show error (with param data)
5. Check `result.hasData` → show data
6. Fallback → initial state

### Without watch_it

<<< @/../code_samples/lib/command_it/command_result_example.dart#example

Same logic using `ValueListenableBuilder` for users who prefer not to use watch_it.

## Using .toWidget() with CommandResult

The `.toWidget()` extension method provides a declarative way to build UI from CommandResult. For complete documentation on how to use `.toWidget()`, including:

- Builder parameters and precedence rules
- Differences between `onData` and `onSuccess`
- When to use `.toWidget()` vs manual state checks
- Examples and common patterns

See **[Command Builders - toWidget() Extension Method](/documentation/command_it/command_builders#towidget-extension-method)**

## Result Properties

### data - The Result Value

```dart
if (result.hasData) {
  final items = result.data!; // Safe to unwrap
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, i) => ItemTile(items[i]),
  );
}
```

**Behavior:**
- `null` while command is running (unless `includeLastResultInCommandResults`)
- `null` on error (unless `includeLastResultInCommandResults`)
- Contains result value on success
- Always `null` for `void` result commands

**Nullability:**
- Type is `TResult?` (nullable)
- Use `hasData` to check before accessing
- Safe to unwrap after `hasData` check

### error - The Exception

```dart
if (result.hasError) {
  return ErrorWidget(
    message: result.error.toString(),
    onRetry: command.run,
  );
}
```

**Behavior:**
- `null` when no error
- Contains thrown exception on failure
- Cleared to `null` when command runs again
- Type is `Object?` (any throwable)

::: tip CommandResult.error vs Command.errors Property
**Important distinction:**
- `CommandResult.error` contains the **raw/pure error object** (type `Object?`)
- The command's `.errors` property contains `CommandError<TParam>?` which **wraps** the error with additional context (parameter data, command name, stack trace, error reaction)

When using `CommandResult`, you get direct access to the thrown error. When using the `.errors` property, you get the error wrapped with metadata.
:::

**Error types:**
```dart
if (result.hasError) {
  if (result.error is ApiException) {
    // Handle API errors
  } else if (result.error is ValidationException) {
    // Handle validation errors
  } else {
    // Generic error
  }
}
```

::: tip UI Error Handling vs Error Filters
The above pattern is recommended for **displaying different UI based on error type**. For more sophisticated error handling strategies (routing errors to different handlers, logging, rethrowing, silencing specific errors, etc.), use **[Error Filters](/documentation/command_it/error_handling)** which offer much richer possibilities for controlling error reactions.
:::

### isRunning - Execution State

```dart
if (result.isRunning) {
  return Center(
    child: Column(
      children: [
        CircularProgressIndicator(),
        Text('Loading...'),
      ],
    ),
  );
}
```

**Behavior:**
- `true` while async function executes
- `false` initially and after completion
- Updates asynchronously (via microtask) - see [Command Properties](/documentation/command_it/command_properties)

### paramData - The Input Parameter

```dart
if (result.hasError) {
  return Column(
    children: [
      Text('Error: ${result.error}'),
      if (result.paramData != null)
        Text('Failed for query: ${result.paramData}'),
      ElevatedButton(
        onPressed: () => command(result.paramData), // Retry with same param
        child: Text('Retry'),
      ),
    ],
  );
}
```

**Behavior:**
- Contains the parameter passed to command
- `null` for no-param commands
- Type is `TParam?` (nullable)
- Useful for error messages and retry logic

**Use cases:**
- Show what query failed in error message
- Retry button with same parameters
- Logging which operation failed

## Convenience Getters

### hasData

```dart
bool get hasData => data != null;

// Usage
if (result.hasData) {
  return DataView(result.data!);
}
```

**Preferred over:**
```dart
if (result.data != null) { ... }
```

### hasError

```dart
bool get hasError => error != null;

// Usage
if (result.hasError) {
  return ErrorView(result.error.toString());
}
```

**Preferred over:**
```dart
if (result.error != null) { ... }
```

### isSuccess

```dart
bool get isSuccess => !hasError && !isRunning;

// Usage
if (result.isSuccess && result.hasData) {
  return SuccessView(result.data!);
}
```

**Useful for:**
- Distinguishing successful completion from initial state
- Showing success animations/messages
- Conditional rendering after completion

## Patterns with CommandResult

### Pattern 1: Progressive States

**With watch_it:**

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((Manager m) => m.command.results);

    // 1. Loading
    if (result.isRunning) {
      return LoadingState(query: result.paramData);
    }

    // 2. Error
    if (result.hasError) {
      return ErrorState(
        error: result.error!,
        query: result.paramData,
        onRetry: () => di<Manager>().command(result.paramData),
      );
    }

    // 3. Success
    if (result.hasData) {
      return DataState(data: result.data!);
    }

    // 4. Initial (no data, no error, not running)
    return InitialState();
  }
}
```

**Without watch_it:**

```dart
ValueListenableBuilder<CommandResult<String, Data>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    // 1. Loading
    if (result.isRunning) {
      return LoadingState(query: result.paramData);
    }

    // 2. Error
    if (result.hasError) {
      return ErrorState(
        error: result.error!,
        query: result.paramData,
        onRetry: () => command(result.paramData),
      );
    }

    // 3. Success
    if (result.hasData) {
      return DataState(data: result.data!);
    }

    // 4. Initial (no data, no error, not running)
    return InitialState();
  },
)
```

### Pattern 2: Optimistic UI with Stale Data

**Setup:**

```dart
Command.createAsync<String, List<Item>>(
  (query) => api.search(query),
  initialValue: [],
  includeLastResultInCommandResults: true, // Keep old data
);
```

**With watch_it:**

```dart
class SearchWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((SearchManager m) => m.searchCommand.results);

    return Stack(
      children: [
        // Always show data (old or new)
        if (result.hasData)
          ItemList(items: result.data!),

        // Overlay loading indicator
        if (result.isRunning)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),

        // Show error banner
        if (result.hasError)
          ErrorBanner(error: result.error),
      ],
    );
  }
}
```

**Without watch_it:**

```dart
ValueListenableBuilder<CommandResult<String, List<Item>>>(
  valueListenable: searchCommand.results,
  builder: (context, result, _) {
    return Stack(
      children: [
        // Always show data (old or new)
        if (result.hasData)
          ItemList(items: result.data!),

        // Overlay loading indicator
        if (result.isRunning)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),

        // Show error banner
        if (result.hasError)
          ErrorBanner(error: result.error),
      ],
    );
  },
)
```

### Pattern 3: Retry with Original Parameters

```dart
if (result.hasError) {
  return ErrorView(
    error: result.error!,
    operation: 'Searching for "${result.paramData}"',
    onRetry: () {
      // Retry with exact same parameter
      command(result.paramData);
    },
  );
}
```

### Pattern 4: Logging with Context

Use the `.errors` property for logging - it provides richer context than `CommandResult.error`:

```dart
command.errors.listen((commandError, _) {
  if (commandError != null) {
    logger.error(
      'Command failed: ${commandError.command}',
      error: commandError.error,
      stackTrace: commandError.stackTrace,
      param: commandError.paramData,
      errorReaction: commandError.errorReaction,
    );
  }
});
```

**Why `.errors` is better for logging:**
- Includes `stackTrace` automatically captured
- Provides `command` name for identifying which command failed
- Contains `errorReaction` showing how the error was handled
- All context bundled in `CommandError<TParam>` wrapper

## CommandResult vs Individual Properties

### Using individual properties (multiple watchers)

```dart
// With watch_it - only rebuilds for properties you watch
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isRunning = watchValue((TodoManager m) => m.loadTodos.isRunning);
    final todos = watchValue((TodoManager m) => m.loadTodos);

    if (isRunning) return CircularProgressIndicator();
    return TodoList(todos: todos);
  }
}
```

**Benefits:**
- Each property only updates when its value changes
- No `if` checks needed when watching 1-2 properties
- Fewer rebuilds - only when watched properties change

### Using CommandResult (single watcher)

```dart
// Single property with if checks
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((TodoManager m) => m.loadTodos.results);

    if (result.isRunning) return CircularProgressIndicator();
    if (result.hasError) return ErrorWidget(result.error);
    return TodoList(todos: result.data ?? []);
  }
}
```

**Trade-offs:**
- **More rebuilds**: Updates on every state change (running, success, error)
- **Requires `if` checks**: Must check state properties
- **Single watcher**: All state in one place
- **Better for**: When you need 3+ properties or all state information

**Recommendation:**
- **Need only 1-2 properties** (e.g., just data + isRunning): Use individual properties
- **Need 3+ properties** or complete state: Use CommandResult

## Common Mistakes

### ❌️️ Accessing data without null check

```dart
// WRONG: data might be null
return ListView.builder(
  itemCount: result.data.length, // Crash if null!
  ...
);
```

```dart
// CORRECT: Check hasData first
if (result.hasData) {
  return ListView.builder(
    itemCount: result.data!.length,
    ...
  );
}
```

### ❌️️ Wrong state check order

```dart
// WRONG: Checks data before checking isRunning
if (result.hasData) return DataView(result.data!);
if (result.isRunning) return LoadingView();
```

```dart
// CORRECT: Check isRunning first
if (result.isRunning) return LoadingView();
if (result.hasData) return DataView(result.data!);
```

### ❌️️ Ignoring initial state

```dart
// WRONG: What if no data, no error, not running?
if (result.isRunning) return LoadingView();
if (result.hasError) return ErrorView(result.error!);
return DataView(result.data!); // Crash on initial state!
```

```dart
// CORRECT: Handle all states
if (result.isRunning) return LoadingView();
if (result.hasError) return ErrorView(result.error!);
if (result.hasData) return DataView(result.data!);
return InitialView(); // Initial state
```

## See Also

- [Command Properties](/documentation/command_it/command_properties) — All command observable properties
- [Command Basics](/documentation/command_it/command_basics) — Creating and running commands
- [Error Handling](/documentation/command_it/error_handling) — Error property usage
- [CommandBuilder Widget](/documentation/command_it/command_builders) — Widget that uses CommandResult
