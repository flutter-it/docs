import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';

// Mock crash reporting service
class CrashReporting {
  void recordError(Object error, StackTrace? stackTrace,
      {Map<String, dynamic>? context}) {
    // Send to Firebase Crashlytics, Sentry, etc.
  }
}

final crashReporting = CrashReporting();

// Mock analytics service
class Analytics {
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    // Send to Firebase Analytics, Mixpanel, etc.
  }
}

final analytics = Analytics();

// #region example
void configureProductionMode() {
  // Production: crash reporting only, respect error filters

  // Don't report all exceptions - respect error filters
  Command.reportAllExceptions = false;

  // Keep detailed stack traces for crash reports
  Command.detailedStackTraces = true;

  // Assertions should throw - catch critical bugs
  Command.assertionsAlwaysThrow = true;

  // Global error handler - send to crash reporting
  Command.globalExceptionHandler = (error, stackTrace) {
    crashReporting.recordError(
      error.error,
      stackTrace,
      context: {
        'command': error.command,
        'parameter': error.paramData?.toString(),
        'error_reaction': error.errorReaction.toString(),
      },
    );
  };

  // Default filter: local errors stay local, unhandled go global
  Command.errorFilterDefault = const GlobalIfNoLocalErrorFilter();

  // If error handler itself throws, report to global handler
  Command.reportErrorHandlerExceptionsToGlobalHandler = true;
}
// #endregion example

void main() {
  configureProductionMode();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Production mode configuration')),
      ),
    );
  }
}
