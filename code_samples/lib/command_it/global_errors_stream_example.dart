import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:sentry_flutter/sentry_flutter.dart';

// Mock analytics service for demonstration
class Analytics {
  void logError(String command, String error) {
    debugPrint('Analytics: Command "$command" failed with: $error');
  }
}

final analytics = Analytics();

// #region example
void setupGlobalErrorMonitoring() {
  // Direct stream listener for analytics and Sentry
  Command.globalErrors.listen((error) {
    // Send to analytics
    analytics.logError(error.commandName ?? 'unknown', error.error.toString());

    // Send to Sentry with command context
    Sentry.captureException(
      error.error,
      stackTrace: error.stackTrace,
      withScope: (scope) {
        scope.setTag('command', error.commandName ?? 'unknown');
        scope.setContexts('command_context', {
          'parameter': error.paramData?.toString(),
        });
      },
    );
  });
}

class MyApp extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // watch_it integration: Show error toasts for all global errors
    registerStreamHandler<Stream<CommandError>, CommandError>(
      target: Command.globalErrors,
      handler: (context, snapshot, cancel) {
        if (snapshot.hasData) {
          final error = snapshot.data!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );

    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Command that will fail and trigger global error stream
  late final failingCommand = Command.createAsyncNoParamNoResult(
    () async {
      await Future.delayed(const Duration(milliseconds: 500));
      throw Exception('Simulated API failure');
    },
    // Use GlobalIfNoLocalErrorFilter to route to global handler
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  @override
  void dispose() {
    failingCommand.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Errors Stream Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Click the button to trigger an error.\n'
              'The error will:\n'
              '• Be logged to analytics\n'
              '• Be sent to crash reporting\n'
              '• Show a toast notification',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => failingCommand.run(),
              child: const Text('Trigger Global Error'),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion example

void main() {
  setupGlobalErrorMonitoring();
  runApp(MyApp());
}
