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


<<< @/../code_samples/lib/get_it/disposable_example.dart#example

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


<<< @/../code_samples/lib/get_it/release_instance_example_signature.dart#example

**How it works:**
1. First call: Creates instance, registers, sets reference count to 1
2. Subsequent calls: Returns existing instance, increments counter
3. `releaseInstance`: Decrements counter
4. When counter reaches 0: Unregisters and disposes

### Recursive Navigation Example


<<< @/../code_samples/lib/get_it/detail_service_example.dart#example

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


<<< @/../code_samples/lib/get_it/code_sample_2fd612f7.dart

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


<<< @/../code_samples/lib/get_it/code_sample_fdab4a35.dart#example

**Example:**


<<< @/../code_samples/lib/get_it/my_widget_example.dart#example

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


<<< @/../code_samples/lib/get_it/code_sample_32653109.dart#example

**Example:**


<<< @/../code_samples/lib/get_it/user_example.dart#example

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


<<< @/../code_samples/lib/get_it/code_sample_3c73f756.dart#example

**Example:**


<<< @/../code_samples/lib/get_it/code_sample_aa613a22.dart

**Use cases:**
- Performance monitoring (track which services have been initialized)
- Conditional initialization (pre-warm services if not created)
- Testing lazy loading behavior
- Debugging initialization order issues

**Example - Pre-warming:**


<<< @/../code_samples/lib/get_it/pre_warm_critical_services_example.dart#example

---

### Reset All Lazy Singletons: `resetLazySingletons()`

Reset all instantiated lazy singletons at once. This clears their instances so they'll be recreated on next access.


<<< @/../code_samples/lib/get_it/reset_lazy_singletons_example_signature.dart#example

**Parameters:**
- `dispose` - If true (default), calls dispose functions before resetting
- `inAllScopes` - If true, resets lazy singletons across all scopes
- `onlyInScope` - Reset only in the named scope (takes precedence over `inAllScopes`)

**Example - Basic usage:**


<<< @/../code_samples/lib/get_it/code_sample_599505d1.dart

**Example - With scopes:**


<<< @/../code_samples/lib/get_it/code_sample_322e6eda.dart

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


<<< @/../code_samples/lib/get_it/code_sample_12625bd9.dart#example

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


<<< @/../code_samples/lib/get_it/write_example.dart#example

**Example - Include lazy singletons:**


<<< @/../code_samples/lib/get_it/code_sample_4c9aa485.dart#example

**Example - Include factories:**


<<< @/../code_samples/lib/get_it/i_output_example.dart#example

**Example - Exact type matching:**


<<< @/../code_samples/lib/get_it/base_logger_example.dart#example

**Example - Instance vs Registration Type:**


<<< @/../code_samples/lib/get_it/file_output_example.dart#example

**Example - Scope control:**


<<< @/../code_samples/lib/get_it/i_output.dart

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


<<< @/../code_samples/lib/get_it/code_sample_f4194899.dart#example

**Example:**


<<< @/../code_samples/lib/get_it/code_sample_be97525b.dart#example

**Use cases:**
- Building tools/debugging utilities on top of GetIt
- Runtime dependency graph visualization
- Advanced lifecycle management
- Debugging registration issues

---

### Accessing an object inside GetIt by a runtime type

In rare occasions you might be faced with the problem that you don't know the type that you want to retrieve from GetIt at compile time which means you can't pass it as a generic parameter. For this the `get` functions have an optional `type` parameter


<<< @/../code_samples/lib/get_it/code_sample_caa57cf3.dart

Be careful that the receiving variable has the correct type and don't pass `type` and a generic parameter.

### More than one instance of GetIt

While not recommended, you can create your own independent instance of `GetIt` if you don't want to share your locator with some
other package or because the physics of your planet demands it :-)


<<< @/../code_samples/lib/get_it/code_sample_e7453700_signature.dart

This new instance does not share any registrations with the singleton instance.
