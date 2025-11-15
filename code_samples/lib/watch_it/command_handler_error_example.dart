import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CommandErrorHandlerWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Use registerHandler to handle command errors
    // Shows error dialog or snackbar when command fails
    registerHandler(
      select: (TodoManager m) => m.fetchTodosCommand.errors,
      handler: (context, error, _) {
        if (error != null) {
          // Show error dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(error.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    di<TodoManager>().fetchTodosCommand.run();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
      },
    );

    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isRunning);
    final todos = watchValue((TodoManager m) => m.todos);

    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.run();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Command Handler - Errors')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'This example uses registerHandler to show error dialogs',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: isLoading && todos.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : todos.isEmpty
                    ? const Center(child: Text('No todos'))
                    : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return ListTile(
                            title: Text(todo.title),
                            subtitle: Text(todo.description),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => di<TodoManager>().fetchTodosCommand.run(),
              child: const Text('Refresh'),
            ),
          ),
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(MaterialApp(
    home: CommandErrorHandlerWidget(),
  ));
}
