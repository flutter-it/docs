# Advanced Integration

Advanced patterns for integrating `watch_it` with get_it, including scopes, named instances, async initialization, and multi-package coordination.

## get_it Scopes with pushScope

Scopes allow you to create temporary registrations that are automatically cleaned up when a widget is disposed. Perfect for feature-specific dependencies or screen-level state.

### What are Scopes?

get_it scopes create isolated registration contexts:
- **Push a scope** - Create new registration context
- **Register in scope** - Dependencies only live in that scope
- **Pop the scope** - All scoped registrations are disposed

### pushScope() - Automatic Scope Management

`pushScope()` creates a scope when the widget mounts and automatically cleans it up on dispose:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#pushscope_automatic

**What happens:**
1. Widget builds first time → Scope is pushed, `init` callback runs
2. Dependencies registered in new scope
3. Widget can watch scoped dependencies
4. Widget disposes → Scope is automatically popped, `dispose` callback runs
5. All scoped registrations are cleaned up

### Use Cases for Scopes

#### 1. Screen-Specific State

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#screen_specific_state

#### 2. Feature Modules

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#feature_modules

#### 3. User Session State

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#user_session_state

### Scope Best Practices

**✅ DO:**
- Use scopes for screen/feature-specific dependencies
- Clean up resources in `dispose` callback
- Keep scopes focused and short-lived

**❌ DON'T:**
- Use scopes for app-wide singletons (use global registration)
- Create deeply nested scopes (keeps things simple)
- Register the same type in multiple scopes (use named instances instead)

## Named Instances

Watch specific named instances from get_it:

### Registering Named Instances

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#registering_named_instances

### Watching Named Instances

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#watching_named_instances

### Environment-Specific Configuration

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#environment_specific_config

## Async Initialization with isReady and allReady

Handle complex initialization scenarios where multiple async dependencies must be ready before the app starts.

### isReady - Single Dependency

Check if a specific async dependency is ready:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#isready_single_dependency

### allReady - Multiple Dependencies

Wait for all async dependencies to complete:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#allready_multiple_dependencies

### Watching Initialization Progress

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#watching_initialization_progress

## Custom GetIt Instances

Use multiple GetIt instances for different contexts:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#custom_getit_instances

## Multi-Package Integration

Coordinate watch_it across multiple packages in a monorepo or modular app.

### Package Structure

```
app/
├── core_package/
│   └── lib/
│       └── managers/
│           └── auth_manager.dart
├── feature_a/
│   └── lib/
│       └── managers/
│           └── feature_a_manager.dart
└── main_app/
    └── lib/
        └── main.dart
```

### Core Package Setup

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#core_package_setup

### Feature Package Setup

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#feature_package_setup

### Main App Integration

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#main_app_integration

### Package Registration Order

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#package_registration_order

## Integration Patterns

### Pattern 1: Lazy Module Loading

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#lazy_module_loading

### Pattern 2: A/B Testing with Named Instances

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#ab_testing_named_instances

### Pattern 3: Hot Swap Dependencies

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#hot_swap_dependencies

## Advanced Patterns

### Local Reactive State with createOnce and watch

For widget-local reactive state that doesn't need get_it registration, combine `createOnce` with `watch`:

<<< @/../code_samples/lib/watch_it/watch_create_once_local_state.dart#example

**When to use this pattern:**
- Widget needs its own local reactive state
- State should persist across rebuilds (not recreated)
- State should be automatically disposed with widget
- Don't want to register in get_it (truly local)

**Key benefits:**
- `createOnce` creates the notifier once and auto-disposes it
- `watch` subscribes to changes and triggers rebuilds
- No manual lifecycle management needed

### Global State Reset

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#global_state_reset

### Dependency Injection Testing

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#dependency_injection_testing

## See Also

- [get_it Scopes Documentation](/documentation/get_it/scopes.md) - Detailed scope information
- [get_it Async Objects](/documentation/get_it/async_objects.md) - Async initialization
- [Best Practices](/documentation/watch_it/best_practices.md) - General best practices
- [Testing](/documentation/get_it/testing.md) - Testing with get_it
