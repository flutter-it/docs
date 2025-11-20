# Best Practices

Production-ready patterns, performance tips, and testing strategies for `watch_it` applications.

## Architecture Patterns

### Self-Contained Widgets

Widgets should access their dependencies directly from `get_it`, not via constructor parameters.

**❌️ Bad - Passing managers as parameters:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#passing_managers_bad

**✅ Good - Access directly:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#access_directly_good

**Why?** Self-contained widgets are:
- Easier to test (mock `get_it`, not constructor params)
- Easier to refactor
- Don't expose internal dependencies
- Can access multiple services without param explosion

### Separate UI State from Business State

**Local UI state** (form input, expansion, selection):

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#local_ui_state

**Business state** (data from API, shared state):

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#business_state

### Local Reactive State with createOnce

For widget-local reactive state that doesn't need `get_it` registration, combine `createOnce` with `watch`:

<<< @/../code_samples/lib/watch_it/watch_create_once_local_state.dart#example

**When to use this pattern:**
- Widget needs its own local reactive state
- State should persist across rebuilds (not recreated)
- State should be automatically disposed with widget
- Don't want to register in `get_it` (truly local)

**Key benefits:**
- `createOnce` creates the notifier once and auto-disposes it
- `watch` subscribes to changes and triggers rebuilds
- No manual lifecycle management needed

## Performance Optimization

### Watch Only What You Need

Watch specific properties, not entire objects. The approach depends on your manager's structure:

**For managers with ValueListenable properties** - use `watchValue()`:

**❌️ Bad - Watching whole manager:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#watching_too_much_bad

**✅ Good - Watch specific ValueListenable property:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#watch_specific_good

**For ChangeNotifier managers** - use `watchPropertyValue()` to rebuild only when a specific property value changes:

**❌️ Bad - Rebuilds on every notifyListeners call:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#rebuilds_on_every_settings_bad

**✅ Good - Rebuilds only when darkMode value changes:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#rebuilds_only_darkmode_good

### Split Large Widgets

Don't watch everything in one giant widget. Split into smaller widgets that watch only what they need. This ensures that only the smaller widgets rebuild when their data changes.

**❌️ Bad - One widget watches everything:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#one_widget_watches_everything_bad

**✅ Good - Each widget watches its own data:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_dashboard

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_user_header

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_todo_list

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_settings_panel

### Const Constructors

::: tip Use const with your watching widgets
Const constructors work with all `watch_it` widget types: `WatchingWidget`, `WatchingStatefulWidget`, and widgets using `WatchItMixin`. Flutter can optimize const widgets for better rebuild performance.
:::

## Testing

### Test Business Logic Separately

Keep your business logic (managers, services) separate from widgets and test them independently:

**Unit test the manager:**
```dart
test('TodoManager filters completed todos', () {
  final manager = TodoManager();
  manager.addTodo('Task 1');
  manager.addTodo('Task 2');
  manager.todos[0].complete();

  expect(manager.completedTodos.length, 1);
  expect(manager.activeTodos.length, 1);
});
```

**No Flutter dependencies = fast tests.**

### Test Widgets with Mocked Dependencies

For widget tests, use scopes to isolate dependencies. **Critical:** You must register any object that your widget watches BEFORE calling `pumpWidget`:

```dart
testWidgets('TodoListWidget displays todos', (tester) async {
  // Use a scope for test isolation
  await GetIt.I.pushNewScope();

  // Register mocks BEFORE pumpWidget
  final mockManager = MockTodoManager();
  when(mockManager.todos).thenReturn([
    Todo('Task 1'),
    Todo('Task 2'),
  ]);
  GetIt.I.registerSingleton<TodoManager>(mockManager);

  // Now create the widget
  await tester.pumpWidget(MaterialApp(home: TodoListWidget()));

  expect(find.text('Task 1'), findsOneWidget);
  expect(find.text('Task 2'), findsOneWidget);

  // Clean up scope
  await GetIt.I.popScope();
});
```

**Key insights:**
- **Register watched objects BEFORE `pumpWidget`** - the widget will try to access them during first build
- Use `pushNewScope()` for test isolation instead of `reset()`
- Widget accesses mocks via `get_it` automatically
- Self-contained widgets are easier to test - no constructor parameters needed

For comprehensive testing strategies with `get_it`, see the [Testing Guide](/documentation/get_it/testing.md).

## Code Organization

### Widget Structure

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#widget_structure

## Anti-Patterns

### ❌️ Don't Access `get_it` in Constructors

**❌️ Bad - Accessing in constructor:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_access_getit_constructors_bad

**✅ Good - Use callOnce:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_access_getit_constructors_good

**Why?** Constructors run before the widget is attached to the tree, and they will be called again every time the widget gets recreated. Use `callOnce()` to ensure initialization happens only once when the widget is actually built.

### ❌️ Don't Violate Watch Ordering Rules

::: warning Watch Ordering is Critical
All `watch*`, `callOnce`, `createOnce`, and `registerHandler` calls must be in the same order on every build. This is a fundamental constraint of `watch_it`'s design.

See [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) for complete details and safe exceptions.
:::

### ❌️ Don't Await Commands

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_await_execute_bad_anti

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_await_execute_good_anti

### ❌️ Don't Put Watch Calls in Callbacks

See [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - watch calls must be in build(), not in callbacks.

## Debugging

Enable tracing with `enableTracing()` or `WatchItSubTreeTraceControl` to understand rebuild behavior. For detailed debugging techniques and troubleshooting common issues, see [Debugging & Troubleshooting](/documentation/watch_it/debugging_tracing.md).

## See Also

- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - CRITICAL constraints
- [Debugging & Troubleshooting](/documentation/watch_it/debugging_tracing.md) - Common issues
- [Observing Commands](/documentation/watch_it/observing_commands.md) - command_it integration
- [Testing](/documentation/get_it/testing.md) - Testing with `get_it`
