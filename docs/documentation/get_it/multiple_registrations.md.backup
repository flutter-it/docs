---
title: Multiple Registrations
---

# Multiple Registrations

get_it provides two different approaches for registering multiple instances of the same type, each suited to different use cases.

## Two Approaches Overview

### Approach 1: Named Registration (Always Available)

Register multiple instances of the same type by giving each a unique name. This is **always available** without any configuration.

```dart
// Register multiple REST services with different configurations
getIt.registerSingleton<ApiClient>(
  ApiClient('https://api.example.com'),
  instanceName: 'mainApi',
);

getIt.registerSingleton<ApiClient>(
  ApiClient('https://analytics.example.com'),
  instanceName: 'analyticsApi',
);

// Access individually by name
final mainApi = getIt<ApiClient>(instanceName: 'mainApi');
final analyticsApi = getIt<ApiClient>(instanceName: 'analyticsApi');
```

**Best for:**
- ✅ Different configurations of the same type (dev/prod endpoints)
- ✅ Known set of instances accessed individually
- ✅ Feature flags (old/new implementation)

### Approach 2: Multiple Unnamed Registrations (Requires Opt-In)

Register multiple instances without names and retrieve them all at once with `getAll<T>()`. Requires explicit opt-in.

```dart
// Enable feature first
getIt.enableRegisteringMultipleInstancesOfOneType();

// Register multiple plugins without names
getIt.registerSingleton<Plugin>(CorePlugin());
getIt.registerSingleton<Plugin>(LoggingPlugin());
getIt.registerSingleton<Plugin>(AnalyticsPlugin());

// Get all at once
final Iterable<Plugin> allPlugins = getIt.getAll<Plugin>();
```

**Best for:**
- ✅ Plugin systems (modules can add implementations)
- ✅ Observer/event handler patterns
- ✅ Middleware chains
- ✅ When you don't need to access instances individually

::: tip You Can Combine Both Approaches
Named and unnamed registrations can coexist. `getAll<T>()` returns both unnamed and named instances.
:::

---

## Named Registration

All registration functions accept an optional `instanceName` parameter. Each name must be **unique per type**.

### Basic Usage

```dart
abstract class RestService {
  Future<Response> get(String endpoint);
}

class RestServiceImpl implements RestService {
  final String baseUrl;

  RestServiceImpl(this.baseUrl);

  @override
  Future<Response> get(String endpoint) async {
    return http.get('$baseUrl/$endpoint');
  }
}

// Register multiple REST services with different base URLs
getIt.registerSingleton<RestService>(
  RestServiceImpl('https://api.example.com'),
  instanceName: 'mainApi',
);

getIt.registerSingleton<RestService>(
  RestServiceImpl('https://analytics.example.com'),
  instanceName: 'analyticsApi',
);

// Access them by name
class UserRepository {
  UserRepository() {
    _mainApi = getIt<RestService>(instanceName: 'mainApi');
    _analyticsApi = getIt<RestService>(instanceName: 'analyticsApi');
  }

  late final RestService _mainApi;
  late final RestService _analyticsApi;

  Future<User> getUser(String id) async {
    final response = await _mainApi.get('users/$id');
    _analyticsApi.get('track/user_fetch'); // Track analytics
    return User.fromJson(response.data);
  }
}
```

### Works with All Registration Types

Named registration works with **every** registration method:

```dart
// Singleton
getIt.registerSingleton<Logger>(
  FileLogger(),
  instanceName: 'fileLogger',
);

// Lazy Singleton
getIt.registerLazySingleton<Cache>(
  () => MemoryCache(),
  instanceName: 'memory',
);

// Factory
getIt.registerFactory<Report>(
  () => DailyReport(),
  instanceName: 'daily',
);

// Async Singleton
getIt.registerSingletonAsync<Database>(
  () async => Database.connect('prod'),
  instanceName: 'production',
);
```

### Named Registration Use Cases

**Environment-specific configurations:**
```dart
void setupForEnvironment(String env) {
  if (env == 'production') {
    getIt.registerSingleton<ApiClient>(
      ApiClient('https://api.prod.example.com'),
      instanceName: 'api',
    );
  } else {
    getIt.registerSingleton<ApiClient>(
      MockApiClient(),
      instanceName: 'api',
    );
  }
}

// Always access with same name
final api = getIt<ApiClient>(instanceName: 'api');
```

**Feature flags:**
```dart
void setupPaymentProcessor(bool useNewVersion) {
  if (useNewVersion) {
    getIt.registerSingleton<PaymentProcessor>(
      StripePaymentProcessor(),
      instanceName: 'payment',
    );
  } else {
    getIt.registerSingleton<PaymentProcessor>(
      LegacyPaymentProcessor(),
      instanceName: 'payment',
    );
  }
}
```

**Multiple database connections:**
```dart
getIt.registerSingletonAsync<Database>(
  () async => Database.connect('postgres://main-db'),
  instanceName: 'mainDb',
);

getIt.registerSingletonAsync<Database>(
  () async => Database.connect('postgres://analytics-db'),
  instanceName: 'analyticsDb',
);

getIt.registerSingletonAsync<Database>(
  () async => Database.connect('postgres://cache-db'),
  instanceName: 'cacheDb',
);
```

---

## Multiple Unnamed Registrations

For plugin systems, observers, and middleware where you want to retrieve **all** instances at once without knowing their names.

### Enabling Multiple Registrations

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

::: tip Alternative: findAll() for Type-Based Discovery
While `getAll<T>()` retrieves instances you've explicitly registered multiple times, `findAll<T>()` finds instances by **type matching** - no multiple registration setup needed. See [Related: Finding Instances by Type](#related-finding-instances-by-type) below for when to use each approach.
:::

---

## Scope Behavior

`getAll<T>()` provides three scope control options:

### Current Scope Only (Default)

By default, searches only the **current scope**:

```dart
getIt.enableRegisteringMultipleInstancesOfOneType();

// Base scope
getIt.registerSingleton<Plugin>(CorePlugin());
getIt.registerSingleton<Plugin>(LoggingPlugin());

// Push new scope
getIt.pushNewScope(scopeName: 'feature');
getIt.registerSingleton<Plugin>(FeatureAPlugin());
getIt.registerSingleton<Plugin>(FeatureBPlugin());

// Current scope only (default)
final featurePlugins = getIt.getAll<Plugin>();
// Returns: [FeatureAPlugin, FeatureBPlugin]
```

### All Scopes

To retrieve from **all scopes**, use `fromAllScopes: true`:

```dart
// All scopes
final allPlugins = getIt.getAll<Plugin>(fromAllScopes: true);
// Returns: [FeatureAPlugin, FeatureBPlugin, CorePlugin, LoggingPlugin]
```

### Specific Named Scope

To search only a **specific named scope**, use `onlyInScope`:

```dart
// Only search the base scope
final basePlugins = getIt.getAll<Plugin>(onlyInScope: 'baseScope');
// Returns: [CorePlugin, LoggingPlugin]

// Only search the 'feature' scope
final featurePlugins = getIt.getAll<Plugin>(onlyInScope: 'feature');
// Returns: [FeatureAPlugin, FeatureBPlugin]
```

::: tip Parameter Precedence
If both `onlyInScope` and `fromAllScopes` are provided, `onlyInScope` takes precedence.
:::

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

**With scope control:**

`getAllAsync()` supports the same scope parameters as `getAll()`:

```dart
// All scopes
final Iterable<Plugin> allPlugins = await getIt.getAllAsync<Plugin>(
  fromAllScopes: true,
);

// Specific named scope
final Iterable<Plugin> basePlugins = await getIt.getAllAsync<Plugin>(
  onlyInScope: 'baseScope',
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

## Choosing the Right Approach

| Feature | Named Registration | Multiple Unnamed Registration |
|---------|-------------------|------------------------------|
| **Enable required** | No | Yes (`enableRegisteringMultipleInstancesOfOneType()`) |
| **Access pattern** | Individual by name: `get<T>(instanceName: 'name')` | All at once: `getAll<T>()` returns all |
| **Get one** | `get<T>(instanceName: 'name')` | `get<T>()` returns first |
| **Use case** | Different configurations, feature flags | Plugin systems, observers, middleware |
| **Module independence** | Must know names upfront | Modules can add implementations without knowing about others |
| **Access method** | String-based names | Type-based retrieval |

**When to use named registration:**
- ✅ Different configurations (dev/prod API endpoints)
- ✅ Feature flags (old/new implementation)
- ✅ Known set of instances accessed individually
- ✅ Multiple database connections

**When to use multiple unnamed registration:**
- ✅ Modular plugin architecture
- ✅ Observer/event handler pattern
- ✅ Middleware chains
- ✅ Validators/processors pipeline

**Combining both approaches:**

Named and unnamed registrations work together seamlessly:

```dart
// Enable multiple unnamed registrations
getIt.enableRegisteringMultipleInstancesOfOneType();

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
| `onlyInScope` | `String?` | `null` | If provided, searches only the named scope (takes precedence over `fromAllScopes`) |

---

## Related: Finding Instances by Type

While `getAll<T>()` retrieves instances you've explicitly registered multiple times, `findAll<T>()` offers a different approach: finding instances by **type matching** criteria.

**Key differences:**

| Feature | `getAll<T>()` | `findAll<T>()` |
|---------|---------------|----------------|
| **Purpose** | Retrieve multiple explicit registrations | Find instances by type matching |
| **Requires** | `enableRegisteringMultipleInstancesOfOneType()` | No special setup |
| **Matches** | Exact type T (with optional names) | T and subtypes (configurable) |
| **Performance** | O(1) map lookup | O(n) linear search |
| **Use case** | Plugin systems, known multiple registrations | Finding implementations, testing, introspection |

**Example comparison:**

```dart
abstract class ILogger {}
class FileLogger implements ILogger {}
class ConsoleLogger implements ILogger {}

// Approach 1: Multiple registrations with getAll()
getIt.enableRegisteringMultipleInstancesOfOneType();
getIt.registerSingleton<ILogger>(FileLogger());
getIt.registerSingleton<ILogger>(ConsoleLogger());

final loggers1 = getIt.getAll<ILogger>();
// Returns: [FileLogger, ConsoleLogger]

// Approach 2: Different registration types with findAll()
getIt.registerSingleton<FileLogger>(FileLogger());
getIt.registerSingleton<ConsoleLogger>(ConsoleLogger());

final loggers2 = getIt.findAll<ILogger>();
// Returns: [FileLogger, ConsoleLogger] (matched by type)
```

::: tip When to Use Each
- Use **`getAll()`** when you explicitly want multiple instances of the same type and will retrieve them all together
- Use **`findAll()`** when you want to discover instances by type relationship, especially for testing or debugging
:::

See [findAll() documentation](/documentation/get_it/advanced#find-all-instances-by-type-findall-t) for comprehensive details on type matching, scope control, and advanced filtering options.

---

## See Also

- [Scopes](/documentation/get_it/scopes) - Hierarchical lifecycle management and scope-specific registrations
- [Object Registration](/documentation/get_it/object_registration) - Different registration types (factories, singletons, etc.)
- [Async Objects](/documentation/get_it/async_objects) - Using `getAllAsync()` with async registrations
- [Advanced - findAll()](/documentation/get_it/advanced#find-all-instances-by-type-findall-t) - Type-based instance discovery
