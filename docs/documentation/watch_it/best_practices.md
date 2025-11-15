# Best Practices

::: warning
This content is AI generated and is currently under review.
:::

Production-ready patterns, performance tips, and testing strategies for `watch_it` applications.

## Architecture Patterns

### Keep Business Logic Out of Widgets

**❌️ Bad - Logic in widget:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#logic_in_widget_bad

**✅ Good - Logic in manager:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#logic_in_manager_good_manager

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#logic_in_manager_good_widget

### Self-Contained Widgets

Widgets should access their dependencies directly from get_it, not via constructor parameters.

**❌️ Bad - Passing managers as parameters:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#passing_managers_bad

**✅ Good - Access directly:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#access_directly_good

**Why?** Self-contained widgets are:
- Easier to test (mock get_it, not constructor params)
- Easier to refactor
- Don't expose internal dependencies
- Can access multiple services without param explosion

### Separate UI State from Business State

**Local UI state** (form input, expansion, selection):

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#local_ui_state

**Business state** (data from API, shared state):

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#business_state

## Performance Optimization

### Minimize Watch Scope

Watch only what you need. Don't watch the whole manager if you only need one property.

**❌️ Bad - Watching too much:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#watching_too_much_bad

**✅ Good - Watch specific property:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#watch_specific_good

### Use watchPropertyValue for Selective Updates

When watching a `Listenable` with many properties, use `watchPropertyValue()` to rebuild only when specific property changes:

**❌️ Bad - Rebuilds on every settings change:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#rebuilds_on_every_settings_bad

**✅ Good - Rebuilds only when darkMode changes:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#rebuilds_only_darkmode_good

### Split Large Widgets

Don't watch everything in one giant widget. Split into smaller widgets that watch only what they need.

**❌️ Bad - One widget watches everything:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#one_widget_watches_everything_bad

**✅ Good - Each widget watches its own data:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_dashboard

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_user_header

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_todo_list

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_settings_panel

### Const Constructors

Use `const` constructors with `WatchItMixin` for better performance:

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#const_constructors

Flutter can optimize const widgets for better rebuild performance.

### Derived Data in Manager

Compute derived data in the manager, not in the widget:

**❌️ Bad - Computing in widget:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#computing_in_widget_bad

**✅ Good - Computed in manager:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#computed_in_manager_good_manager

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#computed_in_manager_good_widget

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
  manager.createTodoCommand.run('New Todo');
  await tester.pump();  // Process command
  await tester.pump();  // Show snackbar

  expect(find.byType(SnackBar), findsOneWidget);
  expect(find.text('Todo created!'), findsOneWidget);
});
```

## Code Organization

### Manager/Service Structure

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#manager_service_structure

### Widget Structure

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#widget_structure

## Common Patterns

### Master-Detail Navigation

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#master_detail_navigation

### Pull-to-Refresh

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#pull_to_refresh_pattern

### Search/Filter

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#search_filter_pattern

### Pagination

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#pagination_pattern

## Anti-Patterns

### ❌️ Don't Access get_it in Constructors

**GOOD - Use callOnce:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_access_getit_constructors_good

### ❌️ Don't Violate Watch Ordering Rules

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_violate_ordering_bad

See [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) for details.

### ❌️ Don't Await execute()

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_await_execute_bad_anti

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_await_execute_good_anti

### ❌️ Don't Put Watch Calls in Callbacks

See [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - watch calls must be in build(), not in callbacks.

## Debugging Tips

### Enable watch_it Tracing

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#enable_tracing

### Log Watch Calls

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#log_watch_calls

### Check Rebuild Frequency

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#check_rebuild_frequency

## See Also

- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - CRITICAL constraints
- [Debugging & Troubleshooting](/documentation/watch_it/debugging_tracing.md) - Common issues
- [Observing Commands](/documentation/watch_it/observing_commands.md) - command_it integration
- [Testing](/documentation/get_it/testing.md) - Testing with get_it
