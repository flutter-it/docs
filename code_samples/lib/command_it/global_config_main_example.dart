import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// #region example
void main() {
  // Configure global command_it settings before runApp

  // 1. Global exception handler - called based on ErrorFilter configuration
  Command.globalExceptionHandler = (error, stackTrace) {
    debugPrint('Command error: ${error.error}');
    debugPrint('Command: ${error.command}');
    debugPrint('Parameter: ${error.paramData}');

    // In production, send to Sentry
    // Sentry.captureException(error.error, stackTrace: stackTrace);
  };

  // 2. Default error filter - determines error handling strategy
  Command.errorFilterDefault = const GlobalIfNoLocalErrorFilter();

  // 3. Logging handler - log all command executions
  Command.loggingHandler = (commandName, result) {
    if (kDebugMode) {
      debugPrint(
          'Command executed: ${result.isRunning ? "started" : "completed"}');
      if (result.hasError) {
        debugPrint('  Error: ${result.error}');
      }
    }
  };

  // 4. Detailed stack traces - strip framework noise (default: true)
  Command.detailedStackTraces = true;

  // 5. Assertions always throw - bypass error filters for assertions (default: true)
  Command.assertionsAlwaysThrow = true;

  // 6. Report all exceptions - ensure all errors reach global handler (for debugging)
  Command.reportAllExceptions = kDebugMode;

  // 7. Report error handler exceptions - if local error handler throws
  Command.reportErrorHandlerExceptionsToGlobalHandler = true;

  runApp(MyApp());
}
// #endregion example

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('App with global command configuration')),
      ),
    );
  }
}
