# Error Handling

Learn how `command_it` handles exceptions - from basic error listening to advanced error routing with filters. Commands catch exceptions automatically, providing multiple ways to handle them based on your needs.

## Basic Error Handling

If the wrapped function inside a `Command` throws an exception, the command catches it so your app won't crash. Instead, it wraps the caught error together with the parameter value in a `CommandError` object and assigns it to the command's `.errors` property.

### The .errors Property

Commands expose a `.errors` property of type `ValueListenable<CommandError?>`:

<<< @/../code_samples/lib/command_it/error_handling_basic_example.dart#example

**Behavior:**
- `.errors` emits `null` at the start of execution (clears previous errors)
- `.errors` emits `CommandError<TParam>` on failure
- `CommandError` contains: `error`, `paramData`, `stackTrace`

**Note:** It's not possible to reset a `ValueNotifier` without triggering listeners. If you've registered a listener, it will be called at every command execution start with `null` to clear previous errors. Using `listen_it`'s `where` extension makes this easy to filter out.

### Using CommandResult

You can also access errors through `.results` which combines all command state:

```dart
ValueListenableBuilder<CommandResult<String, List<Todo>>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    if (result.hasError) {
      return ErrorWidget(
        error: result.error!,
        query: result.paramData,
        onRetry: () => command(result.paramData),
      );
    }
    // ... handle other states
  },
)
```

See [Command Results](/documentation/command_it/command_results) for details.

## Global Error Handler

Global error handler called for all command errors (based on ErrorFilter configuration):

```dart
static void Function(CommandError<dynamic> error, StackTrace stackTrace)?
  globalExceptionHandler;
```

### Usage with Crash Reporting

<<< @/../code_samples/lib/command_it/global_config_error_handler_example.dart#example

### When It's Called

Depends on ErrorFilter configuration:
- Default (`GlobalIfNoLocalErrorFilter`): Called when no local error handler is present
- With `LocalErrorFilter`: Never called
- With `GlobalErrorFilter`: Always called
- When `reportAllExceptions: true`: Always called (bypasses filters)

### Access to Error Context

`CommandError<TParam>` provides rich context:
- `.error` - The actual exception thrown
- `.command` - Command name/identifier
- `.paramData` - Parameter passed to command
- `.stackTrace` - Full stack trace
- `.errorReaction` - How the error was handled

## Global Errors Stream

Observable stream of all command errors routed to the global handler:

```dart
static Stream<CommandError<dynamic>> get globalErrors
```

### Overview

A broadcast stream that emits `CommandError<dynamic>` for every error that would trigger `globalExceptionHandler`. Perfect for centralized error monitoring, analytics, crash reporting, and global UI notifications.

### Stream Behavior

**Emits when:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <code>ErrorFilter</code> routes error to global handler (based on filter configuration)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Error handler itself throws an exception (if <code>reportErrorHandlerExceptionsToGlobalHandler</code> is <code>true</code>)</li>
</ul>

**Does NOT emit when:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ <code>reportAllExceptions</code> is used (debug-only feature, not for production UI)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Error is handled purely locally (<code>LocalErrorFilter</code> with local listeners)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Error filter returns <code>ErrorReaction.none</code> or <code>ErrorReaction.throwException</code></li>
</ul>

### Use Cases

**1. Global Error Toasts (watch_it integration)**

```dart
class MyApp extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerStreamHandler<Stream<CommandError>, CommandError>(
      target: Command.globalErrors,
      handler: (context, snapshot, cancel) {
        if (snapshot.hasData) {
          final error = snapshot.data!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error.error}')),
          );
        }
      },
    );
    return MaterialApp(home: HomePage());
  }
}
```

**2. Centralized Logging and Analytics**

```dart
void setupErrorMonitoring() {
  Command.globalErrors.listen((error) {
    // Send to analytics
    analytics.logEvent('command_error', parameters: {
      'command': error.commandName ?? 'unknown',
      'error_type': error.error.runtimeType.toString(),
      'has_param': error.paramData != null,
    });

    // Log to console in development
    if (kDebugMode) {
      debugPrint('Command error: ${error.commandName} - ${error.error}');
    }
  });
}
```

**3. Sentry Integration**

```dart
void setupSentryIntegration() {
  Command.globalErrors.listen((error) {
    Sentry.captureException(
      error.error,
      stackTrace: error.stackTrace,
      withScope: (scope) {
        scope.setTag('command', error.commandName ?? 'unknown');
        scope.setContexts('command_context', {
          'parameter': error.paramData?.toString(),
          'error_reaction': error.errorReaction.toString(),
        });
      },
    );
  });
}
```

### Key Characteristics

- **Broadcast stream**: Multiple listeners supported
- **Cannot be closed**: Stream is managed by command_it, not user code
- **Production-focused**: Debug-only errors from `reportAllExceptions` are excluded
- **No null resets**: Unlike `ValueListenable<CommandError?>`, stream only emits actual errors

### Relationship with globalExceptionHandler

Both receive the same errors, but serve different purposes:

| Feature | `globalExceptionHandler` | `globalErrors` |
|---------|-------------------------|----------------|
| Type | Callback function | Stream |
| Purpose | Immediate error handling | Reactive error monitoring |
| Multiple handlers | No (single handler) | Yes (multiple listeners) |
| watch_it integration | No | Yes (`registerStreamHandler`) |
| Best for | Crash reporting, logging | UI notifications, analytics |

**Typical pattern: Use both together**
```dart
// Handler for Sentry
Command.globalExceptionHandler = (error, stackTrace) {
  Sentry.captureException(error.error, stackTrace: stackTrace);
};

// Stream for UI notifications
Command.globalErrors.listen((error) {
  showErrorToast(error.error.toString());
});
```

## Catch Always Mechanism

Control when exceptions are caught vs rethrown:

```dart
Command.createAsync<String, Data>(
  (query) => api.search(query),
  initialValue: Data.empty(),
  catchAlways: false, // Only catch if listeners exist
);
```

**catchAlways parameter:**
- `true` - Always catch exceptions, even with no listeners
- `false` - Only catch if there are listeners on `.errors` or `.results`
- `null` (default) - Use `Command.catchAlwaysDefault`

**Global default:**
```dart
// In main() or app initialization
Command.catchAlwaysDefault = false; // Development: find unhandled errors
Command.catchAlwaysDefault = true;  // Production: prevent crashes
```

**Recommendation:**
- Development: Set to `false` to find unhandled exceptions early
- Production: Set to `true` to prevent hard crashes

## Exception Handling Workflow

The overall exception handling flow:

![Exception Handling Workflow](https://github.com/escamoteur/command_it/blob/master/misc/exception_handling.png)

**Key points:**
1. Command catches exception during execution
2. ErrorFilter determines routing (local, global, throw, none)
3. Listeners on `.errors`/`.results` are called if local handler selected
4. Global handler is called if no local listeners and fallback enabled
5. Exception is rethrown if ErrorReaction specifies it

## Error Filters

Error filters provide fine-grained control over how different error types are handled. Instead of treating all errors the same, you can route them declaratively based on type or conditions.

### Why Use Error Filters?

Different error types need different handling:
- **Validation errors** → Show to user in UI
- **Network errors** → Retry logic or offline mode
- **Authentication errors** → Redirect to login
- **Critical errors** → Log to monitoring service
- All without scattered try/catch blocks

### ErrorReaction Enum

ErrorFilter returns an `ErrorReaction` to specify handling:

| Reaction | Behavior |
|----------|----------|
| **localHandler** | Call listeners on `.errors`/`.results` |
| **globalHandler** | Call `Command.globalExceptionHandler` |
| **localAndGlobalHandler** | Call both handlers |
| **firstLocalThenGlobalHandler** | Try local, fallback to global (default) |
| **throwException** | Rethrow immediately |
| **throwIfNoLocalHandler** | Throw if no listeners |
| **noHandlersThrowException** | Throw if no handlers present |
| **none** | Swallow silently |

### PredicatesErrorFilter (Recommended)

Chain predicates to match errors by type hierarchy:

<<< @/../code_samples/lib/command_it/error_filter_predicates_example.dart#example

**How it works:**
1. Predicates are functions: `(error, stackTrace) => ErrorReaction?`
2. Returns first non-null reaction
3. Falls back to default if none match
4. Order matters - check specific types first

**Using the errorFilter helper:**

<<< @/../code_samples/lib/command_it/error_filter_simple_example.dart#example

**Pattern:**
```dart
PredicatesErrorFilter([
  (error, stackTrace) => errorFilter<ApiException>(
        error,
        ErrorReaction.localHandler,
      ),
  (error, stackTrace) => errorFilter<ValidationException>(
        error,
        ErrorReaction.localHandler,
      ),
  (error, stackTrace) => ErrorReaction.globalHandler, // Default
])
```

### TableErrorFilter

Map error types to reactions using exact type equality:

```dart
errorFilter: TableErrorFilter({
  ApiException: ErrorReaction.localHandler,
  ValidationException: ErrorReaction.localHandler,
  NetworkException: ErrorReaction.globalHandler,
  Exception: ErrorReaction.throwException,
})
```

**Limitations:**
- Only matches exact runtime type (not type hierarchy)
- Can't distinguish subclasses
- Special workaround for `Exception` type

**When to use:**
- Simple error routing by type
- Known set of error types
- No inheritance hierarchies

**Prefer PredicatesErrorFilter** for most cases - it's more flexible.

### Built-in Filters

**GlobalIfNoLocalErrorFilter** — Default behavior:
```dart
Command.errorFilterDefault = const GlobalIfNoLocalErrorFilter();
// Try local handler, fallback to global
```

**LocalErrorFilter** — Local only:
```dart
errorFilter: const LocalErrorFilter()
// Only call .errors/.results listeners
```

**LocalAndGlobalErrorFilter** — Both handlers:
```dart
errorFilter: const LocalAndGlobalErrorFilter()
// Call both local and global handlers
```

### Custom ErrorFilter

Implement `ErrorFilter` interface for advanced routing:

```dart
class RetryableErrorFilter implements ErrorFilter {
  final int maxRetries;
  final Map<Object, int> _retryCounts = {};

  RetryableErrorFilter(this.maxRetries);

  @override
  ErrorReaction filter(Object error, StackTrace stackTrace) {
    if (error is NetworkException) {
      final count = _retryCounts[error] ?? 0;

      if (count < maxRetries) {
        _retryCounts[error] = count + 1;
        return ErrorReaction.none; // Swallow, command will retry
      }

      return ErrorReaction.localHandler; // Max retries, show error
    }

    return ErrorReaction.defaulErrorFilter; // Use default
  }
}

// Usage
late final fetchCommand = Command.createAsyncNoParam<Data>(
  () => api.fetch(),
  initialValue: Data.empty(),
  errorFilter: RetryableErrorFilter(3),
);
```

## Error Routing Patterns

### Pattern 1: User vs System Errors

```dart
errorFilter: PredicatesErrorFilter([
  // User-facing errors: show in UI
  (error, _) => errorFilter<ValidationException>(
        error,
        ErrorReaction.localHandler,
      ),
  (error, _) => errorFilter<AuthException>(
        error,
        ErrorReaction.localHandler,
      ),

  // System errors: log and report
  (error, _) => ErrorReaction.globalHandler,
])
```

### Pattern 2: Retry-able vs Fatal

```dart
errorFilter: PredicatesErrorFilter([
  // Network timeouts: local handler with retry UI
  (error, _) {
    if (error is ApiException && error.statusCode == 408) {
      return ErrorReaction.localHandler;
    }
    return null;
  },

  // Auth errors: throw (require re-login)
  (error, _) => errorFilter<AuthException>(
        error,
        ErrorReaction.throwException,
      ),

  // Other: both handlers
  (error, _) => ErrorReaction.localAndGlobalHandler,
])
```

### Pattern 3: Per-Command vs Global

```dart
class DataManager {
  // Critical command: throw on error
  late final saveCriticalData = Command.createAsync<Data, void>(
    (data) => api.saveCritical(data),
    errorFilter: const ErrorFilerConstant(ErrorReaction.throwException),
  );

  // Background sync: silent failure
  late final backgroundSync = Command.createAsyncNoParam<void>(
    () => api.syncInBackground(),
    errorFilter: const ErrorFilerConstant(ErrorReaction.none),
  );

  // Normal commands: use default (local then global)
  late final fetchData = Command.createAsyncNoParam<List<Data>>(
    () => api.fetch(),
    initialValue: [],
    // No errorFilter = uses Command.errorFilterDefault
  );
}
```

## Auto-Undo on Failure

For operations that modify state optimistically, `UndoableCommand` can automatically rollback changes when an error occurs. This is perfect for implementing optimistic updates with automatic error recovery.

```dart
class TodoService {
  final todos = ValueNotifier<List<Todo>>([]);

  late final deleteTodoCommand = Command.createUndoableNoResult<String, List<Todo>>(
    (id, previousTodos) async {
      // Make optimistic update
      todos.value = todos.value.where((t) => t.id != id).toList();

      // Try to delete on server
      await api.deleteTodo(id);
      // If this throws an exception, the undo handler is called automatically
    },
    undo: (id) {
      // Capture state snapshot before execution
      return todos.value;
    },
    undoOnExecutionFailure: true, // Automatically rollback on error
  );
}
```

**How it works:**

1. **Before execution**: The `undo` handler is called to capture the current state
2. **During execution**: Your function runs (e.g., optimistic UI update + API call)
3. **On success**: State snapshot is pushed to the undo stack
4. **On failure** (when `undoOnExecutionFailure: true`):
   - The command automatically calls the undo handler
   - State is restored to the pre-execution snapshot
   - Error is still propagated to error handlers

**Benefits:**

- ✅ Automatic rollback on errors - no manual try/catch needed
- ✅ Clean separation: business logic in command, error recovery is automatic
- ✅ Consistent error recovery across your app
- ✅ Also enables manual undo/redo for user actions

**When to use:**

- Optimistic updates (delete items, toggle states, edit data)
- Multi-step operations where partial failure needs full rollback
- Any operation where you want automatic "if this fails, undo what I just did"

See [Command Types - Undoable Commands](/documentation/command_it/command_types#undoable-commands) for all factory methods and [Best Practices - Undoable Commands](/documentation/command_it/best_practices#pattern-5-undoable-commands-with-automatic-rollback) for more patterns.

## Global Configuration

Configure error handling behavior globally:

```dart
void main() {
  // Default filter for all commands
  Command.errorFilterDefault = const GlobalIfNoLocalErrorFilter();

  // Global handler
  Command.globalExceptionHandler = (error, stackTrace) {
    loggingService.logError(error, stackTrace);
  };

  // Catch behavior default
  Command.catchAlwaysDefault = true;

  // AssertionErrors always throw (ignore filters)
  Command.assertionsAlwaysThrow = true; // default

  // Report ALL exceptions (override filters)
  Command.reportAllExceptions = false; // default

  // Capture detailed stack traces
  Command.detailedStackTraces = true; // default

  runApp(MyApp());
}
```

**Configuration properties:**

- **`errorFilterDefault`** - Default ErrorFilter for all commands (default: `GlobalIfNoLocalErrorFilter`)
- **`globalExceptionHandler`** - Handler called for unhandled errors
- **`catchAlwaysDefault`** - Default catch behavior (default: implementation-specific)
- **`assertionsAlwaysThrow`** - AssertionErrors bypass filters (default: `true`)
- **`reportAllExceptions`** - Force all errors to global handler (default: `false`)
- **`detailedStackTraces`** - Capture full stack traces (default: `true`)

## Error Filters vs Try/Catch

**❌ Traditional approach:**

```dart
Future<void> loadData() async {
  try {
    final data = await api.fetch();
    // Handle success
  } on ValidationException catch (e) {
    // Show to user
  } on ApiException catch (e) {
    // Log to service
  } catch (e) {
    // Generic handler
  }
}
```

**✅ With ErrorFilters:**

```dart
late final loadCommand = Command.createAsyncNoParam<List<Data>>(
  () => api.fetch(),
  initialValue: [],
  errorFilter: PredicatesErrorFilter([
    (e, _) => errorFilter<ValidationException>(e, ErrorReaction.localHandler),
    (e, _) => errorFilter<ApiException>(e, ErrorReaction.globalHandler),
    (e, _) => ErrorReaction.localAndGlobalHandler,
  ]),
);

// Errors automatically routed
loadCommand.errors.listen((error, _) {
  if (error != null) showErrorDialog(error.error.toString());
});
```

**Benefits:**
- Declarative error routing
- Centralized handling logic
- Automatic UI updates via ValueListenable
- No scattered try/catch blocks
- Testable error routing

## Debugging Error Handling

**Enable detailed stack traces:**
```dart
Command.detailedStackTraces = true;
```

**Log all error routing decisions:**
```dart
Command.globalExceptionHandler = (error, stackTrace) {
  debugPrint('Global handler: $error');
  debugPrint('Stack: $stackTrace');
};

// In your predicates
PredicatesErrorFilter([
  (error, stackTrace) {
    debugPrint('Checking error: ${error.runtimeType}');
    return errorFilter<ApiException>(error, ErrorReaction.localHandler);
  },
])
```

**Test error scenarios:**
```dart
// Force errors in development
final command = Command.createAsyncNoParam<Data>(
  () async {
    if (kDebugMode) {
      throw ApiException('Test error');
    }
    return await api.fetch();
  },
  initialValue: Data.empty(),
  errorFilter: yourFilter,
);
```

**Log all command errors:**
```dart
command.errors.listen((error, _) {
  if (error != null) {
    debugPrint('''
      Command Error:
      - Error: ${error.error}
      - Type: ${error.error.runtimeType}
      - Param: ${error.paramData}
      - Stack: ${error.stackTrace}
    ''');
  }
});
```

## Common Mistakes

### ❌ Forgetting to listen to .errors

```dart
// ErrorFilter uses localHandler but nothing listens
errorFilter: const LocalErrorFilter()
// Error: In debug mode, assertion thrown if no listeners
```

```dart
// CORRECT: Always listen when using local handlers
command.errors.listen((error, _) { /* handle */ });
```

### ❌ Using defaulErrorFilter in custom filter

```dart
@override
ErrorReaction filter(Object error, StackTrace stackTrace) {
  // WRONG: Custom filters can't return this
  return ErrorReaction.defaulErrorFilter;
}
```

```dart
// CORRECT: Return null in predicates to fall through
(error, stackTrace) {
  if (someCondition) return ErrorReaction.localHandler;
  return null; // Let next predicate handle
}
```

### ❌ Wrong order in PredicatesErrorFilter

```dart
// WRONG: General Exception before specific types
PredicatesErrorFilter([
  (e, _) => errorFilter<Exception>(e, ErrorReaction.globalHandler),
  (e, _) => errorFilter<ApiException>(e, ErrorReaction.localHandler), // Never reached!
])
```

```dart
// CORRECT: Specific types first
PredicatesErrorFilter([
  (e, _) => errorFilter<ApiException>(e, ErrorReaction.localHandler),
  (e, _) => errorFilter<Exception>(e, ErrorReaction.globalHandler),
])
```

### ❌ Not handling cleared errors

```dart
// WRONG: Doesn't handle null (error cleared)
command.errors.listen((error, _) {
  showErrorDialog(error.error.toString()); // Crash when null!
});
```

```dart
// CORRECT: Filter out null or check explicitly
command.errors.where((x) => x != null).listen((error, _) {
  showErrorDialog(error.error.toString());
});
```

## See Also

- [Command Properties](/documentation/command_it/command_properties) — The `.errors` property
- [Command Results](/documentation/command_it/command_results) — Using errors with CommandResult
- [Command Basics](/documentation/command_it/command_basics) — Creating commands
- [Command Types](/documentation/command_it/command_types) — Error filter parameters
- [Best Practices](/documentation/command_it/best_practices) — Production error handling patterns
