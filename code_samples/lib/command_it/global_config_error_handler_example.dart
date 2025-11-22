import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// #region example
void setupGlobalExceptionHandler() {
  Command.globalExceptionHandler = (commandError, stackTrace) {
    // Access all error context from CommandError
    final error = commandError.error; // The actual exception thrown
    final command = commandError.command; // Command name/identifier
    final param = commandError.paramData; // Parameter passed to command
    final reaction = commandError.errorReaction; // How error was handled

    // Send to Sentry with rich context
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        // Add tags for filtering in Sentry UI
        scope.setTag('command', command ?? 'unknown');
        scope.setTag('error_type', error.runtimeType.toString());

        // Add context for debugging
        scope.setContexts('command_context', {
          'command_name': command,
          'command_parameter': param?.toString(),
          'error_reaction': reaction.toString(),
        });
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
