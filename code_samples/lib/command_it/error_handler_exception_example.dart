import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// Error logging service that can fail
class ErrorLoggingApi {
  bool shouldFailLogging = false;

  Future<void> logError(CommandError error) async {
    await simulateDelay();
    if (shouldFailLogging) {
      throw NetworkException('Failed to reach logging service');
    }
    debugPrint('Successfully logged error: ${error.error}');
  }
}

// #region example
class DataManager {
  final api = ApiClient();
  final errorLoggingApi = ErrorLoggingApi();

  // Error handler that makes async API call - can throw!
  late final loadDataCommand = Command.createAsyncNoParam<List<Todo>>(
    () async {
      await simulateDelay();
      throw ApiException('Failed to load data', 500);
    },
    initialValue: [],
  )..errors.listen((error, _) async {
      if (error != null) {
        try {
          // This async operation can fail with NetworkException
          await errorLoggingApi.logError(error);
        } catch (e) {
          // If reportErrorHandlerExceptionsToGlobalHandler is true (default),
          // this exception will be caught and sent to globalExceptionHandler
          // with originalError set to the command's error
          rethrow;
        }
      }
    });
}

void setupGlobalHandler() {
  Command.globalExceptionHandler = (error, stackTrace) {
    if (error.originalError != null) {
      // This is an exception from an error handler, not the command itself
      debugPrint('''
        Error Handler Failed:
        - Handler exception: ${error.error}
        - Original command error: ${error.originalError}
        - Command: ${error.commandName}
      ''');
      // Log to monitoring service, show alert, etc.
    } else {
      // Normal command error
      debugPrint('Command failed: ${error.error}');
    }
  };

  // Enable reporting (this is the default, shown for clarity)
  Command.reportErrorHandlerExceptionsToGlobalHandler = true;
}
// #endregion example

void main() {
  setupGlobalHandler();

  final manager = DataManager();

  // Scenario 1: Normal error - error handler succeeds
  debugPrint('=== Scenario 1: Error handler succeeds ===');
  manager.loadDataCommand.run();

  // Scenario 2: Error handler fails - both errors reported
  Future.delayed(Duration(seconds: 2), () {
    debugPrint('\n=== Scenario 2: Error handler also fails ===');
    manager.errorLoggingApi.shouldFailLogging = true;
    manager.loadDataCommand.run();
  });
}
