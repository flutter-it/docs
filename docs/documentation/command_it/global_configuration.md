# Global Configuration

Static properties that configure behavior for all commands in your app. Set these once, typically in your app's `main()` function before calling `runApp()`.

## Overview

| Property | Type | Default | Purpose |
|----------|------|---------|---------|
| [**globalExceptionHandler**](#globalexceptionhandler) | `Function?` | `null` | Global error handler for all commands |
| [**globalErrors**](#globalerrors) | `Stream` | N/A | Observable stream of all globally-routed errors |
| [**errorFilterDefault**](#errorfilterdefault) | `ErrorFilter` | `GlobalIfNoLocalErrorFilter()` | Default error filter |
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

Global error handler called for all command errors:

```dart
static void Function(CommandError<dynamic> error, StackTrace stackTrace)?
  globalExceptionHandler;
```

Set this once in your `main()` function to handle errors globally:

```dart
void main() {
  Command.globalExceptionHandler = (error, stackTrace) {
    loggingService.logError(error.error, stackTrace);
    Sentry.captureException(error.error, stackTrace: stackTrace);
  };

  runApp(MyApp());
}
```

**When it's called:**
- Depends on ErrorFilter configuration (default: when no local listeners exist)
- Always called when `reportAllExceptions: true`

**See:** [Error Handling - Global Error Handler](/documentation/command_it/error_handling#global-error-handler) for complete documentation including usage examples, error context details, and patterns.

## globalErrors

Observable stream of all command errors routed to the global handler:

```dart
static Stream<CommandError<dynamic>> get globalErrors
```

Perfect for reactive error monitoring, analytics, crash reporting, and global UI notifications:

```dart
// Example: Global error toast in root widget
class MyApp extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerStreamHandler<Stream<CommandError>, CommandError>(
      target: Command.globalErrors,
      handler: (context, snapshot, cancel) {
        if (snapshot.hasData) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${snapshot.data!.error}')),
          );
        }
      },
    );
    return MaterialApp(home: HomePage());
  }
}
```

**Key points:**
- Broadcast stream (multiple listeners supported)
- Emits when ErrorFilter routes errors to global handler
- Does NOT emit for debug-only `reportAllExceptions`
- Use with `globalExceptionHandler` for comprehensive error handling

**See:** [Error Handling - Global Errors Stream](/documentation/command_it/error_handling#global-errors-stream) for complete documentation including use cases, stream behavior, and integration patterns.

## errorFilterDefault

Default ErrorFilter used when no individual filter is specified per command:

```dart
static ErrorFilter errorFilterDefault = const GlobalIfNoLocalErrorFilter();
```

**Default:** `GlobalIfNoLocalErrorFilter()` - Smart routing that tries local handlers first, falls back to global

**See:** [Error Handling - Global Error Configuration](/documentation/command_it/error_handling#global-error-configuration) for complete details on built-in filters, custom filters, and configuration.

## assertionsAlwaysThrow

AssertionErrors bypass ErrorFilters and are always rethrown:

```dart
static bool assertionsAlwaysThrow = true;
```

**Default:** `true` (recommended) - AssertionErrors indicate programming mistakes and should crash immediately during development

**See:** [Error Handling - Global Error Configuration](/documentation/command_it/error_handling#assertionsalwaysthrow) for complete details.

## reportAllExceptions

Ensure every error calls globalExceptionHandler, regardless of ErrorFilter configuration:

```dart
static bool reportAllExceptions = false;
```

**Default:** `false`

**Common pattern:**
```dart
// In main.dart
Command.reportAllExceptions = kDebugMode;
```

**When to use:** Debugging error handling, development mode, verifying crash reporting

**See:** [Error Handling - Global Error Configuration](/documentation/command_it/error_handling#reportallexceptions) for complete details on how it works, execution flow, and avoiding duplicate calls.

## detailedStackTraces

Clean up stack traces by filtering out framework noise:

```dart
static bool detailedStackTraces = true;
```

**Default:** `true` (recommended)

**What it does:** Uses the `stack_trace` package to filter and simplify stack traces, removing Zone-related frames and framework internals

**Performance:** Minimal overhead. Only disable if profiling shows it's a bottleneck (rare)

**See:** [Error Handling - Global Error Configuration](/documentation/command_it/error_handling#detailedstacktraces) for complete details on what gets filtered and examples.

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

**What it does:** When error handlers throw, catch the exception and send it to `globalExceptionHandler` with the original error stored in `CommandError.originalError`

**Why this matters:** Error handlers can have bugs too. This prevents error handling code from crashing your app.

**See:** [Error Handling - When Error Handlers Throw Exceptions](/documentation/command_it/error_handling#when-error-handlers-throw-exceptions) and [Global Error Configuration](/documentation/command_it/error_handling#reporterrorhandlerexceptionstoglobalhandler) for complete details and examples.

## useChainCapture

**Experimental:** Preserve stack traces across async boundaries to show where commands were called:

```dart
static bool useChainCapture = false;
```

**Default:** `false`

**What it does:**

When enabled, preserves the call stack from where the command was invoked, even when the exception happens inside an async function. Without this, you often get an "async gap" - losing the stack trace context showing which code called the command.

Uses Dart's `Chain.capture()` mechanism to maintain the full stack trace across async boundaries.

**Example without useChainCapture:**
```
#0  ApiClient.fetch (api_client.dart:42)
#1  <async gap>
```

**Example with useChainCapture:**
```
#0  ApiClient.fetch (api_client.dart:42)
#1  _fetchDataCommand.run (data_manager.dart:156)
#2  DataScreen.build.<anonymous> (data_screen.dart:89)
#3  ... (full call chain preserved)
```

**Status:** Experimental feature that may change or be removed in future versions.

**Not recommended for production use** - may have performance implications.

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
- Detailed stack traces for debugging production issues
- No verbose logging (keep production lean)

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
  Sentry.captureException(commandError.error, stackTrace: stackTrace);
  // Missing valuable context!
};
```

**Solution:**
```dart
// ✅ Use full CommandError context with Sentry
Command.globalExceptionHandler = (commandError, stackTrace) {
  Sentry.captureException(
    commandError.error,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.setTag('command', commandError.command ?? 'unknown');
      scope.setContexts('command_context', {
        'parameter': commandError.paramData?.toString(),
        'error_reaction': commandError.errorReaction.toString(),
      });
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
