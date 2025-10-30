---
title: Advanced
---

# Advanced

::: tip Named Registration
Documentation for registering multiple instances with instance names has moved to the [Multiple Registrations](/documentation/get_it/multiple_registrations) chapter, which covers both named and unnamed multiple registration approaches.
:::

---

## Implementing the `Disposable` Interface

Instead of passing a disposing function on registration or when pushing a Scope from V7.0 on your objects `onDispose()` method will be called
if the object that you register implements the `Disposable` interface:

```dart
abstract class Disposable {
  FutureOr onDispose();
}
```

---

## Reference Counting

Reference counting helps manage singleton lifecycle when multiple consumers might need the same instance, especially useful for recursive scenarios like navigation.

### The Problem

Imagine a detail page that can be pushed recursively (e.g., viewing related items, navigating through a hierarchy):

```
Home → DetailPage(item1) → DetailPage(item2) → DetailPage(item3)
```

Without reference counting:
- First DetailPage registers `DetailService`
- Second DetailPage tries to register → Error or must skip registration
- First DetailPage pops, disposes service → Breaks remaining pages

### The Solution: `registerSingletonIfAbsent` and `releaseInstance`

```dart
T registerSingletonIfAbsent<T>(
  T Function() factoryFunc, {
  String? instanceName,
  DisposingFunc<T>? dispose,
})

void releaseInstance(Object instance)
```

**How it works:**
1. First call: Creates instance, registers, sets reference count to 1
2. Subsequent calls: Returns existing instance, increments counter
3. `releaseInstance`: Decrements counter
4. When counter reaches 0: Unregisters and disposes

### Recursive Navigation Example

```dart
class DetailService extends ChangeNotifier {
  final String itemId;
  String? data;
  bool isLoading = false;

  DetailService(this.itemId) {
    // Trigger async loading in constructor (fire and forget)
    _loadData();
  }

  Future<void> _loadData() async {
    if (data != null) return; // Already loaded

    isLoading = true;
    notifyListeners();

    print('Loading data for $itemId from backend...');
    // Simulate backend call
    await Future.delayed(Duration(seconds: 1));
    data = 'Data for $itemId';

    isLoading = false;
    notifyListeners();
  }
}

class DetailPage extends WatchingWidget {
  final String itemId;
  const DetailPage(this.itemId);

  @override
  Widget build(BuildContext context) {
    // Register once when widget is created, dispose when widget is disposed
    callOnce(
      () {
        // Register or get existing - increments reference count
        getIt.registerSingletonIfAbsent<DetailService>(
          () => DetailService(itemId),
          instanceName: itemId,
        );
      },
      dispose: () {
        // Decrements reference count when widget disposes
        getIt.releaseInstance(getIt<DetailService>(instanceName: itemId));
      },
    );

    // Watch the service - rebuilds when notifyListeners() called
    final service = watchIt<DetailService>(instanceName: itemId);

    return Scaffold(
      appBar: AppBar(title: Text('Detail $itemId')),
      body: service.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text(service.data ?? 'No data'),
                ElevatedButton(
                  onPressed: () {
                    // Can push same page recursively
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage('related-$itemId'),
                      ),
                    );
                  },
                  child: Text('View Related'),
                ),
              ],
            ),
    );
  }
}
```

**Flow:**
```
Push DetailPage(item1)      → Create service, load data, refCount = 1
  Push DetailPage(item2)    → Create service, load data, refCount = 1
    Push DetailPage(item1)  → Get existing (NO reload!), refCount = 2
    Pop DetailPage(item1)   → Release, refCount = 1 (service stays)
  Pop DetailPage(item2)     → Release, refCount = 0 (service disposed)
Pop DetailPage(item1)       → Release, refCount = 0 (service disposed)
```

**Benefits:**
- ✅ Service created synchronously (no async factory needed)
- ✅ Async loading triggered in constructor
- ✅ No duplicate loading for same item (checked before loading)
- ✅ Automatic memory management via reference counting
- ✅ Reactive UI updates via watch_it (rebuilds on state changes)
- ✅ ChangeNotifier automatically disposed when refCount reaches 0
- ✅ Each itemId uniquely identified via `instanceName`

**Key Integration:**
This example demonstrates how **get_it** (reference counting) and **watch_it** (reactive UI) work together seamlessly for complex navigation patterns.

---

### Force Release: `ignoreReferenceCount`

In rare cases, you might need to force unregister regardless of reference count:

```dart
// Force unregister even if refCount > 0
getIt.unregister<MyService>(ignoreReferenceCount: true);
```

::: warning Use with Caution
Only use `ignoreReferenceCount: true` when you're certain no other code is using the instance. This can cause crashes if other parts of your app still hold references.
:::

### When to Use Reference Counting

✅ **Good use cases:**
- Recursive navigation (same page pushed multiple times)
- Services needed by multiple simultaneously active features
- Complex hierarchical component structures

❌ **Don't use when:**
- Simple singleton that lives for app lifetime (use regular `registerSingleton`)
- One-to-one widget-service relationship (use scopes)
- Testing (use scopes to shadow instead)

### Best Practices

1. **Always pair register with release**: Every `registerSingletonIfAbsent` should have a matching `releaseInstance`
2. **Store instance reference**: Keep the returned instance so you can release the correct one
3. **Release in dispose/cleanup**: Tie release to widget/component lifecycle
4. **Document shared resources**: Make it clear when a service uses reference counting

---

## Utility Methods

### Safe Retrieval: `maybeGet<T>()`

Returns `null` instead of throwing an exception if the type is not registered. Useful for optional dependencies and feature flags.

```dart
T? maybeGet<T>({
  String? instanceName,
  dynamic param1,
  dynamic param2,
  Type? type,
})
```

**Example:**

```dart
// Feature flag scenario
final analyticsService = getIt.maybeGet<AnalyticsService>();
if (analyticsService != null) {
  analyticsService.trackEvent('user_action');
}

// Optional dependency
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logger = getIt.maybeGet<Logger>();
    logger?.log('Building MyWidget'); // Safe even if Logger not registered

    return Text('Hello');
  }
}

// Graceful degradation
final premiumFeature = getIt.maybeGet<PremiumFeature>();
if (premiumFeature != null) {
  return PremiumUI(feature: premiumFeature);
} else {
  return BasicUI(); // Fallback when premium not available
}
```

**When to use:**
- ✅ Optional features that may or may not be registered
- ✅ Feature flags (service registered only when feature enabled)
- ✅ Platform-specific services (might not exist on all platforms)
- ✅ Graceful degradation scenarios

**Don't use when:**
- ❌ The dependency is required - use `get<T>()` to fail fast
- ❌ Missing registration indicates a bug - exception is helpful

---

### Instance Renaming: `changeTypeInstanceName()`

Rename a registered instance without unregistering and re-registering (avoids triggering dispose functions).

```dart
void changeTypeInstanceName<T>({
  String? instanceName,
  required String newInstanceName,
  T? instance,
})
```

**Example:**

```dart
class User extends ChangeNotifier {
  String username;
  String email;

  User(this.username, this.email);

  Future<void> updateUsername(String newUsername) async {
    // Update on backend
    await api.updateUsername(username, newUsername);

    final oldUsername = username;
    username = newUsername;

    // Rename the instance in GetIt to match new username
    getIt.changeTypeInstanceName<User>(
      instanceName: oldUsername,
      newInstanceName: newUsername,
    );

    notifyListeners();
  }
}

// Register user with username as instance name
final user = User('alice', 'alice@example.com');
getIt.registerSingleton<User>(user, instanceName: 'alice');

// User changes their username
await getIt<User>(instanceName: 'alice').updateUsername('alice_jones');

// Now accessible with new name
final user = getIt<User>(instanceName: 'alice_jones'); // Works!
// getIt<User>(instanceName: 'alice'); // Would throw - old name invalid
```

**Use cases:**
- User profile updates where username is the instance identifier
- Dynamic entity names that can change at runtime
- Avoiding disposal side effects from unregister/register cycle
- Maintaining instance state while updating its identifier

::: tip Avoids Dispose
Unlike `unregister()` + `register()`, this doesn't trigger dispose functions, preserving the instance's state.
:::

---

### Lazy Singleton Introspection: `checkLazySingletonInstanceExists()`

Check if a lazy singleton has been instantiated yet (without triggering its creation).

```dart
bool checkLazySingletonInstanceExists<T>({
  String? instanceName,
})
```

**Example:**

```dart
// Register lazy singleton
getIt.registerLazySingleton<HeavyService>(() => HeavyService());

// Check if it's been created yet
if (getIt.checkLazySingletonInstanceExists<HeavyService>()) {
  print('HeavyService already created');
} else {
  print('HeavyService not created yet - will be lazy loaded');
}

// Access triggers creation
final service = getIt<HeavyService>();

// Now it exists
assert(getIt.checkLazySingletonInstanceExists<HeavyService>() == true);
```

**Use cases:**
- Performance monitoring (track which services have been initialized)
- Conditional initialization (pre-warm services if not created)
- Testing lazy loading behavior
- Debugging initialization order issues

**Example - Pre-warming:**

```dart
void preWarmCriticalServices() {
  // Only initialize if not already created
  if (!getIt.checkLazySingletonInstanceExists<DatabaseService>()) {
    getIt<DatabaseService>(); // Trigger creation
  }

  if (!getIt.checkLazySingletonInstanceExists<CacheService>()) {
    getIt<CacheService>(); // Trigger creation
  }
}
```

---

### Reset All Lazy Singletons: `resetLazySingletons()`

Reset all instantiated lazy singletons at once. This clears their instances so they'll be recreated on next access.

```dart
Future<void> resetLazySingletons({
  bool dispose = true,
  bool inAllScopes = false,
  String? onlyInScope,
})
```

**Parameters:**
- `dispose` - If true (default), calls dispose functions before resetting
- `inAllScopes` - If true, resets lazy singletons across all scopes
- `onlyInScope` - Reset only in the named scope (takes precedence over `inAllScopes`)

**Example - Basic usage:**

```dart
// Register lazy singletons
getIt.registerLazySingleton<CacheService>(() => CacheService());
getIt.registerLazySingleton<UserPreferences>(() => UserPreferences());

// Access them (creates instances)
final cache = getIt<CacheService>();
final prefs = getIt<UserPreferences>();

// Reset all lazy singletons in current scope
await getIt.resetLazySingletons();

// Next access creates fresh instances
final newCache = getIt<CacheService>(); // New instance
```

**Example - With scopes:**

```dart
// Base scope lazy singletons
getIt.registerLazySingleton<GlobalCache>(() => GlobalCache());

// Push scope and register more
getIt.pushNewScope(scopeName: 'session');
getIt.registerLazySingleton<SessionCache>(() => SessionCache());
getIt.registerLazySingleton<UserState>(() => UserState());

// Access them
final globalCache = getIt<GlobalCache>();
final sessionCache = getIt<SessionCache>();

// Reset only current scope ('session')
await getIt.resetLazySingletons();
// GlobalCache NOT reset, SessionCache and UserState ARE reset

// Reset all scopes
await getIt.resetLazySingletons(inAllScopes: true);
// Both GlobalCache and SessionCache are reset

// Reset only specific scope
await getIt.resetLazySingletons(onlyInScope: 'baseScope');
// Only GlobalCache is reset
```

**Use cases:**
- State reset between tests
- User logout (clear session-specific lazy singletons)
- Memory optimization (reset caches that can be recreated)
- Scope-specific cleanup without popping the scope

**Behavior:**
- Only resets lazy singletons that have been **instantiated**
- Uninstantiated lazy singletons are **not affected**
- Regular singletons and factories are **not affected**
- Supports both sync and async dispose functions

---

### Find All Instances by Type: `findAll<T>()`

Find all registered instances that match a given type with powerful filtering and matching options.

```dart
List<T> findAll<T>({
  bool includeSubtypes = true,
  bool inAllScopes = false,
  String? onlyInScope,
  bool includeMatchedByRegistrationType = true,
  bool includeMatchedByInstance = true,
  bool instantiateLazySingletons = false,
  bool callFactories = false,
})
```

::: warning Performance Note
Unlike get_it's O(1) Map-based lookups, `findAll()` performs an O(n) linear search through all registrations. Use sparingly in performance-critical code. Performance can be improved by limiting the search to a single scope using `onlyInScope`.
:::

**Parameters:**

**Type Matching:**
- `includeSubtypes` - If true (default), matches T and all subtypes; if false, matches only exact type T

**Scope Control:**
- `inAllScopes` - If true, searches all scopes (default: false, current scope only)
- `onlyInScope` - Search only the named scope (takes precedence over `inAllScopes`)

**Matching Strategy:**
- `includeMatchedByRegistrationType` - Match by registered type (default: true)
- `includeMatchedByInstance` - Match by actual instance type (default: true)

**Side Effects:**
- `instantiateLazySingletons` - Instantiate lazy singletons that match (default: false)
- `callFactories` - Call factories that match to include their instances (default: false)

**Example - Basic type matching:**

```dart
abstract class IOutput {
  void write(String message);
}

class FileOutput implements IOutput {
  @override
  void write(String message) => File('log.txt').writeAsStringSync(message);
}

class ConsoleOutput implements IOutput {
  @override
  void write(String message) => print(message);
}

// Register different implementation types
getIt.registerSingleton<FileOutput>(FileOutput());
getIt.registerLazySingleton<ConsoleOutput>(() => ConsoleOutput());

// Find by interface (registration type matching)
final outputs = getIt.findAll<IOutput>();
// Returns: [FileOutput] only (ConsoleOutput not instantiated yet)
```

**Example - Include lazy singletons:**

```dart
// Instantiate lazy singletons that match
final all = getIt.findAll<IOutput>(
  instantiateLazySingletons: true,
);
// Returns: [FileOutput, ConsoleOutput]
// ConsoleOutput is now created and cached
```

**Example - Include factories:**

```dart
getIt.registerFactory<IOutput>(() => RemoteOutput());

// Include factories by calling them
final withFactories = getIt.findAll<IOutput>(
  instantiateLazySingletons: true,
  callFactories: true,
);
// Returns: [FileOutput, ConsoleOutput, RemoteOutput]
// Each factory call creates a new instance
```

**Example - Exact type matching:**

```dart
class BaseLogger {}
class FileLogger extends BaseLogger {}
class ConsoleLogger extends BaseLogger {}

getIt.registerSingleton<BaseLogger>(FileLogger());
getIt.registerSingleton<BaseLogger>(ConsoleLogger());

// Find subtypes (default)
final allLoggers = getIt.findAll<BaseLogger>();
// Returns: [FileLogger, ConsoleLogger]

// Find exact type only
final exactBase = getIt.findAll<BaseLogger>(
  includeSubtypes: false,
);
// Returns: [] (no exact BaseLogger instances, only subtypes)
```

**Example - Instance vs Registration Type:**

```dart
// Register as FileOutput but it implements IOutput
getIt.registerSingleton<FileOutput>(FileOutput());

// Match by registration type
final byRegistration = getIt.findAll<IOutput>(
  includeMatchedByRegistrationType: true,
  includeMatchedByInstance: false,
);
// Returns: [] (registered as FileOutput, not IOutput)

// Match by instance type
final byInstance = getIt.findAll<IOutput>(
  includeMatchedByRegistrationType: false,
  includeMatchedByInstance: true,
);
// Returns: [FileOutput] (instance implements IOutput)
```

**Example - Scope control:**

```dart
// Base scope
getIt.registerSingleton<IOutput>(FileOutput());

// Push scope
getIt.pushNewScope(scopeName: 'session');
getIt.registerSingleton<IOutput>(ConsoleOutput());

// Current scope only (default)
final current = getIt.findAll<IOutput>();
// Returns: [ConsoleOutput]

// All scopes
final all = getIt.findAll<IOutput>(inAllScopes: true);
// Returns: [ConsoleOutput, FileOutput]

// Specific scope
final base = getIt.findAll<IOutput>(onlyInScope: 'baseScope');
// Returns: [FileOutput]
```

**Use cases:**
- Find all implementations of a plugin interface
- Collect all registered validators/processors
- Runtime dependency graph visualization
- Testing: verify all expected types are registered
- Migration tools: find instances of deprecated types

**Validation rules:**
- `includeSubtypes=false` requires `includeMatchedByInstance=false`
- `instantiateLazySingletons=true` requires `includeMatchedByRegistrationType=true`
- `callFactories=true` requires `includeMatchedByRegistrationType=true`

**Throws:**
- `StateError` if `onlyInScope` doesn't exist
- `ArgumentError` if validation rules are violated

---

### Advanced Introspection: `findFirstObjectRegistration<T>()`

Get metadata about a registration without retrieving the instance.

```dart
ObjectRegistration? findFirstObjectRegistration<T>({
  Object? instance,
  String? instanceName,
})
```

**Example:**

```dart
final registration = getIt.findFirstObjectRegistration<MyService>();

if (registration != null) {
  print('Type: ${registration.registrationType}'); // factory, singleton, lazy, etc.
  print('Instance name: ${registration.instanceName}');
  print('Is async: ${registration.isAsync}');
  print('Is ready: ${registration.isReady}');
}
```

**Use cases:**
- Building tools/debugging utilities on top of GetIt
- Runtime dependency graph visualization
- Advanced lifecycle management
- Debugging registration issues

---

### Accessing an object inside GetIt by a runtime type

In rare occasions you might be faced with the problem that you don't know the type that you want to retrieve from GetIt at compile time which means you can't pass it as a generic parameter. For this the `get` functions have an optional `type` parameter

```dart
    getIt.registerSingleton(TestClass());

    final instance1 = getIt.get(type: TestClass);

    expect(instance1 is TestClass, true);
```

Be careful that the receiving variable has the correct type and don't pass `type` and a generic parameter.

### More than one instance of GetIt

While not recommended, you can create your own independent instance of `GetIt` if you don't want to share your locator with some
other package or because the physics of your planet demands it :-)

```dart
/// To make sure you really know what you are doing
/// you have to first enable this feature:
GetIt myOwnInstance = GetIt.asNewInstance();
```

This new instance does not share any registrations with the singleton instance.
