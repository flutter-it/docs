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

## Next Steps

Ready to learn more?

- **Want to use watch_it?** See [watch_it Integration](watch_it_integration.md) for comprehensive patterns
- **Need more command features?** Check out [Command Properties](command_properties.md), [Error Handling](error_handling.md), and [Restrictions](restrictions.md)
- **Building production apps?** Read [Best Practices](best_practices.md) for architecture guidance

For more about watch_it and why we recommend it, see the [watch_it documentation](/documentation/watch_it/getting_started.md).
