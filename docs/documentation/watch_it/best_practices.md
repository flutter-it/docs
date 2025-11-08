# Best Practices

Production-ready patterns, performance tips, and testing strategies for watch_it applications.

## Architecture Patterns

### Keep Business Logic Out of Widgets

**❌ Bad - Logic in widget:**
```dart
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    // BAD: Business logic in widget
    final filteredTodos = todos.where((todo) {
      if (DateTime.now().hour > 17) {
        return todo.priority > 2;
      }
      return true;
    }).toList();

    return ListView.builder(...);
  }
}
```

**✅ Good - Logic in manager:**
```dart
// In TodoManager
class TodoManager {
  final todos = ValueNotifier<List<Todo>>([]);

  // Business logic HERE
  ValueListenable<List<Todo>> get filteredTodos =>
      todos.map((list) =>
        list.where((todo) =>
          DateTime.now().hour > 17
            ? todo.priority > 2
            : true
        ).toList()
      );
}

// In widget - just display
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.filteredTodos);
    return ListView.builder(...);
  }
}
```

### Self-Contained Widgets

Widgets should access their dependencies directly from get_it, not via constructor parameters.

**❌ Bad - Passing managers as parameters:**
```dart
class TodoList extends WatchingWidget {
  TodoList({required this.manager});  // DON'T DO THIS
  final TodoManager manager;

  @override
  Widget build(BuildContext context) {
    final todos = watch(manager.todos).value;
    return ListView(...);
  }
}
```

**✅ Good - Access directly:**
```dart
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return ListView(...);
  }
}
```

**Why?** Self-contained widgets are:
- Easier to test (mock get_it, not constructor params)
- Easier to refactor
- Don't expose internal dependencies
- Can access multiple services without param explosion

### Separate UI State from Business State

**Local UI state** (form input, expansion, selection):
```dart
class ExpandableCard extends WatchingStatefulWidget {
  State createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _expanded = false;  // Local UI state

  @override
  Widget build(BuildContext context) {
    // Business state from watch_it
    final data = watchValue((Manager m) => m.data);

    return ExpansionTile(
      initiallyExpanded: _expanded,
      onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
      children: [...],
    );
  }
}
```

**Business state** (data from API, shared state):
```dart
// In manager - registered in get_it
class DataManager {
  final data = ValueNotifier<List<Item>>([]);

  void fetchData() async {
    data.value = await api.getData();
  }
}
```

## Performance Optimization

### Minimize Watch Scope

Watch only what you need. Don't watch the whole manager if you only need one property.

**❌ Bad - Watching too much:**
```dart
final manager = watchIt<TodoManager>();  // Rebuilds on ANY change
final todos = manager.todos.value;
```

**✅ Good - Watch specific property:**
```dart
final todos = watchValue((TodoManager m) => m.todos);  // Only rebuilds when todos change
```

### Use watchPropertyValue for Selective Updates

When watching a `Listenable` with many properties, use `watchPropertyValue()` to rebuild only when specific property changes:

**❌ Bad - Rebuilds on every settings change:**
```dart
final settings = watchIt<SettingsModel>();
final darkMode = settings.darkMode;  // Rebuilds even when other settings change
```

**✅ Good - Rebuilds only when darkMode changes:**
```dart
final darkMode = watchPropertyValue((SettingsModel s) => s.darkMode);
```

### Split Large Widgets

Don't watch everything in one giant widget. Split into smaller widgets that watch only what they need.

**❌ Bad - One widget watches everything:**
```dart
class Dashboard extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final user = watchValue((UserModel m) => m.user);
    final todos = watchValue((TodoManager m) => m.todos);
    final settings = watchValue((Settings m) => m.darkMode);

    return Column(
      children: [
        // When ANYTHING changes, ENTIRE dashboard rebuilds
        UserHeader(user: user),
        TodoList(todos: todos),
        SettingsPanel(darkMode: settings),
      ],
    );
  }
}
```

**✅ Good - Each widget watches its own data:**
```dart
class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserHeader(),      // Only rebuilds when user changes
        TodoList(),        // Only rebuilds when todos change
        SettingsPanel(),   // Only rebuilds when settings change
      ],
    );
  }
}

class UserHeader extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final user = watchValue((UserModel m) => m.user);
    return Text(user.name);
  }
}

class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return ListView.builder(...);
  }
}
```

### Const Constructors

Use `const` constructors with `WatchItMixin` for better performance:

```dart
class TodoCard extends StatelessWidget with WatchItMixin {
  const TodoCard({super.key, required this.todoId});  // const!
  final String todoId;

  @override
  Widget build(BuildContext context) {
    final todo = watchValue((TodoManager m) => m.getTodo(todoId));
    return Card(...);
  }
}

// Usage
ListView.builder(
  itemBuilder: (context, index) =>
    const TodoCard(todoId: ids[index]),  // const!
);
```

Flutter can optimize const widgets for better rebuild performance.

### Derived Data in Manager

Compute derived data in the manager, not in the widget:

**❌ Bad - Computing in widget:**
```dart
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    // Recomputes on EVERY rebuild
    final completedCount = todos.where((t) => t.completed).length;
    final pendingCount = todos.length - completedCount;

    return Text('$completedCount / $pendingCount');
  }
}
```

**✅ Good - Computed in manager:**
```dart
class TodoManager {
  final todos = ValueNotifier<List<Todo>>([]);

  // Cached computation
  ValueListenable<int> get completedCount =>
      todos.map((list) => list.where((t) => t.completed).length);

  ValueListenable<int> get pendingCount =>
      todos.map((list) => list.length - completedCount);
}

class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final completed = watchValue((TodoManager m) => m.completedCount);
    final pending = watchValue((TodoManager m) => m.pendingCount);

    return Text('$completed / $pending');
  }
}
```

## Testing

### Test Business Logic Separately

Test managers/services independently of widgets:

```dart
void main() {
  late TodoManager manager;

  setUp(() {
    manager = TodoManager();
  });

  test('addTodo increases todo count', () {
    expect(manager.todos.value.length, 0);

    manager.addTodo('Test todo');

    expect(manager.todos.value.length, 1);
    expect(manager.todos.value.first.title, 'Test todo');
  });

  test('completeTodo updates status', () {
    final todo = manager.addTodo('Test');

    manager.completeTodo(todo.id);

    expect(manager.todos.value.first.completed, true);
  });
}
```

### Mock get_it for Widget Tests

```dart
testWidgets('TodoList displays todos', (tester) async {
  // Mock get_it
  final mockManager = MockTodoManager();
  when(mockManager.todos).thenReturn(
    ValueNotifier([
      Todo(id: '1', title: 'Test Todo'),
    ]),
  );

  GetIt.I.registerSingleton<TodoManager>(mockManager);

  await tester.pumpWidget(
    MaterialApp(home: TodoList()),
  );

  expect(find.text('Test Todo'), findsOneWidget);
});
```

### Test Reactive Updates

```dart
testWidgets('TodoList updates when todos change', (tester) async {
  final manager = TodoManager();
  GetIt.I.registerSingleton<TodoManager>(manager);

  await tester.pumpWidget(
    MaterialApp(home: TodoList()),
  );

  // Initially empty
  expect(find.byType(ListTile), findsNothing);

  // Add todo
  manager.addTodo('New Todo');
  await tester.pump();  // Rebuild

  // Now shows todo
  expect(find.text('New Todo'), findsOneWidget);
});
```

### Test Handlers

```dart
testWidgets('shows snackbar on success', (tester) async {
  final manager = TodoManager();
  GetIt.I.registerSingleton<TodoManager>(manager);

  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: TodoForm())),
  );

  // Trigger command
  manager.createTodoCommand.execute('New Todo');
  await tester.pump();  // Process command
  await tester.pump();  // Show snackbar

  expect(find.byType(SnackBar), findsOneWidget);
  expect(find.text('Todo created!'), findsOneWidget);
});
```

## Code Organization

### Manager/Service Structure

```dart
class TodoManager {
  // ValueNotifiers for reactive state
  final todos = ValueNotifier<List<Todo>>([]);
  final isLoading = ValueNotifier<bool>(false);

  // Commands for async operations
  late final fetchCommand = Command.createAsyncNoParam(
    _fetchTodos,
    initialValue: <Todo>[],
  );

  late final createCommand = Command.createAsync<Todo, String>(
    _createTodo,
    initialValue: null,
  );

  // Private implementation
  Future<List<Todo>> _fetchTodos() async {
    isLoading.value = true;
    try {
      final result = await api.getTodos();
      todos.value = result;
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Todo> _createTodo(String title) async {
    final todo = await api.createTodo(title);
    todos.value = [...todos.value, todo];
    return todo;
  }

  // Cleanup
  void dispose() {
    todos.dispose();
    isLoading.dispose();
  }
}
```

### Widget Structure

```dart
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // 1. Watch reactive state
    final todos = watchValue((TodoManager m) => m.todos);
    final isLoading = watchValue((TodoManager m) => m.isLoading);

    // 2. Register handlers
    registerHandler(
      select: (TodoManager m) => m.createCommand,
      handler: _onTodoCreated,
    );

    // 3. One-time initialization
    callOnce((_) {
      di<TodoManager>().fetchCommand.execute();
    });

    // 4. Build UI
    if (isLoading) return CircularProgressIndicator();
    return ListView.builder(...);
  }

  void _onTodoCreated(BuildContext context, Command? command, Function cancel) {
    if (command?.value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo created!')),
      );
    }
  }
}
```

## Common Patterns

### Master-Detail Navigation

```dart
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    registerHandler(
      select: (TodoManager m) => m.selectedTodo,
      handler: (context, todo, cancel) {
        if (todo != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TodoDetail(todoId: todo.id),
            ),
          );
        }
      },
    );

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.title),
          onTap: () {
            di<TodoManager>().selectTodo(todo);
          },
        );
      },
    );
  }
}
```

### Pull-to-Refresh

```dart
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    return RefreshIndicator(
      onRefresh: () async {
        final manager = di<TodoManager>();
        manager.fetchCommand.execute();
        await manager.fetchCommand.executeWithFuture();
      },
      child: ListView.builder(...),
    );
  }
}
```

### Search/Filter

```dart
class SearchableList extends WatchingStatefulWidget {
  State createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = watchValue((Manager m) => m.items);

    final filtered = items
        .where((item) => item.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(hintText: 'Search...'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                ItemCard(item: filtered[index]),
          ),
        ),
      ],
    );
  }
}
```

### Pagination

```dart
class PaginatedList extends WatchingStatefulWidget {
  State createState() => _PaginatedListState();
}

class _PaginatedListState extends State<PaginatedList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      di<Manager>().loadMoreCommand.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = watchValue((Manager m) => m.items);
    final isLoadingMore = watchValue((Manager m) => m.loadMoreCommand.isExecuting);

    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Center(child: CircularProgressIndicator());
        }
        return ItemCard(item: items[index]);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

## Anti-Patterns

### ❌ Don't Access get_it in Constructors

```dart
// BAD
class MyWidget extends WatchingWidget {
  MyWidget() {
    final manager = di<Manager>();  // DON'T DO THIS
    manager.init();
  }
}

// GOOD
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((_) {
      di<Manager>().init();  // Do this instead
    });
    return YourUI();
  }
}
```

### ❌ Don't Violate Watch Ordering Rules

```dart
// BAD - conditional watch calls
if (showDetails) {
  final details = watchValue((M m) => m.details);  // Order changes!
}
```

See [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) for details.

### ❌ Don't Await execute()

```dart
// BAD - blocks UI
ElevatedButton(
  onPressed: () async {
    await di<Manager>().command.executeWithFuture();  // Blocks!
  },
  child: Text('Submit'),
)

// GOOD - non-blocking
ElevatedButton(
  onPressed: () => di<Manager>().command.execute(),  // Returns immediately
  child: Text('Submit'),
)
```

### ❌ Don't Put Watch Calls in Callbacks

```dart
// BAD
ElevatedButton(
  onPressed: () {
    final data = watchValue((M m) => m.data);  // Wrong context!
  },
)

// GOOD
final data = watchValue((M m) => m.data);  // In build()
ElevatedButton(
  onPressed: () {
    doSomething(data);  // Use the value
  },
)
```

## Debugging Tips

### Enable watch_it Tracing

```dart
void main() {
  GetIt.I.enableWatchItTracing = true;  // See all watch subscriptions
  runApp(MyApp());
}
```

### Log Watch Calls

```dart
final todos = watchValue(
  (TodoManager m) => m.todos,
  debugLabel: 'TodoList.todos',  // Shows in traces
);
```

### Check Rebuild Frequency

```dart
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    print('TodoList rebuild at ${DateTime.now()}');  // Track rebuilds

    final todos = watchValue((TodoManager m) => m.todos);
    return ListView.builder(...);
  }
}
```

## See Also

- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - CRITICAL constraints
- [Debugging & Troubleshooting](/documentation/watch_it/debugging_tracing.md) - Common issues
- [Observing Commands](/documentation/watch_it/observing_commands.md) - command_it integration
- [Testing](/documentation/get_it/testing.md) - Testing with get_it
