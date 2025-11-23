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

### Using MockCommand

For testing code that depends on commands, use the built-in `MockCommand` class instead of creating real commands:

```dart
import 'package:command_it/command_it.dart';

test('Service uses command correctly', () async {
  // Create a mock command
  final mockLoadCommand = MockCommand<void, List<String>>(
    initialValue: [],
  );

  // Queue results for the next execution
  mockLoadCommand.queueResultsForNextExecuteCall([
    CommandResult<void, List<String>>(null, ['Item 1', 'Item 2', 'Item 3'], null, false),
  ]);

  // Inject into service
  final service = DataService(loadCommand: mockLoadCommand);

  // Trigger the command
  service.loadData();

  // Verify the command was called
  expect(mockLoadCommand.executionCount, 1);

  // Verify the result
  expect(mockLoadCommand.value, ['Item 1', 'Item 2', 'Item 3']);
});
```

**Key MockCommand methods:**

- **<code>queueResultsForNextExecuteCall(List&lt;CommandResult&lt;TParam, TResult&gt;&gt;)</code>** - Queue multiple results to be returned in sequence
- **`startExecution()`** - Manually trigger the running state
- **`endExecutionWithData(TResult data)`** - Complete execution with a result
- **`endExecutionNoData()`** - Complete execution without a result (void commands)
- **`endExecutionWithError(String message)`** - Complete execution with an error
- **`executionCount`** - Track how many times the command was executed

**Testing loading states:**

```dart
test('UI shows loading indicator', () async {
  final mockCommand = MockCommand<void, String>(
    initialValue: '',
  );

  final loadingStates = <bool>[];
  mockCommand.isRunning.listen((running, _) => loadingStates.add(running));

  // Start execution manually
  mockCommand.startExecution();
  expect(mockCommand.isRunning.value, true);

  // Complete execution
  mockCommand.endExecutionWithData('loaded data');
  expect(mockCommand.isRunning.value, false);

  expect(loadingStates, [false, true, false]);
});
```

**Testing error scenarios:**

```dart
test('UI shows error message', () {
  final mockCommand = MockCommand<void, String>(
    initialValue: '',
  );

  CommandError? capturedError;
  mockCommand.errors.listen((error, _) => capturedError = error);

  // Simulate error
  mockCommand.startExecution();
  mockCommand.endExecutionWithError('Network error');

  expect(capturedError?.error.toString(), contains('Network error'));
});
```

**Benefits of MockCommand:**

- ✅ No async delays - tests run faster
- ✅ Full control over execution state
- ✅ Verify execution count
- ✅ Queue multiple results for sequential calls
- ✅ Test loading, success, and error states independently
- ✅ No need for real business logic in tests

**When to use MockCommand:**

- Testing widgets that observe commands
- Testing services that coordinate multiple commands
- Unit testing command-dependent code
- When you need precise control over command state transitions

## See Also

- [Command Basics](/documentation/command_it/command_basics) — Creating commands
- [Command Properties](/documentation/command_it/command_properties) — Observable properties
- [Error Handling](/documentation/command_it/error_handling) — Error management
- [Best Practices](/documentation/command_it/best_practices) — Production patterns
