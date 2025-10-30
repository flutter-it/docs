---
title: Object Registration
---

# Object Registration

get_it offers different registration types that control when objects are created and how long they live. Choose the right type based on your needs.

## Quick Reference

| Type | When Created | How Many Instances | Lifetime | Best For |
|------|--------------|-------------------|----------|----------|
| **Singleton** | Immediately | One | Permanent | Fast to create, needed at startup |
| **LazySingleton** | First access | One | Permanent | Expensive to create, not always needed |
| **Factory** | Every `get()` | Many | Per request | Temporary objects, new state each time |
| **Cached Factory** | First access + after GC | Reused while in memory | Until garbage collected | Performance optimization |

---

## Singleton

```dart
T registerSingleton<T>(
  T instance, {
  String? instanceName,
  bool? signalsReady,
  DisposingFunc<T>? dispose,
})
```

You pass an instance of `T` that will **always** be returned on calls to `get<T>()`. The instance is created **immediately** when you register it.

**Parameters:**
- `instance` - The instance to register
- `instanceName` - Optional name to register multiple instances of the same type
- `signalsReady` - If true, this instance must signal when it's ready (used with async initialization)
- `dispose` - Optional cleanup function called when unregistering or resetting

**Example:**

```dart
void configureDependencies() {
  // Simple registration
  getIt.registerSingleton<Logger>(Logger());

  // With disposal
  getIt.registerSingleton<Database>(
    Database(),
    dispose: (db) => db.close(),
  );
}
```

**When to use Singleton:**
- ✅ Service needed at app startup
- ✅ Fast to create (no expensive initialization)
- ❌ Avoid for slow initialization (use LazySingleton instead)

---

## LazySingleton

```dart
void registerLazySingleton<T>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
  DisposingFunc<T>? dispose,
  void Function(T instance)? onCreated,
  bool useWeakReference = false,
})
```

You pass a factory function that returns an instance of `T`. The function is **only called on first access** to `get<T>()`. After that, the same instance is always returned.

**Parameters:**
- `factoryFunc` - Function that creates the instance
- `instanceName` - Optional name to register multiple instances of the same type
- `dispose` - Optional cleanup function called when unregistering or resetting
- `onCreated` - Optional callback invoked after the instance is created
- `useWeakReference` - If true, uses weak reference (allows garbage collection if not used)

**Example:**

```dart
void configureDependencies() {
  // Simple registration
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // With disposal and onCreated callback
  getIt.registerLazySingleton<Database>(
    () => Database(),
    dispose: (db) => db.close(),
    onCreated: (db) => print('Database initialized'),
  );
}

// First access - factory function runs NOW
final api = getIt<ApiClient>(); // ApiClient() constructor called

// Subsequent calls - returns existing instance
final sameApi = getIt<ApiClient>(); // Same instance, no constructor call
```

**When to use LazySingleton:**
- ✅ Expensive-to-create services (database, HTTP client, etc.)
- ✅ Services not always needed by every user
- ✅ When you need to delay initialization

---

::: tip Concrete Types vs Interfaces
You can register either concrete classes or abstract interfaces. **Register concrete classes directly** unless you expect multiple implementations (e.g., production vs test, different providers). This keeps your code simpler and IDE navigation easier.
:::

## Factory

```dart
void registerFactory<T>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
})
```

You pass a factory function that returns a **NEW instance** of `T` every time you call `get<T>()`. Unlike singletons, you get a different object each time.

**Parameters:**
- `factoryFunc` - Function that creates new instances
- `instanceName` - Optional name to register multiple factories of the same type

**Example:**

```dart
void configureDependencies() {
  getIt.registerFactory<ShoppingCart>(() => ShoppingCart());
}

// Each call creates a NEW instance
final cart1 = getIt<ShoppingCart>(); // New ShoppingCart()
final cart2 = getIt<ShoppingCart>(); // Different ShoppingCart()

print(identical(cart1, cart2)); // false - different objects
```

**When to use Factory:**
- ✅ Temporary objects (dialogs, forms, temporary data holders)
- ✅ Objects that need fresh state each time
- ✅ Objects with short lifecycle
- ❌ Avoid for expensive-to-create objects used frequently (consider Cached Factory)

---

## Passing Parameters to Factories

In some cases, you need to pass values to factories when calling `get()`. get_it supports up to two parameters:

```dart
void registerFactoryParam<T, P1, P2>(
  FactoryFuncParam<T, P1, P2> factoryFunc, {
  String? instanceName,
})

void registerFactoryParamAsync<T, P1, P2>(
  FactoryFuncParamAsync<T, P1, P2> factoryFunc, {
  String? instanceName,
})
```

**Example with two parameters:**

```dart
// Register factory accepting two parameters
getIt.registerFactoryParam<UserViewModel, String, int>(
  (userId, age) => UserViewModel(userId: userId, age: age),
);

// Access with parameters
final vm = getIt<UserViewModel>(param1: 'user-123', param2: 25);
```

**Example with one parameter:**

If you only need one parameter, pass `void` as the second type:

```dart
// Register with one parameter (second type is void)
getIt.registerFactoryParam<ReportGenerator, String, void>(
  (reportType, _) => ReportGenerator(reportType),
);

// Access with one parameter
final report = getIt<ReportGenerator>(param1: 'sales');
```

**Why two parameters?**

Two parameters cover common scenarios like Flutter widgets that need both `BuildContext` and a data object, or services that need both configuration and runtime values.

::: warning Type Safety
Parameters are passed as `dynamic` but are checked at runtime to match the registered types (`P1`, `P2`). Type mismatches will throw an error.
:::

---

## Cached Factories

Cached factories are a **performance optimization** that sits between regular factories and singletons. They create a new instance on first call but cache it with a weak reference, returning the cached instance as long as it's still in memory (meaning some part of your app still holds a reference to it).

```dart
void registerCachedFactory<T>(
  FactoryFunc<T> factoryFunc, {
  String? instanceName,
})

void registerCachedFactoryParam<T, P1, P2>(
  FactoryFuncParam<T, P1, P2> factoryFunc, {
  String? instanceName,
})

void registerCachedFactoryAsync<T>(
  FactoryFuncAsync<T> factoryFunc, {
  String? instanceName,
})

void registerCachedFactoryParamAsync<T, P1, P2>(
  FactoryFuncParamAsync<T, P1, P2> factoryFunc, {
  String? instanceName,
})
```

**How it works:**
1. First call: Creates new instance (like factory)
2. Subsequent calls: Returns cached instance if still in memory (like singleton)
3. If garbage collected (no references held by your app): Creates new instance again (like factory)
4. For param versions: Also checks if parameters match before reusing

**Example:**

```dart
// Register a cached factory
getIt.registerCachedFactory<HeavyParser>(() => HeavyParser());

// First call - creates instance
final parser1 = getIt<HeavyParser>(); // New instance created

// Second call - reuses if not garbage collected
final parser2 = getIt<HeavyParser>(); // Same instance (if still in memory)

// After garbage collection (no references held)
final parser3 = getIt<HeavyParser>(); // New instance created
```

**With parameters:**

```dart
getIt.registerCachedFactoryParam<ImageProcessor, int, int>(
  (width, height) => ImageProcessor(width, height),
);

// Creates new instance
final processor1 = getIt<ImageProcessor>(param1: 1920, param2: 1080);

// Reuses same instance (same parameters)
final processor2 = getIt<ImageProcessor>(param1: 1920, param2: 1080);

// Creates NEW instance (different parameters)
final processor3 = getIt<ImageProcessor>(param1: 3840, param2: 2160);
```

**When to use cached factories:**

✅ **Good use cases:**
- **Heavy objects recreated frequently**: Parsers, formatters, calculators
- **Memory-sensitive scenarios**: Want automatic cleanup but prefer reuse
- **Objects with expensive initialization**: Database connections, file readers
- **Short-to-medium lifetime objects**: Active for a while but not forever

❌ **Don't use when:**
- Object should always be new (use regular factory)
- Object should live forever (use singleton/lazy singleton)
- Object holds critical state that must not be reused

**Performance characteristics:**

| Type | Creation Cost | Memory | Reuse |
|------|---------------|--------|-------|
| Factory | Every call | Low (immediate GC) | Never |
| **Cached Factory** | First call + after GC | Medium (weak ref) | While in memory |
| Lazy Singleton | First call only | High (permanent) | Always |

**Comparison example:**

```dart
// Factory - always new, immediate cleanup
getIt.registerFactory<JsonParser>(() => JsonParser());
final p1 = getIt<JsonParser>(); // Creates instance 1
final p2 = getIt<JsonParser>(); // Creates instance 2 (different)

// Cached Factory - reuses if possible
getIt.registerCachedFactory<JsonParser>(() => JsonParser());
final p3 = getIt<JsonParser>(); // Creates instance 3
final p4 = getIt<JsonParser>(); // Returns instance 3 (if not GC'd)

// Lazy Singleton - reuses forever
getIt.registerLazySingleton<JsonParser>(() => JsonParser());
final p5 = getIt<JsonParser>(); // Creates instance 4
final p6 = getIt<JsonParser>(); // Returns instance 4 (always)
```

::: tip Memory Management
Cached factories use **weak references**, meaning the cached instance can be garbage collected when no other part of your code holds a reference to it. This provides automatic memory management while still benefiting from reuse.
:::

---

## Registering Multiple Implementations

get_it supports multiple ways to register more than one instance of the same type. This is useful for plugin systems, event handlers, and modular architectures where you need to retrieve all implementations of a particular type.

::: tip Learn More
See the [Multiple Registrations](/documentation/get_it/multiple_registrations) chapter for comprehensive documentation covering:
- Different approaches to registering multiple instances
- Why explicit enabling is required for unnamed registrations
- How `get<T>()` vs `getAll<T>()` behave differently
- Named vs unnamed registrations
- Scope behavior with `fromAllScopes`
- Real-world patterns (plugins, observers, middleware)
:::

---

## Managing Registrations

### Checking if a Type is Registered

You can test if a type or instance is already registered:

```dart
bool isRegistered<T>({Object? instance, String? instanceName});
```

**Example:**

```dart
// Check if type is registered
if (getIt.isRegistered<ApiClient>()) {
  print('ApiClient is already registered');
}

// Check by instance name
if (getIt.isRegistered<Database>(instanceName: 'test-db')) {
  print('Test database is registered');
}

// Check if specific instance is registered
final myLogger = Logger();
if (getIt.isRegistered<Logger>(instance: myLogger)) {
  print('This specific logger instance is registered');
}
```

### Unregistering Services

You can remove a registered type from get_it, optionally calling a disposal function:

```dart
void unregister<T>({
  Object? instance,
  String? instanceName,
  void Function(T)? disposingFunction,
});
```

**Example:**

```dart
// Unregister by type with cleanup
getIt.unregister<Database>(
  disposingFunction: (db) => db.close(),
);

// Unregister by instance name
getIt.unregister<ApiClient>(instanceName: 'legacy-api');

// Unregister specific instance
final myService = getIt<MyService>();
getIt.unregister<MyService>(
  instance: myService,
  disposingFunction: (s) => s.dispose(),
);
```

::: tip
The disposing function overrides any disposal function you provided during registration.
:::

### Resetting Lazy Singletons

Sometimes you want to reset a lazy singleton (force recreation on next access) without unregistering it:

```dart
void resetLazySingleton<T>({
  Object? instance,
  String? instanceName,
  void Function(T)? disposingFunction,
});
```

**Example:**

```dart
// Reset so it recreates on next get()
getIt.resetLazySingleton<UserCache>();

// Next access will call the factory function again
final cache = getIt<UserCache>(); // New instance created
```

**When to use:**
- ✅ Refresh cached data (after login/logout)
- ✅ Testing - reset state between tests
- ✅ Development - reload configuration

### Resetting All Registrations

Clear all registered types (useful for tests or app shutdown):

```dart
Future<void> reset({bool dispose = true});
```

**Example:**

```dart
// Reset everything and call disposal functions
await getIt.reset();

// Reset without calling disposals
await getIt.reset(dispose: false);
```

::: warning Important
- Registrations are cleared in **reverse order** (last registered, first disposed)
- This is **async** - always `await` it
- Disposal functions registered during setup will be called (unless `dispose: false`)
:::

**Use cases:**
- Between unit tests (`tearDown` or `tearDownAll`)
- Before app shutdown
- Switching environments entirely

### Overwriting Registrations

By default, get_it prevents registering the same type twice (catches bugs). To allow overwriting:

```dart
getIt.allowReassignment = true;

// Now you can re-register
getIt.registerSingleton<Logger>(ConsoleLogger());
getIt.registerSingleton<Logger>(FileLogger()); // Overwrites previous
```

::: warning Use Sparingly
Allowing reassignment makes bugs harder to catch. Prefer using [scopes](/documentation/get_it/scopes) instead for temporary overrides (especially in tests).
:::

### Skip Double Registration (Testing Only)

In tests, silently ignore double registration instead of throwing an error:

```dart
getIt.skipDoubleRegistration = true;

// If already registered, this does nothing instead of throwing
getIt.registerSingleton<Logger>(Logger());
```

**Only available in tests** - useful when multiple test files might register the same global services.