---
title: Async Objects
prev:
  text: 'Object Registration'
  link: '/documentation/get_it/object_registration'
next:
  text: 'Scopes'
  link: '/documentation/get_it/scopes'
---

# Async Objects

## Overview

GetIt provides comprehensive support for asynchronous object creation and initialization. This is essential for objects that need to perform async operations during creation (database connections, network calls, file I/O) or that depend on other async objects being ready first.

<strong>Key capabilities:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#async-factories">Async Factories</a></strong> - Create new instances asynchronously on each access</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#async-singletons">Async Singletons</a></strong> - Create singletons with async initialization</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#dependency-management">Dependency Management</a></strong> - Automatically wait for dependencies before initialization</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#startup-orchestration">Startup Orchestration</a></strong> - Coordinate complex initialization sequences</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#manual-ready-signaling">Manual Signaling</a></strong> - Fine-grained control over ready state</li>
</ul>

## Quick Reference

### Async Registration Methods

| Method | When Created | How Many Instances | Lifetime | Best For |
|--------|--------------|-------------------|----------|----------|
| [<strong>registerFactoryAsync</strong>](#registerfactoryasync) | Every `getAsync()` | Many | Per request | Async operations on each access |
| [<strong>registerCachedFactoryAsync</strong>](#registercachedfactoryasync) | First access + after GC | Reused while in memory | Until garbage collected | Performance optimization for expensive async operations |
| [<strong>registerSingletonAsync</strong>](#registersingletonasync) | Immediately at registration | One | Permanent | App-level services with async setup |
| [<strong>registerLazySingletonAsync</strong>](#registerlazysingleton) | First `getAsync()` | One | Permanent | Expensive async services not always needed |
| [<strong>registerSingletonWithDependencies</strong>](#sync-singletons-with-dependencies) | After dependencies ready | One | Permanent | Services depending on other services |

## Async Factories

Async factories create a <strong>new instance on each call</strong> to `getAsync()` by executing an asynchronous factory function.

### registerFactoryAsync

Creates a new instance every time you call `getAsync<T>()`.

<<< @/../code_samples/lib/get_it/register_factory_async_signature.dart#example

<strong>Parameters:</strong>
- `factoryFunc` - Async function that creates and returns the instance
- `instanceName` - Optional name to register multiple factories of the same type

<strong>Example:</strong>



<<< @/../code_samples/lib/get_it/async_factory_basic.dart#example

### registerCachedFactoryAsync

Like `registerFactoryAsync`, but caches the instance with a weak reference. Returns the cached instance if it's still in memory; otherwise creates a new one.

<<< @/../code_samples/lib/get_it/register_cached_factory_async_signature.dart#example

<strong>Example:</strong>



<<< @/../code_samples/lib/get_it/async_cached_factory_example.dart#example

### Async Factories with Parameters

Like regular factories, async factories can accept up to two parameters.

<<< @/../code_samples/lib/get_it/async_factory_param_signatures.dart#example

<strong>Example:</strong>



<<< @/../code_samples/lib/get_it/async_factory_param_example.dart#example

## Async Singletons

Async singletons are created once with async initialization and live for the lifetime of the registration (until unregistered or scope is popped).

### registerSingletonAsync

Registers a singleton with an async factory function that's executed <strong>immediately</strong>. The singleton is marked as ready when the factory function completes (unless `signalsReady` is true).

<<< @/../code_samples/lib/get_it/register_singleton_async_signature.dart#example

<strong>Parameters:</strong>
- `factoryFunc` - Async function that creates the singleton instance
- `instanceName` - Optional name to register multiple singletons of the same type
- `dependsOn` - List of types this singleton depends on (waits for them to be ready first)
- `signalsReady` - If true, you must manually call `signalReady()` to mark as ready
- `dispose` - Optional cleanup function called when unregistering or resetting
- `onCreated` - Optional callback invoked after the instance is created

<strong>Example:</strong>



<<< @/../code_samples/lib/get_it/async_singleton_example.dart#example

::: details Common Mistake: Using signalsReady with registerSingletonAsync
<strong>Most of the time, you DON'T need `signalsReady: true` with `registerSingletonAsync`.</strong>

The async factory completion <strong>automatically signals ready</strong> when it returns. Only use `signalsReady: true` if you need multi-stage initialization where the factory completes but you have additional async work before the instance is truly ready.

<strong>Common error pattern:</strong>

<<< @/../code_samples/lib/get_it/signal_ready_error_example.dart#example

<strong>Why it fails:</strong> You can't call `signalReady(instance)` from inside the factory because the instance isn't registered yet.

<strong>Correct alternatives:</strong>

<strong>Option 1 - Let async factory auto-signal (recommended):</strong>

<<< @/../code_samples/lib/get_it/signal_ready_correct_option1.dart#example

<strong>Option 2 - Use registerSingleton for post-registration signaling:</strong>

<<< @/../code_samples/lib/get_it/signal_ready_correct_option2.dart#example

<strong>Option 3 - Implement WillSignalReady interface:</strong>

<<< @/../code_samples/lib/get_it/signal_ready_correct_option3.dart#example

See [Manual Ready Signaling](#manual-ready-signaling) for more details.
:::

### registerLazySingletonAsync

Registers a singleton with an async factory function that's executed <strong>on first access</strong> (when you call `getAsync<T>()` for the first time).

<<< @/../code_samples/lib/get_it/register_lazy_singleton_async_signature.dart#example

<strong>Parameters:</strong>
- `factoryFunc` - Async function that creates the singleton instance
- `instanceName` - Optional name to register multiple singletons of the same type
- `dispose` - Optional cleanup function called when unregistering or resetting
- `onCreated` - Optional callback invoked after the instance is created
- `useWeakReference` - If true, uses weak reference (allows garbage collection if not used)

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/async_objects_2642b731.dart#example


::: warning Lazy Async Singletons and allReady()
`registerLazySingletonAsync` does <strong>not</strong> block `allReady()` because the factory function is not called until first access. However, once accessed, you can use `isReady()` to wait for its completion.
:::

## Accessing Async Objects

::: tip Async Objects Become Normal After Initialization
Once an async singleton has completed initialization (you've awaited `allReady()` or `isReady<T>()`), you can access it like a regular singleton using `get<T>()` instead of `getAsync<T>()`. The async methods are only needed during the initialization phase or when accessing async factories.

```dart
// During startup - wait for initialization
await getIt.allReady();

// After ready - access normally (no await needed)
final database = getIt<Database>();  // Not getAsync!
final apiClient = getIt<ApiClient>();
```
:::

### getAsync()

Retrieves an instance created by an async factory or waits for an async singleton to complete initialization.

<<< @/../code_samples/lib/get_it/async_objects_4c3dc27e_signature.dart#example


<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/async_objects_5324c9ca_signature.dart#example


::: tip Getting Multiple Async Instances
If you need to retrieve multiple async registrations of the same type, see the [Multiple Registrations](/documentation/get_it/multiple_registrations#async-version) chapter for `getAllAsync()` documentation.
:::

## Dependency Management

### Using dependsOn

The `dependsOn` parameter ensures initialization order. When you register a singleton with `dependsOn`, its factory function won't execute until all listed dependencies have signaled ready.

<strong>Example - Sequential initialization:</strong>

<<< @/../code_samples/lib/get_it/async_objects_ae083a64.dart#example


## Sync Singletons with Dependencies

Sometimes you have a regular (sync) singleton that depends on other async singletons being ready first. Use `registerSingletonWithDependencies` for this pattern.

<<< @/../code_samples/lib/get_it/async_objects_e093effa_signature.dart#example


<strong>Parameters:</strong>
- `factoryFunc` - <strong>Sync</strong> function that creates the singleton instance (called after dependencies are ready)
- `instanceName` - Optional name to register multiple singletons of the same type
- `dependsOn` - List of types this singleton depends on (waits for them to be ready first)
- `signalsReady` - If true, you must manually call `signalReady()` to mark as ready
- `dispose` - Optional cleanup function called when unregistering or resetting

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/async_objects_fc40829b.dart#example


## Startup Orchestration

GetIt provides several functions to coordinate async initialization and wait for services to be ready.

### allReady()

Returns a `Future<void>` that completes when <strong>all</strong> async singletons and singletons with `signalsReady` have completed their initialization.

<<< @/../code_samples/lib/get_it/async_objects_93c1b617_signature.dart#example


<strong>Parameters:</strong>
- `timeout` - Optional timeout; throws `WaitingTimeOutException` if not ready in time
- `ignorePendingAsyncCreation` - If true, only waits for manual signals, ignores async singletons

<strong>Example with FutureBuilder:</strong>

<<< @/../code_samples/lib/get_it/async_objects_bbdb298c.dart#example


<strong>Example with timeout:</strong>

<<< @/../code_samples/lib/get_it/async_objects_864b4c27.dart#example


<strong>Calling allReady() multiple times:</strong>

You can call `allReady()` multiple times. After the first `allReady()` completes, if you register new async singletons, you can await `allReady()` again to wait for the new ones.

<<< @/../code_samples/lib/get_it/async_objects_28d751fd.dart#example


This pattern is especially useful with scopes where each scope needs its own initialization:

<<< @/../code_samples/lib/get_it/async_objects_d0a62ccd.dart#example


### isReady()

Returns a `Future<void>` that completes when a <strong>specific</strong> singleton is ready.

<<< @/../code_samples/lib/get_it/async_objects_c603af1e_signature.dart#example


<strong>Parameters:</strong>
- `T` - Type of the singleton to wait for
- `instance` - Alternatively, wait for a specific instance object
- `instanceName` - Wait for named registration
- `timeout` - Optional timeout; throws `WaitingTimeOutException` if not ready in time
- `callee` - Optional parameter for debugging (helps identify who's waiting)

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/async_objects_21920847.dart#example


### isReadySync()

Checks if a singleton is ready <strong>without waiting</strong> (returns immediately).

<<< @/../code_samples/lib/get_it/async_objects_7d06e64a_signature.dart#example


<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/async_objects_96ff9c4e.dart#example


### allReadySync()

Checks if <strong>all</strong> async singletons are ready without waiting.

<<< @/../code_samples/lib/get_it/async_objects_90ee78c4_signature.dart#example


<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/async_objects_4ef84c96.dart#example


### Named Dependencies with InitDependency

If you have named registrations, use `InitDependency` to specify both type and instance name.

<<< @/../code_samples/lib/get_it/async_objects_55d54ef7.dart#example


## Manual Ready Signaling

Sometimes you need more control over when a singleton signals it's ready. This is useful when initialization involves multiple steps or callbacks.

### Using signalsReady Parameter

When you set `signalsReady: true` during registration, GetIt won't automatically mark the singleton as ready. You must manually call `signalReady()`.

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/async_objects_f2965023.dart#example


### Using WillSignalReady Interface

Instead of passing `signalsReady: true`, implement the `WillSignalReady` interface. GetIt automatically detects this and waits for manual signaling.

<<< @/../code_samples/lib/get_it/async_objects_62e38c5b.dart#example


### signalReady()

Manually signals that a singleton is ready.

<<< @/../code_samples/lib/get_it/async_objects_af1df8a2_signature.dart#example


<strong>Parameters:</strong>
- `instance` - The instance that's ready (passing `null` is legacy and not recommended)

<strong>Example:</strong>


<<< @/../code_samples/lib/get_it/async_objects_174d24d3.dart#example


::: tip Legacy Feature
`signalReady(null)` (global ready signal without an instance) is a legacy feature from earlier versions of GetIt. It's recommended to use async registrations (`registerSingletonAsync`, etc.) or instance-specific signaling instead. The global signal approach is less clear about what's being initialized and doesn't integrate well with dependency management.

<strong>Note:</strong> The global `signalReady(null)` will throw an error if you have any async registrations or instances with `signalsReady: true` that haven't signaled yet. Instance-specific signaling works fine alongside async registrations.
:::

## Best Practices

::: details 1. Prefer registerSingletonAsync for App Initialization

For services needed at app startup, use `registerSingletonAsync` (not lazy) so they start initializing immediately.

<<< @/../code_samples/lib/get_it/async_objects_6e8c86b1.dart#example
:::

::: details 2. Use dependsOn to Express Dependencies

Let GetIt manage initialization order instead of manually orchestrating with `isReady()`.

<<< @/../code_samples/lib/get_it/async_objects_a3cbd191.dart#example
:::

::: details 3. Use FutureBuilder for Splash Screens

Display a loading screen while services initialize.

<<< @/../code_samples/lib/get_it/async_objects_d275974b.dart#example
:::

::: details 4. Always Set Timeouts for allReady()

Prevent your app from hanging indefinitely if initialization fails.

<<< @/../code_samples/lib/get_it/async_objects_a6be16da.dart#example
:::


## Common Patterns

### Pattern 1: Layered Initialization

<<< @/../code_samples/lib/get_it/async_objects_65faea06.dart#example

::: details Pattern 2: Conditional Initialization

<<< @/../code_samples/lib/get_it/async_objects_80efa70c.dart#example
:::

::: details Pattern 3: Progress Tracking

<<< @/../code_samples/lib/get_it/async_objects_3be0569c.dart#example
:::

::: details Pattern 4: Retry on Failure

<<< @/../code_samples/lib/get_it/async_objects_b64e81ba.dart#example
:::


## Further Reading

- [Detailed blog post on async factories and startup orchestration](https://blog.burkharts.net/lets-get-this-party-started-startup-orchestration-with-getit)
- [Scopes Documentation](/documentation/get_it/scopes) - Async initialization within scopes
- [Testing Documentation](/documentation/get_it/testing) - Mocking async services in tests
