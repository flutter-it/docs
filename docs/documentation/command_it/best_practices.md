# Best Practices

Production-ready patterns, anti-patterns, and guidelines for using `command_it` effectively.

## When to Use Commands

### ✅ Use Commands For

**Async operations with UI feedback:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#async_ui_feedback

**Operations that can fail:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#operations_can_fail

**User-triggered actions:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#user_triggered

**Operations needing state tracking:**
- Button loading states
- Pull-to-refresh
- Form submissions
- Network requests
- File I/O

### ✅ Use Sync Commands for Input with Operators

When you need to apply operators (debounce, map, where) to user input before triggering other operations, see [Command Chaining](command_chaining) for patterns using `pipeToCommand` and listen_it operators.

### ❌️️ Don't Use Commands For

**Simple getters/setters (without operators or chaining):**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#dont_use_getter

**Pure computations without side effects:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#dont_use_computation

**Immediate state changes:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#dont_use_toggle

## Organization Patterns

### Pattern 1: Commands in Managers

<<< @/../code_samples/lib/command_it/best_practices_organization.dart#managers_managers

**Benefits:**
- Centralized business logic
- Easy testing
- Reusable across widgets
- Clear ownership

### Pattern 2: Feature-Based Organization

<<< @/../code_samples/lib/command_it/best_practices_organization.dart#feature_based

### Pattern 3: Commands in Data Proxies

Commands can also live in data objects that manage their own async operations. This is useful when each data item needs independent loading state:

<<< @/../code_samples/lib/command_it/best_practices_organization.dart#proxy_pattern

**Benefits:**
- Each item has independent loading/error state
- Caching logic lives with the data
- UI can observe individual item state
- Manager stays simple (just creates/caches proxies)

## When to Use runAsync()

As explained in [Command Basics](/documentation/command_it/command_basics), the core command pattern is **fire-and-forget**: call `run()` and let your UI observe state changes reactively. However, there are legitimate cases where using `runAsync()` is appropriate and more expressive than alternatives.

### ✅ Use runAsync() For Sequential Workflows

When commands are part of a larger async workflow mixed with other async operations:

<<< @/../code_samples/lib/command_it/best_practices_run_async.dart#async_workflow

**Why `runAsync()` here?** The command is part of a larger async function that mixes command execution with regular async calls. Using `runAsync()` keeps the code linear and readable.

### ✅ Use runAsync() For APIs Requiring Futures

When interfacing with APIs that require a `Future`:

<<< @/../code_samples/lib/command_it/best_practices_run_async.dart#api_futures

### ❌️ Don't Use runAsync() for Simple UI Updates

<<< @/../code_samples/lib/command_it/best_practices_run_async.dart#dont_use_runasync

### Summary

**Use `runAsync()` when:**
- ✅ Commands are part of a larger async workflow
- ✅ An API requires a Future to be returned
- ✅ The sequential flow is clearer with `await` than with `.listen()`

**Don't use `runAsync()` when:**
- ❌️ Triggering commands from UI interactions (use `run()`)
- ❌️ You just want to observe results (use `watchValue()` or `ValueListenableBuilder`)
- ❌️ The async/await adds no value over fire-and-forget

## Performance Best Practices

### Debounce Text Input

<<< @/../code_samples/lib/command_it/best_practices_performance.dart#debounce

### Dispose Commands Properly

<<< @/../code_samples/lib/command_it/best_practices_performance.dart#dispose

### Avoid Unnecessary Rebuilds

<<< @/../code_samples/lib/command_it/best_practices_performance.dart#rebuilds

## Restriction Best Practices

### Use isRunningSync for Command Dependencies

<<< @/../code_samples/lib/command_it/best_practices_restriction.dart#isrunningsync

### Restriction Logic is Inverted

<<< @/../code_samples/lib/command_it/best_practices_restriction.dart#inverted

## Common Anti-Patterns

### ❌️️ Not Listening to Errors

<<< @/../code_samples/lib/command_it/best_practices_antipatterns.dart#not_listening_errors

### ❌️️ Try/Catch Inside Commands

Don't use try/catch inside command functions - it defeats `command_it`'s error handling system:

<<< @/../code_samples/lib/command_it/best_practices_antipatterns.dart#try_catch_inside

## See Also

- [Command Basics](/documentation/command_it/command_basics) — Getting started
- [Error Handling](/documentation/command_it/error_handling) — Error management
- [Testing](/documentation/command_it/testing) — Testing patterns
- [Observing Commands with `watch_it`](/documentation/watch_it/observing_commands) — Reactive UI patterns
