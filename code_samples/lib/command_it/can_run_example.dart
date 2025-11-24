import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

class DataManager {
  final api = ApiClient();

  late final loadDataCommand = Command.createAsyncNoParam<List<Todo>>(
    () async {
      await simulateDelay();
      return fakeTodos;
    },
    initialValue: [],
  );

  void dispose() {
    loadDataCommand.dispose();
  }
}

// #region example
class DataWidget extends StatelessWidget {
  final manager = DataManager();

  DataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Observe canRun to enable/disable button
        ValueListenableBuilder<bool>(
          valueListenable: manager.loadDataCommand.canRun,
          builder: (context, canRun, _) {
            return ElevatedButton(
              onPressed: canRun ? manager.loadDataCommand.run : null,
              child: const Text('Load Data'),
            );
          },
        ),
        const SizedBox(height: 16),
        // Observe results to show data/loading/error
        ValueListenableBuilder<CommandResult<void, List<Todo>>>(
          valueListenable: manager.loadDataCommand.results,
          builder: (context, result, _) {
            if (result.isRunning) {
              return const CircularProgressIndicator();
            }

            if (result.hasError) {
              return Text(
                'Error: ${result.error}',
                style: const TextStyle(color: Colors.red),
              );
            }

            return Text('Loaded ${result.data?.length ?? 0} todos');
          },
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: DataWidget()),
    ),
  ));
}
