# Error Handling

::: warning AI-Generated Content Under Review
This documentation was generated with AI assistance and is currently under review. While we strive for accuracy, there may be errors or inconsistencies. Please report any issues you find.
:::

## Error Handling
If the wrapped function inside a `Command` throws an `Exception` the `Command` catches it so your App won't crash.
Instead it will wrap the caught error together with the value that was passed when the command was executed in a `CommandError` object and assign it to the `Command's` `errors` property which is a `ValueListenable<CommandError>`.
So to react on occurring error you can register your handler with `addListener` or use my `listen` extension function from `listen_it` as it is done in the example:

```dart
/// in HomePage.dart
@override
void didChangeDependencies() {
  errorSubscription ??= weatherManager
      .updateWeatherCommand
      .errors
      .where((x) => x != null) // filter out the error value reset
      .listen((error, _) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('An error has occured!'),
              content: Text(error.toString()),
            ));
  });
  super.didChangeDependencies();
}
```
Unfortunately its not possible to reset the value of a `ValueNotifier` without triggering its listeners. So if you have registered a listener you will get it called at every start of a `Command` execution with a value of `null` and clear all previous errors. If you use `listen_it` you can do it easily by using the `where` extension.

## Error handling the fine print
You can tweak the behaviour of the error handling by passing a `catchAlways` parameter to the factory functions. If you pass `false` Exceptions will only be caught if there is a listener on `errors` or on `results` (see next chapter). You can also change the default behaviour of all `Command` in your app by changing the value of the `catchAlwaysDefault` property. During development its a good idea to set it to `false` to find any non handled exception. In production, setting it to `true` might be the better decision to prevent hard crashes. Note that `catchAlwaysDefault` property will be implicitly ignored if the `catchAlways` parameter for a command is set.

`Command` also offers a static global Exception handler:

```dart
static void Function(String commandName, CommandError<Object> error) globalExceptionHandler;
```
If you assign a handler function to it, it will be called for all Exceptions thrown by any `Command` in your app independent of the value of `catchAlways` if the `Command` has no listeners on `errors` or on `results`.

The overall work flow of exception handling in command_it is depicted in the following diagram.

 ![](https://github.com/escamoteur/command_it/blob/master/misc/exception_handling.png)

## Auto-Undo on Failure

For operations that modify state optimistically, `UndoableCommand` can automatically rollback changes when an error occurs. This is perfect for implementing optimistic updates with automatic error recovery.

```dart
class TodoService {
  final todos = ValueNotifier<List<Todo>>([]);

  late final deleteTodoCommand = Command.createUndoableNoResult<String, List<Todo>>(
    (id, previousTodos) async {
      // Make optimistic update
      todos.value = todos.value.where((t) => t.id != id).toList();

      // Try to delete on server
      await api.deleteTodo(id);
      // If this throws an exception, the undo handler is called automatically
    },
    undo: (id) {
      // Capture state snapshot before execution
      return todos.value;
    },
    undoOnExecutionFailure: true, // Automatically rollback on error
  );
}
```

**How it works:**

1. **Before execution**: The `undo` handler is called to capture the current state
2. **During execution**: Your function runs (e.g., optimistic UI update + API call)
3. **On success**: State snapshot is pushed to the undo stack
4. **On failure** (when `undoOnExecutionFailure: true`):
   - The command automatically calls the undo handler
   - State is restored to the pre-execution snapshot
   - Error is still propagated to error handlers

**Benefits:**

- ✅ Automatic rollback on errors - no manual try/catch needed
- ✅ Clean separation: business logic in command, error recovery is automatic
- ✅ Consistent error recovery across your app
- ✅ Also enables manual undo/redo for user actions

**When to use:**

- Optimistic updates (delete items, toggle states, edit data)
- Multi-step operations where partial failure needs full rollback
- Any operation where you want automatic "if this fails, undo what I just did"

See [Command Types - Undoable Commands](/documentation/command_it/command_types#undoable-commands) for all factory methods and [Best Practices - Undoable Commands](/documentation/command_it/best_practices#pattern-5-undoable-commands-with-automatic-rollback) for more patterns.
