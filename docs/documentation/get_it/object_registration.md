---
title: Object Registration
---

# Object Registration

get_it offers different registration types that control when objects are created and how long they live. Choose the right type based on your needs.

## Quick Reference

| Type | When Created | How Many Instances | Lifetime | Best For |
|------|--------------|-------------------|----------|----------|
| <strong>Singleton</strong> | Immediately | One | Permanent | Fast to create, needed at startup |
| <strong>LazySingleton</strong> | First access | One | Permanent | Expensive to create, not always needed |
| <strong>Factory</strong> | Every `get()` | Many | Per request | Temporary objects, new state each time |
| <strong>Cached Factory</strong> | First access + after GC | Reused while in memory | Until garbage collected | Performance optimization |

---

## Singleton


<<< @/../code_samples/lib/get_it/t_example_signature.dart#example

You pass an instance of `T` that will <strong>always</strong> be returned on calls to `get<T>()`. The instance is created <strong>immediately</strong> when you register it.

<strong>Parameters:</strong>
- `instance` - The instance to register
- `instanceName` - Optional name to register multiple instances of the same type
- `signalsReady` - If true, this instance must signal when it's ready (used with async initialization)
- `dispose` - Optional cleanup function called when unregistering or resetting

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/configure_dependencies_example_4.dart#example

<strong>When to use Singleton:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Service needed at app startup</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Fast to create (no expensive initialization)</li>
</ul>
- ❌ Avoid for slow initialization (use LazySingleton instead)

---

## LazySingleton


<<< @/../code_samples/lib/get_it/function_example_signature.dart#example

You pass a factory function that returns an instance of `T`. The function is <strong>only called on first access</strong> to `get<T>()`. After that, the same instance is always returned.

<strong>Parameters:</strong>
- `factoryFunc` - Function that creates the instance
- `instanceName` - Optional name to register multiple instances of the same type
- `dispose` - Optional cleanup function called when unregistering or resetting
- `onCreated` - Optional callback invoked after the instance is created
- `useWeakReference` - If true, uses weak reference (allows garbage collection if not used)

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/configure_dependencies_example_5.dart#example

<strong>When to use LazySingleton:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Expensive-to-create services (database, HTTP client, etc.)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Services not always needed by every user</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ When you need to delay initialization</li>
</ul>

---

::: tip Concrete Types vs Interfaces
You can register either concrete classes or abstract interfaces. <strong>Register concrete classes directly</strong> unless you expect multiple implementations (e.g., production vs test, different providers). This keeps your code simpler and IDE navigation easier.
:::

## Factory


<<< @/../code_samples/lib/get_it/t_example_1_signature.dart#example

You pass a factory function that returns a <strong>NEW instance</strong> of `T` every time you call `get<T>()`. Unlike singletons, you get a different object each time.

<strong>Parameters:</strong>
- `factoryFunc` - Function that creates new instances
- `instanceName` - Optional name to register multiple factories of the same type

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/configure_dependencies_example_6.dart#example

<strong>When to use Factory:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Temporary objects (dialogs, forms, temporary data holders)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Objects that need fresh state each time</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Objects with short lifecycle</li>
</ul>
- ❌ Avoid for expensive-to-create objects used frequently (consider Cached Factory)

---

## Passing Parameters to Factories

In some cases, you need to pass values to factories when calling `get()`. get_it supports up to two parameters:


<<< @/../code_samples/lib/get_it/code_sample_30935190_signature.dart

<strong>Example with two parameters:</strong>


<<< @/../code_samples/lib/get_it/code_sample_42c18049.dart#example

<strong>Example with one parameter:</strong>

If you only need one parameter, pass `void` as the second type:


<<< @/../code_samples/lib/get_it/code_sample_8a892376.dart#example

<strong>Why two parameters?</strong>

Two parameters cover common scenarios like Flutter widgets that need both `BuildContext` and a data object, or services that need both configuration and runtime values.

::: warning Type Safety
Parameters are passed as `dynamic` but are checked at runtime to match the registered types (`P1`, `P2`). Type mismatches will throw an error.
:::

---

## Cached Factories

Cached factories are a <strong>performance optimization</strong> that sits between regular factories and singletons. They create a new instance on first call but cache it with a weak reference, returning the cached instance as long as it's still in memory (meaning some part of your app still holds a reference to it).


<<< @/../code_samples/lib/get_it/code_sample_773e24bb_signature.dart

<strong>How it works:</strong>
1. First call: Creates new instance (like factory)
2. Subsequent calls: Returns cached instance if still in memory (like singleton)
3. If garbage collected (no references held by your app): Creates new instance again (like factory)
4. For param versions: Also checks if parameters match before reusing

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/code_sample_135f1ef6.dart#example

<strong>With parameters:</strong>


<<< @/../code_samples/lib/get_it/code_sample_1a719c02.dart#example

<strong>When to use cached factories:</strong>

✅ <strong>Good use cases:</strong>
- <strong>Heavy objects recreated frequently</strong>: Parsers, formatters, calculators
- <strong>Memory-sensitive scenarios</strong>: Want automatic cleanup but prefer reuse
- <strong>Objects with expensive initialization</strong>: Database connections, file readers
- <strong>Short-to-medium lifetime objects</strong>: Active for a while but not forever

❌ <strong>Don't use when:</strong>
- Object should always be new (use regular factory)
- Object should live forever (use singleton/lazy singleton)
- Object holds critical state that must not be reused

<strong>Performance characteristics:</strong>

| Type | Creation Cost | Memory | Reuse |
|------|---------------|--------|-------|
| Factory | Every call | Low (immediate GC) | Never |
| <strong>Cached Factory</strong> | First call + after GC | Medium (weak ref) | While in memory |
| Lazy Singleton | First call only | High (permanent) | Always |

<strong>Comparison example:</strong>


<<< @/../code_samples/lib/get_it/json_parser.dart#example

::: tip Memory Management
Cached factories use <strong>weak references</strong>, meaning the cached instance can be garbage collected when no other part of your code holds a reference to it. This provides automatic memory management while still benefiting from reuse.
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


<<< @/../code_samples/lib/get_it/code_sample_3ddc0f1f_signature.dart

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/code_sample_1c1d87ec.dart#example

### Unregistering Services

You can remove a registered type from get_it, optionally calling a disposal function:


<<< @/../code_samples/lib/get_it/function_example_1_signature.dart#example

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/code_sample_91535ee8.dart#example

::: tip
The disposing function overrides any disposal function you provided during registration.
:::

### Resetting Lazy Singletons

Sometimes you want to reset a lazy singleton (force recreation on next access) without unregistering it:


<<< @/../code_samples/lib/get_it/function_example_2_signature.dart#example

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/code_sample_2ba32f12.dart#example

<strong>When to use:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Refresh cached data (after login/logout)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Testing - reset state between tests</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Development - reload configuration</li>
</ul>

::: tip Reset All Lazy Singletons
If you need to reset <strong>all</strong> lazy singletons at once (instead of one at a time), use `resetLazySingletons()` which supports scope control and batch operations. See [resetLazySingletons() documentation](/documentation/get_it/advanced#reset-all-lazy-singletons-resetlazysingletons) for details.
:::

### Resetting All Registrations

Clear all registered types (useful for tests or app shutdown):


<<< @/../code_samples/lib/get_it/reset_example_signature.dart#example

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/code_sample_14c31d5c.dart#example

::: warning Important
- Registrations are cleared in <strong>reverse order</strong> (last registered, first disposed)
- This is <strong>async</strong> - always `await` it
- Disposal functions registered during setup will be called (unless `dispose: false`)
:::

<strong>Use cases:</strong>
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

