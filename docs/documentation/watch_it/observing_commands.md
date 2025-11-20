# Observing Commands with `watch_it`

One of the most powerful combinations in the `flutter_it` ecosystem is using `watch_it` to observe `command_it` commands. Commands are `ValueListenable` objects that expose their state (`isRunning`, `value`, `errors`) as `ValueListenable` properties, making them naturally observable by `watch_it`. This pattern provides reactive, declarative state management for async operations with automatic loading states, error handling, and result updates.

::: tip Learn about Commands First
If you're new to `command_it`, start with the [command_it Getting Started](/documentation/command_it/getting_started.md) guide to understand how commands work.
:::

## Why `watch_it` + `command_it`?

Commands encapsulate async operations and track their execution state (`isRunning`, `value`, `errors`). `watch_it` allows your widgets to reactively rebuild when these states change, creating a seamless user experience without manual state management.

**Benefits:**
- **Automatic loading states** - No need to manually track `isLoading` booleans
- **Reactive results** - UI updates automatically when command completes
- **Built-in error handling** - Commands track errors, `watch_it` displays them
- **Clean separation** - Business logic in commands, UI logic in widgets
- **No boilerplate** - No `setState`, no `StreamBuilder`, no manual listeners

## Watching a Command

A typical pattern is to watch both the command's result and its execution state as separate values:

<<< @/../code_samples/lib/watch_it/watch_command_basic_example.dart#example

**Key points:**
- Watch the command itself to get its value (the result)
- Watch `command.isRunning` to get the execution state
- Widget rebuilds automatically when either changes
- Commands are `ValueListenable` objects, so they work seamlessly with `watch_it`
- Button disables during execution
- Progress indicator shows while loading

## Watching Command Errors

Display errors by watching the command's `errors` property:

<<< @/../code_samples/lib/watch_it/watch_command_errors_example.dart#example

**Error handling patterns:**
- Show error banner at top of screen
- Display error message inline
- Provide retry button
- Clear errors on retry

## Using Handlers for Side Effects

While `watch` is for rebuilding UI, use `registerHandler` for side effects like navigation or showing toasts:

### Success Handler

<<< @/../code_samples/lib/watch_it/command_handler_success_example.dart#example

**Common success side effects:**
- Navigate to another screen
- Show success snackbar/toast
- Trigger another command
- Log analytics event

### Error Handler

<<< @/../code_samples/lib/watch_it/command_handler_error_example.dart#example

**Common error side effects:**
- Show error dialog
- Show error snackbar
- Log error to crash reporting
- Retry logic

## Watching Command Results

The `results` property provides a `CommandResult` object containing all command state in one place:

<<< @/../code_samples/lib/watch_it/command_results_example.dart#example

**CommandResult contains:**
- `data` - The command's current value
- `isRunning` - Whether the command is executing
- `hasError` - Whether an error occurred
- `error` - The error object if any
- `isSuccess` - Whether execution succeeded (`!isRunning && !hasError`)

**The `.toWidget()` extension:**
- `onData` - Build UI when data is available
- `onError` - Build UI when an error occurs (shows last successful result if available)
- `whileRunning` - Build UI while command is executing

This pattern is ideal when you need to handle all command states in a declarative way.

::: tip Other Command Properties
You can also watch other command properties individually:
- `command.isRunning` - Execution state
- `command.errors` - Error notifications
- `command.canRun` - Whether the command can currently execute (combines `!isRunning && !restriction`)
:::

## Chaining Commands

Use handlers to chain commands together:

<<< @/../code_samples/lib/watch_it/command_chaining_example.dart#example

**Chaining patterns:**
- Create → Refresh list
- Login → Navigate to home
- Delete → Refresh
- Upload → Process → Notify

## Best Practices

### 1. Watch vs Handler

**Use `watch` when:**
- You need to rebuild the widget
- Showing loading indicators
- Displaying results
- Showing error messages inline

**Use `registerHandler` when:**
- Navigation after success
- Showing dialogs/snackbars
- Logging/analytics
- Triggering other commands
- Any side effect that doesn't require rebuild

### 2. Don't Await run()

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#dont_await_execute_good

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#dont_await_execute_bad

**Why?** Commands handle async internally. Just call `run()` and let `watch_it` update the UI reactively.

### 3. Watch Execution State for Loading

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#watch_execution_state_good

**Avoid manual tracking:** Don't use `setState` and boolean flags. Let commands and `watch_it` handle state reactively.

## Common Patterns

### Form Submission

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#form_submission_pattern

### Pull to Refresh

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#pull_to_refresh_pattern

## See Also

- [command_it Documentation](/documentation/command_it/getting_started.md) - Learn about commands
- [Watch Functions](/documentation/watch_it/watch_functions.md) - All watch functions
- [Handler Pattern](/documentation/watch_it/handlers.md) - Using handlers
- [Best Practices](/documentation/watch_it/best_practices.md) - General best practices
