# Command Basics

Learn how to create and run commands, the foundation of command_it.

## What is a Command?

A **Command** wraps a function (sync or async) and makes it observable. Instead of calling a function directly and manually tracking its state, you create a command that:

- Executes your function when called
- Automatically tracks execution state (`isRunning`)
- Publishes results via `ValueListenable`
- Handles errors gracefully
- Prevents parallel execution

**Think of it as**: A function + automatic state management + reactive notifications.

## Creating Your First Command

Commands are created using static factory functions, not constructors. The most common type is `createAsyncNoParam` for async functions without parameters:

<<< @/../code_samples/lib/command_it/counter_basic_example.dart#example

**What happens:**
1. Command wraps your async function
2. When `run()` is called, the function executes
3. While running, `isRunning` is `true`
4. Result is published to `value` property
5. UI rebuilds automatically via `ValueListenableBuilder`

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

### 2. Using `call()` or `runAsync()` (Await Result)

```dart
// Commands are callable - implicit call()
final result = await loadDataCommand();

// Or explicitly with runAsync()
final result = await loadDataCommand.runAsync();
```

Use `runAsync()` when you need to await the result, like with `RefreshIndicator`:

```dart
RefreshIndicator(
  onRefresh: () => updateCommand.runAsync(),
  child: ListView(...),
)
```

## Command with Parameters

Most commands need parameters. Use `createAsync` for async functions with a parameter:

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

**Important:** Sync commands don't support `isRunning` because the UI can't update while they execute.

## Initial Values

Commands that return a value require an `initialValue`:

```dart
Command.createAsyncNoParam<List<Todo>>(
  () => api.fetchTodos(),
  initialValue: [], // Required: what value before first execution?
);
```

**Why?** Commands are `ValueListenable<TResult>`. They need a value from the start, before the first execution completes.

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

  late final saveTodoCommand = Command.createAsync<Todo, void>(
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
  final manager = TodoManager();

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ...;
}
```

**With get_it:** Register as singleton and dispose on app shutdown or use scopes for automatic cleanup.

## See Also

- [Command Properties](/documentation/command_it/command_properties) — value, isRunning, canRun, errors, results
- [Command Types](/documentation/command_it/command_types) — All factory functions
- [Error Handling](/documentation/command_it/error_handling) — Handling errors gracefully
- [Best Practices](/documentation/command_it/best_practices) — Production patterns
