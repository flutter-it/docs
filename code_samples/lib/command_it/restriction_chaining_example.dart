import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class DataManager {
  final api = ApiClient();

  // First command: load initial data
  late final loadCommand = Command.createAsyncNoParam<List<Todo>>(
    () => api.fetchTodos(),
    initialValue: [],
  );

  // Second command: can't save while loading
  late final saveCommand = Command.createAsyncNoResult<Todo>(
    (todo) async {
      await simulateDelay();
      // Save logic here
    },
    // Restrict based on first command's running state
    restriction: loadCommand.isRunningSync,
  );

  // Third command: can't update while saving
  late final updateCommand = Command.createAsyncNoResult<Todo>(
    (todo) async {
      await simulateDelay(500);
      // Update logic here
    },
    // Can't update while save is running
    restriction: saveCommand.isRunningSync,
  );
}

class ChainedCommandsWidget extends StatelessWidget {
  ChainedCommandsWidget({super.key});

  final manager = DataManager();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Command Chaining Example',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),

          // Load button
          ValueListenableBuilder<bool>(
            valueListenable: manager.loadCommand.canRun,
            builder: (context, canRun, _) {
              return ElevatedButton(
                onPressed: canRun ? manager.loadCommand.run : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!canRun) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                    ],
                    Text('Load Data'),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 8),

          // Save button - disabled while loading
          ValueListenableBuilder<bool>(
            valueListenable: manager.saveCommand.canRun,
            builder: (context, canRun, _) {
              return ElevatedButton(
                onPressed: canRun
                    ? () => manager.saveCommand(Todo('1', 'Test Todo', false))
                    : null,
                child:
                    Text(canRun ? 'Save Todo' : 'Save (blocked while loading)'),
              );
            },
          ),
          SizedBox(height: 8),

          // Update button - disabled while saving
          ValueListenableBuilder<bool>(
            valueListenable: manager.updateCommand.canRun,
            builder: (context, canRun, _) {
              return ElevatedButton(
                onPressed: canRun
                    ? () =>
                        manager.updateCommand(Todo('2', 'Updated Todo', false))
                    : null,
                child: Text(
                    canRun ? 'Update Todo' : 'Update (blocked while saving)'),
              );
            },
          ),
          SizedBox(height: 16),

          // Status display
          ValueListenableBuilder<List<Todo>>(
            valueListenable: manager.loadCommand,
            builder: (context, todos, _) {
              return Text('Loaded ${todos.length} todos');
            },
          ),
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(home: Scaffold(body: ChainedCommandsWidget())));
}
