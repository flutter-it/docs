# Debugging & Troubleshooting

Common errors, solutions, debugging techniques, and troubleshooting strategies for `watch_it`.

## Common Errors

### "Watch ordering violation detected!"

**Error message:**
```
Watch ordering violation detected!

You have conditional watch calls (inside if/switch statements) that are
causing watch_it to retrieve the wrong objects on rebuild.

Fix: Move ALL conditional watch calls to the END of your build method.
Only the LAST watch call can be conditional.
```

**Cause:** Watch calls inside `if` statements followed by other watches, causing order to change between builds.

**Solution:** See [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) for detailed explanation, examples, and safe patterns.

**Debugging tip:** Call `enableTracing()` in your build method to see exact source locations of conflicting watch statements.

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

See [get_it Object Registration](/documentation/get_it/object_registration.md) for all registration methods.

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

#### 2. Not notifying changes

```dart
// BAD - Changing value without notifying
class TodoManager {
  final todos = ValueNotifier<List<Todo>>([]);

  void addTodo(Todo todo) {
    todos.value.add(todo);  // Modifies list but doesn't notify!
  }
}
```

**Option 1 - Use ListNotifier from listen_it (recommended):**

```dart
// GOOD - ListNotifier automatically notifies on mutations
class TodoManager {
  final todos = ListNotifier<Todo>([]);

  void addTodo(Todo todo) {
    todos.add(todo);  // Automatically notifies listeners!
  }
}
```

**Option 2 - Use custom ValueNotifier with manual notification:**

```dart
// GOOD - Extend ValueNotifier and call notifyListeners
class TodoManager extends ValueNotifier<List<Todo>> {
  TodoManager() : super([]);

  void addTodo(Todo todo) {
    value.add(todo);
    notifyListeners();  // Manually trigger notification
  }
}
```

See [listen_it Collections](/documentation/listen_it/collections/introduction.md) for ListNotifier, MapNotifier, and SetNotifier.

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

### registerHandler not firing

**Symptoms:**
- Handler callback never executes
- Side effects (navigation, dialogs) don't happen
- No errors thrown

**Common causes:**

#### 1. Handler registered after conditional return

```dart
// BAD - Handler registered AFTER early return
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = watchValue((M m) => m.isLoading);

    if (isLoading) {
      return CircularProgressIndicator();  // Returns early!
    }

    // This handler never gets registered when loading!
    registerHandler(
      select: (M m) => m.saveCommand,
      handler: (context, result, cancel) {
        Navigator.pop(context);
      },
    );

    return MyForm();
  }
}
```

**Solution:** Register handlers BEFORE any conditional returns:

```dart
// GOOD - Handler registered before conditional logic
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (M m) => m.saveCommand,
      handler: (context, result, cancel) {
        Navigator.pop(context);
      },
    );

    final isLoading = watchValue((M m) => m.isLoading);

    if (isLoading) {
      return CircularProgressIndicator();
    }

    return MyForm();
  }
}
```

### callOnce runs multiple times

**Symptoms:**
- `callOnce` callback executes more than once
- Initialization happens repeatedly
- Commands run multiple times unexpectedly

**Cause:** Widget gets recreated (not rebuilt), creating new Element instances.

**Example:**

```dart
// This creates NEW widget instances on every parent rebuild
Widget build(BuildContext context) {
  return MyWidget();  // New instance each time!
}

class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((_) {
      print('Init');  // Will print multiple times!
    });
    return Container();
  }
}
```

**Solution:** Use `const` constructors or cache widget instances:

```dart
// Option 1: const constructor
Widget build(BuildContext context) {
  return const MyWidget();  // Same instance reused
}

// Option 2: Cache the instance
class ParentWidget extends StatelessWidget {
  final child = MyWidget();  // Created once

  @override
  Widget build(BuildContext context) {
    return child;  // Reuses same instance
  }
}
```

**Note:** This is normal Flutter behavior - `callOnce` runs once per widget Element, not per widget class. If you need initialization that survives widget recreation, use get_it registration or manager initialization.

### callOnceAfterThisBuild doesn't execute

**Symptoms:**
- Callback never runs
- Navigation/dialogs don't appear
- No errors

**Cause:** Called inside a conditional that becomes false before the post-frame callback executes.

**Example:**

```dart
// BAD - Condition might change
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isReady = isReady<Database>();

    if (isReady) {
      callOnceAfterThisBuild((context) {
        Navigator.push(...);  // Might not execute if widget rebuilds first
      });
      return LoadedView();
    }

    return LoadingView();
  }
}
```

**Solution:** Use unconditional `callOnceAfterThisBuild` with conditional logic inside:

```dart
// GOOD - Always registers, conditionally executes
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isReady = isReady<Database>();

    callOnceAfterThisBuild((context) {
      if (isReady) {  // Check condition in callback
        Navigator.push(...);
      }
    });

    return isReady ? LoadedView() : LoadingView();
  }
}
```

### createOnce recreates on every build

**Symptoms:**
- Objects created multiple times
- State resets unexpectedly
- Memory leaks from creating many instances

**Cause:** Using `allowObservableChange: true` or creating different objects each build.

**Bad example:**

```dart
// BAD - Creates new notifier every build
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // This creates a NEW selector function each build
    final counter = createOnce(
      () => ValueNotifier(0),
      allowObservableChange: true,  // DON'T DO THIS!
    );

    return Text('$counter.value');
  }
}
```

**Solution:** Remove `allowObservableChange: true`:

```dart
// GOOD - Creates once, reuses instance
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final counter = createOnce(() => ValueNotifier(0));
    // Throws exception if selector changes - helps catch bugs!

    return Text('${counter.value}');
  }
}
```

**When to use `allowObservableChange: true`:**

Only when the created object genuinely needs to change based on other reactive state:

```dart
// Valid use case - different notifier per user
class UserWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final userId = watchValue((AppState s) => s.currentUserId);

    // Create different notifier for different users
    final userNotes = createOnce(
      () => ValueNotifier<String>(''),
      allowObservableChange: true,  // OK here - userId changes
    );

    return TextField(
      controller: TextEditingController(text: userNotes.value),
      onChanged: (value) => userNotes.value = value,
    );
  }
}
```

## Debugging Techniques

### Enable watch_it Tracing

Get detailed logs of watch subscriptions and source locations for ordering violations:

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Call at the start of build to enable tracing
    enableTracing(
      logRebuilds: true,
      logHandlers: true,
      logHelperFunctions: true,
    );

    final todos = watchValue((TodoManager m) => m.todos);
    // ... rest of build
  }
}
```

**Benefits:**
- Shows exact source locations of watch calls
- Helps identify ordering violations
- Tracks rebuild activity
- Shows handler executions

**Alternative:** Use `WatchItSubTreeTraceControl` widget to enable tracing for an entire subtree:

```dart
return WatchItSubTreeTraceControl(
  logRebuilds: true,
  logHandlers: true,
  logHelperFunctions: true,
  child: MyApp(),
);
```

### Track rebuild frequency

Add print statements to track how often widgets rebuild:

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#track_rebuild_frequency

**Analyze output:**
- Too many rebuilds? → Watching too much data
- Not rebuilding? → Not watching the data that changes

### Isolate the problem

Create minimal reproduction:

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#isolate_problem

This isolates:
- Does the watch subscription work?
- Does the widget rebuild on data change?
- Are there ordering issues?

## Performance Profiling

If you suspect performance issues, measure how long your watch-heavy widgets take to rebuild:

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#measure_rebuild_cost

**What to look for:**
- Rebuilds taking > 16ms (60fps) - consider splitting the widget
- Expensive computations in build() - move to managers
- Too many watch calls - watch only what you need

## Troubleshooting Checklist

When something doesn't work:

### 1. Widget not updating?

- [ ] Are you using `WatchingWidget` or `WatchItMixin`?
- [ ] Are you calling `watch*()` directly in `build()`?
- [ ] Is the data registered in get_it?
- [ ] Is the data actually changing? (Add print to verify)
- [ ] Are you creating a new object/list to trigger notification?

### 2. Ordering errors?

- [ ] Are conditional watches at the END of `build()`?
- [ ] No watches inside `if` statements **followed by other watches**?
- [ ] No watches inside loops?
- [ ] Call `enableTracing()` to see source locations?

### 3. Memory issues?

- [ ] Using watch_it widgets (not manual listeners)?
- [ ] Are managers/services being disposed?
- [ ] Are you creating new objects in build()? (Use `createOnce()` instead)

### 4. Performance issues?

- [ ] Watching specific properties instead of whole objects?
- [ ] Using `watchPropertyValue()` for selective updates?
- [ ] Split large widgets into smaller ones?
- [ ] Move computations to managers?

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
