# Command Basics

Learn how to create and run commands, the foundation of command_it.

::: tip Examples Use watch_it
All examples use **watch_it** for observing commands. See [Without watch_it](/documentation/command_it/without_watch_it.md) if you prefer `ValueListenableBuilder`.
:::

## What is a Command?

A **Command** wraps a function (sync or async) and makes it observable. Instead of calling a function directly and manually tracking its state, you create a command that:

- Executes your function when called
- Automatically tracks execution state (`isRunning`)
- Publishes results via `ValueListenable`
- Handles errors gracefully
- Prevents parallel execution

**Think of it as**: A function + automatic state management + reactive notifications.

::: tip The Command Pattern
The core philosophy: **Start commands with `run()` (fire and forget), then your app/UI observes and reacts to their state changes**. This reactive pattern keeps your UI responsive with no blocking—you trigger the action and let your UI automatically respond to loading states, results, and errors.
:::

## Creating Your First Command

Commands are created using static factory functions, not constructors. The most common type is `createAsyncNoParam` for async functions without parameters:

<<< @/../code_samples/lib/command_it/counter_basic_example.dart#example

**What happens:**
1. Command wraps your async function
2. When `run()` is called, the function executes
3. While running, `isRunning` is `true`
4. Result is published to `value` property
5. UI rebuilds automatically via `watchValue`

## Running Commands

There are two ways to execute a command:

### 1. Using `run()` (Fire and Forget)

```dart
// Call the command's run method
loadDataCommand.run();

// Or with a parameter
searchCommand.run('flutter');
```

Use `run()` when you want to trigger execution without waiting for the result. Perfect for button handlers.

### 2. Calling as Callable Class

Commands are callable classes, so you can invoke them directly:

```dart
// Callable - same as run()
loadDataCommand();

// With parameter
searchCommand('flutter');
```

This is just shorthand for `run()` - it doesn't return a value.

::: tip Why Use `.run` for Tearoffs?
In the past, it was possible to pass callable classes directly as tearoffs. However, due to changes in Dart, this is no longer possible. For optional VoidCallbacks (like `onPressed`), passing a callable class directly is now a **compiler error**. Even when it compiles, it triggers the `implicit_call_tearoffs` linter warning because Dart implicitly tears off the `.call()` method, which is considered unclear.

**Always use `.run` for tearoffs:**
```dart
// ✅ Good - explicit tearoff
ElevatedButton(onPressed: command.run, ...)

// ❌ Avoid - implicit call tearoff (compiler error for optional VoidCallback)
ElevatedButton(onPressed: command, ...)
```

This is why command_it renamed from `execute()` to `run()` in v9.0.0 - making the explicit method the primary API.
:::

### 3. Using `runAsync()` (Await Result)

Use `runAsync()` when you need to await the result:

```dart
final result = await loadDataCommand.runAsync();
```

::: warning Use Sparingly
`runAsync()` breaks the fire-and-forget pattern described above. Only use it when an API requires a Future to be returned (like `RefreshIndicator.onRefresh`). For normal application code, always use `run()` and observe state changes reactively.
:::

Perfect for `RefreshIndicator`:

```dart
RefreshIndicator(
  onRefresh: () => updateCommand.runAsync(),
  child: ListView(...),
)
```

## Commands with Parameter and Return Type

Most commands need both parameters and return values. Use `createAsync<TParam, TResult>` for async functions with a parameter and result:

```dart
late final searchCommand = Command.createAsync<String, List<Todo>>(
  (query) async {
    await Future.delayed(Duration(milliseconds: 500));
    return fakeTodos.where((t) => t.title.contains(query)).toList();
  },
  initialValue: [],
);

// Call with parameter
searchCommand.run('flutter');
```

**Type parameters:**
- First type (`String`) = parameter type
- Second type (`List<Todo>`) = result type

## Synchronous Commands

For synchronous functions, use `createSync`:

```dart
late final formatCommand = Command.createSync<String, String>(
  (text) => text.toUpperCase(),
  initialValue: '',
);

// Use exactly like async commands
formatCommand.run('hello');
```

**Important:** Sync commands don't support `isRunning` - accessing it will throw an exception because the UI can't update while synchronous functions execute.

## Initial Values

Commands that return a value require an `initialValue`:

```dart
Command.createAsyncNoParam<List<Todo>>(
  () => api.fetchTodos(),
  initialValue: [], // Required: what value before first execution?
);
```

**Why?** Commands are `ValueListenable<TResult>`. They need a value from the start, before the first execution completes. This is especially important if the command's value should be displayed in a widget—widgets need a value on the first build even if the command hasn't run yet.

Commands returning `void` don't need initial values:

```dart
Command.createAsyncNoResult<String>(
  (message) => api.sendMessage(message),
  // No initialValue needed
);
```

## Automatic Parallel Execution Prevention

Commands automatically prevent parallel execution:

```dart
final saveCommand = Command.createAsyncNoParam<void>(
  () async {
    await Future.delayed(Duration(seconds: 2));
    await api.save();
  },
);

// Click button rapidly
saveCommand.run(); // Starts execution
saveCommand.run(); // Ignored - already running
saveCommand.run(); // Ignored - already running
// ... 2 seconds pass ...
saveCommand.run(); // Now this one executes
```

**This prevents:**
- Double-submissions
- Race conditions
- Wasted API calls

## Using Commands in Managers

**Best practice:** Create commands in manager/controller classes, not in widgets:

```dart
class TodoManager {
  final api = ApiClient();

  late final loadTodosCommand = Command.createAsyncNoParam<List<Todo>>(
    () => api.fetchTodos(),
    initialValue: [],
  );

  late final saveTodoCommand = Command.createAsyncNoResult<Todo>(
    (todo) => api.saveTodo(todo),
  );
}

// In widget
class TodoListWidget extends StatelessWidget {
  final manager = TodoManager();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Todo>>(
      valueListenable: manager.loadTodosCommand,
      builder: (context, todos, _) => ListView(...),
    );
  }
}
```

**Why?**
- Separates business logic from UI
- Easier to test
- Reusable across widgets
- Clear responsibility boundaries

## Disposing Commands

Commands must be disposed to prevent memory leaks:

```dart
class TodoManager {
  late final loadCommand = Command.createAsyncNoParam<List<Todo>>(...);

  void dispose() {
    loadCommand.dispose();
  }
}
```

**When using StatefulWidget:**

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TodoManager manager;

  @override
  void initState() {
    super.initState();
    manager = TodoManager();
  }

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ...;
}
```

**With get_it:** Register as singleton and dispose on app shutdown or use scopes for automatic cleanup. **With watch_it:** Use [`createOnce()`](/documentation/watch_it/lifecycle_functions#createonce) for automatic lifecycle management.

## See Also

- [Command Properties](/documentation/command_it/command_properties) — value, isRunning, canRun, errors, results
- [Command Types](/documentation/command_it/command_types) — All factory functions
- [Error Handling](/documentation/command_it/error_handling) — Handling errors gracefully
- [Best Practices](/documentation/command_it/best_practices) — Production patterns
