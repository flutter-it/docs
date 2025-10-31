---
title: Multiple Registrations
---

# Multiple Registrations

get_it provides two different approaches for registering multiple instances of the same type, each suited to different use cases.

## Two Approaches Overview

### Approach 1: Named Registration (Always Available)

Register multiple instances of the same type by giving each a unique name. This is <strong>always available</strong> without any configuration.


<<< @/../code_samples/lib/get_it/api_client_example_1.dart#example

<strong>Best for:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Different configurations of the same type (dev/prod endpoints)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Known set of instances accessed individually</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Feature flags (old/new implementation)</li>
</ul>

### Approach 2: Multiple Unnamed Registrations (Requires Opt-In)

Register multiple instances without names and retrieve them all at once with `getAll<T>()`. Requires explicit opt-in.


<<< @/../code_samples/lib/get_it/plugin.dart#example

<strong>Best for:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Plugin systems (modules can add implementations)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Observer/event handler patterns</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Middleware chains</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ When you don't need to access instances individually</li>
</ul>

::: tip You Can Combine Both Approaches
Named and unnamed registrations can coexist. `getAll<T>()` returns both unnamed and named instances.
:::

---

## Named Registration

All registration functions accept an optional `instanceName` parameter. Each name must be <strong>unique per type</strong>.

### Basic Usage


<<< @/../code_samples/lib/get_it/rest_service_example.dart#example

### Works with All Registration Types

Named registration works with <strong>every</strong> registration method:


<<< @/../code_samples/lib/get_it/logger_example_2.dart#example

### Named Registration Use Cases

<strong>Multiple database connections:</strong>

<<< @/../code_samples/lib/get_it/code_sample_41a16b51.dart#example

---

## Multiple Unnamed Registrations

For plugin systems, observers, and middleware where you want to retrieve <strong>all</strong> instances at once without knowing their names.

### Enabling Multiple Registrations

By default, get_it <strong>prevents</strong> registering the same type multiple times (without different instance names) to catch accidental duplicate registrations, which are usually bugs.

To enable multiple registrations of the same type, you must explicitly opt-in:


<<< @/../code_samples/lib/get_it/code_sample_980d7414.dart#example

<strong>Why explicit opt-in?</strong>
- <strong>Prevents bugs</strong>: Accidentally registering the same type twice is usually an error
- <strong>Breaking change protection</strong>: Existing code won't break from unintended behavior changes
- <strong>Clear intent</strong>: Makes it obvious that you're using the multiple registration pattern
- <strong>Type safety</strong>: Forces you to be aware that `get<T>()` behavior changes

::: warning Important
Once enabled, this setting applies <strong>globally</strong> to the entire get_it instance. You cannot enable it for only specific types.

<strong>This feature cannot be disabled once enabled.</strong> Even calling `getIt.reset()` will clear all registrations but keep this feature enabled. This is intentional to prevent accidental breaking changes in your application.
:::

---

## Registering Multiple Implementations

After calling `enableRegisteringMultipleInstancesOfOneType()`, you can register the same type multiple times:


<<< @/../code_samples/lib/get_it/plugin_1.dart#example

::: tip Unnamed + Named Together
All registrations coexist - both unnamed and named. `getAll<T>()` returns all of them.
:::

---

## Retrieving Instances

### Using `get<T>()` - Returns First Only

When multiple unnamed registrations exist, `get<T>()` returns <strong>only the first</strong> registered instance:


<<< @/../code_samples/lib/get_it/plugin_2.dart#example

::: tip When to use get()
Use `get<T>()` when you want the "default" or "primary" implementation. Register it first!
:::

### Using `getAll<T>()` - Returns All

To retrieve <strong>all</strong> registered instances (both unnamed and named), use `getAll<T>()`:


<<< @/../code_samples/lib/get_it/plugin_example.dart#example

::: tip Alternative: findAll() for Type-Based Discovery
While `getAll<T>()` retrieves instances you've explicitly registered multiple times, `findAll<T>()` finds instances by <strong>type matching</strong> - no multiple registration setup needed. See [Related: Finding Instances by Type](#related-finding-instances-by-type) below for when to use each approach.
:::

---

## Scope Behavior

`getAll<T>()` provides three scope control options:

### Current Scope Only (Default)

By default, searches only the <strong>current scope</strong>:


<<< @/../code_samples/lib/get_it/plugin_3.dart#example

::: details All Scopes

To retrieve from <strong>all scopes</strong>, use `fromAllScopes: true`:

<<< @/../code_samples/lib/get_it/code_sample_07af7c81.dart#example
:::

::: details Specific Named Scope

To search only a <strong>specific named scope</strong>, use `onlyInScope`:

<<< @/../code_samples/lib/get_it/code_sample_e4fa6049.dart#example
:::

::: tip Parameter Precedence
If both `onlyInScope` and `fromAllScopes` are provided, `onlyInScope` takes precedence.
:::

See [Scopes documentation](/documentation/get_it/scopes) for more details on scope behavior.

---

## Async Version

If you have async registrations, use `getAllAsync<T>()` which waits for all registrations to complete:


<<< @/../code_samples/lib/get_it/code_sample_49d4b664.dart#example

::: details With scope control

`getAllAsync()` supports the same scope parameters as `getAll()`:

<<< @/../code_samples/lib/get_it/code_sample_2cd2b1b0.dart#example
:::

---

## Common Patterns

### Plugin System


<<< @/../code_samples/lib/get_it/configure_dependencies_example_7.dart#example

::: details Event Handlers / Observers

<<< @/../code_samples/lib/get_it/on_app_started_example.dart#example
:::

::: details Middleware / Validator Chains

<<< @/../code_samples/lib/get_it/setup_middleware_example.dart#example
:::

::: details Combining Unnamed and Named Registrations

<<< @/../code_samples/lib/get_it/setup_themes_example.dart#example
:::

---

## Best Practices

### ✅ Do

- <strong>Enable at app startup</strong> before any registrations
- <strong>Register most important/default implementation first</strong> (for `get<T>()`)
- <strong>Use abstract base classes</strong> as registration types
- <strong>Document order dependencies</strong> if middleware/observer order matters
- <strong>Use named registrations</strong> for special-purpose implementations that also need individual access

### ❌ Don't

- <strong>Don't enable mid-application</strong> - do it during initialization
- <strong>Don't rely on `get<T>()`</strong> to retrieve all implementations - use `getAll<T>()`
- <strong>Don't assume registration order</strong> unless you control it
- <strong>Don't mix this pattern with `allowReassignment`</strong> - they serve different purposes

---

## Choosing the Right Approach

| Feature | Named Registration | Multiple Unnamed Registration |
|---------|-------------------|------------------------------|
| <strong>Enable required</strong> | No | Yes (`enableRegisteringMultipleInstancesOfOneType()`) |
| <strong>Access pattern</strong> | Individual by name: `get<T>(instanceName: 'name')` | All at once: `getAll<T>()` returns all |
| <strong>Get one</strong> | `get<T>(instanceName: 'name')` | `get<T>()` returns first |
| <strong>Use case</strong> | Different configurations, feature flags | Plugin systems, observers, middleware |
| <strong>Module independence</strong> | Must know names upfront | Modules can add implementations without knowing about others |
| <strong>Access method</strong> | String-based names | Type-based retrieval |

<strong>When to use named registration:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Different configurations (dev/prod API endpoints)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Feature flags (old/new implementation)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Known set of instances accessed individually</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Multiple database connections</li>
</ul>

<strong>When to use multiple unnamed registration:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Modular plugin architecture</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Observer/event handler pattern</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Middleware chains</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Validators/processors pipeline</li>
</ul>

<strong>Combining both approaches:</strong>

Named and unnamed registrations work together seamlessly:


<<< @/../code_samples/lib/get_it/plugin_4.dart#example

---

::: details How It Works

This section explains the internal implementation details. Understanding this is optional for using the feature.

**Data Structure**

get_it maintains two separate lists for each type:

<<< @/../code_samples/lib/get_it/__type_registration_example.dart#example

When you call:
- `getIt.registerSingleton<T>(instance)` → adds to `registrations` list
- `getIt.registerSingleton<T>(instance, instanceName: 'name')` → adds to `namedRegistrations` map

**Why `get<T>()` Returns First Only**

The `get<T>()` method retrieves instances using this logic:

<<< @/../code_samples/lib/get_it/code_sample_ba79068a.dart#example

This is why `get<T>()` only returns the first unnamed registration, not all of them.

**Why `getAll<T>()` Returns All**

The `getAll<T>()` method combines both lists:

<<< @/../code_samples/lib/get_it/code_sample_b1321fa0.dart#example

This returns every registered instance, regardless of whether it has a name or not.

**Order Preservation**

- <strong>Unnamed registrations</strong>: Preserved in registration order (`List`)
- <strong>Named registrations</strong>: Preserved in registration order (`LinkedHashMap`)
- <strong>`getAll()` order</strong>: Unnamed first (in order), then named (in order)

This is important for middleware/observer patterns where execution order matters.
:::

---

## API Reference

### Enable

| Method | Description |
|--------|-------------|
| `enableRegisteringMultipleInstancesOfOneType()` | Enables multiple unnamed registrations of same type |

### Retrieve

| Method | Description |
|--------|-------------|
| `get<T>()` | Returns <strong>first</strong> unnamed registration |
| `getAll<T>({fromAllScopes})` | Returns <strong>all</strong> registrations (unnamed + named) |
| `getAllAsync<T>({fromAllScopes})` | Async version, waits for async registrations |

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `fromAllScopes` | `bool` | `false` | If `true`, searches all scopes instead of current only |
| `onlyInScope` | `String?` | `null` | If provided, searches only the named scope (takes precedence over `fromAllScopes`) |

---

## Related: Finding Instances by Type

While `getAll<T>()` retrieves instances you've explicitly registered multiple times, `findAll<T>()` offers a different approach: finding instances by <strong>type matching</strong> criteria.

<strong>Key differences:</strong>

| Feature | `getAll<T>()` | `findAll<T>()` |
|---------|---------------|----------------|
| <strong>Purpose</strong> | Retrieve multiple explicit registrations | Find instances by type matching |
| <strong>Requires</strong> | `enableRegisteringMultipleInstancesOfOneType()` | No special setup |
| <strong>Matches</strong> | Exact type T (with optional names) | T and subtypes (configurable) |
| <strong>Performance</strong> | O(1) map lookup | O(n) linear search |
| <strong>Use case</strong> | Plugin systems, known multiple registrations | Finding implementations, testing, introspection |

<strong>Example comparison:</strong>


<<< @/../code_samples/lib/get_it/i_logger.dart#example

::: tip When to Use Each
- Use <strong>`getAll()`</strong> when you explicitly want multiple instances of the same type and will retrieve them all together
- Use <strong>`findAll()`</strong> when you want to discover instances by type relationship, especially for testing or debugging
:::

See [findAll() documentation](/documentation/get_it/advanced#find-all-instances-by-type-findall-t) for comprehensive details on type matching, scope control, and advanced filtering options.

---

## See Also

- [Scopes](/documentation/get_it/scopes) - Hierarchical lifecycle management and scope-specific registrations
- [Object Registration](/documentation/get_it/object_registration) - Different registration types (factories, singletons, etc.)
- [Async Objects](/documentation/get_it/async_objects) - Using `getAllAsync()` with async registrations
- [Advanced - findAll()](/documentation/get_it/advanced#find-all-instances-by-type-findall-t) - Type-based instance discovery
