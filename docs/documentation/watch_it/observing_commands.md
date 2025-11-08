# Observing Commands with watch_it

One of the most powerful combinations in the flutter_it ecosystem is using `watch_it` to observe `command_it` commands. This pattern provides reactive, declarative state management for async operations with automatic loading states, error handling, and result updates.

## Why watch_it + command_it?

Commands encapsulate async operations and track their execution state (`isExecuting`, `value`, `errors`). watch_it allows your widgets to reactively rebuild when these states change, creating a seamless user experience without manual state management.

**Benefits:**
- **Automatic loading states** - No need to manually track `isLoading` booleans
- **Reactive results** - UI updates automatically when command completes
- **Built-in error handling** - Commands track errors, watch_it displays them
- **Clean separation** - Business logic in commands, UI logic in widgets
- **No boilerplate** - No `setState`, no `StreamBuilder`, no manual listeners

## Watching Command Execution State

The most common pattern is watching `isExecuting` to show loading indicators:

<<< @/../code_samples/lib/watch_it/watch_command_basic_example.dart#example

**Key points:**
- `command.isExecuting` is a `ValueListenable<bool>`
- Widget rebuilds automatically when command starts/stops
- Button disables during execution
- Progress indicator shows while loading

## Watching Command Results

Watch the command's `value` property to display results:

<<< @/../code_samples/lib/watch_it/watch_command_value_example.dart#example

**Pattern:**
```dart
// Get the command
final manager = di<WeatherManager>();

// Watch its value
final weather = watch(manager.fetchWeatherCommand).value;
final isLoading = watch(manager.fetchWeatherCommand.isExecuting).value;
```

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

## Loading Button Pattern

A complete pattern for buttons that show loading state:

<<< @/../code_samples/lib/watch_it/command_loading_button_example.dart#example

**This pattern:**
- Disables button during execution (`onPressed: isExecuting ? null : ...`)
- Shows inline loading indicator
- Provides visual feedback to user
- Prevents double-submission

## Watching Multiple Command States

You can watch different aspects of the same command:

<<< @/../code_samples/lib/watch_it/command_multiple_states_example.dart#example

**Watch multiple properties:**
- `command.isExecuting` - Is it running?
- `command.value` - What's the result?
- `command.errors` - Did it fail?
- `command.canExecute` - Can it run now?

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

### 2. Don't Await execute()

```dart
// ✓ GOOD - Non-blocking, UI stays responsive
ElevatedButton(
  onPressed: () => di<Manager>().command.execute(),
  child: Text('Submit'),
)

// ❌ BAD - Blocks UI thread
ElevatedButton(
  onPressed: () async {
    await di<Manager>().command.executeWithFuture();
  },
  child: Text('Submit'),
)
```

**Why?** Commands handle async internally. Just call `execute()` and let watch_it update the UI reactively.

### 3. Watch Execution State for Loading

```dart
// ✓ GOOD - Watch isExecuting
final isLoading = watch(command.isExecuting).value;

if (isLoading) {
  return CircularProgressIndicator();
}

// ❌ BAD - Manual tracking
bool _isLoading = false;

setState(() => _isLoading = true);
await command.executeWithFuture();
setState(() => _isLoading = false);
```

### 4. Handle Errors Gracefully

```dart
// ✓ GOOD - Watch errors and display them
final error = watch(command.errors).value;

if (error != null) {
  return ErrorWidget(error: error);
}

// ✓ ALSO GOOD - Use handler for error dialog
registerHandler(
  select: (Manager m) => m.command.errors,
  handler: (context, error, _) {
    if (error != null) {
      showErrorDialog(context, error);
    }
  },
);
```

### 5. Only Show Loading on Initial Load

```dart
final isLoading = watch(command.isExecuting).value;
final data = watch(command).value;

// Show spinner only when no data yet
if (isLoading && data == null) {
  return CircularProgressIndicator();
}

// Show data even while refreshing
return ListView(
  children: [
    if (isLoading) LinearProgressIndicator(), // Subtle indicator
    ...data.map((item) => ListTile(...)),
  ],
);
```

## Common Patterns

### Form Submission

```dart
final isSubmitting = watch(manager.submitCommand.isExecuting).value;
final canSubmit = formKey.currentState?.validate() ?? false;

ElevatedButton(
  onPressed: canSubmit && !isSubmitting
      ? () => manager.submitCommand.execute(formData)
      : null,
  child: isSubmitting
      ? CircularProgressIndicator()
      : Text('Submit'),
)
```

### Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    manager.refreshCommand.execute();
    await manager.refreshCommand.executeWithFuture();
  },
  child: ListView(...),
)
```

### Retry on Error

```dart
final error = watch(command.errors).value;

if (error != null) {
  return Column(
    children: [
      Text('Error: $error'),
      ElevatedButton(
        onPressed: () => command.execute(),
        child: Text('Retry'),
      ),
    ],
  );
}
```

## See Also

- [command_it Documentation](/documentation/command_it/getting_started.md) - Learn about commands
- [Watch Functions](/documentation/watch_it/watch_functions.md) - All watch functions
- [Handler Pattern](/documentation/watch_it/handlers.md) - Using handlers
- [Best Practices](/documentation/watch_it/best_practices.md) - General best practices
