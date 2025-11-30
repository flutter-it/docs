# Command Chaining

Connect commands together declaratively using `pipeToCommand`. When a source `ValueListenable` changes, it automatically triggers the target command.

## Why Use pipeToCommand?

Instead of manually setting up listeners:

```dart
// ❌ Manual approach - more boilerplate
sourceCommand.listen((value, _) {
  if (value.isNotEmpty) {
    targetCommand(value);
  }
});
```

Use `pipeToCommand` for cleaner, declarative chaining:

```dart
// ✅ Declarative approach
sourceCommand
    .where((value) => value.isNotEmpty)
    .pipeToCommand(targetCommand);
```

**Benefits:**
- Declarative and readable
- Combines with `listen_it` operators (debounce, where, map)
- Returns `ListenableSubscription` for easy cleanup
- Works on any `ValueListenable`, not just commands

## Inline Chaining with Cascade

The cleanest pattern: use Dart's cascade operator `..` to chain directly on command definition:

```dart
class DataManager {
  late final refreshCommand = Command.createAsyncNoParam<List<Data>>(
    () => api.fetchData(),
    initialValue: [],
  );

  // Chain directly on definition - no constructor needed!
  late final saveCommand = Command.createAsyncNoResult<Data>(
    (data) => api.save(data),
  )..pipeToCommand(refreshCommand);
}
```

This eliminates the need for a constructor just to set up pipes. The subscription is managed automatically when the command is disposed.

## Basic Usage

`pipeToCommand` works on any `ValueListenable`:

### From a Command

When one command completes, trigger another:

<<< @/../code_samples/lib/command_it/command_chaining_basic.dart#basic

### From isRunning

React to command execution state:

<<< @/../code_samples/lib/command_it/command_chaining_basic.dart#from_isrunning

### From results

Pipe the full `CommandResult` (includes success/error state):

<<< @/../code_samples/lib/command_it/command_chaining_basic.dart#from_results

### From ValueNotifier

Works with plain `ValueNotifier` too:

<<< @/../code_samples/lib/command_it/command_chaining_basic.dart#from_valuenotifier

## Transform Function

When source and target types don't match, use the `transform` parameter:

### Basic Transform

<<< @/../code_samples/lib/command_it/command_chaining_transform.dart#transform_basic

### Complex Transform

Create complex parameter objects:

<<< @/../code_samples/lib/command_it/command_chaining_transform.dart#transform_complex

### Transform Results

Transform command results before piping:

<<< @/../code_samples/lib/command_it/command_chaining_transform.dart#transform_result

## Type Handling

`pipeToCommand` handles types automatically:

1. **Transform provided** → Uses transform function
2. **Types match** → Passes value directly to `target.run(value)`
3. **Types don't match** → Calls `target.run()` without parameters

This means you can pipe to no-parameter commands without a transform:

```dart
// saveCommand returns Data, refreshCommand takes no params
saveCommand.pipeToCommand(refreshCommand);  // Works! Calls refreshCommand.run()
```

## Combining with listen_it Operators

The real power comes from combining `pipeToCommand` with [listen_it operators](/documentation/listen_it/operators/overview) like `debounce`, `where`, and `map`:

### Search with Debounce

<<< @/../code_samples/lib/command_it/command_chaining_operators.dart#search_example

### Filter Before Piping

<<< @/../code_samples/lib/command_it/command_chaining_operators.dart#filter_example

## Subscription Management

`pipeToCommand` returns a `ListenableSubscription`. Always store and cancel it to prevent memory leaks.

### Basic Cleanup

<<< @/../code_samples/lib/command_it/command_chaining_cleanup.dart#cleanup_basic

### Multiple Subscriptions

<<< @/../code_samples/lib/command_it/command_chaining_cleanup.dart#cleanup_multiple

## Warning: Circular Pipes

::: danger Avoid Circular Pipes
Never create circular pipe chains - they cause infinite loops:

```dart
// ❌ DANGER: Infinite loop!
commandA.pipeToCommand(commandB);
commandB.pipeToCommand(commandA);  // A triggers B triggers A triggers B...
```

If you need bidirectional communication, use guards:

```dart
// ✅ Safe: Guard against loops
bool _updating = false;

commandA.listen((value, _) {
  if (!_updating) {
    _updating = true;
    commandB(value);
    _updating = false;
  }
});
```
:::

## API Reference

```dart
extension ValueListenablePipe<T> on ValueListenable<T> {
  ListenableSubscription pipeToCommand<TTargetParam, TTargetResult>(
    Command<TTargetParam, TTargetResult> target, {
    TTargetParam Function(T value)? transform,
  })
}
```

**Parameters:**
- `target` — The command to trigger when the source changes
- `transform` — Optional function to convert source value to target parameter type

**Returns:** `ListenableSubscription` — Cancel this to stop the pipe

## See Also

- [Restrictions](/documentation/command_it/restrictions) — Disable commands based on state
- [Command Properties](/documentation/command_it/command_properties) — Observable properties like `isRunning`
- [listen_it Operators](/documentation/listen_it/operators/overview) — Operators like `debounce`, `where`, `map`
