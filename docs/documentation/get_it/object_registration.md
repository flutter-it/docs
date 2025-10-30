---
title: Different ways of registration
---

# Different ways of registration

`GetIt` offers different ways how objects are registered that affect the lifetime of these objects.

#### Factory

```dart
void registerFactory<T>(FactoryFunc<T> func)
```

You have to pass a factory function `func` that returns a NEW instance of an implementation of `T`. Each time you call `get<T>()` you will get a new instance returned. How to pass parameters to a factory you can find [here](#passing-parameters-to-factories).

###### Passing Parameters to factories

In some cases, it's handy if you could pass changing values to factories when calling `get()`. For that there are two variants for registering factories:

```dart
/// registers a type so that a new instance will be created on each call of [get] on that type based on
/// up to two parameters provided to [get()]
/// [T] type to register
/// [P1] type of param1
/// [P2] type of param2
/// if you use only one parameter pass void here
/// [factoryfunc] factory function for this type that accepts two parameters
/// [instanceName] if you provide a value here your factory gets registered with that
/// name instead of a type. This should only be necessary if you need to register more
/// than one instance of one type.
///
/// example:
///    getIt.registerFactoryParam<TestClassParam,String,int>((s,i)
///        => TestClassParam(param1:s, param2: i));
///
/// if you only use one parameter:
///
///    getIt.registerFactoryParam<TestClassParam,String,void>((s,_)
///        => TestClassParam(param1:s);
void registerFactoryParam<T,P1,P2>(FactoryFuncParam<T,P1,P2> factoryfunc, {String instanceName});

```

and

```dart
  void registerFactoryParamAsync<T,P1,P2>(FactoryFuncParamAsync<T,P1,P2> factoryfunc, {String instanceName});
```

The reason why I settled to use two parameters is that I can imagine some scenarios where you might want to register a builder function for Flutter Widgets that need to get a `BuildContext` and some data object.

When accessing these factories you pass the parameters a optional arguments to `get()`:

```dart
  var instance = getIt<TestClassParam>(param1: 'abc',param2:3);
```

These parameters are passed as `dynamics` (otherwise I would have had to add more generic parameters to `get()`), but they are checked at runtime to be the correct types.

### Cached Factories

Cached factories are a **performance optimization** that sits between regular factories and singletons. They create a new instance on first call but cache it with a weak reference, returning the cached instance if it hasn't been garbage collected yet.

```dart
void registerCachedFactory<T>(FactoryFunc<T> func)
void registerCachedFactoryParam<T, P1, P2>(FactoryFuncParam<T, P1, P2> func)
void registerCachedFactoryAsync<T>(FactoryFuncAsync<T> func)
void registerCachedFactoryParamAsync<T, P1, P2>(FactoryFuncParamAsync<T, P1, P2> func)
```

**How it works:**
1. First call: Creates new instance (like factory)
2. Subsequent calls: Returns cached instance if still in memory (like singleton)
3. If garbage collected: Creates new instance again (like factory)
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

#### Singleton & LazySingleton

> Although I always would recommend using an abstract base class as a registration type so that you can vary the implementations you don't have to do this. You can also register concrete types.

```dart
T registerSingleton<T>(T instance)
```

You have to pass an instance of `T` or a derived class of `T` that you will always get returned on a call to `get<T>()`. The newly registered instance is also returned which can be sometimes convenient.

As creating this instance can be time-consuming at app start-up you can shift the creation to the time the object is the first time requested with:

```dart
void registerLazySingleton<T>(FactoryFunc<T> func)
```

You have to pass a factory function `func` that returns an instance of an implementation of `T`. Only the first time you call `get<T>()` this factory function will be called to create a new instance. After that, you will always get the same instance returned.

### Registering multiple implementations

Get_it allows you to register multiple implementations of the same type and retrieve them all with `getAll<T>()`. This is useful for plugin systems, event handlers, and modular architectures.

**Quick example:**

```dart
// Enable multiple registrations
getIt.enableRegisteringMultipleInstancesOfOneType();

// Register multiple implementations
getIt.registerLazySingleton<Plugin>(() => CorePlugin());
getIt.registerLazySingleton<Plugin>(() => LoggingPlugin());
getIt.registerLazySingleton<Plugin>(() => AnalyticsPlugin());

// Retrieve all implementations
final Iterable<Plugin> allPlugins = getIt.getAll<Plugin>();
// Returns: [CorePlugin, LoggingPlugin, AnalyticsPlugin]
```

::: tip Learn More
See the [Multiple Registrations](/documentation/get_it/multiple_registrations) chapter for comprehensive documentation covering:
- Why explicit enabling is required
- How `get<T>()` vs `getAll<T>()` behave differently
- Unnamed vs named registrations
- Scope behavior with `fromAllScopes`
- Real-world patterns (plugins, observers, middleware)
:::

### Overwriting registrations

If you try to register a type more than once you will fail with an assertion in debug mode because normally this is not needed and probably a bug.
If you really have to overwrite a registration, then you can by setting the property `allowReassignment = true`.

### Skip Double registrations while testing

If you try to register a type more than once and when `allowReassignment = false`  you will fail with an assertion in debug mode.
If you want to just skip this double registration silently without an error, then you can by setting the property `skipDoubleRegistration = true`.
This is only available inside tests where is can be handy.

### Testing if a Singleton is already registered

You can check if a certain Type or instance is already registered in GetIt with:

```dart
 /// Tests if an [instance] of an object or aType [T] or a name [instanceName]
 /// is registered inside GetIt
 bool isRegistered<T>({Object instance, String instanceName});
```

### Unregistering Singletons or Factories

If you need to you can also unregister your registered singletons and factories and pass an optional `disposingFunction` for clean-up.

```dart
/// Unregister an [instance] of an object or a factory/singleton by Type [T] or by name [instanceName]
/// if you need to dispose some resources before the reset, you can
/// provide a [disposingFunction]. This function overrides the disposing
/// you might have provided when registering.
void unregister<T>({Object instance,String instanceName, void Function(T) disposingFunction})
```

### Resetting LazySingletons

In some cases, you might not want to unregister a LazySingleton but instead, reset its instance so that it gets newly created on the next access to it.

```dart
  /// Clears the instance of a lazy singleton,
  /// being able to call the factory function on the next call
  /// of [get] on that type again.
  /// you select the lazy Singleton you want to reset by either providing
  /// an [instance], its registered type [T] or its registration name.
  /// if you need to dispose some resources before the reset, you can
  /// provide a [disposingFunction]. This function overrides the disposing
  /// you might have provided when registering.
void resetLazySingleton<T>({Object instance,
                            String instanceName,
                            void Function(T) disposingFunction})
```

### Resetting GetIt completely

```dart
/// Clears all registered types in the reverse order in which they were registered.
/// Handy when writing unit tests or before quitting your application.
/// If you provided dispose function when registering they will be called
/// [dispose] if `false` it only resets without calling any dispose
/// functions
/// As dispose funcions can be async, you should await this function.
Future<void> reset({bool dispose = true});
```