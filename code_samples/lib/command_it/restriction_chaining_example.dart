import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:listen_it/listen_it.dart';
import 'package:watch_it/watch_it.dart';
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

  // Third command: can't update while loading OR saving
  late final updateCommand = Command.createAsyncNoResult<Todo>(
    (todo) async {
      await simulateDelay(500);
      // Update logic here
    },
    // Combine multiple restrictions: disabled if EITHER command is running
    restriction: loadCommand.isRunningSync.combineLatest(
      saveCommand.isRunningSync,
      (isLoading, isSaving) => isLoading || isSaving,
    ),
  );
}

class ChainedCommandsWidget extends WatchingWidget {
  const ChainedCommandsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch all canRun states
    final canRunLoad = watchValue((DataManager m) => m.loadCommand.canRun);
    final canRunSave = watchValue((DataManager m) => m.saveCommand.canRun);
    final canRunUpdate = watchValue((DataManager m) => m.updateCommand.canRun);
    final todos = watchValue((DataManager m) => m.loadCommand);

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Command Chaining Example',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),

          // Load button
          ElevatedButton(
            onPressed: canRunLoad ? di<DataManager>().loadCommand.run : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!canRunLoad) ...[
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
          ),
          SizedBox(height: 8),

          // Save button - disabled while loading
          ElevatedButton(
            onPressed: canRunSave
                ? () =>
                    di<DataManager>().saveCommand(Todo('1', 'Test Todo', false))
                : null,
            child:
                Text(canRunSave ? 'Save Todo' : 'Save (blocked while loading)'),
          ),
          SizedBox(height: 8),

          // Update button - disabled while loading OR saving
          ElevatedButton(
            onPressed: canRunUpdate
                ? () => di<DataManager>()
                    .updateCommand(Todo('2', 'Updated Todo', false))
                : null,
            child: Text(canRunUpdate
                ? 'Update Todo'
                : 'Update (blocked while loading/saving)'),
          ),
          SizedBox(height: 16),

          // Status display
          Text('Loaded ${todos.length} todos'),
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  di.registerSingleton(DataManager());
  runApp(MaterialApp(home: Scaffold(body: ChainedCommandsWidget())));
}
