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

## Mocking Dependencies

### Using Mock Classes

```dart
class MockApi {
  bool shouldFail = false;
  int callCount = 0;

  Future<String> fetchData() async {
    callCount++;

    if (shouldFail) {
      throw Exception('API Error');
    }

    return 'Data $callCount';
  }
}

test('Command with mocked dependency', () async {
  final mockApi = MockApi();

  final command = Command.createAsyncNoParam<String>(
    () => mockApi.fetchData(),
    initialValue: '',
  );

  final result = await command.runAsync();

  expect(result, 'Data 1');
  expect(mockApi.callCount, 1);
});
```

### Testing Error Scenarios with Mocks

```dart
test('Command handles API errors', () async {
  final mockApi = MockApi();
  mockApi.shouldFail = true;

  final command = Command.createAsyncNoParam<String>(
    () => mockApi.fetchData(),
    initialValue: '',
  );

  expect(
    () => command.runAsync(),
    throwsA(isA<Exception>()),
  );
});
```

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

## Testing with fake_async

For precise timing control, use `fake_async`:

```dart
import 'package:fake_async/fake_async.dart';

test('Test with controlled time', () {
  fakeAsync((async) {
    var result = '';

    final command = Command.createAsyncNoParam<String>(
      () async {
        await Future.delayed(Duration(seconds: 5));
        return 'delayed result';
      },
      initialValue: '',
    );

    command.listen((value, _) => result = value);
    command.run();

    // Immediately after run, still initial
    expect(result, '');

    // Advance time
    async.elapse(Duration(seconds: 5));

    // Now the result is set
    expect(result, 'delayed result');
  });
});
```

## Testing Disposal

Verify commands clean up properly:

```dart
test('Command disposes correctly', () async {
  var disposed = false;

  final command = Command.createAsyncNoParam<String>(
    () async => 'result',
    initialValue: '',
  );

  // Add listener
  command.listen((_, __) {});

  // Dispose
  await command.dispose();

  // Verify disposed (accessing properties should throw)
  expect(() => command.value, throwsA(anything));
});
```

## Integration Testing

### Testing Commands in Managers

```dart
class DataManager {
  final api = ApiClient();

  late final loadCommand = Command.createAsyncNoParam<List<String>>(
    () => api.fetchData(),
    initialValue: [],
  );

  void dispose() {
    loadCommand.dispose();
  }
}

test('DataManager integration', () async {
  final manager = DataManager();

  final result = await manager.loadCommand.runAsync();

  expect(result, isNotEmpty);

  manager.dispose();
});
```

### Testing Command Chains

```dart
test('Commands chain via restrictions', () async {
  final loadCommand = Command.createAsyncNoParam<void>(
    () async {
      await Future.delayed(Duration(milliseconds: 50));
    },
  );

  final saveCommand = Command.createAsyncNoParam<void>(
    () async {},
    restriction: loadCommand.isRunningSync,
  );

  loadCommand.run();

  // Save is restricted while load is running
  expect(saveCommand.canRun.value, false);

  await Future.delayed(Duration(milliseconds: 100));

  // After load completes, save can run
  expect(saveCommand.canRun.value, true);
});
```

## Common Testing Patterns

### Pattern 1: Setup/Teardown

```dart
group('Command Tests', () {
  late Command<void, String> command;
  late Collector<String> collector;

  setUp(() {
    collector = Collector<String>();
    command = Command.createAsyncNoParam<String>(
      () async => 'result',
      initialValue: '',
    );
    command.listen((value, _) => collector(value));
  });

  tearDown(() async {
    await command.dispose();
    collector.reset();
  });

  test('test 1', () async {
    // Test using command and collector
  });

  test('test 2', () async {
    // Test using command and collector
  });
});
```

### Pattern 2: Verify All States

```dart
test('Verify complete state flow', () async {
  final states = <String>[];

  final command = Command.createAsyncNoParam<String>(
    () async {
      await Future.delayed(Duration(milliseconds: 50));
      return 'done';
    },
    initialValue: 'initial',
  );

  command.results.listen((result, _) {
    if (result.isRunning) {
      states.add('running');
    } else if (result.hasError) {
      states.add('error');
    } else if (result.hasData) {
      states.add('success');
    }
  });

  await command.runAsync();

  expect(states, ['success', 'running', 'success']);
  // success (initial), running, success (completed)
});
```

### Pattern 3: Error Recovery

```dart
test('Command recovers after error', () async {
  var shouldFail = true;

  final command = Command.createAsyncNoParam<String>(
    () async {
      if (shouldFail) {
        throw Exception('Error');
      }
      return 'success';
    },
    initialValue: '',
  );

  // First call fails
  expect(() => command.runAsync(), throwsA(anything));

  await Future.delayed(Duration(milliseconds: 50));

  // Second call succeeds
  shouldFail = false;
  final result = await command.runAsync();
  expect(result, 'success');
});
```

## Debugging Tests

### Enable Print Statements

```dart
void setupCollectors(Command command, {bool enablePrint = true}) {
  command.canRun.listen((canRun, _) {
    if (enablePrint) print('canRun: $canRun');
  });

  command.results.listen((result, _) {
    if (enablePrint) {
      print('Result: data=${result.data}, error=${result.error}, '
          'isRunning=${result.isRunning}');
    }
  });
}
```

### Use testWidgets for UI Integration

```dart
testWidgets('CommandBuilder widget test', (tester) async {
  final command = Command.createAsyncNoParam<String>(
    () async => 'result',
    initialValue: '',
  );

  await tester.pumpWidget(
    MaterialApp(
      home: CommandBuilder(
        command: command,
        whileRunning: (context, _, __) => CircularProgressIndicator(),
        onData: (context, data, _) => Text(data),
      ),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('result'), findsOneWidget);
});
```

## Best Practices

**✅ Do:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Use <code>Collector</code> pattern for state verification</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Test both success and error paths</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Verify state transitions with <code>CommandResult</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Use <code>runAsync()</code> to await results in tests</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Mock external dependencies</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Test restriction behavior</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Verify disposal</li>
</ul>

**❌️ Don't:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Access <code>isRunning</code> on sync commands</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Forget to dispose commands in tearDown</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Test UI and business logic together</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Rely on timing without <code>fake_async</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Ignore error handling tests</li>
</ul>

## See Also

- [Command Basics](/documentation/command_it/command_basics) — Creating commands
- [Command Properties](/documentation/command_it/command_properties) — Observable properties
- [Error Handling](/documentation/command_it/error_handling) — Error management
- [Best Practices](/documentation/command_it/best_practices) — Production patterns
