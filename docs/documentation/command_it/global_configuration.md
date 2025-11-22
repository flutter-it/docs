# Global Configuration

Static properties that configure behavior for all commands in your app. Set these once, typically in your app's `main()` function before calling `runApp()`.

## Overview

| Property | Type | Default | Purpose |
|----------|------|---------|---------|
| [**globalExceptionHandler**](#globalexceptionhandler) | `Function?` | `null` | Global error handler for all commands |
| [**globalErrors**](#globalerrors) | `Stream` | N/A | Observable stream of all globally-routed errors |
| [**errorFilterDefault**](#errorfilterdefault) | `ErrorFilter` | `GlobalErrorFilter()` | Default error filter |
| [**assertionsAlwaysThrow**](#assertionsalwaysthrow) | `bool` | `true` | AssertionErrors bypass filters |
| [**reportAllExceptions**](#reportallexceptions) | `bool` | `false` | Override filters, report all errors |
| [**detailedStackTraces**](#detailedstacktraces) | `bool` | `true` | Enhanced stack traces |
| [**loggingHandler**](#logginghandler) | `Function?` | `null` | Handler for all command executions |
| [**reportErrorHandlerExceptionsToGlobalHandler**](#reporterrorhandlerexceptionstoglobalhandler) | `bool` | `true` | Report error handler exceptions |
| [**useChainCapture**](#usechaincapture) | `bool` | `false` | Experimental detailed traces |

## Complete Setup Example

Here's a typical setup configuring multiple global properties:

<<< @/../code_samples/lib/command_it/global_config_main_example.dart#example

## globalExceptionHandler

Global error handler called for all command errors (based on ErrorFilter configuration):

```dart
static void Function(CommandError<dynamic> error, StackTrace stackTrace)?
  globalExceptionHandler;
```

### Usage with Crash Reporting

<<< @/../code_samples/lib/command_it/global_config_error_handler_example.dart#example

### When It's Called

Depends on ErrorFilter configuration:
- Default (`GlobalErrorFilter`): Called when no local error handler is present
- With `LocalErrorFilter`: Never called
- With `ErrorHandlerGlobal`: Always called
- When `reportAllExceptions: true`: Always called (bypasses filters)

### Access to Error Context

`CommandError<TParam>` provides rich context:
- `.error` - The actual exception thrown
- `.command` - Command name/identifier
- `.paramData` - Parameter passed to command
- `.stackTrace` - Full stack trace
- `.errorReaction` - How the error was handled

## globalErrors

Observable stream of all command errors routed to the global handler:

```dart
static Stream<CommandError<dynamic>> get globalErrors
```

### Overview

A broadcast stream that emits `CommandError<dynamic>` for every error that would trigger `globalExceptionHandler`. Perfect for centralized error monitoring, analytics, crash reporting, and global UI notifications.

### Stream Behavior

**Emits when:**
- ✅ `ErrorFilter` routes error to global handler (based on filter configuration)
- ✅ Error handler itself throws an exception (if `reportErrorHandlerExceptionsToGlobalHandler` is `true`)

**Does NOT emit when:**
- ❌ `reportAllExceptions` is used (debug-only feature, not for production UI)
- ❌ Error is handled purely locally (`LocalErrorFilter` with local listeners)
- ❌ Error filter returns `ErrorReaction.none` or `ErrorReaction.throwException`

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

**3. Crash Reporting Integration**

```dart
void setupCrashReporting() {
  Command.globalErrors.listen((error) {
    crashReporting.recordError(
      error.error,
      error.stackTrace,
      context: {
        'command': error.commandName ?? 'unknown',
        'parameter': error.paramData?.toString(),
        'error_reaction': error.errorReaction.toString(),
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
// Handler for crash reporting
Command.globalExceptionHandler = (error, stackTrace) {
  crashReporting.recordError(error.error, stackTrace);
};

// Stream for UI notifications
Command.globalErrors.listen((error) {
  showErrorToast(error.error.toString());
});
```

## errorFilterDefault

Default ErrorFilter used when no individual filter is specified per command:

```dart
static ErrorFilter errorFilterDefault = const GlobalErrorFilter();
```

### Built-in Error Filters

- `GlobalErrorFilter()` (default) - Try local handlers first, fallback to global
- `LocalErrorFilter()` - Only call local handlers (`.errors` or `.results` listeners)
- `ErrorHandlerGlobal()` - Only call global exception handler
- `LocalAndGlobalErrorFilter()` - Call both local and global handlers

### Example

```dart
// Change default behavior for all commands
Command.errorFilterDefault = const LocalErrorFilter();
```

**See:** [Error Handling](/documentation/command_it/error_handling) for complete ErrorFilter documentation and custom filters.

## assertionsAlwaysThrow

AssertionErrors bypass ErrorFilters and are always rethrown:

```dart
static bool assertionsAlwaysThrow = true;
```

**Default:** `true` (recommended)

### Why This Exists

AssertionErrors indicate programming mistakes (like `assert(condition)` failures). They should be caught immediately during development, not silently swallowed by error filters.

### Example

```dart
// Treat assertions like any other error (not recommended)
Command.assertionsAlwaysThrow = false;
```

**Recommendation:** Keep this `true` to catch bugs early in development.

## reportAllExceptions

Ensure every error calls globalExceptionHandler for debugging:

```dart
static bool reportAllExceptions = false;
```

**Default:** `false`

### How It Works

When `true`, **every error** calls `globalExceptionHandler` immediately, **in addition to** normal ErrorFilter processing.

**Execution flow:**
1. Error occurs in command
2. `globalExceptionHandler` is called (if `reportAllExceptions: true`)
3. ErrorFilter runs normally (determines local/global handling)
4. `globalExceptionHandler` **may be called again** (if ErrorFilter says to)

**Result:** ErrorFilters are **NOT bypassed** - they still control local handlers and can trigger a second global handler call.

### Common Pattern: Debug vs Production

```dart
// In main.dart
Command.reportAllExceptions = kDebugMode;
```

**What this does:**
- Development (`kDebugMode = true`): ALL errors reach global handler for visibility
- Production (`kDebugMode = false`): Only errors routed by ErrorFilter reach global handler

### When to Use

- **Debugging error handling** - Ensure no errors are silently swallowed
- **Development mode** - See all errors regardless of ErrorFilter configuration
- **Verifying crash reporting** - Confirm all errors reach your analytics/crash reporting

### Important: Potential Duplicate Calls

```dart
Command.reportAllExceptions = true;
Command.errorFilterDefault = const ErrorHandlerGlobal(); // Also calls global handler

// Result: globalExceptionHandler called TWICE for each error!
// 1. From reportAllExceptions
// 2. From ErrorFilter
```

**Solution:** In production, use either `reportAllExceptions` OR ErrorFilters that call global, not both

## detailedStackTraces

Clean up stack traces by filtering out framework noise:

```dart
static bool detailedStackTraces = true;
```

**Default:** `true` (recommended)

### What It Does

Uses the `stack_trace` package to filter and simplify stack traces.

**Without detailedStackTraces** (`false`) - raw stack trace:
```
#0      Object._throw (dart:core-patch/object_patch.dart:51)
#1      _Future._propagateToListeners (dart:async/future_impl.dart)
#2      _Future._completeError (dart:async/future_impl.dart)
#3      Zone.run (dart:async/zone.dart:1518)
#4      _rootRun (dart:async/zone.dart:1426)
... [50+ lines of framework internals]
#42     my_file.dart:42  ← Your actual code buried deep
```

**With detailedStackTraces** (`true`) - filtered and simplified:
```
#0      my_file.dart:42
#1      manager.dart:156
#2      widget.dart:89
... [Only relevant frames, framework noise removed]
```

**What gets filtered:**
- `stack_trace` package internal frames
- Zone-related frames (async framework)
- `_rootRun` and similar async framework calls
- `command_it` internal `_run` method frames

The result is also "tersed" - duplicate/redundant frames are removed.

### Performance

Stack trace processing has minimal overhead. Only disable if profiling shows it's a bottleneck (rare).

## loggingHandler

Handler called for every command execution (running, success, error):

```dart
static void Function(CommandResult<dynamic, dynamic> result)? loggingHandler;
```

**Default:** `null` (no logging)

### Analytics Integration Example

<<< @/../code_samples/lib/command_it/global_config_logging_example.dart#example

### What Data Is Available

`CommandResult<TParam, TResult>` provides:
- `.isRunning` - Whether command is currently executing
- `.hasData` - Whether command has result data
- `.hasError` - Whether command failed
- `.error` - The error object (if any)
- `.data` - The result data (if any)
- `.paramData` - Parameter passed to command

### Use Cases

- **Analytics** - Track command execution metrics
- **Performance monitoring** - Measure command execution time
- **Debugging** - Log all command activity
- **Audit trails** - Record user actions

## reportErrorHandlerExceptionsToGlobalHandler

If a local error handler throws an exception, report it to globalExceptionHandler:

```dart
static bool reportErrorHandlerExceptionsToGlobalHandler = true;
```

**Default:** `true` (recommended)

### What This Catches

```dart
command.errors.listen((error, _) {
  // Local error handler
  throw Exception('Oops, error handler has a bug!'); // ← This gets caught
});
```

**With `reportErrorHandlerExceptionsToGlobalHandler: true`:**
- Exception thrown in error handler is caught
- Sent to `globalExceptionHandler`
- Original error is stored in `CommandError.originalError`

### Why This Matters

Error handlers can have bugs too. This prevents error handling code from crashing your app.

## useChainCapture

**Experimental:** Enhanced async stack trace capture:

```dart
static bool useChainCapture = false;
```

**Default:** `false`

**Status:** Experimental feature that may change or be removed in future versions.

**Not recommended for production use.**

## Common Configuration Patterns

### Development Mode

For maximum visibility during development:

<<< @/../code_samples/lib/command_it/global_config_development.dart#example

**Characteristics:**
- Report ALL errors (bypass filters)
- Verbose logging for every command
- Detailed stack traces
- Comprehensive error context

### Production Mode

For production with crash reporting integration:

<<< @/../code_samples/lib/command_it/global_config_production.dart#example

**Characteristics:**
- Respect error filters (don't report everything)
- Send errors to crash reporting service
- Minimal logging (only metrics)
- Detailed stack traces for debugging production issues

### Testing Mode

For unit/integration tests:

```dart
void setupTestMode() {
  // Disable all handlers to avoid side effects in tests
  Command.globalExceptionHandler = null;
  Command.loggingHandler = null;

  // Let errors throw naturally for test assertions
  Command.reportAllExceptions = false;
  Command.errorFilterDefault = const ErrorHandlerNone();
}
```

## Property Interactions

### reportAllExceptions Overrides Error Filters

When `reportAllExceptions: true`:
```dart
Command.reportAllExceptions = true;
Command.errorFilterDefault = const LocalErrorFilter(); // ← Ignored!
```

Every error still goes to `globalExceptionHandler`, regardless of filter configuration.

### assertionsAlwaysThrow Bypasses Everything

```dart
Command.assertionsAlwaysThrow = true; // Default
Command.errorFilterDefault = const ErrorHandlerNone(); // ← Ignored for assertions!
```

AssertionErrors are always rethrown, even if filters would swallow them.

### Error Handler Exception Reporting

```dart
Command.reportErrorHandlerExceptionsToGlobalHandler = true;
Command.globalExceptionHandler = (error, stackTrace) {
  // Receives both:
  // 1. Normal command errors
  // 2. Exceptions thrown by local error handlers

  if (error.originalError != null) {
    // This error came from a buggy error handler
    print('Error handler threw: ${error.error}');
    print('Original error was: ${error.originalError}');
  }
};
```

## Common Mistakes

### ❌️ Setting Global Handler After Creating Commands

```dart
// WRONG: Commands created before handler is set
final command = Command.createAsync(fetchData, []);

Command.globalExceptionHandler = (error, stackTrace) {
  print('This works for future commands, but...');
};
```

**Problem:** Global handlers should be set in `main()` before creating any commands.

**Solution:**
```dart
void main() {
  // ✅ Set global configuration FIRST
  Command.globalExceptionHandler = (error, stackTrace) { ... };
  Command.errorFilterDefault = const GlobalErrorFilter();

  runApp(MyApp()); // Now create commands
}
```

### ❌️ Forgetting kDebugMode for reportAllExceptions

```dart
// WRONG: Always report all exceptions, even in production
Command.reportAllExceptions = true;
```

**Problem:** Production app sends every error to crash reporting, creating noise.

**Solution:**
```dart
// ✅ Only in debug mode
Command.reportAllExceptions = kDebugMode;
```

### ❌️ Not Accessing CommandError Properties

```dart
// WRONG: Only using the error object
Command.globalExceptionHandler = (commandError, stackTrace) {
  crashReporting.recordError(commandError.error, stackTrace);
  // Missing valuable context!
};
```

**Solution:**
```dart
// ✅ Use full CommandError context
Command.globalExceptionHandler = (commandError, stackTrace) {
  crashReporting.recordError(
    commandError.error,
    stackTrace,
    context: {
      'command': commandError.command,
      'parameter': commandError.paramData?.toString(),
      'error_reaction': commandError.errorReaction.toString(),
    },
  );
};
```

### ❌️ Using loggingHandler for Error Handling

```dart
// WRONG: Trying to handle errors in logging handler
Command.loggingHandler = (result) {
  if (result.hasError) {
    showErrorDialog(result.error); // Don't do this!
  }
};
```

**Problem:** `loggingHandler` is for observability, not error handling.

**Solution:**
```dart
// ✅ Use globalExceptionHandler for error handling
Command.globalExceptionHandler = (error, stackTrace) {
  // Handle errors here
};

// ✅ Use loggingHandler only for metrics/analytics
Command.loggingHandler = (result) {
  analytics.logEvent('command_executed', parameters: {
    'has_error': result.hasError,
  });
};
```

### ❌️ Disabling detailedStackTraces Prematurely

```dart
// WRONG: Disabling without measuring
Command.detailedStackTraces = false; // "For performance"
```

**Problem:** Stack trace processing has negligible overhead. Disabling makes debugging harder.

**Solution:**
```dart
// ✅ Only disable if profiling shows it's a bottleneck
Command.detailedStackTraces = true; // Keep the default
```

## See Also

- **[Error Handling](/documentation/command_it/error_handling)** — Learn how `errorFilterDefault` and `globalExceptionHandler` work with error filters, including custom filter creation
- **[Command Properties](/documentation/command_it/command_properties)** — Instance-level properties that can override global defaults (like per-command error filters)
- **[Command Basics](/documentation/command_it/command_basics)** — Start here if you're new to command_it - learn how to create and run commands before configuring globals
- **[Troubleshooting](/documentation/command_it/troubleshooting)** — Common issues and solutions, including configuration problems
