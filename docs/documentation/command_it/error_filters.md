# Error Filters

Declaratively route errors to different handlers based on error type or conditions. ErrorFilters provide fine-grained control over how commands handle exceptions.

## Overview

When a command throws an exception, an **ErrorFilter** decides what happens next:

- **Local handler**: Listeners on `.errors` or `.results`
- **Global handler**: `Command.globalExceptionHandler`
- **Rethrow**: Propagate the exception up
- **None**: Swallow silently

**Why use ErrorFilters?**
- Different error types need different handling
- Validation errors → show to user
- Network errors → retry logic
- Critical errors → log to service
- All without try/catch blocks

## Basic Error Handling

Without filters, use the `.errors` property to listen for all errors:

<<< @/../code_samples/lib/command_it/error_handling_basic_example.dart#example

**Behavior:**
- `.errors` emits `null` at start of execution (clears previous)
- `.errors` emits `CommandError<TParam>` on failure
- `CommandError` contains: `error`, `paramData`, `stackTrace`

## ErrorFilter System

Commands accept an `errorFilter` parameter to customize error routing:

```dart
Command.createAsync<String, List<Data>>(
  (query) => api.search(query),
  initialValue: [],
  errorFilter: PredicatesErrorFilter([
    // Route based on error type
  ]),
);
```

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

## PredicatesErrorFilter (Recommended)

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

## TableErrorFilter

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

## Built-in Filters

**ErrorHandlerGlobalIfNoLocal** — Default behavior:
```dart
Command.errorFilterDefault = const ErrorHandlerGlobalIfNoLocal();
// Try local handler, fallback to global
```

**ErrorHandlerLocal** — Local only:
```dart
errorFilter: const ErrorHandlerLocal()
// Only call .errors/.results listeners
```

**ErrorHandlerLocalAndGlobal** — Both handlers:
```dart
errorFilter: const ErrorHandlerLocalAndGlobal()
// Call both local and global handlers
```

## Global Error Handler

Set a global handler for unhandled errors:

```dart
void main() {
  // Configure global handler
  Command.globalExceptionHandler = (error, stackTrace) {
    // Log to service
    loggingService.logError(error, stackTrace);

    // Report to crash analytics
    crashReporter.report(error, stackTrace);
  };

  runApp(MyApp());
}
```

**When global handler is called:**
- ErrorFilter returns `ErrorReaction.globalHandler`
- ErrorFilter returns `firstLocalThenGlobalHandler` with no local listeners
- `Command.reportAllExceptions = true` (overrides filters)

## Custom ErrorFilter

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

## Global Configuration

Configure error handling behavior globally:

```dart
// Default filter for all commands
Command.errorFilterDefault = const ErrorHandlerGlobalIfNoLocal();

// Global handler
Command.globalExceptionHandler = (error, stackTrace) {
  print('Error: $error');
};

// AssertionErrors always throw (ignore filters)
Command.assertionsAlwaysThrow = true; // default

// Report ALL exceptions (override filters)
Command.reportAllExceptions = false; // default

// Capture detailed stack traces
Command.detailedStackTraces = true; // default
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

## Error Filters vs Try/Catch

**❌️️ Traditional approach:**

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

## Debugging ErrorFilters

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

## Common Mistakes

### ❌️️ Forgetting to listen to .errors

```dart
// ErrorFilter uses localHandler but nothing listens
errorFilter: const ErrorHandlerLocal()
// Error: In debug mode, assertion thrown if no listeners
```

```dart
// CORRECT: Always listen when using local handlers
command.errors.listen((error, _) { /* handle */ });
```

### ❌️️ Using defaulErrorFilter in custom filter

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

### ❌️️ Wrong order in PredicatesErrorFilter

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

## See Also

- [Error Handling](/documentation/command_it/error_handling) — Basic error handling concepts
- [Command Properties](/documentation/command_it/command_properties) — The `.errors` property
- [Command Basics](/documentation/command_it/command_basics) — Creating commands
- [Best Practices](/documentation/command_it/best_practices) — Production error handling patterns
