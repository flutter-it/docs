---
title: Scopes
---

# Scopes

Scopes provide **hierarchical lifecycle management** for your business objects, independent of the widget tree.

::: info get_it Scopes vs Widget-Tree Scoping (Provider, InheritedWidget)
**get_it scopes are intentionally independent of the widget tree.** They manage the lifecycle of business objects based on application state (login/logout, sessions, features), not widget position.

For **widget-lifetime scoping**, use [watch_it's `pushScope`](/documentation/watch_it/watch_it) which automatically pushes a get_it scope for the lifetime of a widget.
:::

## What Are Scopes?

Think of scopes as a **stack of registration layers**. When you register a type in a new scope, it shadows (hides) any registration of the same type in lower scopes. Popping a scope automatically restores the previous registrations and cleans up resources.

<div class="diagram-dark">

![Scope Stack Visualization](/images/scopes-stack.svg)

</div>

<div class="diagram-light">

![Scope Stack Visualization](/images/scopes-stack-light.svg)

</div>

### How Shadowing Works


<<< @/../code_samples/lib/get_it/user.dart

The search order is **top to bottom** - get_it always returns the first match starting from the current scope.

---

## When to Use Scopes

### ✅ Perfect Use Cases

**1. Authentication States**

<<< @/../code_samples/lib/get_it/user_signature_1.dart

**2. Session Management**

<<< @/../code_samples/lib/get_it/shopping_cart.dart

**3. Feature Flags / A-B Testing**

<<< @/../code_samples/lib/get_it/checkout_service_example.dart#example

**4. Test Isolation**

<<< @/../code_samples/lib/get_it/api_client_example.dart#example

---

## Creating and Managing Scopes

### Basic Scope Operations


<<< @/../code_samples/lib/get_it/service_example.dart#example

### Async Scope Initialization

When scope setup requires async operations (loading config files, establishing connections):


<<< @/../code_samples/lib/get_it/tenant_config_example.dart#example

::: tip Async Dependencies Between Services
For services with async initialization that **depend on each other**, use `registerSingletonAsync` with the `dependsOn` parameter instead. See [Async Objects documentation](/documentation/get_it/async_objects) for details.
:::

---

## Advanced Scope Features

### Final Scopes (Preventing Accidental Registrations)

Prevent race conditions by locking a scope after initialization:


<<< @/../code_samples/lib/get_it/service_a_example.dart#example

**Use when:**
- Building plugin systems where scope setup must be atomic
- Preventing accidental registration after scope initialization

### Shadow Change Handlers

Objects can be notified when they're shadowed or restored:


<<< @/../code_samples/lib/get_it/init_example.dart#example

**Use cases:**
- Resource-heavy services that should pause when inactive
- Services with subscriptions that need cleanup/restoration
- Preventing duplicate background work

### Scope Change Notifications

Get notified when any scope change occurs:


<<< @/../code_samples/lib/get_it/code_sample_062bd775.dart#example

**Note:** watch_it automatically handles UI rebuilds on scope changes via `rebuildOnScopeChanges`.

---

## Scope Lifecycle & Disposal

### Disposal Order

When a scope is popped:

1. **Scope dispose function** is called (if provided)
2. **Object dispose functions** are called in reverse registration order
3. **Scope is removed** from the stack

```dart
getIt.pushNewScope(
  dispose: () async {
    // Called FIRST - objects still accessible
    final service = getIt<MyService>();
    await service.saveState();
  },
);

getIt.registerSingleton<MyService>(
  MyService(),
  dispose: (service) {
    // Called SECOND - after scope dispose
    service.cleanup();
  },
);

await getIt.popScope();
// Order: scope dispose → MyService.cleanup → scope removed
```

### Implementing Disposable Interface

Instead of passing dispose functions, implement `Disposable`:


<<< @/../code_samples/lib/get_it/init_example_1.dart#example

### Reset vs Pop


<<< @/../code_samples/lib/get_it/code_sample_39fe26fa.dart

---

## Common Patterns

### Login/Logout Flow


<<< @/../code_samples/lib/get_it/auth_service_example.dart#example

### Multi-Tenant Applications


<<< @/../code_samples/lib/get_it/tenant_manager_example.dart#example

### Feature Toggles with Scopes


<<< @/../code_samples/lib/get_it/enable_feature_example.dart#example

### Testing with Scopes

Use scopes to shadow real services with mocks while keeping the rest of your DI setup:


<<< @/../code_samples/lib/get_it/api_client.dart

**Benefits:**
- No need to duplicate all registrations in tests
- Only mock what's necessary (ApiClient, Database)
- Other services use real implementations
- Automatic cleanup via popScope()

---

## Debugging Scopes

### Check Current Scope


<<< @/../code_samples/lib/get_it/code_sample_e395f3ff.dart#example

### Check Registration Scope


<<< @/../code_samples/lib/get_it/code_sample_661a189f.dart#example

### Verify Scope Exists


<<< @/../code_samples/lib/get_it/code_sample_0eb8db1b.dart#example

---

## Best Practices

### ✅ Do

- **Name your scopes** for easier debugging and management
- **Use init parameter** to register objects immediately when pushing scope
- **Always await popScope()** to ensure proper cleanup
- **Implement Disposable** for automatic cleanup instead of passing dispose functions
- **Use scopes for business logic lifecycle**, not UI state

### ❌ Don't

- **Don't use scopes for temporary state** - use parameters or variables instead
- **Don't forget to pop scopes** - memory leaks if scopes accumulate
- **Don't rely on scope order** for logic - use explicit dependencies
- **Don't push scopes inside build methods** - use watch_it's `pushScope` for widget-bound scopes

---

## Widget-Bound Scopes with watch_it

For scopes tied to widget lifetime, use **watch_it**:


<<< @/../code_samples/lib/get_it/user_profile_page_example.dart#example

See [watch_it documentation](/documentation/watch_it/watch_it) for details.

---

## API Reference

### Scope Management

| Method | Description |
|--------|-------------|
| `pushNewScope({init, scopeName, dispose, isFinal})` | Push a new scope with optional immediate registration |
| `pushNewScopeAsync({init, scopeName, dispose})` | Push scope with async initialization |
| `popScope()` | Pop current scope and dispose objects |
| `popScopesTill(name, {inclusive})` | Pop all scopes until named scope |
| `dropScope(scopeName)` | Drop specific scope by name |
| `resetScope({dispose})` | Clear current scope registrations |
| `hasScope(scopeName)` | Check if scope exists |
| `currentScopeName` | Get current scope name (getter) |

### Scope Callbacks

| Property | Description |
|----------|-------------|
| `onScopeChanged` | Called when scope pushed/popped |

### Object Lifecycle

| Interface | Description |
|-----------|-------------|
| `ShadowChangeHandlers` | Implement to get notified when shadowed |
| `Disposable` | Implement for automatic cleanup |

---

## See Also

- [Object Registration](/documentation/get_it/object_registration) - How to register objects
- [Async Objects](/documentation/get_it/async_objects) - Working with async initialization
- [Testing](/documentation/get_it/testing) - Using scopes in tests
- [watch_it pushScope](/documentation/watch_it/watch_it) - Widget-bound scoping
