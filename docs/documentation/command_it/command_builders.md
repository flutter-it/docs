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
CommandBuilder(
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

**Generic Types:**
- `TParam` - The parameter that was passed when the command was called (e.g., the search query)
- `TResult` - The return value from the command's execution

| Parameter | Type | Description |
|-----------|------|-------------|
| **command** | `Command<TParam, TResult>` | Required. The command to observe |
| **onData** | `Widget Function(BuildContext, TResult, TParam?)` | Builder for successful execution with return value |
| **onSuccess** | `Widget Function(BuildContext, TParam?)` | Builder for successful execution (ignores return value) |
| **onNullData** | `Widget Function(BuildContext, TParam?)` | Builder when command returns null |
| **whileRunning** | `Widget Function(BuildContext, TResult?, TParam?)` | Builder while command is executing |
| **onError** | `Widget Function(BuildContext, Object, TResult?, TParam?)` | Builder when command throws error |
| **runCommandOnFirstBuild** | `bool` | If true, executes command in initState (default: false) |
| **initialParam** | `TParam?` | Parameter to pass when runCommandOnFirstBuild is true |

### When to Use Each Builder

**onData** - Commands with return values:
```dart
CommandBuilder(
  command: searchCommand,
  onData: (context, items, query) => ItemList(items),  // ✅ Use items
)
```

**onSuccess** - Void commands or when you don't need the result:
```dart
CommandBuilder(
  command: deleteCommand,
  onSuccess: (context, deletedItem) => Text('Deleted: ${deletedItem?.name}'),
)
```

**onNullData** - Handle null results explicitly:
```dart
CommandBuilder(
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

::: tip
The `lastValue` parameter in `whileRunning` and `onError` will only contain data if the command was created with `includeLastResultInCommandResults: true`. Otherwise, it will always be `null`. See [includeLastResultInCommandResults](/documentation/command_it/command_results#includelastresultincommandresults).
:::

## Showing Parameter in UI

Access the command parameter in any builder:

```dart
CommandBuilder(
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

## Auto-Running Commands on Mount

CommandBuilder can automatically execute a command when the widget is first built using the `runCommandOnFirstBuild` parameter. This is particularly useful when not using watch_it (which provides `callOnce` for this purpose).

### Basic Usage (No Parameter)

```dart
CommandBuilder(
  command: loadTodosCommand,
  runCommandOnFirstBuild: true, // Executes command in initState
  whileRunning: (context, _, __) => CircularProgressIndicator(),
  onData: (context, todos, _) => TodoList(todos),
  onError: (context, error, _, __) => ErrorWidget(error),
)
```

**What happens:**
1. Widget builds
2. Command executes automatically in `initState`
3. UI shows loading state → data/error state
4. Command only runs **once** - not on rebuilds

### With Parameters

Use `initialParam` to pass a parameter to the command:

```dart
CommandBuilder(
  command: searchCommand,
  runCommandOnFirstBuild: true,
  initialParam: 'flutter', // Parameter to pass
  whileRunning: (context, _, query) => Text('Searching for: $query'),
  onData: (context, items, query) => ItemList(items),
  onError: (context, error, _, query) => Text('Search failed: $error'),
)
```

### When to Use

**✅ Use runCommandOnFirstBuild when:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Not using watch_it (no access to `callOnce`)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Widget should load its own data on mount</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Want self-contained data-loading widgets</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Simple data fetching scenarios</li>
</ul>

**❌️ Don't use when:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Using watch_it - prefer `callOnce` instead (clearer separation)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Command is already running elsewhere</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Need conditional logic before running</li>
</ul>

### Comparison with watch_it's callOnce

**With watch_it (recommended if using watch_it):**
```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((Manager m) => m.loadTodos()); // Explicit trigger

    return CommandBuilder(
      command: getIt<Manager>().loadTodos,
      onData: (context, todos, _) => TodoList(todos),
    );
  }
}
```

**Without watch_it (use runCommandOnFirstBuild):**
```dart
class TodoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommandBuilder(
      command: getIt<Manager>().loadTodos,
      runCommandOnFirstBuild: true, // Built-in trigger
      onData: (context, todos, _) => TodoList(todos),
    );
  }
}
```

## Builder Precedence Rules

Both `CommandBuilder` and `CommandResult.toWidget()` use the same precedence rules when determining which builder to call:

**Full precedence order:**
1. **`if (error != null)`** → call `onError`
2. **`if (isRunning)`** → call `whileRunning`
3. **`if (onSuccess != null)`** → call `onSuccess` ⚠️ **Takes priority over onData!**
4. **`if (data != null)`** → call `onData`
5. **`else`** → call `onNullData`

::: tip onData vs onSuccess
**When command completes successfully:**
1. If `onSuccess` provided → call it (doesn't check if data is null)
2. Else if data != null → call `onData`
3. Else → call `onNullData`

**Choose `onSuccess` when:**
- Command returns void (e.g., `Command.createAsyncNoResult`)
- You only need to show confirmation/success message
- Result data is irrelevant to the UI

**Choose `onData` when:**
- Command returns data you need to display/use
- You want to handle non-null data differently from null data
:::

## toWidget() Extension Method

The `.toWidget()` extension method on `CommandResult` provides the same declarative builder pattern as `CommandBuilder`, but for use when you already have access to a `CommandResult` (e.g., via `watch_it`, `provider`, or `flutter_hooks`).

<<< @/../code_samples/lib/command_it/command_result_towidget_example.dart#example

**Parameters:**

You must provide **at least one** of these two:

- **`onData`** - `Widget Function(TResult result, TParam? param)?`
  - Called when command has **non-null data** (only if `onSuccess` not provided)
  - Receives both the result data and parameter
  - Use for commands that return data you need to display

- **`onSuccess`** - `Widget Function(TParam? param)?`
  - Called on successful completion (no error, not running)
  - Does **NOT** receive result data, only the parameter
  - **Takes priority** over `onData` if both provided
  - Use for void-returning commands or when you don't need the result value

Optional builders:

- **`whileRunning`** - `Widget Function(TResult? lastResult, TParam? param)?`
  - Called while command executes
  - Receives last result (if `includeLastResultInCommandResults: true`) and parameter

- **`onError`** - `Widget Function(Object error, TResult? lastResult, TParam? param)?`
  - Called when error occurs
  - Receives error, last result, and parameter

- **`onNullData`** - `Widget Function(TParam? param)?`
  - Called when data is null (only if neither `onSuccess` nor `onData` handle it)
  - Receives only the parameter

**Key differences from CommandBuilder:**

| Feature | CommandBuilder | toWidget() |
|---------|---------------|-----------|
| BuildContext in builders | ✅ Yes (as parameter) | ❌️ No (access from enclosing build) |
| Requires CommandResult | ❌️ No (takes Command) | ✅ Yes |
| Use case | Direct Command usage | Already watching results |
| Builder precedence | Same as toWidget() | Same as CommandBuilder |

## When to Use What

**Use CommandBuilder when:**
- Building UI directly from a Command
- Prefer declarative widget composition
- Don't use state management that exposes results
- Want BuildContext passed to builder functions

**Use toWidget() when:**
- Already watching `command.results` via watch_it/provider/hooks
- Want simpler builder signatures (no BuildContext parameter)
- Prefer less boilerplate when already subscribed to results

**Use ValueListenableBuilder when:**
- Need complete control over rendering logic
- Complex state combinations beyond standard patterns
- Performance-critical custom caching logic

## Common Patterns

### Loading with Previous Data

Show stale data while loading fresh data:

::: warning Required Configuration
This pattern requires the command to be created with `includeLastResultInCommandResults: true`. Without this option, `lastItems` will always be `null` during execution. See [Command Results - includeLastResultInCommandResults](/documentation/command_it/command_results#includelastresultincommandresults) for details.
:::

```dart
// Command must be created with this option:
final searchCommand = Command.createAsync<String, List<Item>>(
  searchApi,
  [],
  includeLastResultInCommandResults: true, // Required for pattern below
);

CommandBuilder(
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

::: warning Required Configuration
To display the last successful value (line 7), the command must be created with `includeLastResultInCommandResults: true`. See [Command Results - includeLastResultInCommandResults](/documentation/command_it/command_results#includelastresultincommandresults).
:::

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
CommandBuilder(
  command: command,
  onData: (context, data, _) => Text(data),
)

// No loading indicator needed
CommandBuilder(
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
