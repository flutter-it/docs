<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/command_it.svg" alt="command_it logo" width="100" />
  <h1 style="margin: 0;">Getting Started</h1>
</div>

command_it is a way to manage your state based on `ValueListenable` and the `Command` design pattern. A `Command` is an object that wraps a function, making it callable while providing reactive state updates—perfect for bridging your UI and business logic.

![command_it Data Flow](/images/command-it-flow.svg)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  command_it: ^2.0.0
```

For the recommended setup with watch_it and get_it, just import `flutter_it`:

```yaml
dependencies:
  flutter_it: ^1.0.0
```

## Why Commands?

When I started Flutter, the most recommended approach was `BLoC`. But pushing objects into a `StreamController` to trigger processes never felt right—it should feel like calling a function. Coming from the .NET world, I was used to Commands: callable objects that automatically disable their trigger button while running and emit results reactively.

I ported this concept to Dart with [rx_command](https://pub.dev/packages/rx_command), but Streams felt heavy. After Remi Rousselet convinced me how much simpler `ValueNotifiers` are, I created command_it: all the power of the Command pattern, zero Streams, 100% `ValueListenable`.

## Core Concept

A `Command` is:
1. **A function wrapper** - Encapsulates sync/async functions as callable objects
2. **A ValueListenable** - Publishes results reactively so your UI can observe changes
3. **Type-safe** - `Command<TParam, TResult>` where `TParam` is the input type and `TResult` is the output type

::: tip The Command Pattern
The core philosophy: **Start commands with `run()` (fire and forget), then your app/UI observes and reacts to their state changes**. This reactive pattern keeps your UI responsive with no blocking—you trigger the action and let your UI automatically respond to loading states, results, and errors.
:::

Here's the simplest possible example using **watch_it** (the recommended approach):

<<< @/../code_samples/lib/command_it/counter_watch_it.dart#example

**Key points:**
- Create with `Command.createSyncNoParam<TResult>()` (see [Command Types](command_types.md) for different signatures)
- Command has a **`.run` method** - use it as tearoff for `onPressed`
- Use **`watchValue`** to observe the command - auto-rebuilds when the value changes
- Register your service with get_it (call setup in `main()`), extend `WatchingWidget` for watch_it functionality
- Initial value is required so the UI has something to show immediately

::: tip Using Commands without watch_it
Commands also work with plain `ValueListenableBuilder` if you prefer not to use watch_it. See [Without watch_it](without_watch_it.md) for examples. For more about watch_it, see the [watch_it documentation](/documentation/watch_it/getting_started.md).
:::

## Real-World Example: Async Commands with Loading States

Most real apps need async operations (HTTP calls, database queries, etc.). Commands make this trivial by tracking execution state automatically. Here's an example with **watch_it**:

<<< @/../code_samples/lib/command_it/watch_it_simple.dart#example

**What's happening:**
1. `Command.createAsync<TParam, TResult>()` wraps an async function
2. `watchValue` observes both the command result AND its `isRunning` property
3. The UI automatically shows a loading indicator while the command executes
4. No nested `ValueListenableBuilder` widgets - watch_it keeps the code clean
5. The command parameter (`'London'`) is passed to the wrapped function

This pattern eliminates the boilerplate of manually tracking loading states and nested builders → commands + watch_it handle everything for you.

::: tip Commands Always Notify (By Default)
Commands notify listeners on **every execution**, even if the result value is identical. This is intentional because:

1. **User actions need feedback** - When clicking "Refresh", users expect loading indicators even if data hasn't changed
2. **State changes during execution** - `isRunning`, `CommandResult`, and error states update during the async operation
3. **The action matters, not just the result** - The command executed (API called, file saved), which is important regardless of return value

**When to use `notifyOnlyWhenValueChanges: true`:**
- Pure computation commands where only the result matters
- High-frequency updates where identical results should be ignored
- Performance optimization when listeners are expensive

For most real-world scenarios with user actions and async operations, the default behavior is what you want.
:::

## Key Concepts at a Glance

command_it offers powerful features for production apps:

### Command Properties

The **command itself** is a `ValueListenable<TResult>` that publishes the result. Commands also expose additional observable properties:
- **`value`** - Property getter for the current result (not a ValueListenable, just the value)
- **`isRunning`** - `ValueListenable<bool>` indicating if the command is currently executing (async commands only)
- **`canRun`** - `ValueListenable<bool>` combining `!isRunning && !restriction` (see restrictions below)
- **`errors`** - `ValueListenable<CommandError?>` of execution errors

See [Command Properties](command_properties.md) for details.

### CommandResult

Instead of watching multiple properties separately, use `results` to get comprehensive state:

```dart
command.results // ValueListenable<CommandResult<TParam, TResult>>
```

`CommandResult` combines `data`, `error`, `isRunning`, and `paramData` in one object. Perfect for comprehensive error/loading/success UI states.

See [Command Results](command_results.md) for details.

### Error Handling

Commands capture exceptions automatically and publish them via the `errors` property. You can use **listen_it** operators to filter and handle specific error types:

```dart
command.errors.where((error) => error?.error is NetworkError).listen((error, _) {
  showSnackbar('Network error: ${error!.error.message}');
});
```

For advanced scenarios, use **error filters** to route different error types at the command level. See [Error Handling](error_handling.md) for details.

### Restrictions

Control when a command can execute by passing a `ValueListenable<bool>` restriction:

```dart
final isOnline = ValueNotifier(true);

final command = Command.createAsync(
  fetchData,
  initialValue: [],
  restriction: isOnline, // Command only runs when isOnline.value == true
);
```

Because it's a `ValueNotifier` passed to the constructor, a command can be enabled and disabled at any time by changing the notifier's value.

See [Restrictions](restrictions.md) for details.

## Next Steps

Choose your learning path based on your goal:

### 📚 I want to learn the fundamentals
Start with [Command Basics](command_basics.md) to understand:
- All command factory methods (sync/async, with/without parameters)
- How to run commands programmatically vs. with UI triggers
- Return values and initial values

### ⚡ I want to build a real feature
Follow the [Weather App Tutorial](/examples/command_it/weather_app_tutorial.md) to build a complete feature:
- Async commands with real API calls
- Debouncing user input
- Loading states and error handling
- Command restrictions
- Multiple commands working together

### 🛡️ I need robust error handling
Check out [Error Handling](error_handling.md):
- Capturing and displaying errors
- Routing different error types to different handlers
- Retry logic and fallback strategies

### 🎯 I want production-ready patterns
See [Best Practices](best_practices.md) for:
- When to use commands vs. other patterns
- Avoiding common pitfalls
- Performance optimization
- Architecture recommendations

### 🧪 I need to write tests
Head to [Testing](testing.md) for:
- Unit testing commands in isolation
- Widget testing with commands
- Mocking command responses
- Testing error scenarios

## Quick Reference

| Topic | Link |
|-------|------|
| Creating commands (all factory methods) | [Command Basics](command_basics.md) |
| Command types (signatures) | [Command Types](command_types.md) |
| Observable properties (value, isRunning, etc.) | [Command Properties](command_properties.md) |
| CommandResult (comprehensive state) | [Command Results](command_results.md) |
| CommandBuilder widget | [Command Builders](command_builders.md) |
| Error handling and routing | [Error Handling](error_handling.md) |
| Conditional execution | [Restrictions](restrictions.md) |
| Testing patterns | [Testing](testing.md) |
| Integration with watch_it | [watch_it Integration](watch_it_integration.md) |
| Production patterns | [Best Practices](best_practices.md) |

Ready to dive deeper? Pick a topic from the [Quick Reference](#quick-reference) above or follow one of the [Next Steps](#next-steps) learning paths!
