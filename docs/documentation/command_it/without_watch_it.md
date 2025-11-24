# Using Commands without watch_it

All the examples in [Getting Started](getting_started.md) use **watch_it**, which is our recommended approach for production apps. However, commands work perfectly with plain `ValueListenableBuilder` if you prefer not to use watch_it or get_it.

## When to Use ValueListenableBuilder

Consider using `ValueListenableBuilder` instead of watch_it when:
- You're prototyping or learning and want to minimize dependencies
- You have a simple widget that doesn't need dependency injection
- You prefer explicit builder patterns over implicit observation
- You're working on a project that doesn't use get_it

For production apps, we still recommend [watch_it](watch_it_integration.md) for cleaner, more maintainable code.

## Simple Counter Example

Here's the basic counter example using `ValueListenableBuilder`:

<<< @/../code_samples/lib/command_it/counter_simple_sync.dart#example

**Key points:**
- Use `ValueListenableBuilder` to observe the command
- Use `StatelessWidget` instead of `WatchingWidget`
- No need for get_it registration - service can be created directly in the widget
- Command is still a `ValueListenable`, just observed differently

## Async Example with Loading States

Here's the weather example showing async commands with loading indicators:

<<< @/../code_samples/lib/command_it/loading_state_example.dart#example

**Key points:**
- Watch `isRunning` with a separate `ValueListenableBuilder` for loading state
- Nested builders required - one for loading state, one for data
- More verbose than watch_it but works without additional dependencies
- All command features (async, error handling, restrictions) still work

## Comparing the Approaches

| Aspect | watch_it | ValueListenableBuilder |
|--------|----------|------------------------|
| **Dependencies** | Requires get_it + watch_it | No additional dependencies |
| **Widget Base** | `WatchingWidget` | `StatelessWidget` or `StatefulWidget` |
| **Observation** | `watchValue((Service s) => s.command)` | `ValueListenableBuilder(valueListenable: command, ...)` |
| **Multiple Properties** | Clean - separate `watchValue` calls | Nested builders required |
| **Boilerplate** | Minimal | More verbose |
| **Recommended For** | Production apps | Learning, prototyping |

## Observing Multiple Properties

When you need to observe both the command result AND its state (like `isRunning`), the difference becomes more apparent:

### With watch_it (Recommended)

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((Service s) => s.command);
    final isLoading = watchValue((Service s) => s.command.isRunning);

    if (isLoading) return CircularProgressIndicator();
    return Text(data);
  }
}
```

### With ValueListenableBuilder

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: command.isRunning,
      builder: (context, isLoading, _) {
        if (isLoading) return CircularProgressIndicator();

        return ValueListenableBuilder<String>(
          valueListenable: command,
          builder: (context, data, _) {
            return Text(data);
          },
        );
      },
    );
  }
}
```

Notice the nesting required with `ValueListenableBuilder` versus the clean, flat structure with watch_it.

## Using CommandResult

For the cleanest `ValueListenableBuilder` experience, use `CommandResult` to observe all command state in a single builder:

```dart
class MyWidget extends StatelessWidget {
  final myCommand = Command.createAsync<void, String>(
    () async => 'Hello',
    initialValue: '',
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CommandResult<void, String>>(
      valueListenable: myCommand.results,
      builder: (context, result, _) {
        if (result.isRunning) {
          return CircularProgressIndicator();
        }

        if (result.hasError) {
          return Text('Error: ${result.error}');
        }

        return Text(result.data);
      },
    );
  }
}
```

See [Command Results](command_results.md) for more details on using `CommandResult`.

## StatefulWidget Patterns

When you need to react to command events (like errors or state changes) without rebuilding the UI, use a `StatefulWidget` with `.listen()` subscriptions in `initState`.

### Error Handling with .listen()

Here's how to handle errors and show dialogs using StatefulWidget:

<<< @/../code_samples/lib/command_it/error_handling_stateful_example.dart#example

**Key points:**
- Subscribe to `.errors` in `initState` - runs once, not on every build
- Use `.where((e) => e != null)` to filter out null values (emitted at execution start)
- **CRITICAL:** Cancel subscriptions in `dispose()` to prevent memory leaks
- Store `StreamSubscription` to cancel later
- Check `mounted` before showing dialogs to avoid errors on disposed widgets
- Dispose the command in `dispose()` to clean up resources

**When to use StatefulWidget + .listen():**
- Need to react to events (errors, state changes) with side effects
- Want to show dialogs, trigger navigation, or log events
- Prefer explicit subscription management

**Important:** Always cancel subscriptions in `dispose()` to prevent memory leaks!

::: tip Want Automatic Cleanup?
For automatic subscription cleanup, consider using watch_it's `registerHandler` - see [watch_it Integration](watch_it_integration.md) for patterns that eliminate manual subscription management.
:::

For more error handling patterns, see [Command Properties - Error Notifications](/documentation/command_it/command_properties#errors---error-notifications).

## Observing canRun

The `canRun` property automatically combines the command's restriction state and execution state, making it perfect for enabling/disabling UI elements:

<<< @/../code_samples/lib/command_it/can_run_example.dart#example

**Key points:**
- `canRun` is `false` when command is running OR restricted
- Perfect for button `onPressed` - automatically disables during execution
- Cleaner than manually checking both `isRunning` and restriction state
- Updates automatically when either state changes

## Command Restrictions

Commands can be conditionally disabled using the `restriction` parameter. Here's how to use restrictions with ValueListenableBuilder:

<<< @/../code_samples/lib/command_it/restriction_example.dart#example

**Key points:**
- `restriction` accepts a `ValueListenable<bool>` where `true` = disabled
- Use `.map()` to invert logic if needed (e.g., `isLoggedIn.map((v) => !v)`)
- `ifRestrictedRunInstead` callback called when user tries to run while restricted
- `canRun` automatically reflects both restriction and execution state
- No need to manually check restriction - use `canRun` for button state

See [Command Restrictions](restrictions.md) for more details on restriction patterns.

## Choosing Your Approach

When using commands without watch_it, you have several options:

### ValueListenableBuilder with CommandResult (Recommended)

**Best for:** Most cases - single builder handles all states

```dart
ValueListenableBuilder<CommandResult<TParam, TResult>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    if (result.isRunning) return LoadingWidget();
    if (result.hasError) return ErrorWidget(result.error);
    return DataWidget(result.data);
  },
)
```

**Pros:** Clean, all state in one place, no nesting
**Cons:** Rebuilds UI on every state change

### Nested ValueListenableBuilders

**Best for:** When you need different rebuild granularity

```dart
ValueListenableBuilder<bool>(
  valueListenable: command.isRunning,
  builder: (context, isRunning, _) {
    if (isRunning) return LoadingWidget();
    return ValueListenableBuilder<TResult>(
      valueListenable: command,
      builder: (context, data, _) => DataWidget(data),
    );
  },
)
```

**Pros:** Fine-grained control over rebuilds
**Cons:** Nesting can get complex with multiple properties

### StatefulWidget + .listen()

**Best for:** Side effects (dialogs, navigation, logging)

```dart
class _MyWidgetState extends State<MyWidget> {
  ListenableSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = command.errors
      .where((e) => e != null)
      .listen((error, _) {
        if (mounted) showDialog(...);
      });
  }

  @override
  void dispose() {
    _subscription?.cancel();  // CRITICAL: Prevent memory leaks
    super.dispose();
  }
}
```

**Pros:** Separate side effects from UI, runs once, full control
**Cons:** Must manage subscriptions manually, more boilerplate

**Decision tree:**
1. Need side effects (dialogs, navigation)? → StatefulWidget + .listen()
2. Observing multiple states? → CommandResult
3. Need fine-grained rebuilds? → Nested builders
4. Want simplest approach? → CommandResult

::: tip Want Even Cleaner Code?
watch_it's `registerHandler` provides automatic subscription cleanup. See [watch_it Integration](watch_it_integration.md) if you want to eliminate manual subscription management entirely.
:::

## Next Steps

Ready to learn more?

- **Want to use watch_it?** See [watch_it Integration](watch_it_integration.md) for comprehensive patterns
- **Need more command features?** Check out [Command Properties](command_properties.md), [Error Handling](error_handling.md), and [Restrictions](restrictions.md)
- **Building production apps?** Read [Best Practices](best_practices.md) for architecture guidance

For more about watch_it and why we recommend it, see the [watch_it documentation](/documentation/watch_it/getting_started.md).
