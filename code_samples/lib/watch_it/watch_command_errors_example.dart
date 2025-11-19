import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CommandErrorWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.run();
    });

    // Watch command's errors property to display error messages
    final error = watchValue((TodoManager m) => m.fetchTodosCommand.errors);
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isRunning);
    final todos = watchValue((TodoManager m) => m.fetchTodosCommand);

    return Scaffold(
      appBar: AppBar(title: const Text('Watch Command - Errors')),
      body: Column(
        children: [
          // Display error banner when command fails
          if (error != null)
            Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      // Clear error by executing again
                      di<TodoManager>().fetchTodosCommand.run();
                    },
                  ),
                ],
              ),
            ),
          if (isLoading)
            const LinearProgressIndicator()
          else
            const SizedBox(height: 4),
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (error != null) ...[
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text('Failed to load todos'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                di<TodoManager>().fetchTodosCommand.run(),
                            child: const Text('Retry'),
                          ),
                        ] else if (isLoading)
                          const CircularProgressIndicator()
                        else
                          const Text('No todos'),
                      ],
                    ),
                  )
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
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(MaterialApp(
    home: CommandErrorWidget(),
  ));
}
