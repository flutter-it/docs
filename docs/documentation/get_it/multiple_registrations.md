---
title: Multiple Registrations
---

# Multiple Registrations

get_it provides two different approaches for registering multiple instances of the same type, each suited to different use cases.

## Two Approaches Overview

### Approach 1: Named Registration (Always Available)

Register multiple instances of the same type by giving each a unique name. This is **always available** without any configuration.


<<< @/../code_samples/lib/get_it/api_client_example_1.dart#example

**Best for:**
- ✅ Different configurations of the same type (dev/prod endpoints)
- ✅ Known set of instances accessed individually
- ✅ Feature flags (old/new implementation)

### Approach 2: Multiple Unnamed Registrations (Requires Opt-In)

Register multiple instances without names and retrieve them all at once with `getAll<T>()`. Requires explicit opt-in.


<<< @/../code_samples/lib/get_it/plugin.dart

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


<<< @/../code_samples/lib/get_it/rest_service_example.dart#example

### Works with All Registration Types

Named registration works with **every** registration method:


<<< @/../code_samples/lib/get_it/logger_example_2.dart#example

### Named Registration Use Cases

**Environment-specific configurations:**

<<< @/../code_samples/lib/get_it/setup_for_environment_example.dart#example

**Feature flags:**

<<< @/../code_samples/lib/get_it/setup_payment_processor_example.dart#example

**Multiple database connections:**

<<< @/../code_samples/lib/get_it/code_sample_41a16b51.dart#example

---

## Multiple Unnamed Registrations

For plugin systems, observers, and middleware where you want to retrieve **all** instances at once without knowing their names.

### Enabling Multiple Registrations

By default, get_it **prevents** registering the same type multiple times (without different instance names) to catch accidental duplicate registrations, which are usually bugs.

To enable multiple registrations of the same type, you must explicitly opt-in:


<<< @/../code_samples/lib/get_it/code_sample_980d7414.dart

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


<<< @/../code_samples/lib/get_it/plugin_1.dart

::: tip Unnamed + Named Together
All registrations coexist - both unnamed and named. `getAll<T>()` returns all of them.
:::

---

## Retrieving Instances

### Using `get<T>()` - Returns First Only

When multiple unnamed registrations exist, `get<T>()` returns **only the first** registered instance:


<<< @/../code_samples/lib/get_it/plugin_2.dart

::: tip When to use get()
Use `get<T>()` when you want the "default" or "primary" implementation. Register it first!
:::

### Using `getAll<T>()` - Returns All

To retrieve **all** registered instances (both unnamed and named), use `getAll<T>()`:


<<< @/../code_samples/lib/get_it/plugin_example.dart#example

::: tip Alternative: findAll() for Type-Based Discovery
While `getAll<T>()` retrieves instances you've explicitly registered multiple times, `findAll<T>()` finds instances by **type matching** - no multiple registration setup needed. See [Related: Finding Instances by Type](#related-finding-instances-by-type) below for when to use each approach.
:::

---

## Scope Behavior

`getAll<T>()` provides three scope control options:

### Current Scope Only (Default)

By default, searches only the **current scope**:


<<< @/../code_samples/lib/get_it/plugin_3.dart

### All Scopes

To retrieve from **all scopes**, use `fromAllScopes: true`:


<<< @/../code_samples/lib/get_it/code_sample_07af7c81.dart

### Specific Named Scope

To search only a **specific named scope**, use `onlyInScope`:


<<< @/../code_samples/lib/get_it/code_sample_e4fa6049.dart

::: tip Parameter Precedence
If both `onlyInScope` and `fromAllScopes` are provided, `onlyInScope` takes precedence.
:::

See [Scopes documentation](/documentation/get_it/scopes) for more details on scope behavior.

---

## Async Version

If you have async registrations, use `getAllAsync<T>()` which waits for all registrations to complete:


<<< @/../code_samples/lib/get_it/code_sample_49d4b664.dart

**With scope control:**

`getAllAsync()` supports the same scope parameters as `getAll()`:


<<< @/../code_samples/lib/get_it/code_sample_2cd2b1b0.dart#example

---

## Common Patterns

### Plugin System


<<< @/../code_samples/lib/get_it/configure_dependencies_example_7.dart#example

### Event Handlers / Observers


<<< @/../code_samples/lib/get_it/on_app_started_example.dart#example

### Middleware / Validator Chains


<<< @/../code_samples/lib/get_it/setup_middleware_example.dart#example

### Combining Unnamed and Named Registrations


<<< @/../code_samples/lib/get_it/setup_themes_example.dart#example

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


<<< @/../code_samples/lib/get_it/plugin_4.dart

---

## How It Works

This section explains the internal implementation details. Understanding this is optional for using the feature.

### Data Structure

get_it maintains two separate lists for each type:


<<< @/../code_samples/lib/get_it/__type_registration_example.dart#example

When you call:
- `getIt.registerSingleton<T>(instance)` → adds to `registrations` list
- `getIt.registerSingleton<T>(instance, instanceName: 'name')` → adds to `namedRegistrations` map

### Why `get<T>()` Returns First Only

The `get<T>()` method retrieves instances using this logic:


<<< @/../code_samples/lib/get_it/code_sample_ba79068a.dart#example

This is why `get<T>()` only returns the first unnamed registration, not all of them.

### Why `getAll<T>()` Returns All

The `getAll<T>()` method combines both lists:


<<< @/../code_samples/lib/get_it/code_sample_b1321fa0.dart#example

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


<<< @/../code_samples/lib/get_it/i_logger.dart

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
