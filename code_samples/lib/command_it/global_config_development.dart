import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// #region example
void configureDevelopmentMode() {
  // Development: verbose logging and error reporting

  // Report ALL exceptions - even if error filters would swallow them
  Command.reportAllExceptions = true;

  // Detailed stack traces - strip framework noise for easier debugging
  Command.detailedStackTraces = true;

  // Assertions always throw - catch programming errors immediately
  Command.assertionsAlwaysThrow = true;

  // Log every command execution for debugging
  Command.loggingHandler = (commandName, result) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] Command execution:');
    debugPrint('  isRunning: ${result.isRunning}');
    debugPrint('  hasData: ${result.hasData}');
    debugPrint('  hasError: ${result.hasError}');
    if (result.paramData != null) {
      debugPrint('  param: ${result.paramData}');
    }
    if (result.hasError) {
      debugPrint('  error: ${result.error}');
    }
  };

  // Global error handler - print detailed error information
  Command.globalExceptionHandler = (error, stackTrace) {
    debugPrint('═══ COMMAND ERROR ═══');
    debugPrint('Command: ${error.command}');
    debugPrint('Error: ${error.error}');
    debugPrint('Parameter: ${error.paramData}');
    debugPrint('Stack trace:');
    debugPrint(stackTrace.toString());
    debugPrint('═══════════════════');
  };

  // Default filter: try local, fallback to global
  Command.errorFilterDefault = const GlobalErrorFilter();
}
// #endregion example

void main() {
  configureDevelopmentMode();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Development mode configuration')),
      ),
    );
  }
}
