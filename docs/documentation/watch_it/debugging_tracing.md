# Debugging & Troubleshooting

Common errors, solutions, debugging techniques, and troubleshooting strategies for watch_it.

## Common Errors

### "watch call order changed"

**Error message:**
```
Assertion failed: Watch call order has changed
```

**Cause:** You have conditional watch calls or watches in different execution branches.

**Example:**
```dart
// BAD
if (showDetails) {
  final details = watchValue((M m) => m.details);  // Only sometimes!
}
```

**Solution:** Move ALL watch calls to the top of build(), unconditionally:

```dart
// GOOD
final details = watchValue((M m) => m.details);  // ALWAYS watch

if (showDetails) {
  // Use the value conditionally
  return DetailView(details);
}
```

**See:** [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) for complete explanation.

### "More/fewer watches than last build"

**Error message:**
```
Expected X watches but found Y
```

**Cause:** Number of watch calls changed between builds.

**Common causes:**
- Watches inside `if` statements
- Watches inside loops
- Watches after early returns

**Example:**
```dart
// BAD
if (isLoading) {
  return CircularProgressIndicator();  // Returns early!
}

// This watch only happens sometimes
final data = watchValue((M m) => m.data);
```

**Solution:** Call ALL watches before any early returns:

```dart
// GOOD
final data = watchValue((M m) => m.data);

if (isLoading) {
  return CircularProgressIndicator();  // Can return now
}

return DataView(data);
```

### "watch() called outside build"

**Error message:**
```
watch() can only be called inside build()
```

**Cause:** Trying to use watch functions in callbacks, constructors, or other methods.

**Example:**
```dart
// BAD
class MyWidget extends WatchingWidget {
  MyWidget() {
    final data = watchValue((M m) => m.data);  // Wrong context!
  }

  void onPressed() {
    final data = watchValue((M m) => m.data);  // Wrong!
  }
}
```

**Solution:** Only call watch functions directly in `build()`:

```dart
// GOOD
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((M m) => m.data);  // Correct!

    return ElevatedButton(
      onPressed: () {
        doSomething(data);  // Use the value
      },
      child: Text('$data'),
    );
  }
}
```

### "Type 'X' is not a subtype of type 'Listenable'"

**Error message:**
```
type 'MyManager' is not a subtype of type 'Listenable'
```

**Cause:** Using `watchIt<T>()` on an object that isn't a `Listenable`.

**Example:**
```dart
// BAD
class TodoManager {  // Not a Listenable!
  final todos = ValueNotifier<List<Todo>>([]);
}

final manager = watchIt<TodoManager>();  // ERROR!
```

**Solution:** Use `watchValue()` instead:

```dart
// GOOD
final todos = watchValue((TodoManager m) => m.todos);
```

Or make your manager extend `ChangeNotifier`:

```dart
// Also GOOD
class TodoManager extends ChangeNotifier {
  List<Todo> _todos = [];

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();  // Now it's a Listenable
  }
}

final manager = watchIt<TodoManager>();  // Works now!
```

### "get_it: Object/factory with type X is not registered"

**Error message:**
```
get_it: Object/factory with type TodoManager is not registered inside GetIt
```

**Cause:** Trying to watch an object that hasn't been registered in get_it.

**Solution:** Register it before using:

```dart
void main() {
  // Register BEFORE runApp
  di.registerSingleton<TodoManager>(TodoManager());

  runApp(MyApp());
}
```

### Widget doesn't rebuild when data changes

**Symptoms:**
- Data changes but UI doesn't update
- `print()` shows new values but widget still shows old data

**Common causes:**

#### 1. Not watching the data

```dart
// BAD - Not watching, just accessing
final manager = di<TodoManager>();
final todos = manager.todos.value;  // No watch!
```

```dart
// GOOD - Actually watching
final todos = watchValue((TodoManager m) => m.todos);
```

#### 2. Watching the wrong thing

```dart
// BAD - Watching a one-time snapshot
final todos = watchValue((TodoManager m) => m.todos).value;  // Gets value once
```

```dart
// GOOD - Watching the listenable itself
final todos = watchValue((TodoManager m) => m.todos);  // Watches for changes
```

#### 3. Not notifying changes

```dart
// BAD - Changing value without notifying
class TodoManager {
  final todos = ValueNotifier<List<Todo>>([]);

  void addTodo(Todo todo) {
    todos.value.add(todo);  // Modifies list but doesn't notify!
  }
}
```

```dart
// GOOD - Create new list to trigger notification
class TodoManager {
  final todos = ValueNotifier<List<Todo>>([]);

  void addTodo(Todo todo) {
    todos.value = [...todos.value, todo];  // New list triggers notification
  }
}
```

### Memory leaks - subscriptions not cleaned up

**Symptoms:**
- Memory usage grows over time
- Old widgets still reacting to changes
- Performance degrades

**Cause:** Not using `WatchingWidget` or `WatchItMixin` - doing manual subscriptions.

**Solution:** Always use watch_it widgets:

```dart
// BAD - Manual subscriptions leak
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final manager = di<Manager>();
    manager.data.addListener(() {
      // This leaks! No cleanup
    });
  }
}
```

```dart
// GOOD - Automatic cleanup
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((Manager m) => m.data);
    return Text('$data');
  }
}
```

## Debugging Techniques

### Enable watch_it Tracing

Get detailed logs of all watch subscriptions:

```dart
void main() {
  // Enable tracing BEFORE runApp
  GetIt.I.enableWatchItTracing = true;

  runApp(MyApp());
}
```

**Output:**
```
watch_it: TodoList subscribed to TodoManager.todos
watch_it: UserHeader subscribed to UserModel.name
watch_it: TodoList disposed subscription to TodoManager.todos
```

### Use debugLabel for watch calls

Label your watch calls to identify them in traces:

```dart
final todos = watchValue(
  (TodoManager m) => m.todos,
  debugLabel: 'TodoList.todos',  // Shows in traces
);

final user = watchValue(
  (UserModel m) => m.user,
  debugLabel: 'UserHeader.user',
);
```

**Output with labels:**
```
watch_it: [TodoList.todos] subscribed to TodoManager.todos
watch_it: [UserHeader.user] subscribed to UserModel.name
```

### Track rebuild frequency

Add print statements to track how often widgets rebuild:

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#track_rebuild_frequency

**Analyze output:**
- Too many rebuilds? → Watching too much data
- Not rebuilding? → Not watching the data that changes

### Use Flutter DevTools

#### 1. Widget Inspector
- See rebuild highlights (enable "Highlight Repaints")
- Check if correct widgets rebuild when data changes
- Verify no unnecessary rebuilds

#### 2. Performance View
- Check for performance issues during rebuilds
- Look for expensive operations in `build()`
- Profile memory usage

#### 3. Timeline
- See when widgets rebuild
- Correlate with data changes
- Identify unnecessary work

### Isolate the problem

Create minimal reproduction:

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#isolate_problem

This isolates:
- Does the watch subscription work?
- Does the widget rebuild on data change?
- Are there ordering issues?

### Verify get_it registration

Check what's registered:

```dart
void main() {
  setupDependencies();

  // Print all registrations
  print('Registered types:');
  // GetIt doesn't expose registrations publicly,
  // but you can test by trying to get them:

  try {
    final manager = di<TodoManager>();
    print('✓ TodoManager registered');
  } catch (e) {
    print('✗ TodoManager NOT registered');
  }

  runApp(MyApp());
}
```

## Performance Profiling

### Measure rebuild cost

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#measure_rebuild_cost

**What to look for:**
- Rebuilds taking > 16ms (60fps)
- Expensive computations in build()
- Move expensive work to managers

### Profile memory usage

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#profile_memory

### Find excessive watch calls

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#find_excessive_watch_calls

## Troubleshooting Checklist

When something doesn't work:

### 1. Widget not updating?

- [ ] Are you using `WatchingWidget` or `WatchItMixin`?
- [ ] Are you calling `watch*()` directly in `build()`?
- [ ] Is the data registered in get_it?
- [ ] Is the data actually changing? (Add print to verify)
- [ ] Are you creating a new object/list to trigger notification?

### 2. Ordering errors?

- [ ] Are ALL watch calls at the top of `build()`?
- [ ] No watches inside `if` statements?
- [ ] No watches inside loops?
- [ ] No early returns before all watches?

### 3. Memory issues?

- [ ] Using watch_it widgets (not manual listeners)?
- [ ] Are managers/services being disposed?
- [ ] Are you creating new objects in build()? (Use `createOnce()` instead)

### 4. Performance issues?

- [ ] Watching specific properties instead of whole objects?
- [ ] Using `watchPropertyValue()` for selective updates?
- [ ] Split large widgets into smaller ones?
- [ ] Move computations to managers?

## Advanced Debugging

### Custom watch wrapper with logging

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#custom_watch_wrapper_logging

### Conditional tracing

Enable tracing only for specific widgets:

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#conditional_tracing

### Detect watch ordering violations early

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#detect_watch_ordering_violations

## Getting Help

When reporting issues:

1. **Minimal reproduction** - Isolate the problem
2. **Versions** - watch_it, Flutter, Dart versions
3. **Error messages** - Full stack trace
4. **Expected vs actual** - What should happen vs what happens
5. **Code sample** - Complete, runnable example

**Where to ask:**
- **Discord:** [Join flutter_it community](https://discord.gg/ZHYHYCM38h)
- **GitHub Issues:** [watch_it issues](https://github.com/escamoteur/watch_it/issues)
- **Stack Overflow:** Tag with `flutter` and `watch-it`

## See Also

- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - CRITICAL constraints
- [Best Practices](/documentation/watch_it/best_practices.md) - Patterns and tips
- [How watch_it Works](/documentation/watch_it/how_it_works.md) - Understanding the mechanism
