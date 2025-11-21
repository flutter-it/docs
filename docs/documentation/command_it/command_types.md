# Command Types

Learn about `command_it`'s factory function pattern for creating commands. Understanding this pattern makes it easy to choose the right factory for your needs.

## Why Factory Functions?

Commands use **static factory functions** instead of a single constructor because:

1. **Type safety** - Each factory accepts exactly the right function signature:
   - `createAsync<String, List<Todo>>` takes `Future<List<Todo>> Function(String)`
   - `createAsyncNoParam<List<Todo>>` takes `Future<List<Todo>> Function()`
   - No risk of passing the wrong function type

2. **Implementation simplicity** - Different function signatures (0-2 parameters, void/non-void returns) would require multiple optional function parameters in a constructor, making it error-prone and confusing

3. **Clear intent** - The factory name tells you exactly what you're creating:
   - `createAsyncNoParam<List<Todo>>` is clearer than `Command<void, List<Todo>>()`

## The Naming Pattern

All 12 factory functions follow a simple formula:

```
create + [Sync|Async|Undoable] + [NoParam] + [NoResult]
```

**How to read the names:**
- **Sync/Async/Undoable** - What kind of command (always present)
- **NoParam** - If present, command takes NO parameters
- **NoResult** - If present, command returns void
- **Omitted parts** - If "NoParam" or "NoResult" is missing, that feature IS present

**Examples:**

| Factory Name | Has Parameter? | Has Result? | Type |
|--------------|----------------|-------------|------|
| `createAsync<TParam, TResult>` | ✅ Yes (TParam) | ✅ Yes (TResult) | Async |
| `createAsyncNoParam<TResult>` | ❌ No (void) | ✅ Yes (TResult) | Async |
| `createAsyncNoResult<TParam>` | ✅ Yes (TParam) | ❌ No (void) | Async |
| `createSyncNoParamNoResult` | ❌ No (void) | ❌ No (void) | Sync |
| `createUndoable<TParam, TResult, TUndoState>` | ✅ Yes (TParam) | ✅ Yes (TResult) | Undoable |

**Key insight:** If "NoParam" or "NoResult" appears in the name, that feature is ABSENT. If omitted, it's PRESENT.

::: tip NoResult Commands Still Notify Listeners
Even though NoResult commands return `void`, they still notify listeners when they complete successfully. This means you can watch them to trigger UI updates, navigation, or other side effects.

```dart
final saveCommand = Command.createAsyncNoResult<Data>(
  (data) async => await api.save(data),
);

// You can still listen to completion
saveCommand.listen((_, __) {
  showSnackbar('Saved successfully!');
});

// Or use with watch_it
watchValue(saveCommand, (_, __) {
  // Called when save completes
});
```

Commands are `ValueListenable<TResult>` where `TResult` is `void` for NoResult variants - the value doesn't change, but notifications still fire on execution.
:::

## Parameter Reference

Here's the complete signature of `createAsync<TParam, TResult>` - the most common factory function. All other factories share these same parameters (or a subset):

```dart
static Command<TParam, TResult> createAsync<TParam, TResult>(
  Future<TResult> Function(TParam x) func, {
  required TResult initialValue,
  ValueListenable<bool>? restriction,
  RunInsteadHandler<TParam>? ifRestrictedRunInstead,
  bool includeLastResultInCommandResults = false,
  ErrorFilter? errorFilter,
  ErrorFilterFn? errorFilterFn,
  bool notifyOnlyWhenValueChanges = false,
  String? debugName,
})
```

**Required parameters:**

- **`func`** - The async function to wrap (positional parameter). Takes a parameter of type `TParam` and returns `Future<TResult>`
- **`initialValue`** - The command's initial value before first execution (required named parameter). Commands are `ValueListenable<TResult>` and need a value immediately. **Not available for void commands** (see NoResult variants below)

**Optional parameters:**

- **`restriction`** - `ValueListenable<bool>` to enable/disable the command dynamically. When `true`, command cannot execute. See [Restrictions](/documentation/command_it/restrictions)

- **`ifRestrictedRunInstead`** - Alternative function called when command is restricted (e.g., show login dialog). See [Restrictions](/documentation/command_it/restrictions)

- **`includeLastResultInCommandResults`** - When `true`, keeps the last successful value visible in `CommandResult.data` during execution and error states. Default is `false`. See [Command Results - includeLastResultInCommandResults](/documentation/command_it/command_results#includelastresultincommandresults) for detailed explanation and use cases

- **`errorFilter`/`errorFilterFn`** - Configure how errors are handled (local handler, global handler, or both). See [Error Handling](/documentation/command_it/error_handling)

- **`notifyOnlyWhenValueChanges`** - When `true`, only notifies listeners if value actually changes. Default notifies on every execution

- **`debugName`** - Identifier for logging and debugging, included in error messages

## Variant Differences

All 12 factory functions use the same parameter pattern above, with these variations:

**Sync vs Async:**
- **Sync commands** (`createSync*`):
  - Function parameter: `TResult Function(TParam)` (regular function)
  - Execute immediately
  - **No `isRunning` support** (accessing it throws an exception)
- **Async commands** (`createAsync*`):
  - Function parameter: `Future<TResult> Function(TParam)` (returns Future)
  - Provide `isRunning` tracking during execution

**NoParam variants:**
- Function signature has **no parameter**: `Future<TResult> Function()` instead of `Future<TResult> Function(TParam)`
- **`ifRestrictedRunInstead` has no parameter**: `void Function()` instead of `RunInsteadHandler<TParam>`

**NoResult variants:**
- Function returns `void`: `Future<void> Function(TParam)` instead of `Future<TResult> Function(TParam)`
- **No `initialValue` parameter** (void commands don't need initial value)
- **No `includeLastResultInCommandResults` parameter** (nothing to include)

**Undoable commands:**
- Covered in detail in the Undoable Commands section below

## Undoable Commands

Undoable commands extend async commands with undo capability. They maintain an `UndoStack<TUndoState>` that stores state snapshots, allowing you to undo operations.

**Complete signature:**

```dart
static Command<TParam, TResult> createUndoable<TParam, TResult, TUndoState>(
  Future<TResult> Function(TParam, UndoStack<TUndoState>) func, {
  required TResult initialValue,
  required UndoFn<TUndoState, TResult> undo,
  bool undoOnExecutionFailure = true,
  ValueListenable<bool>? restriction,
  RunInsteadHandler<TParam>? ifRestrictedRunInstead,
  bool includeLastResultInCommandResults = false,
  ErrorFilter? errorFilter,
  ErrorFilterFn? errorFilterFn,
  bool notifyOnlyWhenValueChanges = false,
  String? debugName,
})
```

**Required parameters:**

- **`func`** - Your async function that receives **TWO parameters**: the command parameter (`TParam`) AND the undo stack (`UndoStack<TUndoState>`) where you push state snapshots (positional parameter)

- **`initialValue`** - The command's initial value before first execution (required named parameter)

- **`undo`** - Handler function called to perform the undo operation (required named parameter):
  ```dart
  typedef UndoFn<TUndoState, TResult> = FutureOr<TResult> Function(
    UndoStack<TUndoState> undoStack,
    Object? reason
  )
  ```
  Pop state from the stack and restore it. Called when user manually undos or when `undoOnExecutionFailure: true` and execution fails

**Optional parameters:**

- **`undoOnExecutionFailure`** - When `true` (default), automatically calls the undo handler and restores state if the command fails. Perfect for optimistic updates that need rollback on error

**Type parameters:**

- **`TParam`** - Command parameter type (same as regular commands)
- **`TResult`** - Return value type (same as regular commands)
- **`TUndoState`** - Type of state snapshot needed to undo the operation

**Inherited parameters:**

All other parameters (`initialValue`, `restriction`, `errorFilter`, etc.) work the same as in `createAsync` - see the [Parameter Reference](#parameter-reference) section above.

**Additional methods:**

Undoable commands provide undo/redo functionality:

- **`undo()`** - Undo the last operation
- **`redo()`** - Redo the last undone operation
- **`canUndo`** - `ValueListenable<bool>` indicating if undo is available
- **`canRedo`** - `ValueListenable<bool>` indicating if redo is available
- **`clearStack()`** - Clear the entire undo/redo stack

**See also:**
- [Best Practices - Undoable Commands](/documentation/command_it/best_practices#pattern-5-undoable-commands-with-automatic-rollback) for practical examples
- [Error Handling - Auto-Undo on Failure](/documentation/command_it/error_handling#auto-undo-on-failure) for error recovery patterns

## Common Parameters

Most factory functions share these parameters:

- **`initialValue`** (required for non-void returns) - Sets the command's initial `.value` before first execution. Widgets need this value on first build. See [Command Basics - Initial Values](/documentation/command_it/command_basics#initial-values) for details.

- **`restriction`** - `ValueListenable<bool>` to dynamically enable/disable the command. When `true`, the command cannot execute. See [Restrictions](/documentation/command_it/restrictions) for patterns.

- **`ifRestrictedRunInstead`** - Callback executed when command is restricted (e.g., show login dialog when user isn't authenticated). See [Restrictions](/documentation/command_it/restrictions#ifrestrictedruninstead).

- **`errorFilter`/`errorFilterFn`** - Configure error handling strategy. See [Error Handling](/documentation/command_it/error_handling).

- **`includeLastResultInCommandResults`** - When `true`, keeps previous result visible during execution and error states. See [Command Results - includeLastResultInCommandResults](/documentation/command_it/command_results#includelastresultincommandresults) for detailed explanation.

- **`notifyOnlyWhenValueChanges`** - When `true`, only notifies listeners if the value actually changes. Default is to notify on every execution.

- **`debugName`** - Optional identifier included in error logs and global exception handler callbacks.

## See Also

- [Command Basics](/documentation/command_it/command_basics) - Detailed usage examples and patterns
- [Command Properties](/documentation/command_it/command_properties) - Understanding command state (value, isRunning, canRun, errors)
- [Best Practices](/documentation/command_it/best_practices) - When to use which factory and production patterns
- [Error Handling](/documentation/command_it/error_handling) - Error management strategies
- [Restrictions](/documentation/command_it/restrictions) - Dynamic command enable/disable patterns
