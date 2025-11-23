import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart' hide di;

class DataManager {
  final api = ApiClient();
  bool shouldFail = false;

  late final loadDataCommand = Command.createAsyncNoParam<List<Todo>>(
    () async {
      await simulateDelay();
      if (shouldFail) {
        throw ApiException('Failed to load data', 500);
      }
      return fakeTodos;
    },
    initialValue: [],
  );
}

// #region example
class DataWidget extends WatchingWidget {
  const DataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = di<DataManager>();
    final error = watchValue((DataManager m) => m.loadDataCommand.errors);

    // Register handler for errors to show dialog
    registerHandler(
      select: (DataManager m) => m.loadDataCommand.errors,
      handler: (context, error, cancel) {
        if (error != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text(error.error.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      },
    );

    return Column(
      children: [
        if (error != null)
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              error.error.toString(),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ElevatedButton(
          onPressed: manager.loadDataCommand.run,
          child: Text('Load Data'),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            manager.shouldFail = true;
            manager.loadDataCommand.run();
          },
          child: Text('Load Data (will fail)'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  di.registerSingleton<DataManager>(DataManager());
  runApp(MaterialApp(home: Scaffold(body: Center(child: DataWidget()))));
}
