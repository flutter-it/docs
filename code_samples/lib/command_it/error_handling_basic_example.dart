import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

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
class DataWidget extends StatefulWidget {
  const DataWidget({super.key});

  @override
  State<DataWidget> createState() => _DataWidgetState();
}

class _DataWidgetState extends State<DataWidget> {
  final manager = DataManager();
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Listen to errors
    manager.loadDataCommand.errors.listen((error, _) {
      if (error != null) {
        setState(() {
          errorMessage = error.error.toString();
        });

        // Show error dialog
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
      } else {
        // Error cleared (command started again)
        setState(() {
          errorMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (errorMessage != null)
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              errorMessage!,
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
  runApp(MaterialApp(home: Scaffold(body: Center(child: DataWidget()))));
}
