import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;

// Mock services for demonstration
class Analytics {
  void logError(String command, String error) {
    debugPrint('Analytics: Command "$command" failed with: $error');
  }
}

class CrashReporter {
  void report(Object error, StackTrace? stackTrace) {
    debugPrint('Crash report: $error\n$stackTrace');
  }
}

final analytics = Analytics();
final crashReporter = CrashReporter();

// #region example
void setupGlobalErrorMonitoring() {
  // Direct stream listener for analytics and crash reporting
  Command.globalErrors.listen((error) {
    // Send to analytics
    analytics.logError(error.commandName ?? 'unknown', error.error.toString());

    // Send to crash reporting
    crashReporter.report(error.error, error.stackTrace);
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
    // Use GlobalErrorFilter to route to global handler
    errorFilter: const GlobalErrorFilter(),
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
