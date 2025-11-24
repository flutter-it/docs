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

  void dispose() {
    loadDataCommand.dispose();
  }
}

// #region example
class DataWidget extends StatefulWidget {
  const DataWidget({super.key});

  @override
  State<DataWidget> createState() => _DataWidgetState();
}

class _DataWidgetState extends State<DataWidget> {
  final manager = DataManager();
  ListenableSubscription? _errorSubscription;

  @override
  void initState() {
    super.initState();

    // Subscribe to errors in initState - runs once, not on every build
    _errorSubscription = manager.loadDataCommand.errors
        .where((e) => e != null) // Filter out null values
        .listen((error, _) {
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(error!.error.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // CRITICAL: Cancel subscription to prevent memory leaks
    _errorSubscription?.cancel();
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CommandResult<void, List<Todo>>>(
      valueListenable: manager.loadDataCommand.results,
      builder: (context, result, _) {
        return Column(
          children: [
            if (result.hasError)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  result.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (result.isRunning)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: manager.loadDataCommand.run,
                    child: const Text('Load Data'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      manager.shouldFail = true;
                      manager.loadDataCommand.run();
                    },
                    child: const Text('Load Data (will fail)'),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
// #endregion example

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(child: DataWidget()),
    ),
  ));
}
