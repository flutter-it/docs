# Integration with watch_it

::: warning AI-Generated Content Under Review
This documentation was generated with AI assistance and is currently under review. While we strive for accuracy, there may be errors or inconsistencies. Please report any issues you find.
:::

Use commands with watch_it for builder-free reactive UI. Observe command state without `ValueListenableBuilder` widgets.

## Overview

watch_it provides a cleaner alternative to `ValueListenableBuilder` for observing commands:

**Without watch_it:**
```dart
ValueListenableBuilder<List<Todo>>(
  valueListenable: command,
  builder: (context, todos, _) {
    return ValueListenableBuilder<bool>(
      valueListenable: command.isRunning,
      builder: (context, isRunning, _) {
        // Nested builders...
      },
    );
  },
)
```

**With watch_it:**
```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((Service s) => s.command);
    final isRunning = watchValue((Service s) => s.command.isRunning);
    // Direct usage, no builders!
  }
}
```

## Basic Integration

<<< @/../code_samples/lib/command_it/watch_it_integration_example.dart#example

**How it works:**
1. Register command-containing service with get_it
2. Extend `WatchingWidget` (or `WatchingStatefulWidget`)
3. Use `watchValue()` to observe command properties
4. Widget rebuilds automatically when values change

## watchValue with Commands

### Watch Command Result

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch the command's value (last successful result)
    final data = watchValue((DataService s) => s.loadCommand);

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => ItemTile(data[index]),
    );
  }
}
```

### Watch Loading State

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = watchValue((DataService s) => s.loadCommand.isRunning);

    if (isLoading) {
      return CircularProgressIndicator();
    }

    return DataView();
  }
}
```

### Watch canRun

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final canSave = watchValue((DataService s) => s.saveCommand.canRun);
    final service = GetIt.instance<DataService>();

    return ElevatedButton(
      onPressed: canSave ? service.saveCommand.run : null,
      child: Text('Save'),
    );
  }
}
```

### Watch CommandResult

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch comprehensive state
    final result = watchValue(
      (DataService s) => s.loadCommand.results,
    );

    if (result.isRunning) return LoadingView();
    if (result.hasError) return ErrorView(result.error!);
    if (result.hasData) return DataView(result.data!);
    return InitialView();
  }
}
```

## Multiple Command Properties

Watch multiple properties in the same widget:

```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch multiple command properties
    final todos = watchValue((TodoService s) => s.loadTodosCommand);
    final isLoading = watchValue((TodoService s) => s.loadTodosCommand.isRunning);
    final canAdd = watchValue((TodoService s) => s.addTodoCommand.canRun);
    final hasError = watchValue((TodoService s) => s.loadTodosCommand.errors);

    final service = GetIt.instance<TodoService>();

    return Column(
      children: [
        if (isLoading) LinearProgressIndicator(),
        if (hasError != null) ErrorBanner(error: hasError.error),
        Expanded(
          child: TodoList(todos: todos),
        ),
        FloatingActionButton(
          onPressed: canAdd ? () => service.addTodoCommand(newTodo) : null,
          child: Icon(Icons.add),
        ),
      ],
    );
  }
}
```

**Each `watchValue` creates an independent subscription** - the widget rebuilds when any watched value changes.

## Error Handling with watch_it

```dart
class DataWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((DataService s) => s.loadCommand.results);
    final service = GetIt.instance<DataService>();

    return Column(
      children: [
        if (result.hasError)
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: Icon(Icons.error, color: Colors.red),
              title: Text('Error: ${result.error}'),
              trailing: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: service.loadCommand.run,
              ),
            ),
          ),
        if (result.hasData)
          DataDisplay(data: result.data!),
      ],
    );
  }
}
```

## Service with Commands Pattern

**Recommended pattern:** Commands in services, observed via watch_it:

```dart
// Service containing commands
class UserService {
  final api = ApiClient();

  late final loginCommand = Command.createAsync<LoginData, User>(
    (data) => api.login(data.email, data.password),
    initialValue: User.empty(),
  );

  late final logoutCommand = Command.createAsyncNoParam<void>(
    () => api.logout(),
  );

  late final loadProfileCommand = Command.createAsyncNoParam<UserProfile>(
    () => api.loadProfile(),
    initialValue: UserProfile.empty(),
    restriction: loginCommand.map((user) => !user.isLoggedIn),
  );

  void dispose() {
    loginCommand.dispose();
    logoutCommand.dispose();
    loadProfileCommand.dispose();
  }
}

// Register with get_it
void setupServices() {
  GetIt.instance.registerLazySingleton<UserService>(() => UserService());
}

// UI observes via watch_it
class ProfileWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final profile = watchValue((UserService s) => s.loadProfileCommand);
    final isLoading = watchValue((UserService s) => s.loadProfileCommand.isRunning);

    if (isLoading) return CircularProgressIndicator();

    return ProfileView(profile: profile);
  }
}
```

## WatchingWidget vs WatchingStatefulWidget

### Use WatchingWidget for stateless observation

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((Service s) => s.command);
    return DataView(data: data);
  }
}
```

### Use WatchingStatefulWidget when you need local state

```dart
class MyWidget extends WatchingStatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool showDetails = false; // Local state

  @override
  Widget build(BuildContext context) {
    // Can watch commands AND use local state
    final data = watchValue((Service s) => s.command);

    return Column(
      children: [
        DataView(data: data, showDetails: showDetails),
        ElevatedButton(
          onPressed: () => setState(() => showDetails = !showDetails),
          child: Text('Toggle Details'),
        ),
      ],
    );
  }
}
```

## Reacting to Command Execution

Use `registerHandler` to run code when commands complete:

```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final service = GetIt.instance<TodoService>();

    // React to command completion
    registerHandler(
      select: (TodoService s) => s.addTodoCommand.results,
      handler: (context, result, cancel) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Todo added!')),
          );
        }
      },
    );

    final todos = watchValue((TodoService s) => s.loadTodosCommand);

    return TodoList(
      todos: todos,
      onAdd: service.addTodoCommand,
    );
  }
}
```

## Combining Commands with watch_it Lifecycle

### callOnce for Initial Load

```dart
class DataWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Load data once when widget mounts
    callOnce((DataService s) => s.loadCommand.run);

    final data = watchValue((DataService s) => s.loadCommand);
    final isLoading = watchValue((DataService s) => s.loadCommand.isRunning);

    if (isLoading) return CircularProgressIndicator();
    return DataView(data: data);
  }
}
```

### rebuildOnChange for Manual Control

```dart
class DataWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Only rebuild when data changes, not when isRunning changes
    final data = rebuildOnChange((DataService s) => s.loadCommand.value);

    return DataView(data: data);
  }
}
```

## Performance Considerations

### Watch Specific Properties

```dart
// ❌️️ Inefficient: Rebuilds on every command property change
final command = watchValue((Service s) => s.command);

// ✅ Efficient: Only rebuilds when result value changes
final data = watchValue((Service s) => s.command.value);
```

### Use rebuildOnChange for Selective Rebuilds

```dart
// Only rebuild when canRun changes
final canRun = rebuildOnChange((Service s) => s.command.canRun.value);

// Not when errors change
final data = watchValue((Service s) => s.command);
```

### Avoid Watching in Nested Widgets

```dart
// ❌️️ Bad: Multiple widgets watching same command
class ParentWidget extends WatchingWidget {
  Widget build(BuildContext context) {
    final data = watchValue((Service s) => s.command);
    return ChildWidget(); // Also watches command
  }
}

// ✅ Good: Watch once at parent, pass down
class ParentWidget extends WatchingWidget {
  Widget build(BuildContext context) {
    final data = watchValue((Service s) => s.command);
    return ChildWidget(data: data); // Receives data as prop
  }
}
```

## Common Patterns

### Pattern 1: Pull-to-Refresh

```dart
class DataWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((DataService s) => s.loadCommand);
    final service = GetIt.instance<DataService>();

    return RefreshIndicator(
      onRefresh: () => service.loadCommand.runAsync(),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) => ItemTile(data[index]),
      ),
    );
  }
}
```

### Pattern 2: Search with Debounce

```dart
class SearchWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final results = watchValue((SearchService s) => s.searchCommand);
    final isSearching = watchValue((SearchService s) => s.searchCommand.isRunning);
    final service = GetIt.instance<SearchService>();

    return Column(
      children: [
        TextField(
          onChanged: service.searchTextCommand,
          decoration: InputDecoration(
            hintText: 'Search...',
            suffixIcon: isSearching ? CircularProgressIndicator() : null,
          ),
        ),
        Expanded(
          child: SearchResults(results: results),
        ),
      ],
    );
  }
}
```

### Pattern 3: Chained Commands

```dart
class CheckoutWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final service = GetIt.instance<CheckoutService>();

    // Watch multiple chained commands
    final canValidate = watchValue((CheckoutService s) => s.validateCommand.canRun);
    final canSubmit = watchValue((CheckoutService s) => s.submitCommand.canRun);
    final isProcessing = watchValue((CheckoutService s) => s.submitCommand.isRunning);

    return Column(
      children: [
        CheckoutForm(),
        ElevatedButton(
          onPressed: canValidate ? service.validateCommand.run : null,
          child: Text('Validate'),
        ),
        ElevatedButton(
          onPressed: canSubmit ? service.submitCommand.run : null,
          child: Text(isProcessing ? 'Processing...' : 'Submit'),
        ),
      ],
    );
  }
}
```

## Comparison: ValueListenableBuilder vs watch_it

### ValueListenableBuilder Approach

```dart
class TodoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = GetIt.instance<TodoService>();

    return ValueListenableBuilder<bool>(
      valueListenable: service.loadCommand.isRunning,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<List<Todo>>(
          valueListenable: service.loadCommand,
          builder: (context, todos, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: service.addCommand.canRun,
              builder: (context, canAdd, _) {
                // Deeply nested builders
                if (isLoading) return CircularProgressIndicator();
                return TodoListView(todos: todos, canAdd: canAdd);
              },
            );
          },
        );
      },
    );
  }
}
```

### watch_it Approach

```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = watchValue((TodoService s) => s.loadCommand.isRunning);
    final todos = watchValue((TodoService s) => s.loadCommand);
    final canAdd = watchValue((TodoService s) => s.addCommand.canRun);

    if (isLoading) return CircularProgressIndicator();
    return TodoListView(todos: todos, canAdd: canAdd);
  }
}
```

**Benefits:**
- No nested builders
- Flat, readable code
- Multiple observations without nesting
- Same rebuild efficiency

## See Also

- [Command Properties](/documentation/command_it/command_properties) — Observable properties
- [Command Basics](/documentation/command_it/command_basics) — Creating commands
- [watch_it Documentation](/documentation/watch_it/getting_started) — watch_it package
- [Best Practices](/documentation/command_it/best_practices) — Recommended patterns
