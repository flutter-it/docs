# Command Builders

Simplify command UI integration with `CommandBuilder` - a widget that handles all command states (loading, data, error) with minimal boilerplate.

## Why Use CommandBuilder?

Instead of manually building `ValueListenableBuilder` widgets for `command.results`, use `CommandBuilder` to declaratively handle all command states:

```dart
// Instead of this:
ValueListenableBuilder<CommandResult<void, String>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    if (result.isRunning) return CircularProgressIndicator();
    if (result.hasError) return Text('Error: ${result.error}');
    return Text('Count: ${result.data}');
  },
)

// Use this:
CommandBuilder<void, String>(
  command: command,
  whileRunning: (context, _, __) => CircularProgressIndicator(),
  onError: (context, error, _, __) => Text('Error: $error'),
  onData: (context, value, _) => Text('Count: $value'),
)
```

**Benefits:**
- Cleaner, more declarative code
- Separate builders for each state
- Less nesting than ValueListenableBuilder
- Type-safe parameter access

## Basic Example

<<< @/../code_samples/lib/command_it/command_builder_example.dart#example

## Parameters

All parameters are optional except `command`:

| Parameter | Type | Description |
|-----------|------|-------------|
| **command** | `Command<TParam, TResult>` | Required. The command to observe |
| **onData** | `Widget Function(BuildContext, TResult, TParam?)` | Builder for successful execution with return value |
| **onSuccess** | `Widget Function(BuildContext, TParam?)` | Builder for successful execution (ignores return value) |
| **onNullData** | `Widget Function(BuildContext, TParam?)` | Builder when command returns null |
| **whileRunning** | `Widget Function(BuildContext, TResult?, TParam?)` | Builder while command is executing |
| **onError** | `Widget Function(BuildContext, Object, TResult?, TParam?)` | Builder when command throws error |

### When to Use Each Builder

**onData** - Commands with return values:
```dart
CommandBuilder<String, List<Item>>(
  command: searchCommand,
  onData: (context, items, query) => ItemList(items),  // ✅ Use items
)
```

**onSuccess** - Void commands or when you don't need the result:
```dart
CommandBuilder<Item, void>(
  command: deleteCommand,
  onSuccess: (context, deletedItem) => Text('Deleted: ${deletedItem?.name}'),
)
```

**onNullData** - Handle null results explicitly:
```dart
CommandBuilder<void, Data?>(
  command: fetchCommand,
  onData: (context, data, _) => DataWidget(data),
  onNullData: (context, _) => Text('No data available'),
)
```

**whileRunning** - Show loading state:
```dart
whileRunning: (context, lastValue, param) => Column(
  children: [
    CircularProgressIndicator(),
    if (lastValue != null) Text('Previous: $lastValue'), // Show stale data
    if (param != null) Text('Loading: $param'),
  ],
)
```

**onError** - Handle errors:
```dart
onError: (context, error, lastValue, param) => ErrorWidget(
  error: error,
  onRetry: () => command(param), // Retry with same parameter
)
```

## Showing Parameter in UI

Access the command parameter in any builder:

```dart
CommandBuilder<String, List<Item>>(
  command: searchCommand,
  whileRunning: (context, _, query) => Text('Searching for: $query'),
  onData: (context, items, query) => Column(
    children: [
      Text('Results for: $query'),
      ItemList(items),
    ],
  ),
  onError: (context, error, _, query) => Text('Search "$query" failed: $error'),
)
```

## toWidget() Extension Method

For use with `get_it_mixin`, `provider`, or `flutter_hooks` where you already have access to `CommandResult`:

```dart
class MyWidget extends StatelessWidget with GetItStatefulWidgetMixin {
  @override
  Widget build(BuildContext context) {
    final result = watchX((Manager m) => m.command.results);

    return result.toWidget(
      whileRunning: (lastValue, param) => CircularProgressIndicator(),
      onResult: (data, param) => DataWidget(data),
      onError: (error, lastValue, param) => ErrorWidget(error),
    );
  }
}
```

**Key differences from CommandBuilder:**

| Feature | CommandBuilder | toWidget() |
|---------|---------------|-----------|
| Access to BuildContext | ✅ Yes | ❌ No |
| Requires CommandResult | ❌ No (takes Command) | ✅ Yes |
| Use case | Direct Command usage | Already watching results |

## When to Use What

**Use CommandBuilder when:**
- Building UI directly from a Command
- Need access to BuildContext in builders
- Prefer declarative widget composition
- Don't use state management that exposes results

**Use toWidget() when:**
- Already watching `command.results` via get_it_mixin/provider/hooks
- Don't need BuildContext in builders
- Want slightly less boilerplate

**Use ValueListenableBuilder when:**
- Need complete control over rendering logic
- Complex state combinations beyond standard patterns
- Performance-critical custom caching logic

## Common Patterns

### Loading with Previous Data

Show stale data while loading fresh data:

```dart
CommandBuilder<String, List<Item>>(
  command: searchCommand,
  whileRunning: (context, lastItems, query) => Column(
    children: [
      LinearProgressIndicator(),
      if (lastItems != null)
        Opacity(opacity: 0.5, child: ItemList(lastItems)),
    ],
  ),
  onData: (context, items, _) => ItemList(items),
)
```

### Error with Retry

```dart
onError: (context, error, lastValue, param) => Column(
  children: [
    Text('Error: $error'),
    ElevatedButton(
      onPressed: () => command(param), // Retry with same parameter
      child: Text('Retry'),
    ),
    if (lastValue != null) Text('Last successful: $lastValue'),
  ],
)
```

### Conditional Builders

Not all builders are required - only provide what you need:

```dart
// Minimal: only show data
CommandBuilder<void, String>(
  command: command,
  onData: (context, data, _) => Text(data),
)

// No loading indicator needed
CommandBuilder<void, String>(
  command: command,
  onData: (context, data, _) => Text(data),
  onError: (context, error, _, __) => Text('Error: $error'),
  // whileRunning omitted - shows nothing while loading
)
```

## See Also

- [Command Results](/documentation/command_it/command_results) - Understanding CommandResult structure
- [Command Basics](/documentation/command_it/command_basics) - Creating and running commands
- [Command Properties](/documentation/command_it/command_properties) - The `.results` property
- [Integration with watch_it](/documentation/command_it/watch_it_integration) - Using with reactive state management
