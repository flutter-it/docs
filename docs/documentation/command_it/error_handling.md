# Error Handling

Stop worrying about uncaught exceptions crashing your app. `command_it` provides automatic exception handling with powerful routing capabilities - no more messy `try-catch` blocks or `Result<T, Error>` types everywhere.

**Key Features:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🛡️ <strong>Never worry about exceptions</strong> - Commands catch all errors automatically</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🎯 <strong>Powerful error routing</strong> - Route errors locally, globally, or let them throw</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🎁 <strong>Stop returning Result types</strong> - Functions return clean <code>T</code>, not <code>Result&lt;T, Error&gt;</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">📡 <strong>Reactive error handling</strong> - Observable <code>Stream</code>s and <code>ValueListenable</code> for errors</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🔧 <strong>Flexible filters</strong> - Configure per-command or global error handling strategies</li>
</ul>

From basic error listening to advanced routing patterns, command_it gives you complete control over how your app handles failures.

::: tip Don't Be Intimidated!
This documentation is comprehensive, but error handling in command_it is actually simple once you understand the core principle: **errors are just data that flows through your app**. Start with [Basic Error Handling](#basic-error-handling) below - you can listen to `.errors` just like any other property.
:::

## Basic Error Handling

If the wrapped function inside a `Command` throws an exception, the command catches it so your app won't crash. Instead, it wraps the caught error together with the parameter value in a `CommandError` object and assigns it to the command's `.errors` property.

### The .errors Property

Commands expose a `.errors` property of type `ValueListenable<CommandError?>`:

**Behavior:**
- `.errors` is reset to `null` at the start of execution (does not notify listeners)
- `.errors` is set to `CommandError<TParam>` on failure (notifies listeners)
- `CommandError` contains: `error`, `paramData`, `stackTrace`

#### Pattern 1: Display Error State with watchValue

Watch the error value to display it in your UI:

```dart
class DataWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final error = watchValue((DataManager m) => m.loadData.errors);

    if (error != null) {
      return Text(
        'Error: ${error.error}',
        style: TextStyle(color: Colors.red),
      );
    }
    return Text('No errors');
  }
}
```

#### Pattern 2: Handle Errors with registerHandler

Use `registerHandler` for side effects like showing toasts or snackbars:

```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Show snackbar with retry button when error occurs
    registerHandler(
      select: (TodoManager m) => m.loadTodos.errors,
      handler: (context, error, cancel) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.error}'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => di<TodoManager>().loadTodos(error.paramData),
              ),
            ),
          );
        }
      },
    );

    return TodoList();
  }
}
```

#### Pattern 3: Listen Directly on Command Definition

Chain `.listen()` when defining commands for logging or analytics:

```dart
class DataManager {
  late final loadData = Command.createAsyncNoParam<List<Item>>(
    () => api.fetchData(),
    [],
  )..errors.listen((error, _) {
      if (error != null) {
        debugPrint('Load failed: ${error.error}');
        analytics.logError(error.error, error.stackTrace);
      }
    });
}
```

---

These patterns are referred to as **local error handling** because they handle errors for one specific command. This gives you fine-grained control over how each command's errors are handled. For handling errors from multiple commands in one place, see [Global Error Handler](#global-error-handler) below.

::: tip Error Clearing Behavior
The `.errors` property normally never notifies with a `null` value unless you explicitly call `clearErrors()`. You normally never need to call `clearErrors()` - and if you don't, you don't need to add `if (error != null)` checks in your error handlers. See [clearErrors](/documentation/command_it/command_properties#clearerrors-clear-error-state) for details.
:::

::: tip Without `watch_it`
For StatefulWidget patterns using `.listen()` in `initState`, see [Without `watch_it`](/documentation/command_it/without_watch_it) for patterns.
:::

### Using CommandResult

You can also access errors through `.results` which combines all command state:

```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((TodoManager m) => m.loadTodos.results);

    if (result.hasError) {
      return ErrorWidget(
        error: result.error!,
        query: result.paramData,
        onRetry: () => di<TodoManager>().loadTodos(result.paramData),
      );
    }
    // ... handle other states
  }
}
```

See [Command Results](/documentation/command_it/command_results) for details.

## Global Error Handler

Set a global error handler to catch all command errors routed by [ErrorFilter](#error-filters):

```dart
static void Function(CommandError<dynamic> error, StackTrace stackTrace)?
  globalExceptionHandler;
```

### Access to Error Context

`CommandError<TParam>` provides rich context:
- `.error` - The actual exception thrown
- `.commandName` - Command name/identifier (from `debugName`)
- `.paramData` - Parameter passed to command
- `.stackTrace` - Full stack trace
- `.errorReaction` - How the error was handled

### Handling Specific Error Types

You can handle different error types centrally in your global handler. A common pattern is handling authentication errors by logging out and cleaning up scopes:

```dart
void setupGlobalExceptionHandler() {
  Command.globalExceptionHandler = (commandError, stackTrace) {
    final error = commandError.error;

    // Handle auth errors: logout and clean up
    if (error is AuthException) {
      // Logout (clears tokens, user state, etc.)
      getIt<UserManager>().logout();

      // Pop the 'loggedIn' scope to dispose logged-in services
      // See: https://flutter-it.dev/documentation/get_it/scopes
      getIt.popScope();

      // Navigate to login screen would happen via app-level observer
      // watching userManager.isLoggedIn
      return;
    }

    // Handle other errors: log to crash reporter
    crashReporter.logError(error, stackTrace);
  };
}
```

This centralizes authentication cleanup - any command that throws `AuthException` will automatically trigger logout, regardless of where it's called.

### Usage with Crash Reporting

<<< @/../code_samples/lib/command_it/global_config_error_handler_example.dart#example

When the global handler is called depends on your [ErrorFilter](#error-filters) configuration. See [Built-in Filters](#built-in-filters) for details.

## Error Filters

Error filters decide how each error should be handled: by a local handler, the global handler, both, or not at all. Instead of treating all errors the same, you can route them declaratively based on type or conditions.

### Why Use Error Filters?

Different error types need different handling:
- **Validation errors** → Show to user in UI
- **Network errors** → Retry logic or offline mode
- **Authentication errors** → Redirect to login
- **Critical errors** → Log to monitoring service
- All without scattered try/catch blocks

### Two Approaches to Error Filtering

Commands support two mutually exclusive ways to specify error filtering logic:

**Function-based approach** (`errorFilterFn`) - Direct function with compile-time type safety:

```dart
typedef ErrorFilterFn = ErrorReaction? Function(
  Object error,
  StackTrace stackTrace,
);

Command.createAsync(
  fetchData,
  [],
  errorFilterFn: (e, s) => e is NetworkException
      ? ErrorReaction.globalHandler
      : null,
  // Compile-time checked signature! ✅
);
```

**Class-based approach** (`errorFilter`) - ErrorFilter objects for complex logic:

```dart
Command.createAsync(
  fetchData,
  [],
  errorFilter: PredicatesErrorFilter([
    (e, s) => e is NetworkException ? ErrorReaction.globalHandler : null,
    (e, s) => e is ValidationException ? ErrorReaction.localHandler : null,
  ]),
);
```

command_it provides built-in filter classes (`PredicatesErrorFilter`, `TableErrorFilter`, etc.), but you can also [define your own](#custom-errorfilter) by implementing the `ErrorFilter` interface.

**Key differences:**

| Feature | `errorFilterFn` (Function) | `errorFilter` (Class) |
|---------|---------------------------|----------------------|
| Simplicity | ✅ Direct inline function | Requires object creation |
| With parameters | ❌️ Needs lambda wrapper | ✅ Can be `const` objects |
| Reusability | ❌️ Creates new closure each time | ✅ Reuse same `const` instance |
| Best for | Simple, one-off filters | Parameterized, reusable filters |

::: warning Mutually Exclusive
You cannot use both `errorFilter` and `errorFilterFn` on the same command - an assertion enforces this. Choose one approach based on your needs.
:::

### ErrorReaction Enum

An ErrorFilter returns an `ErrorReaction` to specify handling:

| Reaction | Behavior |
|----------|----------|
| **localHandler** | Call listeners on `.errors`/`.results` |
| **globalHandler** | Call `Command.globalExceptionHandler` |
| **localAndGlobalHandler** | Call both handlers |
| **firstLocalThenGlobalHandler** | Try local, fallback to global (default) |
| **throwException** | Rethrow immediately (debugging only) |
| **throwIfNoLocalHandler** | Throw if no listeners |
| **noHandlersThrowException** | Throw if no handlers present |
| **none** | Swallow silently |

### Simple Error Filters

Built-in `const` filters for common routing patterns:

| Filter | Behavior | Usage |
|--------|----------|-------|
| **ErrorFilterConstant** | Always returns same `ErrorReaction` | `const ErrorFilterConstant(ErrorReaction.none)` |
| **LocalErrorFilter** | Route to local handler only | `const LocalErrorFilter()` |
| **GlobalIfNoLocalErrorFilter** | Try local, fallback to global ([default](/documentation/command_it/global_configuration#errorfilterdefault)) | `const GlobalIfNoLocalErrorFilter()` |
| **LocalAndGlobalErrorFilter** | Route to both local and global handlers | `const LocalAndGlobalErrorFilter()` |

**Example:**
```dart
// Silent failure for background sync
late final backgroundSync = Command.createAsyncNoParam<void>(
  () => api.syncInBackground(),
  errorFilter: const ErrorFilterConstant(ErrorReaction.none),
);

// Debug: throw on error to catch in debugger
late final debugCommand = Command.createAsync<Data, void>(
  (data) => api.saveCritical(data),
  errorFilter: const ErrorFilterConstant(ErrorReaction.throwException),
);
```

::: tip Understanding GlobalIfNoLocalErrorFilter (The Default)
**Why this is the default:** The `GlobalIfNoLocalErrorFilter` provides smart routing that adapts to your code. It returns `firstLocalThenGlobalHandler`, which works like this:

**How it works:**
1. **Checks if local listeners exist** - Are you handling `.errors` or `.results` for this command (listen, watchValue, registerHandler)?
2. **If YES** → Routes to local handler only (assumes you're handling it)
3. **If NO** → Falls back to global handler (prevents silent failures)

**Why this matters:**
```dart
// Example 1: Has local error handler
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Local listener exists
    final error = watchValue((TodoManager m) => m.loadTodos.errors);
    // ✅ Errors route to LOCAL handler only
    if (error != null) return ErrorWidget(error);
    return TodoList();
  }
}

// Example 2: No local error handler
class DataManager {
  late final loadData = Command.createAsyncNoParam<List<Item>>(
    () => api.fetchData(),
    [],
  );
  // ❌ No .errors/.results listeners
  // ✅ Errors route to GLOBAL handler automatically
}
```

This prevents the common mistake of forgetting to handle errors - they'll at least reach your global crash reporter. If you add a local handler later, the global handler automatically stops being called for that command.

See the [exception handling flowchart](#exception-handling-workflow) for the complete decision flow.
:::

### Custom ErrorFilter

Build your own ErrorFilters for advanced routing:

```dart
// Handle 4xx client errors locally, let 5xx go to global handler
late final fetchUserCommand = Command.createAsync<String, User>(
  (userId) => api.fetchUser(userId),
  initialValue: User.empty(),
  errorFilter: _ApiErrorFilter([400, 401, 403, 404, 422]),
);

class _ApiErrorFilter implements ErrorFilter {
  final List<int> statusCodes;

  const _ApiErrorFilter(this.statusCodes);

  @override
  ErrorReaction filter(Object error, StackTrace stackTrace) {
    if (error is ApiException && statusCodes.contains(error.statusCode)) {
      return ErrorReaction.localHandler;
    }
    return ErrorReaction.defaulErrorFilter;
  }
}
```

## More Error Filters

:::details PredicatesErrorFilter (Recommended)

Chain predicates to match errors by type hierarchy:

<<< @/../code_samples/lib/command_it/error_filter_predicates_example.dart#example

**How it works:**
1. Predicates are functions: `(error, stackTrace) => ErrorReaction?`
2. Returns first non-null reaction
3. Falls back to default if none match
4. Order matters - check specific types first

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

**Prefer this** for most cases - it's more flexible than TableErrorFilter.
:::

:::details TableErrorFilter

Map error types to reactions using exact type equality:

```dart
errorFilter: TableErrorFilter({
  ApiException: ErrorReaction.localHandler,
  ValidationException: ErrorReaction.localHandler,
  NetworkException: ErrorReaction.globalHandler,
  Exception: ErrorReaction.globalHandler,
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
:::

## Error Behavior with runAsync()

When using `runAsync()` and the command throws an exception, **both** things happen:

1. **Error handlers are called** - `.errors` listeners and `globalExceptionHandler` receive the error (based on ErrorFilter)
2. **The Future completes with error** - The exception is rethrown to the caller

**Important:** You MUST wrap `runAsync()` in try/catch to prevent app crashes:

```dart
// ✅ GOOD: Catch the rethrown exception
try {
  final result = await loadCommand.runAsync();
  // Use result...
} catch (e) {
  // Handle the error - show UI feedback, log, etc.
  showErrorToast(e.toString());
}

// ❌ BAD: Unhandled exception will crash the app
await loadCommand.runAsync(); // If this throws, app crashes!
```

**Using both try/catch and .errors listener:**

If you have an `.errors` listener for reactive UI updates, you still need try/catch but the catch block can be empty:

```dart
// Set up error listener for reactive UI
loadCommand.errors.listen((error, _) {
  if (error != null) showErrorToast(error.error);
});

// Still need try/catch to prevent crash
try {
  final result = await loadCommand.runAsync();
  // Use result...
} catch (e) {
  // Error already handled by .errors listener above
  // Empty catch just prevents the crash
}
```

::: warning ErrorReaction.none Not Allowed
Using `ErrorReaction.none` with `runAsync()` will trigger an assertion error. Since the error would be swallowed, there's no value to complete the Future with.
:::

## When Error Handlers Throw Exceptions

Error handlers are regular Dart code - they can fail too. When your error handler makes async API calls or processes data, those operations can throw exceptions.

### The Problem

Error handlers that perform side effects can fail in many scenarios:

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">⚠️ <strong>Async operations</strong> - Logging to remote services that might timeout</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">⚠️ <strong>Data processing</strong> - Parsing or formatting errors</li>
</ul>

Without proper handling, these secondary exceptions could crash your app or go unnoticed.

### reportErrorHandlerExceptionsToGlobalHandler

Control whether exceptions thrown inside error handlers are reported to the global handler:

<<< @/../code_samples/lib/command_it/error_handler_exception_example.dart#example

**Configuration:**
```dart
// In main() or app initialization (this is the default)
Command.reportErrorHandlerExceptionsToGlobalHandler = true;
```

See [Global Configuration - reportErrorHandlerExceptionsToGlobalHandler](/documentation/command_it/global_configuration#reporterrorhandlerexceptionstoglobalhandler) for details.

### How It Works

**With `true` (default, recommended)**:

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Exceptions in error handlers are automatically caught</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Sent to <code>Command.globalExceptionHandler</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Original command error preserved in <code>CommandError.originalError</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Your app doesn't crash from buggy error handling code</li>
</ul>

**With `false`**:

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Only logged by Flutter error logger</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Won't reach your global exception handler</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Less visibility into error handler bugs</li>
</ul>

::: tip How This Works
The `.errors` property is a `CustomValueNotifier` from **listen_it**, which provides the built-in ability to catch exceptions thrown by listeners. You can use this same feature in your own code with `CustomValueNotifier` - see [listen_it CustomValueNotifier](/documentation/listen_it/listen_it#customvaluenotifier) for details.
:::

::: tip Production Recommendation
Always keep `reportErrorHandlerExceptionsToGlobalHandler: true` in production. Error handler failures indicate bugs in your error handling code that need immediate attention.
:::

## Global Errors Stream

Static `Stream` on the `Command` class for all command errors routed to the global handler:

```dart
static Stream<CommandError<dynamic>> get globalErrors
```

### Overview

A broadcast stream that emits `CommandError<dynamic>` for every error that would trigger `globalExceptionHandler`. Perfect for centralized error monitoring, analytics, crash reporting, and global UI notifications.

### Stream Behavior

**Emits when:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅️ <code>ErrorFilter</code> routes error to global handler (based on filter configuration)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅️ Error handler itself throws an exception (if <code>reportErrorHandlerExceptionsToGlobalHandler</code> is <code>true</code>)</li>
</ul>

**Does NOT emit when:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ <code>reportAllExceptions</code> is used (debug-only feature, not for production UI)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Error is handled purely locally (<code>LocalErrorFilter</code> with local listeners)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Error filter returns <code>ErrorReaction.none</code> or <code>ErrorReaction.throwException</code></li>
</ul>

### Use Cases

**1. Global Error Toasts (`watch_it` integration)**

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

Use stream transformers to filter and route specific error types:

```dart
void setupErrorMonitoring() {
  // Track only network errors for retry analytics
  Command.globalErrors
      .where((error) => error.error is NetworkException)
      .listen((error) {
    analytics.logEvent('network_error', parameters: {
      'command': error.commandName ?? 'unknown',
      'error_code': (error.error as NetworkException).statusCode,
    });
  });

  // Log critical errors to crash reporter
  Command.globalErrors
      .where((error) => error.error is CriticalException)
      .listen((error) {
    crashReporter.logCritical(
      error.error,
      stackTrace: error.stackTrace,
      command: error.commandName,
    );
  });

  // General error metrics (all errors)
  Command.globalErrors.listen((error) {
    metrics.incrementCounter('command_errors_total');
    metrics.recordErrorType(error.error.runtimeType.toString());
  });
}
```

### Key Characteristics

- **Broadcast stream**: Multiple listeners supported
- **Cannot be closed**: Stream is managed by command_it, not user code
- **Production-focused**: Debug-only errors from `reportAllExceptions` are excluded
- **No null events emitted**: Unlike `ValueListenable<CommandError?>`, stream only emits actual errors

### Relationship with globalExceptionHandler

Both receive the same errors, but serve different purposes:

| Feature | `globalExceptionHandler` | `globalErrors` |
|---------|-------------------------|----------------|
| Type | Callback function | Stream |
| Purpose | Immediate error handling | Reactive error monitoring |
| Multiple handlers | No (single handler) | Yes (multiple listeners) |
| `watch_it` integration | No | Yes (`registerStreamHandler`, `watchStream`) |
| Best for | Crash reporting, logging | UI notifications, analytics |

::: tip Typical Pattern: Use Both Together
Use `globalExceptionHandler` for immediate side effects like crash reporting and logging, while `globalErrors` stream is perfect for reactive UI updates using `watch_it` (`registerStreamHandler` or `watchStream`). This separation keeps your error handling clean and focused.
:::

## Exception Handling Workflow

The overall exception handling flow:

![Exception Handling Workflow](/images/exception_handling_simple.svg)

For the complete technical flow with all decision points, see the [full exception handling diagram](/images/exception_handling_full.svg).

**Key points:**
1. **Mandatory checks**: AssertionErrors and debug flags can bypass filtering
2. **ErrorFilter**: Determines routing (local, global, throw, none)
3. **Local handlers**: Listeners on `.errors`/`.results` are called if configured
4. **Global handler**: Called based on ErrorReaction (emits to stream + calls callback)
5. **Handler exceptions**: If error handler throws, can be routed to global handler with `originalError`

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

  // Auth errors: global handler (centralized logout & scope cleanup)
  (error, _) => errorFilter<AuthException>(
        error,
        ErrorReaction.globalHandler,
      ),

  // Other: both handlers
  (error, _) => ErrorReaction.localAndGlobalHandler,
])
```

### Pattern 3: Per-Command Configuration

```dart
class DataManager {
  // Critical command: always report to global handler
  late final saveCriticalData = Command.createAsync<Data, void>(
    (data) => api.saveCritical(data),
    errorFilter: const ErrorFilterConstant(ErrorReaction.globalHandler),
  );

  // Background sync: silent failure (don't bother user)
  late final backgroundSync = Command.createAsyncNoParam<void>(
    () => api.syncInBackground(),
    errorFilter: const ErrorFilterConstant(ErrorReaction.none),
  );

  // Normal commands: use default (local then global)
  late final fetchData = Command.createAsyncNoParam<List<Data>>(
    () => api.fetch(),
    initialValue: [],
    // No errorFilter = uses Command.errorFilterDefault
  );
}
```

## Optimistic Updates with Auto-Rollback

`UndoableCommand` provides automatic rollback on failure, perfect for optimistic UI updates. When an operation fails, the command automatically restores the previous state - no manual error recovery needed.

For complete details on implementing optimistic updates, automatic rollback, and manual undo/redo patterns, see [Optimistic Updates](/documentation/command_it/optimistic_updates).

## Global Error Configuration

Configure error handling behavior globally in your `main()` function:

```dart
void main() {
  // Default filter for all commands
  Command.errorFilterDefault = const GlobalIfNoLocalErrorFilter();

  // Global handler
  Command.globalExceptionHandler = (error, stackTrace) {
    loggingService.logError(error, stackTrace);
  };

  // AssertionErrors always throw (ignore filters)
  Command.assertionsAlwaysThrow = true; // default

  // Report ALL exceptions (override filters)
  Command.reportAllExceptions = false; // default

  // Report error handler exceptions to global handler
  Command.reportErrorHandlerExceptionsToGlobalHandler = true; // default

  // Capture detailed stack traces
  Command.detailedStackTraces = true; // default

  runApp(MyApp());
}
```

### errorFilterDefault

Default ErrorFilter used when no per-command filter is specified:

```dart
static ErrorFilter errorFilterDefault = const GlobalIfNoLocalErrorFilter();
```

**Default:** `GlobalIfNoLocalErrorFilter()` - Smart routing that tries local handlers first, falls back to global

Use any of the [predefined filters](#simple-error-filters) or [define your own](#custom-errorfilter).

### assertionsAlwaysThrow

AssertionErrors bypass all ErrorFilters and are always rethrown:

```dart
static bool assertionsAlwaysThrow = true; // default
```

**Default:** `true` (recommended)

**Why this exists:** AssertionErrors indicate programming mistakes (like `assert(condition)` failures). They should crash immediately during development to catch bugs, not be swallowed by error filters.

**Recommendation:** Keep this `true` to catch bugs early in development.

### reportAllExceptions

Ensure every error calls `globalExceptionHandler`, regardless of ErrorFilter configuration:

```dart
static bool reportAllExceptions = false; // default
```

**Default:** `false`

**How it works:** When `true`, **every error** calls `globalExceptionHandler` immediately, **in addition to** normal ErrorFilter processing. ErrorFilters still run and control local handlers.

**Common pattern - Debug vs Production:**
```dart
// In main.dart
Command.reportAllExceptions = kDebugMode;
```

**What this does:**
- Development: ALL errors reach global handler for visibility
- Production: Only errors routed by ErrorFilter reach global handler

**When to use:**
- Debugging error handling - ensure no errors are silently swallowed
- Development mode - see all errors regardless of ErrorFilter
- Verifying crash reporting - confirm all errors reach analytics

::: warning Potential Duplicate Calls
```dart
Command.reportAllExceptions = true;
Command.errorFilterDefault = const GlobalErrorFilter();

// Result: globalExceptionHandler called TWICE for each error!
// 1. From reportAllExceptions
// 2. From ErrorFilter
```
In production, use either `reportAllExceptions` OR ErrorFilters that call global, not both.
:::

### reportErrorHandlerExceptionsToGlobalHandler

Report exceptions thrown by error handlers to `globalExceptionHandler`:

```dart
static bool reportErrorHandlerExceptionsToGlobalHandler = true; // default
```

**Default:** `true` (recommended) - Error handlers can have bugs too; this prevents error handling code from crashing your app

See [When Error Handlers Throw Exceptions](#when-error-handlers-throw-exceptions) for complete details, examples, and how it works.

### detailedStackTraces

Clean up stack traces by filtering out framework noise:

```dart
static bool detailedStackTraces = true; // default
```

**Default:** `true` (recommended)

**What it does:** Uses the `stack_trace` package to filter and simplify stack traces.

**Without detailedStackTraces** - raw stack trace with 50+ lines of framework internals

**With detailedStackTraces** - filtered and simplified, showing only relevant frames

**What gets filtered:**
- Zone-related frames (async framework)
- `stack_trace` package internals
- `command_it` internal `_run` method frames

**Performance:** Stack trace processing has minimal overhead. Only disable if profiling shows it's a bottleneck (rare).

::: tip See Also
For non-error-related global configuration (like `loggingHandler`, `useChainCapture`), see [Global Configuration](/documentation/command_it/global_configuration).
:::

## Error Filters vs Try/Catch

**❌️ Traditional approach:**

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

### Find Missing Error Handlers During Development

Set the default error filter to throw while manually testing your app to catch unhandled errors immediately:

```dart
void main() {
  // During development, make unhandled errors crash the app
  if (kDebugMode) {
    Command.errorFilterDefault = const ErrorFilterConstant(
      ErrorReaction.throwException,
    );
  }

  runApp(MyApp());
}
```

**What this does:**
- Any command error without a local `.errors` or `.results` listener will throw
- App crashes immediately, showing you exactly which command lacks error handling
- Forces you to add error handling before you can test that feature
- Only active in debug mode - production uses normal error routing

**Example:**
```dart
// Without error handling - app will crash when this fails
final loadData = Command.createAsyncNoParam<Data>(
  () => api.fetch(),
  initialValue: Data.empty(),
);

// ✅ Add error handling to prevent crash:
final loadData = Command.createAsyncNoParam<Data>(
  () => api.fetch(),
  initialValue: Data.empty(),
)..errors.listen((error, _) {
    if (error != null) {
      showErrorDialog(error.error.toString());
    }
  });
```

**Why this helps:**
- Catches missing error handlers as soon as you trigger that code path
- Prevents shipping features without error handling
- Makes error handling a requirement, not an afterthought
- Remove `if (kDebugMode)` check once all commands have handlers

::: tip
This is a strict development mode. Once you've verified all commands have proper error handling, switch back to the default `GlobalIfNoLocalErrorFilter()` which provides better fallback behavior.
:::

## Common Mistakes

### ❌️ Forgetting to listen to .errors

```dart
// ErrorFilter uses localHandler but nothing listens
errorFilter: const LocalErrorFilter()
// Error: In debug mode, assertion thrown if no listeners
```

### ❌️ Wrong order in PredicatesErrorFilter

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

### ❌️ Not handling cleared errors

::: tip Only Necessary If Using clearErrors()
This is only an issue if you explicitly call [clearErrors()](/documentation/command_it/command_properties#clearerrors-clear-error-state). By default, `.errors` [never notifies with null](#error-clearing-behavior), so you don't need null checks.
:::

```dart
// If you use clearErrors(), handle null:
command.errors.listen((error, _) {
  if (error != null) {
    showErrorDialog(error.error.toString());
  }
});
```

## See Also

- [Command Properties](/documentation/command_it/command_properties) — The `.errors` property
- [Command Results](/documentation/command_it/command_results) — Using errors with CommandResult
- [Command Basics](/documentation/command_it/command_basics) — Creating commands
- [Command Types](/documentation/command_it/command_types) — Error filter parameters
- [Best Practices](/documentation/command_it/best_practices) — Production error handling patterns
