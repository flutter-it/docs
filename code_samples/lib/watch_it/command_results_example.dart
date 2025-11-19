import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CommandResultsWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((_) => di<TodoManager>().fetchTodosCommand.run());

    // Watch the command's results property which contains all state:
    // - data: The command's value
    // - isRunning: Execution state
    // - hasError: Whether an error occurred
    // - error: The error if any
    return watchValue(
      (TodoManager m) => m.fetchTodosCommand.results,
    ).toWidget(
      onData: (todos, param) => ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(todos[index].title),
          subtitle: Text(todos[index].description),
        ),
      ),
      onError: (error, lastResult, param) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => di<TodoManager>().fetchTodosCommand.run(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      whileRunning: (lastResult, param) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Command Results Pattern')),
      body: CommandResultsWidget(),
    ),
  ));
}
