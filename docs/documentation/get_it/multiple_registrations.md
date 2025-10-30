---
title: Multiple Registrations
---

# Multiple Registrations

get_it allows you to register multiple implementations of the same type and retrieve them all at once. This is particularly useful for plugin systems, event handlers, middleware chains, and modular architectures.

## Enabling Multiple Registrations

By default, get_it **prevents** registering the same type multiple times (without different instance names) to catch accidental duplicate registrations, which are usually bugs.

To enable multiple registrations of the same type, you must explicitly opt-in:

```dart
getIt.enableRegisteringMultipleInstancesOfOneType();
```

**Why explicit opt-in?**
- **Prevents bugs**: Accidentally registering the same type twice is usually an error
- **Breaking change protection**: Existing code won't break from unintended behavior changes
- **Clear intent**: Makes it obvious that you're using the multiple registration pattern
- **Type safety**: Forces you to be aware that `get<T>()` behavior changes

::: warning Important
Once enabled, this setting applies **globally** to the entire get_it instance. You cannot enable it for only specific types.

**This feature cannot be disabled once enabled.** Even calling `getIt.reset()` will clear all registrations but keep this feature enabled. This is intentional to prevent accidental breaking changes in your application.
:::

---

## Registering Multiple Implementations

After calling `enableRegisteringMultipleInstancesOfOneType()`, you can register the same type multiple times:

```dart
// First unnamed registration
getIt.registerSingleton<Plugin>(CorePlugin());

// Second unnamed registration (now allowed!)
getIt.registerSingleton<Plugin>(LoggingPlugin());

// Named registrations (always allowed - even without enabling)
getIt.registerSingleton<Plugin>(FeaturePlugin(), instanceName: 'feature');
```

::: tip Unnamed + Named Together
All registrations coexist - both unnamed and named. `getAll<T>()` returns all of them.
:::

---

## Retrieving Instances

### Using `get<T>()` - Returns First Only

When multiple unnamed registrations exist, `get<T>()` returns **only the first** registered instance:

```dart
getIt.enableRegisteringMultipleInstancesOfOneType();

getIt.registerSingleton<Plugin>(CorePlugin());
getIt.registerSingleton<Plugin>(LoggingPlugin());
getIt.registerSingleton<Plugin>(AnalyticsPlugin());

final plugin = getIt<Plugin>();
// Returns: CorePlugin (the first one only!)
```

::: tip When to use get()
Use `get<T>()` when you want the "default" or "primary" implementation. Register it first!
:::

### Using `getAll<T>()` - Returns All

To retrieve **all** registered instances (both unnamed and named), use `getAll<T>()`:

```dart
getIt.enableRegisteringMultipleInstancesOfOneType();

getIt.registerSingleton<Plugin>(CorePlugin());        // unnamed
getIt.registerSingleton<Plugin>(LoggingPlugin());     // unnamed
getIt.registerSingleton<Plugin>(AnalyticsPlugin(), instanceName: 'analytics'); // named

final Iterable<Plugin> allPlugins = getIt.getAll<Plugin>();
// Returns: [CorePlugin, LoggingPlugin, AnalyticsPlugin]
//          ALL unnamed + ALL named registrations
```

---

## Scope Behavior

By default, `getAll<T>()` only searches the **current scope**. To retrieve from **all scopes**, use `fromAllScopes: true`:

```dart
getIt.enableRegisteringMultipleInstancesOfOneType();

// Base scope
getIt.registerSingleton<Plugin>(CorePlugin());
getIt.registerSingleton<Plugin>(LoggingPlugin());

// Push new scope
getIt.pushNewScope(scopeName: 'feature');
getIt.registerSingleton<Plugin>(FeatureAPlugin());
getIt.registerSingleton<Plugin>(FeatureBPlugin());

// Current scope only
final featurePlugins = getIt.getAll<Plugin>();
// Returns: [FeatureAPlugin, FeatureBPlugin]

// All scopes
final allPlugins = getIt.getAll<Plugin>(fromAllScopes: true);
// Returns: [FeatureAPlugin, FeatureBPlugin, CorePlugin, LoggingPlugin]
```

See [Scopes documentation](/documentation/get_it/scopes) for more details on scope behavior.

---

## Async Version

If you have async registrations, use `getAllAsync<T>()` which waits for all registrations to complete:

```dart
getIt.enableRegisteringMultipleInstancesOfOneType();

getIt.registerSingletonAsync<Plugin>(() async => await CorePlugin.create());
getIt.registerSingletonAsync<Plugin>(() async => await LoggingPlugin.create());

// Wait for all plugins to be ready
await getIt.allReady();

// Retrieve all async instances
final Iterable<Plugin> plugins = await getIt.getAllAsync<Plugin>();
```

**With scopes:**
```dart
final Iterable<Plugin> allPlugins = await getIt.getAllAsync<Plugin>(
  fromAllScopes: true,
);
```

---

## Common Patterns

### Plugin System

```dart
// Enable multiple registrations at app startup
void configureDependencies() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Core plugins (unnamed - always loaded)
  getIt.registerSingleton<AppPlugin>(CorePlugin());
  getIt.registerSingleton<AppPlugin>(LoggingPlugin());
  getIt.registerSingleton<AppPlugin>(AnalyticsPlugin());
}

// Feature module registers additional plugins
void enableShoppingFeature() {
  getIt.pushNewScope(scopeName: 'shopping');
  getIt.registerSingleton<AppPlugin>(ShoppingCartPlugin());
  getIt.registerSingleton<AppPlugin>(PaymentPlugin());
}

// App initialization
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize all plugins
    final allPlugins = getIt.getAll<AppPlugin>(fromAllScopes: true);
    for (final plugin in allPlugins) {
      plugin.initialize();
    }

    return MaterialApp(...);
  }
}
```

### Event Handlers / Observers

```dart
abstract class AppLifecycleObserver {
  void onAppStarted();
  void onAppPaused();
  void onAppResumed();
}

void setupApp() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Multiple observers can register
  getIt.registerSingleton<AppLifecycleObserver>(AnalyticsObserver());
  getIt.registerSingleton<AppLifecycleObserver>(LoggingObserver());
  getIt.registerSingleton<AppLifecycleObserver>(CacheObserver());
}

class AppLifecycleManager {
  void notifyAppStarted() {
    final observers = getIt.getAll<AppLifecycleObserver>();
    for (final observer in observers) {
      observer.onAppStarted();
    }
  }

  void notifyAppPaused() {
    final observers = getIt.getAll<AppLifecycleObserver>();
    for (final observer in observers) {
      observer.onAppPaused();
    }
  }
}
```

### Middleware / Validator Chains

```dart
abstract class RequestMiddleware {
  Future<bool> handle(Request request);
}

void setupMiddleware() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Order matters! First registered = first executed
  getIt.registerSingleton<RequestMiddleware>(AuthMiddleware());
  getIt.registerSingleton<RequestMiddleware>(RateLimitMiddleware());
  getIt.registerSingleton<RequestMiddleware>(LoggingMiddleware());
}

class ApiClient {
  Future<Response> send(Request request) async {
    // Execute all middleware in registration order
    final middlewares = getIt.getAll<RequestMiddleware>();
    for (final middleware in middlewares) {
      final canProceed = await middleware.handle(request);
      if (!canProceed) {
        return Response.forbidden();
      }
    }

    return _executeRequest(request);
  }
}
```

### Combining Unnamed and Named Registrations

```dart
abstract class ThemeProvider {
  ThemeData getTheme();
}

void setupThemes() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Unnamed - available to getAll()
  getIt.registerSingleton<ThemeProvider>(LightThemeProvider());
  getIt.registerSingleton<ThemeProvider>(DarkThemeProvider());

  // Named - accessible individually or via getAll()
  getIt.registerSingleton<ThemeProvider>(
    HighContrastThemeProvider(),
    instanceName: 'highContrast',
  );
}

// Get all themes for theme picker
class ThemePickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final allThemes = getIt.getAll<ThemeProvider>();
    // Returns: [LightThemeProvider, DarkThemeProvider, HighContrastThemeProvider]

    return ListView(
      children: allThemes.map((themeProvider) {
        return ListTile(
          title: Text(themeProvider.getTheme().name),
          onTap: () => applyTheme(themeProvider.getTheme()),
        );
      }).toList(),
    );
  }
}

// Access high contrast theme directly
final highContrastTheme = getIt<ThemeProvider>(instanceName: 'highContrast');
```

---

## Best Practices

### ✅ Do

- **Enable at app startup** before any registrations
- **Register most important/default implementation first** (for `get<T>()`)
- **Use abstract base classes** as registration types
- **Document order dependencies** if middleware/observer order matters
- **Use named registrations** for special-purpose implementations that also need individual access

### ❌ Don't

- **Don't enable mid-application** - do it during initialization
- **Don't rely on `get<T>()`** to retrieve all implementations - use `getAll<T>()`
- **Don't assume registration order** unless you control it
- **Don't mix this pattern with `allowReassignment`** - they serve different purposes

---

## Comparison: Multiple Registrations vs Named Registrations

| Feature | Multiple Registrations | Named Registrations Only |
|---------|----------------------|--------------------------|
| **Enable required** | Yes (`enableRegisteringMultipleInstancesOfOneType()`) | No |
| **Get all** | `getAll<T>()` returns all | Must call `get<T>(instanceName: 'name1')`, `get<T>(instanceName: 'name2')`, etc. individually |
| **Get one** | `get<T>()` returns first | `get<T>(instanceName: 'name')` |
| **Use case** | Plugin systems, observers, middleware | Different configurations of same type |
| **Module independence** | Modules can add implementations without knowing about others | Must know all names upfront |
| **Type safety** | ✅ All returned | ❌ Must know names as strings |

**When to use multiple registrations:**
- ✅ Modular plugin architecture
- ✅ Observer/event handler pattern
- ✅ Middleware chains
- ✅ Validators/processors pipeline

**When to use named registrations only:**
- ✅ Different configurations (dev/prod API endpoints)
- ✅ Feature flags (old/new implementation)
- ✅ Known set of instances needed individually

**You can combine both:**
```dart
// Core plugins (unnamed)
getIt.registerSingleton<Plugin>(CorePlugin());
getIt.registerSingleton<Plugin>(LoggingPlugin());

// Special plugins (named for individual access + included in getAll())
getIt.registerSingleton<Plugin>(DebugPlugin(), instanceName: 'debug');

// Get all including named
final all = getIt.getAll<Plugin>(); // [CorePlugin, LoggingPlugin, DebugPlugin]

// Get specific named one
final debug = getIt<Plugin>(instanceName: 'debug');
```

---

## How It Works

This section explains the internal implementation details. Understanding this is optional for using the feature.

### Data Structure

get_it maintains two separate lists for each type:

```dart
class _TypeRegistration<T> {
  final registrations = <_ObjectRegistration>[];           // Unnamed registrations
  final namedRegistrations = LinkedHashMap<String, ...>(); // Named registrations
}
```

When you call:
- `getIt.registerSingleton<T>(instance)` → adds to `registrations` list
- `getIt.registerSingleton<T>(instance, instanceName: 'name')` → adds to `namedRegistrations` map

### Why `get<T>()` Returns First Only

The `get<T>()` method retrieves instances using this logic:

```dart
_ObjectRegistration? getRegistration(String? name) {
  return name != null
    ? namedRegistrations[name]           // If name provided, look in map
    : registrations.firstOrNull;         // Otherwise, return FIRST from list
}
```

This is why `get<T>()` only returns the first unnamed registration, not all of them.

### Why `getAll<T>()` Returns All

The `getAll<T>()` method combines both lists:

```dart
final registrations = [
  ...typeRegistration.registrations,              // ALL unnamed
  ...typeRegistration.namedRegistrations.values,  // ALL named
];
```

This returns every registered instance, regardless of whether it has a name or not.

### Order Preservation

- **Unnamed registrations**: Preserved in registration order (`List`)
- **Named registrations**: Preserved in registration order (`LinkedHashMap`)
- **`getAll()` order**: Unnamed first (in order), then named (in order)

This is important for middleware/observer patterns where execution order matters.

---

## API Reference

### Enable

| Method | Description |
|--------|-------------|
| `enableRegisteringMultipleInstancesOfOneType()` | Enables multiple unnamed registrations of same type |

### Retrieve

| Method | Description |
|--------|-------------|
| `get<T>()` | Returns **first** unnamed registration |
| `getAll<T>({fromAllScopes})` | Returns **all** registrations (unnamed + named) |
| `getAllAsync<T>({fromAllScopes})` | Async version, waits for async registrations |

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `fromAllScopes` | `bool` | `false` | If `true`, searches all scopes instead of current only |

---

## See Also

- [Named Registration](/documentation/get_it/advanced#named-registration) - Register multiple instances with different names
- [Scopes](/documentation/get_it/scopes) - Hierarchical lifecycle management
- [Object Registration](/documentation/get_it/object_registration) - Different registration types
