import 'package:command_it/command_it.dart';
import 'package:flutter_test/flutter_test.dart';

// #region example
/// Example service that uses a command (for dependency injection in tests)
class DataService {
  final Command<void, List<String>> loadCommand;

  DataService({required this.loadCommand});

  void loadData() {
    loadCommand.run();
  }
}

void main() {
  group('MockCommand Examples', () {
    test('Queue results with CommandResult', () async {
      final mockLoadCommand = MockCommand<void, List<String>>(
        initialValue: [],
      );

      // Queue results for the next execution using CommandResult
      mockLoadCommand.queueResultsForNextExecuteCall([
        CommandResult<void, List<String>>(
            null, ['Item 1', 'Item 2', 'Item 3'], null, false),
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

    test('Manually control execution states', () {
      final mockCommand = MockCommand<void, String>(
        initialValue: '',
      );

      // Initially not running
      expect(mockCommand.isRunning.value, false);

      // Start execution manually
      mockCommand.startExecution();
      expect(mockCommand.isRunning.value, true);

      // Complete execution with data
      mockCommand.endExecutionWithData('loaded data');
      expect(mockCommand.isRunning.value, false);
      expect(mockCommand.value, 'loaded data');
    });

    test('Simulate error scenarios', () {
      final mockCommand = MockCommand<void, String>(
        initialValue: '',
      );

      CommandError? capturedError;
      mockCommand.errors.listen((error, _) => capturedError = error);

      // Simulate error with String message (not Exception)
      mockCommand.startExecution();
      mockCommand.endExecutionWithError('Network error');

      expect(capturedError?.error.toString(), contains('Network error'));
      expect(mockCommand.isRunning.value, false);
    });

    test('Complete execution without data (void commands)', () {
      final mockCommand = MockCommand<void, void>(
        initialValue: null,
        noReturnValue: true,
      );

      var executionCompleted = false;
      mockCommand.results.listen((result, _) {
        if (!result.isRunning && !result.hasError) {
          executionCompleted = true;
        }
      });

      mockCommand.startExecution();
      mockCommand.endExecutionNoData();

      expect(executionCompleted, true);
      expect(mockCommand.isRunning.value, false);
    });

    test('Track execution count', () {
      final mockCommand = MockCommand<String, void>(
        initialValue: null,
        noReturnValue: true,
      );

      expect(mockCommand.executionCount, 0);

      mockCommand.run('test1');
      expect(mockCommand.executionCount, 1);
      expect(mockCommand.lastPassedValueToExecute, 'test1');

      mockCommand.run('test2');
      expect(mockCommand.executionCount, 2);
      expect(mockCommand.lastPassedValueToExecute, 'test2');
    });
  });
}
// #endregion example
