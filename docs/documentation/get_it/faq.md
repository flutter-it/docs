---
title: FAQ
---

# FAQ

## Why do we need get_it?

::: details Click to see answer

**Question:** I do not understand the benefits of using get_it or InheritedWidget.

I've looked into why we need InheritedWidget, this solves the data passing problem. However for that we have a state management system so we do not need InheritedWidget at all.

I've looked into get_it and from my understanding if we are already using a state management system the only benefit we would have is the ability to encapsulate the services/methods related to a chunk of widgets into one place. (dependency injection)

For example if we have a map and a locate me button then they could share the same _locateMe service.
For this we would create an abstract class that defines the _locateMe method and connect it with the dependency injection using a locator.registerLazySingleton.

But what is the point? I can just create a methods.dart file with the locateMe method without any classes, we can just put the method into the methods.dart which is faster and easier and we can access it from anywhere.
I am not sure how dart internally works, what makes sense for me is that registerLazySingleton would remove the _locateMe method from memory after I use the _locateMe method. And if we put the locateMe method inside a normal .dart file without classes or anything else it will be always in memory hence less performant.
Is my assumption true? Is there something I am missing?

---

**Answer:** Let me put it this way, you are not completely wrong. You definitely can use just global functions and global variables to make state accessible to your UI.

The real power of dependency injection comes from using abstract interface classes when registering the types. This allows you to switch implementations at one time without changing any other part of your code.
This is especially helpful when it comes to write unit tests or UI tests so that you can easily inject mock objects.

Another aspect is scoping of the objects. Inherited widgets as well as get_it allow you to override registered objects based on a current scope. For inherited widgets this scope is defined by your current position in the widget tree, in get_it you can push and pop registrations scopes independent of the widget tree.

Scopes allow you to override existing behaviour or to easily manage the lifetime and disposal of objects.

The general idea of any dependency injection system is that you have defined point in your code where you have all your setup and configuration.
Furthermore GetIt helps you initialise your synchronous business objects while automatically care for dependencies between such objects.

You wrote your already using some sort of state management solution. Which probably means that the solution already offer some sort of object location. In this case you probably won't need get_it.
Together with the [watch_it](/documentation/watch_it/watch_it) however you don't need any other state management solution if you already use get_it.
:::

## Object/factory with type X is not registered - how to fix?

::: details Click to see answer

**Error message:** `GetIt: Object/factory with type X is not registered inside GetIt. (Did you forget to register it?)`

This error means you're trying to access a type that hasn't been registered yet. Common causes:

**1. Forgot to register the type**

<<< @/../code_samples/lib/get_it/code_sample_383c0a19.dart#example

**Fix:** Register before accessing:

<<< @/../code_samples/lib/get_it/main_example_4.dart#example

**2. Wrong order - accessing before registration**

<<< @/../code_samples/lib/get_it/main_example_5.dart#example

**Fix:** Register first, use later:

<<< @/../code_samples/lib/get_it/main_example_6.dart#example

**3. Using parentheses on GetIt.instance**

<<< @/../code_samples/lib/get_it/code_sample_6f9d6d83.dart#example

**Fix:** No parentheses - it's a getter, not a function:

<<< @/../code_samples/lib/get_it/code_sample_0da49c29.dart#example

**4. Type mismatch - registered concrete type but accessing interface**

<<< @/../code_samples/lib/get_it/code_sample_6c897c2f.dart#example

**Fix:** Register with the interface type:

<<< @/../code_samples/lib/get_it/code_sample_3b6bf5d9.dart#example

**5. Accessing in wrong scope**
If you registered in a scope that has been popped, the service is no longer available.

**Debug tips:**
- Check `getIt.isRegistered<MyService>()` to verify registration
- Use `getIt.allReady()` if you have async registrations
- Ensure registration happens before `runApp()` in main()
:::

## Object/factory with type X is already registered - how to fix?

::: details Click to see answer

This error means you're trying to register the same type twice. Common causes:

**1. Calling registration function multiple times**

<<< @/../code_samples/lib/get_it/main_example_7.dart#example

**Fix:** Only call once:

<<< @/../code_samples/lib/get_it/main_example_8.dart#example

**2. Registering inside build methods (hot reload issue)**
If you register services inside `build()` or `initState()`, hot reload will call it again.

❌ **Wrong:**

<<< @/../code_samples/lib/get_it/my_app_example.dart#example

✅ **Fix:** Move registration to `main()` before `runApp()`:

<<< @/../code_samples/lib/get_it/main_example_9.dart#example

**3. Tests re-registering services**
Each test tries to register, but setup from previous test didn't clean up.

**Fix:** Use scopes in tests (see "How do I test code that uses get_it?" FAQ below).

**4. Multiple registrations with different instance names**
If you want multiple instances of the same type:

<<< @/../code_samples/lib/get_it/api_client_2.dart

Or use unnamed multiple registrations (see [Multiple Registrations documentation](/documentation/get_it/multiple_registrations)).

**Best practice:**
- Register once at app startup in main()
- Use scopes for login/logout (not unregister/register)
- Use scopes in tests (not reset/re-register)
:::

## Should I use Singleton or LazySingleton?

::: details Click to see answer

**registerSingleton()** creates the instance immediately when you call the registration method. Use this when:
- The object is needed at app startup
- Initialization is fast and non-blocking
- You want to fail fast if construction fails

**registerLazySingleton()** delays creation until the first call to `get()`. Use this when:
- The object might not be needed in every app session
- Initialization is expensive (heavy computation, large data loading)
- You want faster app startup time

**Example:**

<<< @/../code_samples/lib/get_it/logger.dart

**Best practice:** Start with `registerLazySingleton()` by default. Only use `registerSingleton()` when you specifically need immediate initialization.
:::

## What's the difference between Factory and Singleton?

::: details Click to see answer

**Factory** (`registerFactory()`) creates a **new instance** every time you call `get<T>()`:

<<< @/../code_samples/lib/get_it/shopping_cart_example.dart#example

**Singleton** (`registerSingleton()` / `registerLazySingleton()`) returns the **same instance** every time:

<<< @/../code_samples/lib/get_it/code_sample_c1d7f5e3.dart#example

**When to use Factory:**
- Short-lived objects (view models for dialogs, temporary calculators)
- Objects with per-call state (request handlers, data processors)
- You need multiple independent instances

**When to use Singleton:**
- App-wide services (API client, database, auth service)
- Expensive-to-create objects you want to reuse
- Shared state across your app

**Pro tip:** Most services should be Singletons. Factories are less common - use them only when you specifically need multiple instances.
:::

## How do I handle circular dependencies?

::: details Click to see answer

Circular dependencies indicate a design problem. Here are solutions:

**1. Use an interface/abstraction (Best)**

<<< @/../code_samples/lib/get_it/do_something_example.dart#example

**2. Use a mediator/event bus**
Instead of direct dependencies, communicate through events:

<<< @/../code_samples/lib/get_it/emit_example.dart#example

**3. Rethink your design**
Circular dependencies often mean:
- Responsibilities are mixed (split into more services)
- Missing abstraction layer
- Logic should be in a third service that coordinates both

**What NOT to do:**
❌ Using `late` without proper initialization
❌ Using global variables to break the cycle
❌ Passing getIt instance around
:::

## Why do I get "This instance is not available in GetIt" when calling signalReady?

::: details Click to see answer

This error typically occurs when you try to call `signalReady(instance)` **before** the instance is actually registered in GetIt. This commonly happens when using `signalsReady: true` with `registerSingletonAsync`.

**Common mistake:**

<<< @/../code_samples/lib/get_it/signal_ready_error_example.dart#example

**Why it fails:** Inside the async factory, the instance hasn't been registered yet. GetIt only adds it to the registry after the factory completes. Therefore, `signalReady(service)` fails because GetIt doesn't know about `service` yet.

**Solution 1 - Don't use signalsReady with registerSingletonAsync (recommended):**

The async factory automatically signals ready when it completes. You don't need manual signaling:

<<< @/../code_samples/lib/get_it/signal_ready_correct_option1.dart#example

**Solution 2 - Use registerSingleton with signalsReady:**

If you need manual signaling, register the instance synchronously and signal after it's in GetIt:

<<< @/../code_samples/lib/get_it/signal_ready_correct_option2.dart#example

**Solution 3 - Implement WillSignalReady interface:**

GetIt automatically detects this interface and waits for manual signaling:

<<< @/../code_samples/lib/get_it/signal_ready_correct_option3.dart#example

**When to use each approach:**

- **registerSingletonAsync** - Factory handles ALL initialization, returns ready instance
- **registerSingleton + signalsReady** - Instance needs async initialization AFTER registration
- **WillSignalReady interface** - Cleaner alternative to `signalsReady` parameter

See [Async Objects documentation](/documentation/get_it/async_objects#manual-ready-signaling) for complete details.
:::

## How do I test code that uses get_it?

::: details Click to see answer

See the comprehensive [Testing documentation](/documentation/get_it/testing) for detailed testing patterns, including:
- Using scopes to shadow services with mocks
- Integration testing approaches
- Best practices for test setup and teardown
:::

## Where should I put my get_it setup code?

::: details Click to see answer

**Key principle:** Organize all registrations into **dedicated functions** (not scattered throughout your app). This enables you to reinitialize parts of your app using scopes.

**Simple approach - single function:**

<<< @/../code_samples/lib/get_it/configure_dependencies_example_9.dart#example

**Better approach - split by feature/scope:**
Split registrations into separate functions that encapsulate scope management:


<<< @/../code_samples/lib/get_it/configure_core_dependencies_example.dart#example

**Why functions matter:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ **Reusable** - Call the same function when pushing scopes to reinitialize features</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ **Testable** - Call specific registration functions in test setup</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ **Organized** - Clear separation of concerns by feature/layer</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ **Centralized** - All registration logic in one place, not scattered</li>
</ul>

**Don't:**
❌ Scatter registration calls throughout your app
❌ Call registration methods from widget code
❌ Mix registration with business logic
❌ Duplicate registration code for different scopes

See [Scopes documentation](/documentation/get_it/scopes) for more on scope-based architecture.
:::

## When should I use Scopes vs unregister/register?

::: details Click to see answer

Use **scopes** - they're designed for this exact use case:

**With Scopes (Recommended ✅):**

<<< @/../code_samples/lib/get_it/on_login_example.dart#example

**Without Scopes (Not recommended ❌):**

<<< @/../code_samples/lib/get_it/on_login.dart

**Why scopes are better:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Automatic cleanup and restoration</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Can't forget to re-register original services</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Dispose functions called automatically</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Cleaner, less error-prone code</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Can push multiple nested scopes</li>
</ul>

**Use unregister when:**
- You're truly removing a service permanently (rare)
- You're resetting during app lifecycle (use `reset()` instead)

See [Scopes documentation](/documentation/get_it/scopes) for more patterns.
:::

## Can I use get_it with code generation (injectable)?

::: details Click to see answer

**Yes!** The [`injectable`](https://pub.dev/packages/injectable) package provides code generation for get_it registrations using annotations.

**Without injectable (manual):**

<<< @/../code_samples/lib/get_it/configure_dependencies_example_10.dart#example

**With injectable (generated):**

<<< @/../code_samples/lib/get_it/configure_dependencies_example_11.dart#example

**When to use injectable:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Large apps with many services (50+)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You prefer declarative over imperative code</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You want dependency injection to be more automatic</li>
</ul>

**When manual registration is fine:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Small to medium apps (< 50 services)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You prefer explicit, straightforward code</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You want to avoid code generation build step</li>
</ul>

**Important:** injectable is **optional**. get_it works great without it! The documentation here focuses on manual registration, which is simpler to learn and works for most apps.

See [injectable documentation](https://pub.dev/packages/injectable) if you want to use it.
:::

## How do I pass parameters to factories?

::: details Click to see answer

See the [Object Registration documentation](/documentation/get_it/object_registration#passing-parameters-to-factories) for detailed information on:
- Using `registerFactoryParam()` with one or two parameters
- Practical examples with different parameter types
- Alternative patterns for 3+ parameters using configuration objects
:::

## get_it vs Provider - which should I use?

::: details Click to see answer

**Important:** get_it and Provider serve **different purposes**, though they're often confused.

**get_it** is a **service locator** for dependency injection:
- Manages service/repository instances
- Not specifically for UI state management
- Decouples interface from implementation
- Works anywhere in your app (not tied to widget tree)

**Provider** is for **state propagation** down the widget tree:
- Passes data/state to descendant widgets efficiently
- Alternative to InheritedWidget
- Tied to widget tree position
- Primarily for UI state

**You can use both together!**

<<< @/../code_samples/lib/get_it/my_app_example_1.dart#example

**Or use get_it + watch_it instead:**

<<< @/../code_samples/lib/get_it/login_page_example_1.dart#example

**Choose:**
- **get_it only**: If you already have state management (BLoC, Riverpod, etc.)
- **get_it + watch_it**: All-in-one DI + reactive state management
- **get_it + Provider**: If you're already using Provider and want better DI

**Bottom line:** get_it is for service location, watch_it (built on get_it) handles both DI and state. Provider is orthogonal - you can use it with or without get_it.

See [watch_it documentation](/documentation/watch_it/watch_it) for the complete solution.
:::

## How do I re-register a service after unregister?

::: details Click to see answer

**Don't use unregister + register for logout/login!** Use **scopes** instead (see FAQ above).

But if you really need to unregister and re-register:

**Problem pattern:**

<<< @/../code_samples/lib/get_it/on_logout_example.dart#example

**Solution 1: Await unregister**

<<< @/../code_samples/lib/get_it/on_logout_example_1.dart#example

**Solution 2: Use unregister's disposing function**

<<< @/../code_samples/lib/get_it/code_sample_9b560463.dart#example

**Solution 3: Reset lazy singleton instead**
If you want to keep the registration but reset the instance:

<<< @/../code_samples/lib/get_it/code_sample_a449e220.dart

**Why await matters:**
- If your object implements `Disposable` or has a dispose function, unregister calls it
- These dispose functions can be `async`
- If you don't await, the next registration might happen before disposal completes
- This causes "already registered" errors

**Again, strongly prefer scopes over unregister/register:**

<<< @/../code_samples/lib/get_it/code_sample_657c692e.dart#example

Much cleaner and less error-prone!
:::





