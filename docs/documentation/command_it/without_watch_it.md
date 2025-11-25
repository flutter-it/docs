# Using Commands without watch_it

All the examples in [Getting Started](getting_started.md) use **watch_it**, which is our recommended approach for production apps. However, commands work perfectly with plain `ValueListenableBuilder` or any state management solution that can observe a `Listenable` (like Provider or Riverpod).

## Quick Navigation

| Approach | Best For |
|----------|----------|
| [ValueListenableBuilder](#when-to-use-valuelistenablebuilder) | Learning, prototyping, no DI needed |
| [CommandBuilder](#commandbuilder-easiest) | Simplest approach with state-aware builders |
| [CommandResult](#using-commandresult) | Single builder for all command states |
| [StatefulWidget + .listen()](#statefulwidget-patterns) | Side effects (dialogs, navigation) |
| [Provider](#provider-integration) | Existing Provider apps |
| [Riverpod](#riverpod-integration) | Existing Riverpod apps |
| [flutter_hooks](#flutter_hooks-integration) | Direct watch-style calls (similar to watch_it!) |

## When to Use ValueListenableBuilder

Consider using `ValueListenableBuilder` instead of watch_it when:
- You're prototyping or learning and want to minimize dependencies
- You have a simple widget that doesn't need dependency injection
- You prefer explicit builder patterns over implicit observation
- You're working on a project that doesn't use get_it

For production apps, we still recommend [watch_it](/documentation/watch_it/observing_commands) for cleaner, more maintainable code.

::: tip Easiest Approach: CommandBuilder
If you want the simplest way to use commands without watch_it, consider `CommandBuilder` - a widget that handles all command states with minimal boilerplate. It's cleaner than manual `ValueListenableBuilder` patterns. Jump to [CommandBuilder example](#commandbuilder-easiest) or see [Command Builders](command_builders.md) for complete documentation.
:::

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

For watch_it examples, see [Observing Commands with watch_it](/documentation/watch_it/observing_commands).

| Aspect | watch_it | ValueListenableBuilder |
|--------|----------|------------------------|
| **Dependencies** | Requires get_it + watch_it | No additional dependencies |
| **Widget Base** | `WatchingWidget` | `StatelessWidget` or `StatefulWidget` |
| **Observation** | `watchValue((Service s) => s.command)` | `ValueListenableBuilder(valueListenable: command, ...)` |
| **Multiple Properties** | Clean - separate `watchValue` calls | Nested builders required |
| **Boilerplate** | Minimal | More verbose |
| **Recommended For** | Production apps | Learning, prototyping |

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
For automatic subscription cleanup, consider using watch_it's `registerHandler` - see [Observing Commands with watch_it](/documentation/watch_it/observing_commands) for patterns that eliminate manual subscription management.
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

## Choosing Your Approach

When using commands without watch_it, you have several options:

### CommandBuilder (Easiest)

**Best for:** Simplest approach with dedicated builders for each state

```dart
CommandBuilder(
  command: loadDataCommand,
  whileRunning: (context, _, __) => CircularProgressIndicator(),
  onError: (context, error, _, __) => Text('Error: $error'),
  onData: (context, data, _) => ListView(
    children: data.map((item) => ListTile(title: Text(item))).toList(),
  ),
)
```

**Pros:** Cleanest code, separate builders for each state, no manual state checking
**Cons:** Additional widget in tree

See [Command Builders](command_builders.md) for complete documentation.

### ValueListenableBuilder with CommandResult

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
1. Want simplest approach? → CommandBuilder
2. Need side effects (dialogs, navigation)? → StatefulWidget + .listen()
3. Observing multiple states? → CommandResult
4. Need fine-grained rebuilds? → Nested builders

::: tip Want Even Cleaner Code?
watch_it's `registerHandler` provides automatic subscription cleanup. See [Observing Commands with watch_it](/documentation/watch_it/observing_commands) if you want to eliminate manual subscription management entirely.
:::

## Integration with Other State Management Solutions

Commands integrate well with other state management solutions (watch_it is ours). Since each command property (`isRunning`, `errors`, `results`, etc.) is itself a `ValueListenable`, any solution that can observe a `Listenable` can watch them with granular rebuilds.

### Provider Integration

Use `ListenableProvider` to watch specific command properties:

<<< @/../code_samples/lib/command_it/provider_integration.dart#manager

**Setup with ChangeNotifierProvider:**

<<< @/../code_samples/lib/command_it/provider_integration.dart#setup

**Granular observation with ListenableProvider:**

<<< @/../code_samples/lib/command_it/provider_integration.dart#granular

**Key points:**
- Use `context.read<Manager>()` to get the manager without listening
- Use `ListenableProvider.value()` to provide specific command properties
- Each property (`isRunning`, `results`, etc.) is a separate `Listenable`
- Only the widgets watching that specific property rebuild when it changes

### Riverpod Integration

With Riverpod's `@riverpod` annotation, create providers for specific command properties:

<<< @/../code_samples/lib/command_it/riverpod_integration.dart#providers

**In your widget:**

<<< @/../code_samples/lib/command_it/riverpod_integration.dart#widget

**Key points:**
- Use `Raw<T>` wrapper to prevent Riverpod from auto-disposing the notifiers
- Use `ref.onDispose()` to clean up commands when the provider is disposed
- Create separate providers for each command property you want to observe
- Requires `riverpod_annotation` package and code generation (`build_runner`)

### flutter_hooks Integration

flutter_hooks provides a direct watch-style pattern very similar to watch_it! Use `useValueListenable` for clean, declarative observation:

**Manager setup:**

<<< @/../code_samples/lib/command_it/flutter_hooks_integration.dart#manager

**In your widget:**

<<< @/../code_samples/lib/command_it/flutter_hooks_integration.dart#widget

**Key points:**
- `useValueListenable` provides direct watch-style calls - no nested builders!
- Pattern is very similar to watch_it's `watchValue`
- Each `useValueListenable` call observes a specific property for granular rebuilds
- Requires `flutter_hooks` package

### About Bloc/Cubit

Commands and Bloc/Cubit solve the same problem - managing async operation state. Using both creates redundancy:

| Feature | command_it | Bloc/Cubit |
|---------|-----------|------------|
| Loading state | `command.isRunning` | `LoadingState()` |
| Error handling | `command.errors` | `ErrorState(error)` |
| Result/Data | `command.value` | `LoadedState(data)` |
| Execution | `command.run()` | `emit()` / `add(Event)` |
| Restrictions | `command.canRun` | Manual logic |
| Progress tracking | `command.progress` | Manual implementation |

**Recommendation:** Choose one approach. If you're already using Bloc/Cubit for async operations, you don't need commands for those operations. If you want to use commands, they replace the need for Bloc/Cubit in async state management.

## Next Steps

Ready to learn more?

- **Want to use watch_it?** See [Observing Commands with watch_it](/documentation/watch_it/observing_commands) for comprehensive patterns
- **Need more command features?** Check out [Command Properties](command_properties.md), [Error Handling](error_handling.md), and [Restrictions](restrictions.md)
- **Building production apps?** Read [Best Practices](best_practices.md) for architecture guidance

For more about watch_it and why we recommend it, see the [watch_it documentation](/documentation/watch_it/getting_started.md).
