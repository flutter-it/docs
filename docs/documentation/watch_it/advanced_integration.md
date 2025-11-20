# Accessing `get_it` Features

This guide shows how to access `get_it` features from within `watch_it` widgets. For detailed explanations of each `get_it` feature, see the [`get_it` documentation](/documentation/get_it/getting_started.md).

## Scopes with pushScope

`get_it` scopes create temporary registrations that are automatically cleaned up. Perfect for screen-specific state. See [`get_it` Scopes](/documentation/get_it/scopes.md) for details.

### pushScope() - Automatic Scope Management

`pushScope()` creates a scope when the widget mounts and automatically cleans it up on dispose:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#pushscope_automatic

**What happens:**
1. Widget builds first time → Scope is pushed, `init` callback runs
2. Dependencies registered in new scope
3. Widget can watch scoped dependencies
4. Widget disposes → Scope is automatically popped, `dispose` callback runs

### Use Case: Screen-Specific State

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#screen_specific_state

## Named Instances

Watch specific named instances from `get_it`. See [`get_it` Named Instances](/documentation/get_it/object_registration.md#named-instances) for registration details.

### Watching Named Instances

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#watching_named_instances

**Use cases:**
- Multiple configurations (dev/prod)
- Feature flags
- A/B testing variants

## Async Initialization

Handle complex initialization where async dependencies must be ready before the app starts. See [`get_it` Async Objects](/documentation/get_it/async_objects.md) for registration details.

### isReady - Single Dependency

Check if a specific async dependency is ready:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#isready_single_dependency

### allReady - Multiple Dependencies

Wait for all async dependencies to complete:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#allready_multiple_dependencies

### Watching Initialization Progress

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#watching_initialization_progress

## See Also

- [`get_it` Scopes Documentation](/documentation/get_it/scopes.md)
- [`get_it` Async Objects](/documentation/get_it/async_objects.md)
- [`get_it` Named Instances](/documentation/get_it/object_registration.md#named-instances)
- [Best Practices](/documentation/watch_it/best_practices.md)
