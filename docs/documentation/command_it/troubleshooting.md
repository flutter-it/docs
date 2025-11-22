# Troubleshooting

Common issues with command_it and how to solve them.

::: tip Problem → Diagnosis → Solution
This guide is organized by **symptoms** you observe. Find your issue, diagnose the cause, and apply the solution.
:::

## UI Not Updating

### Command completes but UI doesn't rebuild

**Symptoms:**
- Command executes successfully
- Data changes but screen doesn't update
- No errors in console

**Diagnosis:**

Check if you're watching the command property:

```dart
class MyWidget extends StatelessWidget { // ❌️ Not a WatchingWidget
  @override
  Widget build(BuildContext context) {
    final data = watchValue((Manager m) => m.command); // Won't work!
    return Text('$data');
  }
}
```

**Solution:**

Extend `WatchingWidget` or `WatchingStatefulWidget`:

```dart
class MyWidget extends WatchingWidget { // ✅ Correct
  @override
  Widget build(BuildContext context) {
    final data = watchValue((Manager m) => m.command);
    return Text('$data');
  }
}
```

**Alternative with ValueListenableBuilder:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final manager = GetIt.I<Manager>();
    return ValueListenableBuilder(
      valueListenable: manager.command,
      builder: (context, data, _) => Text('$data'),
    );
  }
}
```

**See also:** [watch_it documentation](/documentation/watch_it/getting_started)

---

### UI updates but shows stale data

**Symptoms:**
- UI rebuilds when command executes
- But shows old data instead of new results

**Diagnosis:**

Check if you're watching the command itself vs a derived value:

```dart
// ❌️ Creates new list on every build - watch_it sees different instance
final items = watchValue((Manager m) => m.command.value.where((x) => x.isActive).toList());
```

**Solution:**

Watch the command, then transform in the widget:

```dart
// ✅ Watch the command, transform in build
final allItems = watchValue((Manager m) => m.command);
final items = allItems.where((x) => x.isActive).toList();
```

Or use listen_it operators:

```dart
// ✅ Create filtered command once in your manager
late final activeItems = command.where((items) => items.where((x) => x.isActive).toList());

// Then watch it
final items = watchValue((Manager m) => m.activeItems);
```

---

## Command Execution Issues

### Command doesn't execute / nothing happens

**Symptoms:**
- Calling `command('param')` does nothing
- No loading state, no errors, no results

**Diagnosis:**

Check if command is restricted:

```dart
final command = Command.createAsync(
  fetchData,
  [],
  restriction: someValueNotifier, // Is this true?
);
```

**Solution 1:** Check restriction value

```dart
// Debug: print restriction state
print('Can run: ${command.canRun.value}');
print('Is restricted: ${restriction.value}'); // Should be false to run
```

**Solution 2:** Handle restricted execution

```dart
final command = Command.createAsync(
  fetchData,
  [],
  restriction: isLoggedOut,
  ifRestrictedRunInstead: (param) {
    // Show login dialog
    showLoginDialog();
  },
);
```

**See also:** [Command Properties - Restrictions](/documentation/command_it/command_properties#restriction)

---

### Command stuck in "running" state

**Symptoms:**
- `isRunning` stays `true` forever
- Loading indicator never disappears
- Command won't execute again

**Diagnosis:**

Check if async function completes:

```dart
Command.createAsync((param) async {
  await fetchData(); // Does this ever complete?
  // Missing return statement?
}, []);
```

**Common causes:**

1. **Async function never completes:**
   ```dart
   // ❌️ Waiting for something that never happens
   (param) async {
     await neverCompletingFuture;
   }
   ```

2. **Unhandled error in async function:**
   ```dart
   // ❌️ Error thrown but not caught
   (param) async {
     throw Exception('Oops'); // Command catches this, but might not be configured to handle it
   }
   ```

3. **Missing return statement:**
   ```dart
   // ❌️ Function body doesn't return
   Command.createAsync<String, List<Item>>((query) async {
     final items = await api.search(query);
     // Missing: return items;
   }, []);
   ```

**Solution:**

Add timeout and error handling:

```dart
Command.createAsync((param) async {
  try {
    return await fetchData().timeout(Duration(seconds: 30));
  } catch (e) {
    print('Command failed: $e');
    rethrow; // Let command's error handling deal with it
  }
}, []);
```

---

## Error Handling Issues

### Errors not showing in UI

**Symptoms:**
- Command fails but UI doesn't show error state
- Errors logged to console but not displayed

**Diagnosis:**

Check error filter configuration:

```dart
// Is error being swallowed?
final command = Command.createAsync(
  fetchData,
  [],
  errorFilter: const ErrorHandlerNone(), // ❌️ Swallows all errors!
);
```

**Solution 1:** Use appropriate error filter

```dart
final command = Command.createAsync(
  fetchData,
  [],
  errorFilter: const ErrorHandlerLocal(), // ✅ Notifies .errors property
);
```

**Solution 2:** Watch the errors property

```dart
final error = watchValue((Manager m) => m.command.errors);
if (error != null) {
  return ErrorWidget(error.error);
}
```

**Solution 3:** Use CommandResult

```dart
final result = watchValue((Manager m) => m.command.results);
if (result.hasError) {
  return ErrorWidget(result.error);
}
```

**See also:** [Error Handling](/documentation/command_it/error_handling)

---

### Errors appear briefly then disappear

**Symptoms:**
- Error shows for a moment
- Then vanishes when you retry

**Diagnosis:**

This is **expected behavior** - errors are cleared when command runs again:

```dart
command('query'); // Error occurs
// error.value = CommandError(...)

command('new query'); // Run again
// error.value = null  ← Error cleared!
```

**Solution:**

If you need to keep error history, listen and store them:

```dart
class Manager {
  final errorHistory = <CommandError>[];

  late final command = Command.createAsync(
    fetchData,
    [],
  )..errors.listen((error, _) {
    if (error != null) {
      errorHistory.add(error);
    }
  });
}
```

---

## Performance Issues

### Too many rebuilds / UI laggy

**Symptoms:**
- UI rebuilds constantly
- Scrolling is janky
- Performance issues

**Diagnosis:**

Check if you're watching `.results` unnecessarily:

```dart
// ❌️ Rebuilds on EVERY state change (running, success, error)
final result = watchValue((Manager m) => m.command.results);
return Text('${result.data}');
```

**Solution:**

Watch only the data you need:

```dart
// ✅ Only rebuilds when data changes
final data = watchValue((Manager m) => m.command);
return Text('$data');
```

**Or watch specific properties:**

```dart
// ✅ Only rebuilds when isRunning changes
final isRunning = watchValue((Manager m) => m.command.isRunning);
if (isRunning) return CircularProgressIndicator();

// ✅ Only rebuilds when data changes
final data = watchValue((Manager m) => m.command);
return DataWidget(data);
```

**See also:** [CommandResult vs Individual Properties](/documentation/command_it/command_results#commandresult-vs-individual-properties)

---

### Command executes too often

**Symptoms:**
- Command runs multiple times unexpectedly
- Seeing duplicate API calls
- Wasting resources

**Diagnosis:**

Check if you're calling the command in build:

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    command('query'); // ❌️ Called on every build!
    return SomeWidget();
  }
}
```

**Solution 1:** Call in event handlers only

```dart
// Call command only when button is pressed
ElevatedButton(
  onPressed: () => command('query'),
  child: const Text('Search'),
)
```

**Solution 2:** Use `callOnce` for initialization

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((Manager m) => m.command('initial'));
    return SomeWidget();
  }
}
```

**Solution 3:** Debounce rapid calls

```dart
// In your manager
late final debouncedSearch = Command.createSync<String, String>(
  (query) => query,
  '',
);

debouncedSearch.debounce(Duration(milliseconds: 500)).listen((query, _) {
  actualSearchCommand(query);
});
```

---

## Memory Leaks

### Commands not being disposed

**Symptoms:**
- Memory usage grows over time
- Flutter DevTools shows increasing listeners
- App becomes sluggish

**Diagnosis:**

Check if you're disposing commands:

```dart
class Manager {
  late final command = Command.createAsync(fetchData, []);

  // ❌️ Missing dispose!
}
```

**Solution:**

Always dispose commands in `dispose()` or `onDispose()`:

```dart
class Manager extends DisposableObject {
  late final command = Command.createAsync(fetchData, []);

  @override
  void onDispose() {
    command.dispose(); // ✅ Clean up
  }
}
```

**For get_it singletons:**

```dart
getIt.registerSingleton<Manager>(
  Manager(),
  dispose: (manager) => manager.dispose(),
);
```

---

## Integration Issues

### watch_it not finding command

**Symptoms:**
- `watchValue` throws error: "No registered instance found"
- Command works with direct access but not with watch_it

**Diagnosis:**

Check if manager is registered in get_it:

```dart
// ❌️ Manager not registered
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((Manager m) => m.command); // Fails!
    return Text('$data');
  }
}
```

**Solution:**

Register manager in get_it before using watch_it:

```dart
void main() {
  GetIt.I.registerSingleton<Manager>(Manager()); // ✅ Register first
  runApp(MyApp());
}
```

**See also:** [get_it documentation](/documentation/get_it/getting_started)

---

### ValueListenableBuilder not updating

**Symptoms:**
- Using `ValueListenableBuilder` directly
- UI doesn't update when command completes

**Diagnosis:**

Check if you're passing the right `ValueListenable`:

```dart
// ❌️ Passing the command object, not a ValueListenable
ValueListenableBuilder(
  valueListenable: manager.command, // This IS a ValueListenable, should work
  builder: (context, value, _) => Text('$value'),
)
```

**Common mistake - not watching changes:**

```dart
// ❌️ Creating new instance on every build
ValueListenableBuilder(
  valueListenable: Command.createAsync(fetch, []), // New command each build!
  builder: (context, value, _) => Text('$value'),
)
```

**Solution:**

Command must be created once and reused:

```dart
class Manager {
  late final command = Command.createAsync(fetch, []); // ✅ Created once
}

// In widget:
ValueListenableBuilder(
  valueListenable: manager.command, // ✅ Same instance
  builder: (context, value, _) => Text('$value'),
)
```

---

## Type Issues

### Cannot convert TResult to expected type

**Symptoms:**
- Type error: "type 'Null' is not a subtype of type `List<Item>`"
- Compiler errors about incompatible types

**Diagnosis:**

Check if you're handling null data:

```dart
// ❌️ data might be null initially
final result = watchValue((Manager m) => m.command.results);
return ListView.builder(
  itemCount: result.data.length, // Crash if data is null!
  ...
);
```

**Solution:**

Always check for null or provide default:

```dart
final result = watchValue((Manager m) => m.command.results);
if (!result.hasData) return EmptyState();

return ListView.builder(
  itemCount: result.data!.length, // ✅ Safe - checked above
  ...
);
```

**Or use null-aware operators:**

```dart
return ListView.builder(
  itemCount: result.data?.length ?? 0, // ✅ Default to 0
  ...
);
```

---

### Generic type inference fails

**Symptoms:**
- Dart can't infer command types
- Need to specify types explicitly everywhere

**Diagnosis:**

Command created without explicit types:

```dart
// ❌️ Dart can't infer types from context
final command = Command.createAsync(
  (param) async => await fetchData(param),
  [],
);
```

**Solution:**

Specify generic types explicitly:

```dart
// ✅ Explicit types
final command = Command.createAsync<String, List<Item>>(
  (query) async => await fetchData(query),
  [],
);
```

---

## Still Having Issues?

1. **Check the documentation:** Each command_it feature has detailed documentation
2. **Search existing issues:** [command_it GitHub issues](https://github.com/escamoteur/command_it/issues)
3. **Ask on Discord:** [flutter_it Discord](https://discord.gg/ZHYHYCM38h)
4. **Create an issue:** Include minimal reproduction code

**When reporting issues, include:**
- Minimal code example that reproduces the problem
- Expected behavior vs actual behavior
- command_it version (`pubspec.yaml`)
- Flutter version (`flutter --version`)
- Any error messages or stack traces
