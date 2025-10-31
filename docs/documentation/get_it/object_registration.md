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


<<< @/../code_samples/lib/get_it/t_example.dart#example

You pass an instance of `T` that will **always** be returned on calls to `get<T>()`. The instance is created **immediately** when you register it.

**Parameters:**
- `instance` - The instance to register
- `instanceName` - Optional name to register multiple instances of the same type
- `signalsReady` - If true, this instance must signal when it's ready (used with async initialization)
- `dispose` - Optional cleanup function called when unregistering or resetting

**Example:**


<<< @/../code_samples/lib/get_it/configure_dependencies_example_4.dart#example

**When to use Singleton:**
- ✅ Service needed at app startup
- ✅ Fast to create (no expensive initialization)
- ❌ Avoid for slow initialization (use LazySingleton instead)

---

## LazySingleton


<<< @/../code_samples/lib/get_it/function_example.dart#example

You pass a factory function that returns an instance of `T`. The function is **only called on first access** to `get<T>()`. After that, the same instance is always returned.

**Parameters:**
- `factoryFunc` - Function that creates the instance
- `instanceName` - Optional name to register multiple instances of the same type
- `dispose` - Optional cleanup function called when unregistering or resetting
- `onCreated` - Optional callback invoked after the instance is created
- `useWeakReference` - If true, uses weak reference (allows garbage collection if not used)

**Example:**


<<< @/../code_samples/lib/get_it/configure_dependencies_example_5.dart#example

**When to use LazySingleton:**
- ✅ Expensive-to-create services (database, HTTP client, etc.)
- ✅ Services not always needed by every user
- ✅ When you need to delay initialization

---

::: tip Concrete Types vs Interfaces
You can register either concrete classes or abstract interfaces. **Register concrete classes directly** unless you expect multiple implementations (e.g., production vs test, different providers). This keeps your code simpler and IDE navigation easier.
:::

## Factory


<<< @/../code_samples/lib/get_it/t_example_1.dart#example

You pass a factory function that returns a **NEW instance** of `T` every time you call `get<T>()`. Unlike singletons, you get a different object each time.

**Parameters:**
- `factoryFunc` - Function that creates new instances
- `instanceName` - Optional name to register multiple factories of the same type

**Example:**


<<< @/../code_samples/lib/get_it/configure_dependencies_example_6.dart#example

**When to use Factory:**
- ✅ Temporary objects (dialogs, forms, temporary data holders)
- ✅ Objects that need fresh state each time
- ✅ Objects with short lifecycle
- ❌ Avoid for expensive-to-create objects used frequently (consider Cached Factory)

---

## Passing Parameters to Factories

In some cases, you need to pass values to factories when calling `get()`. get_it supports up to two parameters:


<<< @/../code_samples/lib/get_it/code_sample_30935190.dart#example

**Example with two parameters:**


<<< @/../code_samples/lib/get_it/code_sample_42c18049.dart#example

**Example with one parameter:**

If you only need one parameter, pass `void` as the second type:


<<< @/../code_samples/lib/get_it/code_sample_8a892376.dart#example

**Why two parameters?**

Two parameters cover common scenarios like Flutter widgets that need both `BuildContext` and a data object, or services that need both configuration and runtime values.

::: warning Type Safety
Parameters are passed as `dynamic` but are checked at runtime to match the registered types (`P1`, `P2`). Type mismatches will throw an error.
:::

---

## Cached Factories

Cached factories are a **performance optimization** that sits between regular factories and singletons. They create a new instance on first call but cache it with a weak reference, returning the cached instance as long as it's still in memory (meaning some part of your app still holds a reference to it).


<<< @/../code_samples/lib/get_it/code_sample_773e24bb.dart#example

**How it works:**
1. First call: Creates new instance (like factory)
2. Subsequent calls: Returns cached instance if still in memory (like singleton)
3. If garbage collected (no references held by your app): Creates new instance again (like factory)
4. For param versions: Also checks if parameters match before reusing

**Example:**


<<< @/../code_samples/lib/get_it/code_sample_135f1ef6.dart#example

**With parameters:**


<<< @/../code_samples/lib/get_it/code_sample_1a719c02_signature.dart

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


<<< @/../code_samples/lib/get_it/json_parser_signature.dart

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


<<< @/../code_samples/lib/get_it/code_sample_3ddc0f1f.dart#example

**Example:**


<<< @/../code_samples/lib/get_it/code_sample_1c1d87ec.dart#example

### Unregistering Services

You can remove a registered type from get_it, optionally calling a disposal function:


<<< @/../code_samples/lib/get_it/function_example_1.dart#example

**Example:**


<<< @/../code_samples/lib/get_it/code_sample_91535ee8.dart#example

::: tip
The disposing function overrides any disposal function you provided during registration.
:::

### Resetting Lazy Singletons

Sometimes you want to reset a lazy singleton (force recreation on next access) without unregistering it:


<<< @/../code_samples/lib/get_it/function_example_2.dart#example

**Example:**


<<< @/../code_samples/lib/get_it/code_sample_2ba32f12.dart#example

**When to use:**
- ✅ Refresh cached data (after login/logout)
- ✅ Testing - reset state between tests
- ✅ Development - reload configuration

::: tip Reset All Lazy Singletons
If you need to reset **all** lazy singletons at once (instead of one at a time), use `resetLazySingletons()` which supports scope control and batch operations. See [resetLazySingletons() documentation](/documentation/get_it/advanced#reset-all-lazy-singletons-resetlazysingletons) for details.
:::

### Resetting All Registrations

Clear all registered types (useful for tests or app shutdown):


<<< @/../code_samples/lib/get_it/reset_example.dart#example

**Example:**


<<< @/../code_samples/lib/get_it/code_sample_14c31d5c_signature.dart

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


<<< @/../code_samples/lib/get_it/logger_example.dart#example

::: warning Use Sparingly
Allowing reassignment makes bugs harder to catch. Prefer using [scopes](/documentation/get_it/scopes) instead for temporary overrides (especially in tests).
:::

### Skip Double Registration (Testing Only)

In tests, silently ignore double registration instead of throwing an error:


<<< @/../code_samples/lib/get_it/logger_example_1.dart#example

**Only available in tests** - useful when multiple test files might register the same global services.