# Command Results

Deep dive into `CommandResult` - the comprehensive state object that combines execution state, result data, errors, and parameters in a single observable property.

## Overview

`CommandResult<TParam, TResult>` is a value class containing all command execution information:

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
- Just need the data: Use command itself (`ValueListenable<TResult>`)
- Just need loading state: Use `.isRunning`
- Just need errors: Use `.errors`

## Complete Example

<<< @/../code_samples/lib/command_it/command_result_example.dart#example

**How it works:**
1. Single `ValueListenableBuilder` observes `.results`
2. Check `result.isRunning` first → show loading
3. Check `result.hasError` next → show error (with param data)
4. Check `result.hasData` → show data
5. Fallback → initial state

## Result State Transitions

### Normal Flow (Success)

```
Initial:    { data: [], error: null, isRunning: false }
            ↓ command.run('query')
Running:    { data: null, error: null, isRunning: true }
            ↓ async operation completes
Success:    { data: [results], error: null, isRunning: false }
```

**Note:** `data` becomes `null` during execution by default.

### Error Flow

```
Initial:    { data: [], error: null, isRunning: false }
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

**Modified flow:**

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
- ✅ List/feed refresh scenarios where empty states look jarring
- ✅ Search results that update incrementally
- ✅ Data that's better stale than absent
- ❌ Login/authentication where stale data is misleading
- ❌ Critical data where showing old values during errors is unsafe

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

```dart
Command.createAsync<String, List<Item>>(
  (query) => api.search(query),
  initialValue: [],
  includeLastResultInCommandResults: true, // Keep old data
);

// UI shows old results while loading new ones
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

```dart
command.results.listen((result, _) {
  if (result.hasError) {
    logger.error(
      'Command failed',
      error: result.error,
      param: result.paramData,
      hadPreviousData: result.data != null,
    );
  }
});
```

## CommandResult vs Individual Properties

### Using individual properties (multiple builders)

```dart
// Nested builders - verbose
ValueListenableBuilder<bool>(
  valueListenable: command.isRunning,
  builder: (context, isRunning, _) {
    if (isRunning) return CircularProgressIndicator();

    return ValueListenableBuilder<CommandError?>(
      valueListenable: command.errors,
      builder: (context, error, _) {
        if (error != null) return ErrorWidget(error.error);

        return ValueListenableBuilder<List<Todo>>(
          valueListenable: command,
          builder: (context, data, _) {
            return TodoList(todos: data);
          },
        );
      },
    );
  },
)
```

### Using CommandResult (single builder)

```dart
// Single builder - clean
ValueListenableBuilder<CommandResult<void, List<Todo>>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    if (result.isRunning) return CircularProgressIndicator();
    if (result.hasError) return ErrorWidget(result.error);
    return TodoList(todos: result.data ?? []);
  },
)
```

**Trade-off:**
- **More updates**: `.results` updates on running, success, error
- **Simpler code**: Single builder, all state in one place
- **Better for**: Complex UIs with multiple states

## CommandResult and CommandBuilder

`CommandBuilder` widget internally uses `CommandResult`:

```dart
CommandBuilder<String, List<Todo>>(
  command: searchCommand,
  whileRunning: (context, lastValue, _) => CircularProgressIndicator(),
  onData: (context, data, _) => TodoList(todos: data),
  onError: (context, error, lastValue, param) => ErrorView(
    error: error,
    query: param,
  ),
)
```

The widget automatically handles `CommandResult` state transitions.

## Debugging CommandResult

**Log all state changes:**

```dart
command.results.listen((result, _) {
  debugPrint('''
    CommandResult Update:
    - isRunning: ${result.isRunning}
    - hasData: ${result.hasData}
    - hasError: ${result.hasError}
    - paramData: ${result.paramData}
  ''');
});
```

**Visualize in DevTools:**

```dart
// Add to your debug widget tree
if (kDebugMode)
  ValueListenableBuilder<CommandResult>(
    valueListenable: command.results,
    builder: (context, result, _) {
      return Container(
        color: Colors.black87,
        padding: EdgeInsets.all(8),
        child: Text(
          'Running: ${result.isRunning}, '
          'Data: ${result.hasData}, '
          'Error: ${result.hasError}',
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
      );
    },
  )
```

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
