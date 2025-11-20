import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock API for testing
class MockApi {
  bool shouldFail = false;
  int callCount = 0;

  Future<String> fetchData() async {
    callCount++;
    await Future.delayed(Duration(milliseconds: 100));

    if (shouldFail) {
      throw Exception('API Error');
    }

    return 'Data $callCount';
  }
}

// #region example
/// Helper class to collect ValueListenable emissions during tests
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

void main() {
  late MockApi mockApi;
  late Collector<String> resultCollector;
  late Collector<bool> isRunningCollector;
  late Collector<CommandError?> errorCollector;

  setUp(() {
    mockApi = MockApi();
    resultCollector = Collector<String>();
    isRunningCollector = Collector<bool>();
    errorCollector = Collector<CommandError?>();
  });

  group('Command Basic Tests', () {
    test('Command executes successfully', () async {
      final command = Command.createAsyncNoParam<String>(
        () => mockApi.fetchData(),
        initialValue: '',
      );

      // Set up listeners
      command.listen((result, _) => resultCollector(result));
      command.isRunning.listen((running, _) => isRunningCollector(running));

      // Execute command
      final result = await command.runAsync();

      expect(result, 'Data 1');
      expect(mockApi.callCount, 1);
      expect(resultCollector.values, ['', 'Data 1']);
      expect(isRunningCollector.values, [false, true, false]);
    });

    test('Command handles errors correctly', () async {
      mockApi.shouldFail = true;

      final command = Command.createAsyncNoParam<String>(
        () => mockApi.fetchData(),
        initialValue: '',
      );

      // Listen to errors
      command.errors.listen((error, _) => errorCollector(error));

      // Execute and expect error
      try {
        await command.runAsync();
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('API Error'));
      }

      expect(errorCollector.values?.length, 2); // null, then error
      expect(
          errorCollector.values?.last?.error.toString(), contains('API Error'));
    });

    test('Command prevents parallel execution', () async {
      var executionCount = 0;

      final command = Command.createAsyncNoParam<int>(
        () async {
          executionCount++;
          await Future.delayed(Duration(milliseconds: 50));
          return executionCount;
        },
        initialValue: 0,
      );

      // Start multiple executions rapidly
      command.run();
      command.run();
      command.run();

      // Wait for completion
      await Future.delayed(Duration(milliseconds: 100));

      // Only one execution should have occurred
      expect(executionCount, 1);
    });
  });

  group('Command with Restrictions', () {
    test('Restriction prevents execution', () {
      final restriction = ValueNotifier<bool>(false);
      var executionCount = 0;

      final command = Command.createSyncNoParamNoResult(
        () => executionCount++,
        restriction: restriction,
      );

      // Can execute when not restricted
      expect(command.canRun.value, true);
      command.run();
      expect(executionCount, 1);

      // Cannot execute when restricted
      restriction.value = true;
      expect(command.canRun.value, false);
      command.run();
      expect(executionCount, 1); // Still 1, didn't execute
    });

    test('canRun combines restriction and running state', () {
      final restriction = ValueNotifier<bool>(false);
      var executionCount = 0;

      final command = Command.createSyncNoParamNoResult(
        () => executionCount++,
        restriction: restriction,
      );

      expect(command.canRun.value, true); // Not restricted, not running

      restriction.value = true;
      expect(command.canRun.value, false); // Restricted

      restriction.value = false;
      expect(command.canRun.value, true); // No longer restricted
    });
  });

  group('CommandResult Testing', () {
    test('CommandResult state transitions', () async {
      final resultCollector = Collector<CommandResult<void, String>>();

      final command = Command.createAsyncNoParam<String>(
        () => mockApi.fetchData(),
        initialValue: 'initial',
      );

      command.results.listen((result, _) => resultCollector(result));

      await command.runAsync();

      final results = resultCollector.values!;

      // Initial state
      expect(results[0].data, 'initial');
      expect(results[0].isRunning, false);
      expect(results[0].hasError, false);

      // Running state
      expect(results[1].isRunning, true);
      expect(results[1].data, null); // Data cleared during execution

      // Success state
      expect(results[2].isRunning, false);
      expect(results[2].data, 'Data 1');
      expect(results[2].hasError, false);
    });

    test('includeLastResultInCommandResults keeps old data', () async {
      final resultCollector = Collector<CommandResult<void, String>>();

      final command = Command.createAsyncNoParam<String>(
        () => mockApi.fetchData(),
        initialValue: 'initial',
        includeLastResultInCommandResults: true, // Keep old data
      );

      command.results.listen((result, _) => resultCollector(result));

      await command.runAsync();

      final results = resultCollector.values!;

      // Running state keeps old data
      expect(results[1].isRunning, true);
      expect(results[1].data, 'initial'); // Old data still visible

      // Success state
      expect(results[2].data, 'Data 1');
    });
  });

  group('Error Filter Testing', () {
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
      expect(globalHandlerCalled, false); // Only local handler
    });
  });

  group('Sync Command Testing', () {
    test('Sync command executes immediately', () {
      var result = '';

      final command = Command.createSyncNoParam<String>(
        () => 'immediate',
        initialValue: '',
      );

      command.listen((value, _) => result = value);

      command.run();

      expect(result, 'immediate');
    });

    test('Sync command does not have isRunning', () {
      final command = Command.createSyncNoParam<String>(
        () => 'test',
        initialValue: '',
      );

      // Accessing isRunning on sync command throws
      expect(
        () => command.isRunning,
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
// #endregion example
