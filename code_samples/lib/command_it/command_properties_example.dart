import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

class DataManager {
  final isEnabled = ValueNotifier<bool>(true);
  final api = ApiClient();

  late final loadCommand = Command.createAsyncNoParam<List<Todo>>(
    () => api.fetchTodos(),
    initialValue: [],
    restriction: isEnabled.map((enabled) => !enabled),
  );
}

// #region example
class PropertiesDemo extends StatelessWidget {
  PropertiesDemo({super.key});

  final manager = DataManager();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. value - Last successful result
        Text('Command Properties Demo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),

        ValueListenableBuilder<List<Todo>>(
          valueListenable: manager.loadCommand,
          builder: (context, todos, _) {
            return Text('value: ${todos.length} todos loaded');
          },
        ),
        SizedBox(height: 8),

        // 2. isRunning - Async execution state
        ValueListenableBuilder<bool>(
          valueListenable: manager.loadCommand.isRunning,
          builder: (context, isRunning, _) {
            return Row(
              children: [
                Text('isRunning: '),
                if (isRunning)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.check, size: 16, color: Colors.green),
              ],
            );
          },
        ),
        SizedBox(height: 8),

        // 3. canRun - Combined restriction and running state
        ValueListenableBuilder<bool>(
          valueListenable: manager.loadCommand.canRun,
          builder: (context, canRun, _) {
            return Text(
              'canRun: $canRun',
              style: TextStyle(color: canRun ? Colors.green : Colors.red),
            );
          },
        ),
        SizedBox(height: 8),

        // 4. errors - Error notifications
        ValueListenableBuilder<CommandError?>(
          valueListenable: manager.loadCommand.errors,
          builder: (context, error, _) {
            return Text(
              'errors: ${error?.error.toString() ?? 'none'}',
              style: TextStyle(color: error != null ? Colors.red : Colors.black),
            );
          },
        ),
        SizedBox(height: 16),

        // Control buttons
        Row(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: manager.loadCommand.canRun,
              builder: (context, canRun, _) {
                return ElevatedButton(
                  onPressed: canRun ? manager.loadCommand.run : null,
                  child: Text('Load Data'),
                );
              },
            ),
            SizedBox(width: 8),
            ValueListenableBuilder<bool>(
              valueListenable: manager.isEnabled,
              builder: (context, enabled, _) {
                return ElevatedButton(
                  onPressed: () => manager.isEnabled.value = !enabled,
                  child: Text(enabled ? 'Disable' : 'Enable'),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(home: Scaffold(body: Padding(padding: EdgeInsets.all(16), child: PropertiesDemo()))));
}
