# Global Configuration

Static properties that configure behavior for all commands in your app. Set these once, typically in your app initialization.

## Overview

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

## globalExceptionHandler

Global error handler called for all command errors (based on ErrorFilter):

```dart
static void Function(CommandError<dynamic> error, StackTrace stackTrace)?
  globalExceptionHandler;
```

**Usage:**

```dart
void main() {
  Command.globalExceptionHandler = (error, stackTrace) {
    // Log to analytics, crash reporting, etc.
    print('Command ${error.commandName} failed: ${error.error}');
    logToAnalytics(error);
  };

  runApp(MyApp());
}
```

**When called:** Depends on ErrorFilter configuration. Default behavior calls it when no local handler is present.

## errorFilterDefault

Default ErrorFilter used when no individual filter is specified:

```dart
static ErrorFilter errorFilterDefault = const ErrorHandlerGlobalIfNoLocal();
```

**Usage:**

```dart
// Change default behavior for all commands
Command.errorFilterDefault = const ErrorHandlerLocal();
```

**Default:** `ErrorHandlerGlobalIfNoLocal()` - tries local handlers first, falls back to global.

See [Error Handling](/documentation/command_it/error_handling) for ErrorFilter details.

## assertionsAlwaysThrow

AssertionErrors bypass ErrorFilters and are always rethrown:

```dart
static bool assertionsAlwaysThrow = true;
```

**Default:** `true` (recommended for catching assertions during development)

**Usage:**

```dart
// Treat assertions like any other error
Command.assertionsAlwaysThrow = false;
```

**Why:** AssertionErrors indicate programming mistakes and should be caught early in development.

## reportAllExceptions

Override all ErrorFilters and report every error to globalExceptionHandler:

```dart
static bool reportAllExceptions = false;
```

**Default:** `false`

**Usage:**

```dart
// Debug mode: report everything
Command.reportAllExceptions = kDebugMode;
```

**Use case:** Debugging error handling - ensures all errors are visible regardless of filters.

## detailedStackTraces

Enhance stack traces by removing framework noise and adding command names:

```dart
static bool detailedStackTraces = true;
```

**Default:** `true`

**Behavior:**
- Strips internal framework calls
- Adds command name to stack trace
- Makes debugging easier

**Performance:** If stack trace processing impacts performance, set to `false`.

## loggingHandler

Handler called on every command execution (if command has a `debugName`):

```dart
static void Function(String? commandName, CommandResult<dynamic, dynamic> result)?
  loggingHandler;
```

**Usage:**

```dart
Command.loggingHandler = (commandName, result) {
  if (result.hasError) {
    print('❌ $commandName failed');
  } else {
    print('✅ $commandName completed');
  }
};
```

**Note:** Only called for commands with `debugName` parameter set.

## reportErrorHandlerExceptionsToGlobalHandler

If a local error handler throws, report to globalExceptionHandler:

```dart
static bool reportErrorHandlerExceptionsToGlobalHandler = true;
```

**Default:** `true`

**Behavior:** Original error is stored in `CommandError.originalError`.

**Use case:** Catch errors in your error handlers (error handler bugs).

## useChainCapture

**Experimental:** Enhanced stack trace capture:

```dart
static bool useChainCapture = false;
```

**Default:** `false` (experimental feature)

**Warning:** Experimental feature, may change or be removed.

## See Also

- [Command Properties](/documentation/command_it/command_properties) — Instance properties reference
- [Error Handling](/documentation/command_it/error_handling) — Error handling patterns
- [Command Basics](/documentation/command_it/command_basics) — Creating and running commands
