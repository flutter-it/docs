# Command Types

::: warning AI-Generated Content Under Review
This documentation was generated with AI assistance and is currently under review. While we strive for accuracy, there may be errors or inconsistencies. Please report any issues you find.
:::

## How to create Commands
´Command´ offers different static factory functions for the different function types you want to wrap:

```dart
  /// for syncronous functions with no parameter and no result
  static Command<void, void> createSyncNoParamNoResult(
    void Function() action, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  /// for syncronous functions with one parameter and no result
  static Command<TParam, void> createSyncNoResult<TParam>(
    void Function(TParam x) action, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  /// for syncronous functions with no parameter and but a result
  static Command<void, TResult> createSyncNoParam<TResult>(
    TResult Function() func,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  /// for syncronous functions with one parameter and result
  static Command<TParam, TResult> createSync<TParam, TResult>(
    TResult Function(TParam x) func,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })

  /// and for Async functions:
  static Command<void, void> createAsyncNoParamNoResult(
    Future Function() action, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  static Command<TParam, void> createAsyncNoResult<TParam>(
    Future Function(TParam x) action, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  static Command<void, TResult> createAsyncNoParam<TResult>(
    Future<TResult> Function() func,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  static Command<TParam, TResult> createAsync<TParam, TResult>(
    Future<TResult> Function(TParam x) func,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })

  /// and for Undoable async commands:
  static UndoableCommand<void, void, TUndoState> createUndoableNoParamNoResult<TUndoState>(
    Future Function(TUndoState) action,
    UndoHandler<void, TUndoState> undo, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool undoOnExecutionFailure = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  static UndoableCommand<TParam, void, TUndoState> createUndoableNoResult<TParam, TUndoState>(
    Future Function(TParam, TUndoState) action,
    UndoHandler<TParam, TUndoState> undo, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool undoOnExecutionFailure = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  static UndoableCommand<void, TResult, TUndoState> createUndoableNoParam<TResult, TUndoState>(
    Future<TResult> Function(TUndoState) func,
    UndoHandler<void, TUndoState> undo,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool undoOnExecutionFailure = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  static UndoableCommand<TParam, TResult, TUndoState> createUndoable<TParam, TResult, TUndoState>(
    Future<TResult> Function(TParam, TUndoState) func,
    UndoHandler<TParam, TUndoState> undo,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool undoOnExecutionFailure = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  ```

## Undoable Commands

Undoable commands extend async commands with undo capability. They maintain an `UndoStack<TUndoState>` that stores state snapshots, allowing you to undo operations.

**Key parameters:**
- **`action`/`func`** - Your async function that receives the undo state as an additional parameter
- **`undo`** - Handler function that returns the state snapshot needed to undo the operation
- **`undoOnExecutionFailure`** - When `true`, automatically calls `undo()` if the command fails

**Type parameters:**
- **`TUndoState`** - The type of state snapshot needed to undo the operation

See [Best Practices - Undoable Commands](/documentation/command_it/best_practices#undoable-commands-with-automatic-rollback) for practical examples and [Error Handling - Auto-Undo on Failure](/documentation/command_it/error_handling#auto-undo-on-failure) for error recovery patterns.

For detailed information on the parameters of these functions consult the API docs or the source code documentation.
