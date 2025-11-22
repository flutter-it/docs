import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';

// Mock crash reporting service
class CrashReporting {
  void recordError(Object error, StackTrace? stackTrace,
      {Map<String, dynamic>? context}) {
    debugPrint('Crash report: $error');
    debugPrint('Context: $context');
  }
}

final crashReporting = CrashReporting();

// #region example
void setupGlobalExceptionHandler() {
  Command.globalExceptionHandler = (commandError, stackTrace) {
    // Access all error context from CommandError
    final error = commandError.error; // The actual exception thrown
    final command = commandError.command; // Command name/identifier
    final param = commandError.paramData; // Parameter passed to command
    final reaction = commandError.errorReaction; // How error was handled

    // Send to crash reporting with rich context
    crashReporting.recordError(
      error,
      stackTrace,
      context: {
        'command_name': command,
        'command_parameter': param?.toString(),
        'error_reaction': reaction.toString(),
        'error_type': error.runtimeType.toString(),
      },
    );

    // Log for debugging
    if (kDebugMode) {
      debugPrint('Command "$command" failed');
      debugPrint('Parameter: $param');
      debugPrint('Error: $error');
      debugPrint('Reaction: $reaction');
    }
  };
}
// #endregion example

void main() {
  setupGlobalExceptionHandler();
}
