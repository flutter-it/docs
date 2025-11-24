# Testing Commands

Learn how to write effective tests for commands, verify state transitions, and test error handling. command_it is designed to be highly testable.

## Why Commands Are Easy to Test

Commands provide clear interfaces for testing:

- **Observable state**: All state changes via `ValueListenable`
- **Predictable behavior**: Run → execute → notify
- **Error containment**: Errors don't crash tests
- **No UI dependencies**: Test business logic independently

## Basic Testing Pattern

<<< @/../code_samples/test/command_it/command_testing_example_test.dart#example

## The Collector Pattern

Use a `Collector` helper to accumulate `ValueListenable` emissions:

```dart
class Collector<T> {
  List<T>? values;

  void call(T value) {
    values ??= <T>[];
    values!.add(value);
  }

  void reset() {
    values?.clear();
    values = null;
  }
}

// Usage in tests
final resultCollector = Collector<String>();
command.listen((result, _) => resultCollector(result));

await command.runAsync();

expect(resultCollector.values, ['initial', 'loaded data']);
```

**Why this pattern?**

Commands are designed to work **asynchronously without being awaited** - they're meant to be **observed**, not awaited. This is the core architectural principle of command_it:

- Commands emit state changes via `ValueListenable` (results, errors, isRunning)
- UI observes commands reactively, not via `await`
- Tests need to verify the **sequence** of emitted values
- Collector accumulates all emissions so you can assert on complete state transitions

While `runAsync()` is useful when you need to await a result (like with `RefreshIndicator`), the Collector pattern tests commands the way they're typically used: fire-and-forget with observation.

## Testing Async Commands

### Using runAsync()

```dart
test('Async command executes successfully', () async {
  final command = Command.createAsyncNoParam<String>(
    () async {
      await Future.delayed(Duration(milliseconds: 100));
      return 'result';
    },
    initialValue: '',
  );

  // Await the result
  final result = await command.runAsync();

  expect(result, 'result');
});
```

## Testing Error Handling

### Basic Error Testing

```dart
test('Command handles errors', () async {
  final errorCollector = Collector<CommandError?>();

  final command = Command.createAsyncNoParam<String>(
    () async {
      throw Exception('Test error');
    },
    initialValue: '',
  );

  command.errors.listen((error, _) => errorCollector(error));

  try {
    await command.runAsync();
    fail('Should have thrown');
  } catch (e) {
    expect(e.toString(), contains('Test error'));
  }

  // errors emits null first, then the error
  expect(errorCollector.values?.length, 2);
  expect(errorCollector.values?.last?.error.toString(), contains('Test error'));
});
```

### Testing ErrorFilters

```dart
test('ErrorFilter routes errors correctly', () async {
  var localHandlerCalled = false;
  var globalHandlerCalled = false;

  Command.globalExceptionHandler = (error, stackTrace) {
    globalHandlerCalled = true;
  };

  final command = Command.createAsyncNoParam<String>(
    () => throw Exception('Test error'),
    initialValue: '',
    errorFilter: PredicatesErrorFilter([
      (error, stackTrace) => ErrorReaction.localHandler,
    ]),
  );

  command.errors.listen((error, _) {
    if (error != null) localHandlerCalled = true;
  });

  try {
    await command.runAsync();
  } catch (_) {}

  expect(localHandlerCalled, true);
  expect(globalHandlerCalled, false); // Only local
});
```

## MockCommand

For testing code that depends on commands, use the built-in `MockCommand` class to create controlled test environments. The pattern below shows how to create a real manager with actual commands, then a mock version for testing.

<<< @/../code_samples/test/command_it/mock_command_example_test.dart#example

**Key MockCommand methods:**

- **<code>queueResultsForNextRunCall(List&lt;CommandResult&lt;TParam, TResult&gt;&gt;)</code>** - Queue multiple results to be returned in sequence
- **`startRun()`** - Manually trigger the running state
- **`endRunWithData(TResult data)`** - Complete execution with a result
- **`endRunNoData()`** - Complete execution without a result (void commands)
- **`endRunWithError(String message)`** - Complete execution with an error
- **`runCount`** - Track how many times the command was run

**This pattern demonstrates:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Real service with actual command using get_it for dependencies</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Mock service implements real service and overrides command with MockCommand</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Control methods make test code readable and maintainable</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Manager uses get_it to access service (full dependency injection)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Tests register mock service to control command behavior</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ No async delays - tests run instantly</li>
</ul>

**When to use MockCommand:**

- Testing code that depends on commands without async delays
- Testing loading, success, and error state handling
- Unit testing services that coordinate commands
- When you need precise control over command state transitions

## See Also

- [Command Basics](/documentation/command_it/command_basics) — Creating commands
- [Command Properties](/documentation/command_it/command_properties) — Observable properties
- [Error Handling](/documentation/command_it/error_handling) — Error management
- [Best Practices](/documentation/command_it/best_practices) — Production patterns
